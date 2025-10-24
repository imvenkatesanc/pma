# Teams Webhook Configuration
$TeamsWebhookUrl = "https://default00a2f2d91d7b4a75adb10c64636b80.6b.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/e31987fcfce1413eb198ccb103cf2d6e/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=bFMEFFg7ovLbbC5a_2rxa0nLvvThrMZIiJ3rL89ODL8"

# SQL Server connection details
$ServerInstance = "10.32.56.5"
$Database       = "CIRRUS"

# Load credentials securely
$Credential = Get-StoredCredential -Target "SQLServerCreds"

# Helper: Convert UTC -> Central Time (CDT)
function Convert-ToCDT {
    param([datetime]$utcTime)
    try {
        $cdtZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Central Standard Time")
        return [System.TimeZoneInfo]::ConvertTimeFromUtc($utcTime, $cdtZone)
    } catch {
        return $utcTime  # fallback
    }
}

# Function to Send Teams Notifications
function Send-TeamsNotification {
    param([string]$messageText)
    if ([string]::IsNullOrWhiteSpace($TeamsWebhookUrl)) {
        Write-Host "Teams Webhook URL not configured. Skipping notification." -ForegroundColor Yellow
        return $false
    }

    $payload = @{
        type = "message"
        attachments = @(
            @{
                contentType = "application/vnd.microsoft.card.adaptive"
                content = @{
                    "`$schema" = "http://adaptivecards.io/schemas/adaptive-card.json"
                    type       = "AdaptiveCard"
                    version    = "1.2"
                    body       = @(@{ type = "TextBlock"; text = $messageText; wrap = $true })
                }
            }
        )
    }

    try {
        $jsonPayload = $payload | ConvertTo-Json -Depth 5 -Compress
        $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)
        Invoke-RestMethod -Uri $TeamsWebhookUrl -Method Post -Body $utf8Bytes -ContentType 'application/json' -TimeoutSec 10
        Write-Host "Teams notification sent." -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Failed to send Teams notification: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# SQL Query
$query = @"
SELECT TOP 1000 
    prcs.PRCS_ID, 
    prcs.PRTFL_CD, 
    prcs.PRCS_STS_ID, 
    prcs.STRT_DTTM, 
    prcs.END_DTTM,
    prcs.EXEC_RQST_UNQ_ID,
    sts.PRCS_STS_DESC, 
    enum.PRCS_NM
FROM [RPT].[PRCS_LOG] (NOLOCK) prcs
JOIN [ENUM].[PRCS] enum ON enum.PRCS_ID = prcs.PRCS_ID
JOIN [ENUM].[PRCS_STS] sts ON sts.PRCS_STS_ID = prcs.PRCS_STS_ID
WHERE prcs.BUS_DT = CAST(GETUTCDATE()-2 AS DATE)
ORDER BY prcs.STRT_DTTM DESC;
"@

# Monitoring Configuration
$checkIntervalSeconds = 30
$majorCodes = @('303','304','305')
$completedMajor = @{}
$notified = @{}
foreach ($code in $majorCodes) { $completedMajor[$code] = $false }

# Global variables for cutoff start tracking
$script:cutoffStartTime = $null
$script:cutoffMessageSent = $false

# Function: Check Jobs and Notify
function Check-Jobs {
    param($results)

    foreach ($row in $results) {
        $id          = $row.PRCS_ID.ToString()
        $code        = $row.PRTFL_CD.ToString()
        $statusId    = [int]$row.PRCS_STS_ID
        $statusDesc  = $row.PRCS_STS_DESC
        $processName = $row.PRCS_NM
        $key         = "$id-$statusId"

        # Convert UTC → CDT
        $startTime = if ($row.STRT_DTTM) { (Convert-ToCDT $row.STRT_DTTM).ToString("yyyy-MM-dd HH:mm:ss") } else { "N/A" }
        $endTime   = if ($row.END_DTTM -and $row.END_DTTM -ne [System.DBNull]::Value) { (Convert-ToCDT $row.END_DTTM).ToString("yyyy-MM-dd HH:mm:ss") } else { "N/A" }

        # 1️⃣ Detect PRCS_ID = 1 to set Cutoff start time
        if ($id -eq '1' -and -not $script:cutoffMessageSent) {
            $script:cutoffStartTime = $startTime
            $msg = "Cutoff triggered at $startTime (CDT). Monitoring has started."
            if (Send-TeamsNotification -messageText $msg) {
                Write-Host "Cutoff start message sent." -ForegroundColor Green
                $script:cutoffMessageSent = $true
            }
        }

        # Track major completions
        if ($statusId -eq 3 -and ($majorCodes -contains $id)) {
            $completedMajor[$id] = $true
        }

        # Only notify once per job-status
        if (-not $notified.ContainsKey($key)) {
            switch ($statusId) {
                4 {
                    $execId = $row.EXEC_RQST_UNQ_ID.ToString()
                    $msg = "Portfolio: $code Cutoff`n`n**Status: $statusDesc** (Failed)`n`n**Process:** $processName`nStart: $startTime`nEnd: $endTime`nExecution ID: $execId`nProcess ID: $id`nCutoff Start: $($script:cutoffStartTime)"
                    Send-TeamsNotification -messageText $msg
                }
                5 {
                    $execId = $row.EXEC_RQST_UNQ_ID.ToString()
                    $msg = "Portfolio: $code Cutoff`n`n**Status: $statusDesc** (Timeout)`n`n**Process:** $processName`nStart: $startTime`nEnd: $endTime`nExecution ID: $execId`nProcess ID: $id`nCutoff Start: $($script:cutoffStartTime)"
                    Send-TeamsNotification -messageText $msg
                }
                3 {
                    if ($majorCodes -contains $id) {
                        $msg = "Portfolio: $code Cutoff Completed`n`nStatus: $statusDesc`nStart: $startTime`nEnd: $endTime`nCutoff Start: $($script:cutoffStartTime)"
                        Send-TeamsNotification -messageText $msg
                    }
                }
            }
            $notified[$key] = $true
        }
    }
}

# Main Monitoring Loop
while ($true) {
    try {
        $results = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Credential $Credential -Query $query -TrustServerCertificate
        Check-Jobs -results $results

        # Exit if all major jobs done
        if ($completedMajor.Values -notcontains $false) {
            $final = "Today's Cutoff process completed.`nCutoff started at: $($script:cutoffStartTime)`nAll major processes are done."
            Send-TeamsNotification -messageText $final
            Write-Host "All major jobs completed successfully. Monitoring finished." -ForegroundColor Green
            break
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Send-TeamsNotification -messageText "Monitoring Script Error: $($_.Exception.Message)"
    }

    Start-Sleep -Seconds $checkIntervalSeconds
}
