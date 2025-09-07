# =========================================
# Teams Webhook Configuration
# =========================================
$TeamsWebhookUrl = "https://<your-teams-webhook-url>"

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
        [string]$statusColor # 'Red', 'Green', 'Default'
    )

    $payload = @{
        "type" = "message"
        "attachments" = @(
            @{
                "contentType" = "application/vnd.microsoft.card.adaptive"
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
                            "color" = if ($statusColor -eq "Red") { "Attention" } elseif ($statusColor -eq "Green") { "Good" } else { "Default" }
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
        Invoke-RestMethod -Uri $TeamsWebhookUrl -Method Post -Body $jsonPayload -ContentType 'application/json'
        Write-Host "Teams notification sent: $title" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to send Teams notification: $($_.Exception.Message)" -ForegroundColor Red
    }
}

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
$majorJobs = @('303','304','305')  # PRCS_ID values considered major

# Track job states
$completedMajor = @{}
$notified = @{}
foreach ($mj in $majorJobs) { $completedMajor[$mj] = $false }

# =========================================
# Function to Process Results
# =========================================
function Check-Jobs {
    param($results)

    foreach ($row in $results) {
        $id         = $row.PRCS_ID.ToString()
        $code       = $row.PRTFL_CD.ToString()
        $statusId   = [int]$row.PRCS_STS_ID
        $statusDesc = $row.PRCS_STS_DESC
        $name       = $row.PRCS_NM
        $key        = "$id-$statusId"

        # Mark completed majors
        if ($statusId -eq 3 -and ($majorJobs -contains $id)) {
            $completedMajor[$id] = $true
        }

        # Notify only once per status per process
        if (-not $notified.ContainsKey($key)) {
            switch ($statusId) {
                4 { # FAILED
                    $title   = "❌ Process FAILED: $name"
                    $message = "Process FAILED (PRCS_ID=$id, PRTFL_CD=$code)`nStatus: $statusDesc"
                    Send-TeamsNotification -title $title -message $message -statusColor "Red"
                }
                5 { # TIMED OUT
                    $title   = "⏳ Process TIMED-OUT: $name"
                    $message = "Process TIMED-OUT (PRCS_ID=$id, PRTFL_CD=$code)`nStatus: $statusDesc"
                    Send-TeamsNotification -title $title -message $message -statusColor "Red"
                }
                3 { # COMPLETED (only majors)
                    if ($majorJobs -contains $id) {
                        $title   = "✅ Major Process COMPLETED: $name"
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

        # Exit condition:
        if (($completedMajor.Values -notcontains $false) -and
            ($results.PRCS_STS_ID -notcontains 4) -and
            ($results.PRCS_STS_ID -notcontains 5)) {
            
            $title   = "🎉 All Major Jobs Completed Successfully"
            $message = "All major jobs (303, 304, 305) completed without failures or timeouts at $(Get-Date)."
            Send-TeamsNotification -title $title -message $message -statusColor "Green"

            Write-Host "All major jobs completed. Monitoring finished." -ForegroundColor Green
            break
        }
    }
    catch {
        Write-Host "Error during monitoring: $($_.Exception.Message)" -ForegroundColor Red
        Send-TeamsNotification -title "⚠️ Monitoring Script Error" -message "Error: $($_.Exception.Message)" -statusColor "Red"
    }

    Start-Sleep -Seconds $checkIntervalSeconds
}
