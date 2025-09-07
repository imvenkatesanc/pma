# =========================================
# Teams Webhook Configuration
# =========================================
$TeamsWebhookUrl = "https://default00a2f2d91d7b4a75adb10c64636b80.6b.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/479c4f91d483473e9ef607e4a910a256/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=t6wTYJK5fIte2VTjFoPrevFuvIQjaK0dxUURzyVMjWg" 

# =========================================
# SQL Server connection details
# =========================================
$ServerInstance = "10.32.56.5"
$Username       = "venkatesan.c@sagentlending.com"
$Password       = "dara@sagent2024"
$Database       = "CIRRUS"

# =========================================
# Function to Send Teams Notifications (Adaptive Card)
# =========================================
function Send-TeamsNotification {
    param(
        [string]$title, 
        [string]$message,
        [string]$statusColor
    )

    if ([string]::IsNullOrWhiteSpace($TeamsWebhookUrl)) {
        Write-Host "Teams Webhook URL not configured. Skipping notification." -ForegroundColor Yellow
        return
    }

    $payload = @{
        "type" = "message"
        "attachments" = @(
            @{
                "contentType" = "application/vnd.microsoft.card.adaptive"
                "contentUrl" = $null
                "content" = @{
                    "$schema" = "http://adaptivecards.io/schemas/adaptive-card.json"
                    "type"    = "AdaptiveCard"
                    "version" = "1.2"
                    "body"    = @(
                        @{
                            "type"  = "TextBlock"
                            "text"  = $title
                            "weight"= "bolder"
                            "size"  = "medium"
                        },
                        @{
                            "type" = "TextBlock"
                            "text" = $message
                            "wrap" = $true
                        }
                    )
                }
            }
        )
    }

    try {
        $jsonPayload = $payload | ConvertTo-Json -Depth 5 -Compress
        Invoke-RestMethod -Uri $TeamsWebhookUrl -Method Post -Body $jsonPayload -ContentType 'application/json' -TimeoutSec 10
        Write-Host "Teams notification sent: $title" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to send Teams notification: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ---- Test Teams before monitoring ----
Send-TeamsNotification -title "PowerShell Monitoring Test" -message "Teams webhook setup works at $(Get-Date). Script starting..." -statusColor "Green"

# =========================================
# SQL Query for Process Log Monitoring
# =========================================
$query = @"
SELECT TOP 1000 
    prcs.PRCS_ID, 
    prcs.PRTFL_CD, 
    prcs.PRCS_STS_ID, 
    prcs.STRT_DTTM, 
    sts.PRCS_STS_DESC, 
    enum.PRCS_NM
FROM [RPT].[PRCS_LOG] (NOLOCK) prcs
JOIN [ENUM].[PRCS] enum ON enum.PRCS_ID = prcs.PRCS_ID
JOIN [ENUM].[PRCS_STS] sts ON sts.PRCS_STS_ID = prcs.PRCS_STS_ID
WHERE prcs.BUS_DT = CAST(GETUTCDATE()-1 AS DATE)
ORDER BY prcs.STRT_DTTM DESC;
"@

# =========================================
# Monitoring Configuration
# =========================================
$checkIntervalSeconds = 30
$majorCodes = @('303','304','305')

$completedMajor = @{}
$notified = @{}
foreach ($code in $majorCodes) { $completedMajor[$code] = $false }

# =========================================
# Function to Check Job Status and Send Notifications
# =========================================
function Check-Jobs {
    param($results)

    foreach ($row in $results) {
        $id          = $row.PRCS_ID.ToString()
        $code        = $row.PRTFL_CD.ToString()
        $statusId    = [int]$row.PRCS_STS_ID
        $statusDesc  = $row.PRCS_STS_DESC
        $processName = $row.PRCS_NM
        $key         = "$id-$statusId"

        # Track major completions
        if ($statusId -eq 3 -and ($majorCodes -contains $id)) {
            $completedMajor[$id] = $true
        }

        # Only notify once per job+status
        if (-not $notified.ContainsKey($key)) {
            switch ($statusId) {
                4 { # FAILED
                    $title   = "❌ SQL Process FAILED: $processName"
                    $message = "Process FAILED (PRCS_ID=$id, PRTFL_CD=$code)`nStatus: $statusDesc"
                    Send-TeamsNotification -title $title -message $message -statusColor "Red"
                }
                5 { # TIMED-OUT
                    $title   = "⏳ SQL Process TIMED-OUT: $processName"
                    $message = "Process TIMED-OUT (PRCS_ID=$id, PRTFL_CD=$code)`nStatus: $statusDesc"
                    Send-TeamsNotification -title $title -message $message -statusColor "Red"
                }
                3 { # COMPLETED
                    if ($majorCodes -contains $id) {
                        $title   = "✅ Major Process COMPLETED: $processName"
                        $message = "Process COMPLETED (PRCS_ID=$id, PRTFL_CD=$code)`nStatus: $statusDesc"
                        Send-TeamsNotification -title $title -message $message -statusColor "Green"
                    }
                }
            }
            $notified[$key] = $true
        }
    }
}

# =========================================
# Main Monitoring Loop
# =========================================
Write-Host "Starting SQL process monitoring loop..." -ForegroundColor Magenta

while ($true) {
    try {
        $results = Invoke-Sqlcmd -ServerInstance $ServerInstance `
                                 -Database $Database `
                                 -Username $Username `
                                 -Password $Password `
                                 -Query $query `
                                 -TrustServerCertificate

        Check-Jobs -results $results

        # Exit condition
        if (($completedMajor.Values -notcontains $false) -and
            ($results.PRCS_STS_ID -notcontains 4) -and
            ($results.PRCS_STS_ID -notcontains 5)) {
            
            $title   = "🎉 All Major Jobs Completed Successfully"
            $message = "All major jobs (303, 304, 305) completed without failures or timeouts at $(Get-Date)."
            Send-TeamsNotification -title $title -message $message -statusColor "Green"

            Write-Host "All major jobs completed successfully. Monitoring finished." -ForegroundColor Green
            break
        }
    }
    catch {
        Write-Host "Error during monitoring: $($_.Exception.Message)" -ForegroundColor Red
        Send-TeamsNotification -title "⚠️ Monitoring Script Error" -message "Error: $($_.Exception.Message)" -statusColor "Red"
    }

    Start-Sleep -Seconds $checkIntervalSeconds
}
