# Teams Webhook Configuration
$TeamsWebhookUrl = "https://default00a2f2d91d7b4a75adb10c64636b80.6b.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/e31987fcfce1413eb198ccb103cf2d6e/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=bFMEFFg7ovLbbC5a_2rxa0nLvvThrMZIiJ3rL89ODL8"

#$TeamsWebhookUrl = "https://default00a2f2d91d7b4a75adb10c64636b80.6b.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/88ef2b6713fe46c984a5164f209ba5db/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=0N7ut56H1F9CQQMKnWBTOMDQ_mDELszP-Exxq91rlOA"

# SQL Server connection details
$ServerInstance = "10.32.56.5"
$Database       = "CIRRUS"


# Load credentials securely
$Credential = Get-StoredCredential -Target "SQLServerCreds"


# Function to Send Simple Teams Notifications
function Send-TeamsNotification {
    param(
        [string]$messageText
    )

    if ([string]::IsNullOrWhiteSpace($TeamsWebhookUrl)) {
        Write-Host "Teams Webhook URL not configured. Skipping notification." -ForegroundColor Yellow
        return $false
    }

    $payload = @{
        type = "message"
        attachments = @(
            @{
                contentType = "application/vnd.microsoft.card.adaptive"
                contentUrl  = $null
                content     = @{
                    "`$schema" = "http://adaptivecards.io/schemas/adaptive-card.json"
                    type       = "AdaptiveCard"
                    version    = "1.2"
                    body       = @(
                        @{
                            type = "TextBlock"
                            text = $messageText
                            wrap = $true
                        }
                    )
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
    }
    catch {
        Write-Host "Failed to send Teams notification: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# SQL Query for Process Log Monitoring
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

# Function to Check Job Status and Send Notifications
function Check-Jobs {
    param($results)

    

    # Use a flag to ensure the initial message is sent only once
    if (-not $script:initialMessageSent -and $results.Count -gt 0) {
        $messageText = "Cutoff triggered. We are monitoring the cutoff process."
        $sent = Send-TeamsNotification -messageText $messageText
        if ($sent) {
            Write-Host "Start-of-process notification sent." -ForegroundColor Green
            $script:initialMessageSent = $true
        } else {
            Write-Host "Start-of-process notification FAILED." -ForegroundColor Red
        }
    }

    foreach ($row in $results) {
        # Define and handle variables first
        $id          = $row.PRCS_ID.ToString()
        $code        = $row.PRTFL_CD.ToString()
        $statusId    = [int]$row.PRCS_STS_ID
        $statusDesc  = $row.PRCS_STS_DESC
        $processName = $row.PRCS_NM
        $key         = "$id-$statusId"
        $startTime   = $row.STRT_DTTM.ToString("yyyy-MM-dd HH:mm:ss")
        
        # Handle potential NULL value for END_DTTM
        # This is the correct, safe way to handle database NULLs.
        $endTime = if ($row.END_DTTM -and $row.END_DTTM -ne [System.DBNull]::Value) {
            $row.END_DTTM.ToString("yyyy-MM-dd HH:mm:ss")
        } else {
            "N/A"
        }
        
        # Track major completions
        if ($statusId -eq 3 -and ($majorCodes -contains $id)) {
            $completedMajor[$id] = $true
        }
        
        # Only notify once per job+status
        if (-not $notified.ContainsKey($key)) {
            switch ($statusId) {
                4 {
                    # For FAILED, include the EXEC_RQST_UNQ_ID
                    $execRqstUnqId = $row.EXEC_RQST_UNQ_ID.ToString()
                    $messageText = "Portfolio: $code Cutoff`n`n**Status: $statusDesc**`n`n**Failure Details:**`n"
                    $messageText += "`n`nProcess: $processName`n"
                    $messageText += "`n`nStart Time: $startTime`n"
                    $messageText += "`n`nEnd Time: $endTime`n"
                    $messageText += "`n`nExecution ID: $execRqstUnqId`n"
                    $messageText += "`n`nProcess ID: $id`n"
                    $sent = Send-TeamsNotification -messageText $messageText
                    if ($sent) {
                        Write-Host "Failure notification sent for $processName ($id)" -ForegroundColor Red
                    } else {
                        Write-Host "Failure notification FAILED for $processName ($id)" -ForegroundColor Red
                    }
                }
                5 {
                    # For TIMED-OUT, include the EXEC_RQST_UNQ_ID
                    $execRqstUnqId = $row.EXEC_RQST_UNQ_ID.ToString()
                    $messageText = "Portfolio: $code Cutoff`n`n**Status: $statusDesc**`n`n**Timeout Details:**`n"
                    $messageText += "`n`nProcess: $processName`n"
                    $messageText += "`n`nStart Time: $startTime`n"
                    $messageText += "`n`nEnd Time: $endTime`n"
                    $messageText += "`n`nExecution ID: $execRqstUnqId`n"
                    $messageText += "`n`nProcess ID: $id`n"
                    $sent = Send-TeamsNotification -messageText $messageText
                    if ($sent) {
                        Write-Host "Timeout notification sent for $processName ($id)" -ForegroundColor Yellow
                    } else {
                        Write-Host "Timeout notification FAILED for $processName ($id)" -ForegroundColor Red
                    }
                }
                3 {
                    if ($majorCodes -contains $id) {
                        $messageText = "Portfolio: $code Cutoff`n`n**Status: $statusDesc**`n`nStart Time: $startTime`n`nEnd Time: $endTime"
                        $sent = Send-TeamsNotification -messageText $messageText
                        if ($sent) {
                            Write-Host "Completion notification sent for $processName ($id)" -ForegroundColor Green
                        } else {
                            Write-Host "Completion notification FAILED for $processName ($id)" -ForegroundColor Red
                        }
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
        $results = Invoke-Sqlcmd -ServerInstance $ServerInstance `
                         -Database $Database `
                         -Credential $Credential `
                         -Query $query `
                         -TrustServerCertificate
                         
        Check-Jobs -results $results

        # Exit condition
        if ($completedMajor.Values -notcontains $false) {
            
            $finalMessage = "Today's Cutoff process completed."
            $sent = Send-TeamsNotification -messageText $finalMessage
            if ($sent) {
                Write-Host "Final summary notification sent." -ForegroundColor Green
            } else {
                Write-Host "Final summary notification FAILED." -ForegroundColor Red
            }

            Write-Host "All major jobs completed successfully. Monitoring finished." -ForegroundColor Green
            break
        }
    }
    catch {
        Write-Host "Error during monitoring: $($_.Exception.Message)" -ForegroundColor Red
        $errorMessage = "Monitoring Script Error`n`nError: $($_.Exception.Message)"
        $sent = Send-TeamsNotification -messageText $errorMessage
        if ($sent) {
            Write-Host "Error notification sent."
        } else {
            Write-Host "Error notification FAILED."
        }
    }

    Start-Sleep -Seconds $checkIntervalSeconds
}

