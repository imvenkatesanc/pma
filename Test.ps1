# =========================================
# Teams Webhook Configuration
# =========================================
$TeamsWebhookUrl = "https://default00a2f2d91d7b4a75adb10c64636b80.6b.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/479c4f91d483473e9ef607e4a910a256/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=t6wTYJK5fIte2VTjFoPrevFuvIQjaK0dxUURzyVMjWg" 

# =========================================
# SQL Server connection details
# !!! SECURITY WARNING: Storing plain-text password is not recommended for production !!!
# =========================================
$ServerInstance = "10.32.56.5"
$Username = "venkatesan.c@sagentlending.com"
$Password = "dara@sagent2024" # !!! REPLACE THIS WITH YOUR ACTUAL SQL SERVER PASSWORD !!!
$Database = "CIRRUS"

# =========================================
# Function to Send Teams Notifications (Adaptive Card)
# =========================================
# =========================================
# Function to Send Teams Notifications (Adaptive Card)
# =========================================

function Send-TeamsNotification {
    param(
        [string]$title, 
        [string]$message,
        [string]$statusColor # Optional: 'Red' for failed, 'Green' for completed
    )

    # Basic validation for webhook URL
    if ([string]::IsNullOrWhiteSpace($TeamsWebhookUrl) -or $TeamsWebhookUrl.Contains("placeholder")) {
        Write-Host "Teams Webhook URL is not configured or is a placeholder. Skipping notification." -ForegroundColor Yellow
        return
    }

    # Use a direct, simpler object creation to avoid the cast error
    $payload = @{
        "type" = "message"
        "attachments" = @(
            @{
                "contentType" = "application/vnd.microsoft.card.adaptive"
                "contentUrl" = $null
                "content" = @{
                    "$schema" = "http://adaptivecards.io/schemas/adaptive-card.json"
                    "type" = "AdaptiveCard"
                    "version" = "1.2"
                    "body" = @(
                        @{
                            "type" = "TextBlock"
                            "text" = $title
                            "weight" = "bolder"
                            "size" = "medium"
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
        # Convert the payload to JSON for the request body
        $jsonPayload = $payload | ConvertTo-Json -Depth 5 -Compress
        Invoke-RestMethod -Uri $TeamsWebhookUrl -Method Post -Body $jsonPayload -ContentType 'application/json' -TimeoutSec 10
        Write-Host "Teams notification sent: $title" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to send Teams notification: $($_.Exception.Message)" -ForegroundColor Red
    }
}


# ---- Test Teams before monitoring ----
Write-Host "Sending initial Teams webhook test notification..." -ForegroundColor Yellow
Send-TeamsNotification -title "PowerShell Monitoring Test" -message "Teams webhook setup works from PowerShell at $(Get-Date). Script starting..." -statusColor "Green"

# =========================================
# Ensure SQL Server Module is Available
# =========================================

Write-Host "Checking for SqlServer PowerShell module..." -ForegroundColor Cyan
if (-not (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue)) {
    try {
        Write-Host "SqlServer module not found. Attempting to import..." -ForegroundColor Yellow
        Import-Module SqlServer -ErrorAction Stop
        Write-Host "SqlServer module imported successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Invoke-Sqlcmd not found. Please ensure the SqlServer module is installed and accessible." -ForegroundColor Red
        Write-Host "You might need to run: Install-Module -Name SqlServer -Scope CurrentUser -Force" -ForegroundColor Yellow
        exit 1 # Exit with an error code
    }
}

# =========================================
# SQL Query for Process Log Monitoring
# =========================================

$query = @"
SELECT TOP 1000 PRCS_NM, PRCS_STS_DESC, prcs.PRCS_ID, prcs.PRCS_STS_ID, prcs.PRTFL_CD, prcs.STRT_DTTM
FROM [RPT].[PRCS_LOG] (NOLOCK) prcs
JOIN [ENUM].[PRCS] enum ON enum.PRCS_ID = prcs.PRCS_ID
JOIN [ENUM].[PRCS_STS] sts ON sts.PRCS_STS_ID = prcs.PRCS_STS_ID
WHERE BUS_DT = CAST(GETUTCDATE()-1 AS DATE)
ORDER BY prcs.STRT_DTTM DESC;
"@

# =========================================
# Monitoring Configuration
# =========================================
$checkIntervalSeconds = 30 # Increased interval for less frequent checks (adjust as needed)
$majorCodes = @('303', '304', '305') # PRCS_ID values considered 'major' jobs

# Tracking for job completion and notification status
$completedMajor = @{} # Tracks if major jobs are completed
$notified = @{}       # Tracks if a notification has been sent for a specific process status

# Initialize $completedMajor for each major code
foreach ($code in $majorCodes) {
    $completedMajor[$code] = $false
}

# =========================================
# Function to Check Job Status and Send Notifications
# =========================================
function Check-Jobs {
    param($results)

    if (-not $results) {
        Write-Host "No results returned from SQL query." -ForegroundColor Yellow
        return
    }

    foreach ($row in $results) {
        # Ensure properties exist before accessing to prevent errors
        if ($row.PSObject.Properties.Name -notcontains 'PRTFL_CD' -or
            $row.PSObject.Properties.Name -notcontains 'PRCS_ID' -or
            $row.PSObject.Properties.Name -notcontains 'PRCS_STS_ID' -or
            $row.PSObject.Properties.Name -notcontains 'PRCS_STS_DESC' -or
            $row.PSObject.Properties.Name -notcontains 'PRCS_NM') {
            Write-Host "Skipping row due to missing required properties." -ForegroundColor Yellow
            continue
        }

        $code        = $row.PRTFL_CD.ToString()
        $id          = $row.PRCS_ID.ToString()
        $statusId    = [int]$row.PRCS_STS_ID
        $statusDesc  = $row.PRCS_STS_DESC
        $processName = $row.PRCS_NM
        $key         = "$id-$statusId"

        # Update completion status for major jobs
        if ($statusId -eq 3 -and ($majorCodes -contains $id)) {
            $completedMajor[$id] = $true
        }

        # Send notification only if this specific status for this process hasn't been notified yet
        if (-not $notified.ContainsKey($key)) {
            switch ($statusId) {
                0 { # FAILED
                    $title   = "SQL Process FAILED: $($processName)"
                    $message = "Process **FAILED** (PRCS_ID=$id, PRTFL_CD=$code)`nStatus: $statusDesc"
                    Send-TeamsNotification -title $title -message $message -statusColor "Red"
                    Write-Host "Notification Sent (FAILED) -> PRCS_ID=$id, PRTFL_CD=$code - $processName" -ForegroundColor Red
                }
                3 { # COMPLETED
                    if ($majorCodes -contains $id) {
                        $title   = "SQL Process COMPLETED: $($processName)"
                        $message = "Process **COMPLETED** (PRCS_ID=$id, PRTFL_CD=$code)`nStatus: $statusDesc"
                        Send-TeamsNotification -title $title -message $message -statusColor "Green"
                        Write-Host "Notification Sent (COMPLETED) -> PRCS_ID=$id, PRTFL_CD=$code - $processName" -ForegroundColor Green
                    } else {
                        Write-Host "COMPLETED -> PRCS_ID=$id, PRTFL_CD=$code - $processName" -ForegroundColor DarkGreen
                    }
                }
                1 { # PRODUCED
                    Write-Host "Status: PRODUCED -> PRCS_ID=$id, PRTFL_CD=$code - $processName" -ForegroundColor Yellow
                }
                2 { # PROCESSING
                    Write-Host "Status: PROCESSING -> PRCS_ID=$id, PRTFL_CD=$code - $processName" -ForegroundColor Cyan
                }
                default { # Other statuses
                    Write-Host "Status: UNKNOWN ($statusDesc) -> PRCS_ID=$id, PRTFL_CD=$code - $processName" -ForegroundColor White
                }
            }
            $notified[$key] = $true # Mark as notified
        }
    }
}

# =========================================
# Main Monitoring Loop
# =========================================

Write-Host "Starting SQL process monitoring loop..." -ForegroundColor Magenta

while ($true) {
    try {
        Write-Host "Executing SQL query for process status at $(Get-Date)..." -ForegroundColor DarkCyan
        # Using hardcoded Username and Password for Invoke-Sqlcmd
        $results = Invoke-Sqlcmd -ServerInstance $ServerInstance `
                                 -Database $Database `
                                 -Username $Username `
                                 -Password $Password `
                                 -Query $query `
                                 -TrustServerCertificate

        Check-Jobs -results $results
    }
    catch {
        Write-Host "An error occurred during the monitoring loop: $($_.Exception.Message)" -ForegroundColor Red
        Send-TeamsNotification -title "PowerShell Monitoring Script Error" -message "An error occurred connecting to the database or running the query. Error: $($_.Exception.Message)" -statusColor "Red"
    }
    
    # Wait for the next check
    Write-Host "Waiting for $checkIntervalSeconds seconds..." -ForegroundColor DarkGray
    Start-Sleep -Seconds $checkIntervalSeconds
}
