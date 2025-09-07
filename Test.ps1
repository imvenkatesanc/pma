# =========================================
# Teams Webhook / SQL config - REPLACE THESE
# =========================================
$TeamsWebhookUrl = "https://default00a2f2d91d7b4a75adb10c64636b80.6b.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/479c4f91d483473e9ef607e4a910a256/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=t6wTYJK5fIte2VTjFoPrevFuvIQjaK0dxUURzyVMjWg"

$ServerInstance = "10.32.56.5"
$Username = "venkatesan.c@sagentlending.com"
$Password = "your_password_here"
$Database = "CIRRUS"

# =========================================
# Helper: send Adaptive Card to Teams
# =========================================
function Send-TeamsNotification {
    param(
        [string]$title,
        [string]$message,
        [string]$severity    # "Red"|"Green"|"Yellow"|"Default"
    )

    if ([string]::IsNullOrWhiteSpace($TeamsWebhookUrl)) {
        Write-Host "Teams webhook not configured. Skipping notification." -ForegroundColor Yellow
        return
    }

    # map severity to adaptive card color keyword
    $textColor = switch ($severity) {
        "Red"     { "attention" }
        "Green"   { "good" }
        "Yellow"  { "warning" }
        default   { "default" }
    }

    $content = @{
        '$schema' = "http://adaptivecards.io/schemas/adaptive-card.json"
        type      = "AdaptiveCard"
        version   = "1.2"
        body      = @(
            @{
                type  = "TextBlock"
                text  = $title
                weight = "Bolder"
                size  = "Medium"
            },
            @{
                type  = "TextBlock"
                text  = $message
                wrap  = $true
                color = $textColor
            }
        )
    }

    $payload = @{
        type = "message"
        attachments = @(
            @{
                contentType = "application/vnd.microsoft.card.adaptive"
                contentUrl  = $null
                content      = $content
            }
        )
    }

    try {
        $jsonPayload = $payload | ConvertTo-Json -Depth 10 -Compress
        Invoke-RestMethod -Uri $TeamsWebhookUrl -Method Post -Body $jsonPayload -ContentType 'application/json' -TimeoutSec 15
        Write-Host "Teams notification sent: $title" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to send Teams notification: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =========================================
# SQL query (edit if needed)
# =========================================
$query = @"
SELECT TOP 1000 
    PRCS_NM, 
    PRCS_STS_DESC, 
    prcs.PRCS_ID, 
    prcs.PRCS_STS_ID, 
    prcs.PRTFL_CD, 
    prcs.STRT_DTTM
FROM [RPT].[PRCS_LOG] (NOLOCK) prcs
JOIN [ENUM].[PRCS] enum ON enum.PRCS_ID = prcs.PRCS_ID
JOIN [ENUM].[PRCS_STS] sts ON sts.PRCS_STS_ID = prcs.PRCS_STS_ID
WHERE BUS_DT = CAST(GETUTCDATE()-1 AS DATE)
ORDER BY prcs.STRT_DTTM DESC;
"@

# =========================================
# Monitoring settings
# =========================================
$checkIntervalSeconds = 30
$majorIds = @(303,304,305)        # major PRCS_IDs (ints)

# "notified" ensures one-time notifications per push state (PRCS_ID-status)
$notified = @{}

Write-Host "Starting monitoring loop..." -ForegroundColor Magenta

while ($true) {
    try {
        $results = Invoke-Sqlcmd -ServerInstance $ServerInstance `
                                 -Database $Database `
                                 -Username $Username `
                                 -Password $Password `
                                 -Query $query `
                                 -TrustServerCertificate

        if (-not $results) {
            Write-Host "Query returned no rows." -ForegroundColor Yellow
        }
        else {
            # Iterate results and send notifications for:
            #  - any PRCS_STS_ID = 4 (FAILED)  -> notify
            #  - any PRCS_STS_ID = 5 (TIMED-OUT) -> notify
            #  - PRCS_STS_ID = 3 (COMPLETED) only for majors -> notify
            foreach ($row in $results) {
                $idInt     = [int]$row.PRCS_ID
                $statusId  = [int]$row.PRCS_STS_ID
                $processNm = [string]$row.PRCS_NM
                $prtfl     = [string]$row.PRTFL_CD
                $statusDesc= [string]$row.PRCS_STS_DESC

                $key = "$idInt-$statusId"
                if ($notified.ContainsKey($key)) { continue }

                if ($statusId -eq 4) {
                    # FAILED
                    $title = "FAILED: $processNm"
                    $msg   = "Process FAILED (PRCS_ID=$idInt, PRTFL_CD=$prtfl)`nStatus: $statusDesc"
                    Send-TeamsNotification -title $title -message $msg -severity "Red"
                    Write-Host "NOTIFIED FAILED -> PRCS_ID=$idInt, PRTFL_CD=$prtfl" -ForegroundColor Red
                    $notified[$key] = $true
                }
                elseif ($statusId -eq 5) {
                    # TIMED-OUT
                    $title = "TIMED-OUT: $processNm"
                    $msg   = "Process TIMED-OUT (PRCS_ID=$idInt, PRTFL_CD=$prtfl)`nStatus: $statusDesc"
                    Send-TeamsNotification -title $title -message $msg -severity "Red"
                    Write-Host "NOTIFIED TIMED-OUT -> PRCS_ID=$idInt, PRTFL_CD=$prtfl" -ForegroundColor Red
                    $notified[$key] = $true
                }
                elseif ($statusId -eq 3 -and ($majorIds -contains $idInt)) {
                    # Major completed
                    $title = "COMPLETED: $processNm"
                    $msg   = "Major process COMPLETED (PRCS_ID=$idInt, PRTFL_CD=$prtfl)`nStatus: $statusDesc"
                    Send-TeamsNotification -title $title -message $msg -severity "Green"
                    Write-Host "NOTIFIED COMPLETED (major) -> PRCS_ID=$idInt, PRTFL_CD=$prtfl" -ForegroundColor Green
                    $notified[$key] = $true
                }
                # produced(1) and processing(2) are ignored (no notification)
            }

            # --- Determine final exit condition ---
            # All majorIds must be present and have status 3 (Completed)
            $allMajorsCompleted = $true
            foreach ($mid in $majorIds) {
                $majDone = $results | Where-Object { ([int]$_.PRCS_ID -eq $mid) -and ([int]$_.PRCS_STS_ID -eq 3) }
                if (-not $majDone) { $allMajorsCompleted = $false; break }
            }

            # No failures/timeouts anywhere in results
            $anyFailureOrTimeout = $results | Where-Object { ([int]$_.PRCS_STS_ID -eq 4) -or ([int]$_.PRCS_STS_ID -eq 5) }

            if ($allMajorsCompleted -and -not $anyFailureOrTimeout) {
                $title = "All Major Jobs Completed - Clean Run"
                $message = "All major processes ($($majorIds -join ', ')) are COMPLETED and no FAILED/TIMED-OUT statuses detected. Monitoring stopping at $(Get-Date)."
                Send-TeamsNotification -title $title -message $message -severity "Green"
                Write-Host "Exit condition met: majors completed and no failures/timeouts. Stopping." -ForegroundColor Green
                break
            }
            else {
                # informational log
                if (-not $allMajorsCompleted) { Write-Host "Waiting: not all major jobs are COMPLETED yet." -ForegroundColor Yellow }
                if ($anyFailureOrTimeout) { Write-Host "Waiting: failures or timeouts present (won't stop until cleared)." -ForegroundColor Red }
            }
        }
    }
    catch {
        $err = $_.Exception.Message
        Write-Host "Error during monitoring: $err" -ForegroundColor Red
        Send-TeamsNotification -title "Monitoring Script Error" -message "Error: $err" -severity "Red"
    }

    Start-Sleep -Seconds $checkIntervalSeconds
}
