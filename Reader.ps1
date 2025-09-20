# Create Outlook COM object
$outlook = New-Object -ComObject Outlook.Application
$namespace = $outlook.GetNamespace("MAPI")

# Get Inbox folder
$inbox = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox)

# Get today's emails
$today = (Get-Date).Date
$emails = $inbox.Items | Where-Object { 
    ($_.ReceivedTime -ge $today) -and ($_.Subject -like "*PR*") 
} | Sort-Object ReceivedTime -Descending

# Load speech synthesis
Add-Type –AssemblyName System.Speech
$synthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer

# Loop through filtered emails
foreach ($email in $emails) {
    $subject = $email.Subject
    $body = $email.Body

    Write-Host "Subject: $subject"
    $synthesizer.Speak("New email with subject: $subject")
}

# Release COM object
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($outlook)
