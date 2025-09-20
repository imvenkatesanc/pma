# Create Outlook COM object
$outlook = New-Object -ComObject Outlook.Application
$namespace = $outlook.GetNamespace("MAPI")

# Get Inbox folder
$inbox = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox)

# Keywords to filter in subject
$keywords = @("PR", "Invoice", "Meeting")  # Add more subjects here

# Get today's emails
$today = (Get-Date).Date
$emails = $inbox.Items | Where-Object { 
    ($_.ReceivedTime -ge $today) -and ($keywords | ForEach-Object { $_ -and $_.Subject -like "*$_*" })
} | Sort-Object ReceivedTime -Descending

# Load speech synthesis
Add-Type –AssemblyName System.Speech
$synthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer

# Loop through filtered emails
foreach ($email in $emails) {
    $subject = $email.Subject

    # Escape double quotes in the subject
    $safeSubject = $subject -replace '"','`"'

    Write-Host "Subject: $subject"
    $synthesizer.Speak("New email with subject: $safeSubject")
}

# Release COM object
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($outlook)
