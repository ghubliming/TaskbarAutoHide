# Define registry path
$path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'

# First, let's check if StuckRects3 exists (some Windows versions use StuckRects2)
if (-not (Test-Path $path)) {
    $path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects2'
    if (-not (Test-Path $path)) {
        Write-Host "Could not find StuckRects registry key. This might be due to a different Windows version."
        exit
    }
}

# Get the current settings
$settings = (Get-ItemProperty -Path $path).Settings

# Ensure we are working with a mutable array
$settingsArray = [byte[]]$settings.Clone()

# Modify settings for auto-hide
# The taskbar auto-hide flag is at offset 8
# 1 = Always show taskbar
# 3 = Auto-hide taskbar
$settingsArray[8] = 3

# Apply changes
Set-ItemProperty -Path $path -Name Settings -Value $settingsArray

# Also set the AppVisibility registry key which affects taskbar behavior
$appVisibilityPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty -Path $appVisibilityPath -Name 'TaskbarAutoHideInTabletMode' -Value 0 -Type DWord
Set-ItemProperty -Path $appVisibilityPath -Name 'TaskbarGlomLevel' -Value 0 -Type DWord

# Make sure the taskbar is set to show on all displays
$mmTaskbarPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
if (Test-Path $mmTaskbarPath) {
    Set-ItemProperty -Path $mmTaskbarPath -Name 'MMTaskbarEnabled' -Value 1 -Type DWord
}

# Clean up any taskbar-related notification issues that might prevent auto-hide
$cleanNotificationDB = @'
# Import required libraries
Add-Type -AssemblyName System.Windows.Forms

# Send Windows key + B to focus on the notification area
[System.Windows.Forms.SendKeys]::SendWait('^{ESC}')
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait('{ESC}')
'@

# Run the notification cleanup in a separate PowerShell process to avoid permission issues
$encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($cleanNotificationDB))
Start-Process powershell.exe -ArgumentList "-EncodedCommand $encodedCommand" -NoNewWindow -Wait

# Finally, restart Explorer completely to apply all changes
Write-Host "Restarting Explorer to apply taskbar changes..."
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2
Start-Process explorer.exe

Write-Host "Changes applied. Your taskbar should now auto-hide properly."
Write-Host "If you still have issues, try checking if any applications are causing notifications that prevent hiding."