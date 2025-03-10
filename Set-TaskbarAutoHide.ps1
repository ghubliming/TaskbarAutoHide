# Get the number of active monitors
$monitorCount = (Get-WmiObject Win32_PnPEntity | Where-Object { $_.PNPClass -eq "Monitor" }).Count

# Registry path for taskbar settings
$path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
$settings = (Get-ItemProperty -Path $path).Settings

# Modify settings: [8] controls auto-hide (3 = auto-hide enabled, 2 = disabled)
if ($monitorCount -eq 1) {
    # Only internal monitor connected – enable auto-hide
    $settings[8] = 3
} else {
    # External monitor detected – disable auto-hide
    $settings[8] = 2
}

# Save the new setting to the registry
Set-ItemProperty -Path $path -Name Settings -Value $settings

# Restart Explorer to apply the changes
Stop-Process -f -ProcessName explorer
