# PowerShell Script: FilteredTeamsReader.ps1
# Reads new Outlook mails for Dynatrace PR and Dara DM every 1 minute

# Load Outlook COM object
$outlook = New-Object -ComObject Outlook.Application
$namespace = $outlook.GetNamespace("MAPI")
$inbox = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox)

# Load Text-to-Speech
Add-Type -AssemblyName System.Speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.SelectVoice("Microsoft Zira Desktop")   # Optional: Change voice
$speak.Rate = 0                                # Speed (-10 to 10)
$speak.Volume = 100                            # Volume (0-100)

Write-Host "🔔 Teams Reader Assistant started... (Press Ctrl + C to stop)" -ForegroundColor Green

# Infinite loop
while ($true) {
    try {
        # Fetch unread mails with subject Dynatrace PR or Dara DM
        $filteredMails = $inbox.Items | Where-Object {
            $_.UnRead -eq $true -and (
                $_.Subject -like "*Dynatrace PR*" -or
                $_.Subject -like "*Dara DM*"
            )
        } | Sort-Object ReceivedTime -Descending

        foreach ($mail in $filteredMails) {
            $subject = $mail.Subject
            $text = "New important mail: $subject"

            # Print to console
            Write-Host $text -ForegroundColor Cyan

            # Speak aloud
            $speak.Speak($text)

            # Mark mail as read
            $mail.UnRead = $false
            $mail.Save()
        }
    }
    catch {
        Write-Host "⚠️ Error checking mail: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Wait for 1 minute before checking again
    Start-Sleep -Seconds 60
}
