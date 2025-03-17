# Get the number of active monitors
$monitorCount = (Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.PNPClass -eq "Monitor" }).Count

# Registry path for taskbar settings
$path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'

# Get the current settings
$settings = (Get-ItemProperty -Path $path).Settings

# Ensure we are working with a mutable array
$settingsArray = [byte[]]$settings.Clone()

# Modify settings: [8] controls auto-hide (3 = auto-hide enabled, 2 = disabled)
$settingsArray[8] = if ($monitorCount -eq 1) { 3 } else { 2 }

# Save the new setting to the registry
Set-ItemProperty -Path $path -Name Settings -Value $settingsArray

# Restart Explorer to apply the changes
Stop-Process -ProcessName explorer -Force
