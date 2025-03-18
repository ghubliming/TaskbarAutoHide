# Define registry path
$path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
# Check if StuckRects3 exists (some Windows versions use StuckRects2)
if (-not (Test-Path $path)) {
    $path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects2'
    if (-not (Test-Path $path)) {
        Write-Host "Neither StuckRects3 nor StuckRects2 registry keys found. Exiting."
        exit
    }
}

# Function to detect monitors and their types
function Get-MonitorInformation {
    try {
        # Get monitor information using WMI
        $monitors = Get-WmiObject -Namespace root\wmi -Class WmiMonitorBasicDisplayParams -ErrorAction Stop
        $connectedSources = Get-WmiObject -Namespace root\wmi -Class WmiMonitorConnectionParams -ErrorAction Stop
        
        $internalCount = 0
        $externalCount = 0
        
        foreach ($monitor in $monitors) {
            $instanceName = $monitor.InstanceName
            
            # Check each connection source
            foreach ($source in $connectedSources) {
                if ($source.InstanceName -eq $instanceName) {
                    # Type 2 usually indicates internal/built-in display
                    # Types other than 2 (like 1=VGA, 3=DVI, 4=HDMI, etc.) are typically external
                    if ($source.VideoOutputTechnology -eq 2) {
                        $internalCount++
                    } else {
                        $externalCount++
                    }
                }
            }
        }
        
        # Create result object
        $result = @{
            TotalMonitors = $monitors.Count
            InternalMonitors = $internalCount
            ExternalMonitors = $externalCount
        }
        
        return $result
    }
    catch {
        Write-Host "Error detecting monitors: $_"
        # Return default values assuming single internal monitor
        return @{
            TotalMonitors = 1
            InternalMonitors = 1
            ExternalMonitors = 0
        }
    }
}

# Get monitor information
$monitorInfo = Get-MonitorInformation
Write-Host "Detected $($monitorInfo.TotalMonitors) monitor(s): $($monitorInfo.InternalMonitors) internal, $($monitorInfo.ExternalMonitors) external"

# Determine if taskbar should auto-hide based on monitor configuration
$enableAutoHide = $false

# Rule 1: Only internal monitor connected - enable auto-hide
if ($monitorInfo.TotalMonitors -eq 1 -and $monitorInfo.InternalMonitors -eq 1) {
    $enableAutoHide = $true
    Write-Host "Only internal monitor detected - enabling taskbar auto-hide"
}
# Rule 2 & 3: External monitor connected or multiple monitors - disable auto-hide
else {
    $enableAutoHide = $false
    Write-Host "External or multiple monitors detected - disabling taskbar auto-hide"
}

# Get the current settings
$settings = (Get-ItemProperty -Path $path).Settings
# Ensure we are working with a mutable array
$settingsArray = [byte[]]$settings.Clone()

# Modify settings for auto-hide status
# 3 = Auto-hide taskbar, 2 = Don't auto-hide
$settingsArray[8] = if ($enableAutoHide) { 3 } else { 2 }

# Apply changes
Set-ItemProperty -Path $path -Name Settings -Value $settingsArray

# Set the AppVisibility registry key which affects taskbar behavior
$appVisibilityPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty -Path $appVisibilityPath -Name 'TaskbarAutoHideInTabletMode' -Value 0 -Type DWord
Set-ItemProperty -Path $appVisibilityPath -Name 'TaskbarGlomLevel' -Value 0 -Type DWord

# Make sure the taskbar is set to show on all displays if multiple monitors
if ($monitorInfo.TotalMonitors -gt 1) {
    $mmTaskbarPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (Test-Path $mmTaskbarPath) {
        Set-ItemProperty -Path $mmTaskbarPath -Name 'MMTaskbarEnabled' -Value 1 -Type DWord
    }
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

# Run the notification cleanup in a separate PowerShell process
$encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($cleanNotificationDB))
Start-Process powershell.exe -ArgumentList "-EncodedCommand $encodedCommand" -NoNewWindow -Wait

# Restart Explorer to apply all changes
Write-Host "Restarting Explorer to apply changes..."
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2
Start-Process explorer.exe