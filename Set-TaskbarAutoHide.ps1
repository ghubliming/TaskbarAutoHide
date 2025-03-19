param(
    [switch]$ForceInternal = $false
)

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

# Simple function that assumes laptop internal monitor
function Get-MonitorInformation {
    # Force internal monitor mode
    if ($ForceInternal) {
        Write-Host "Forced internal monitor mode"
        return @{
            TotalMonitors = 1
            InternalMonitors = 1
            ExternalMonitors = 0
        }
    }
    
    # Try a simple method to detect display count
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $screens = [System.Windows.Forms.Screen]::AllScreens
        $screenCount = $screens.Count
        
        # Check if laptop
        $isLaptop = $false
        try {
            $battery = Get-WmiObject -Class Win32_Battery
            if ($battery -ne $null) {
                $isLaptop = $true
            }
        } catch {
            # Default to assuming it's a laptop
            $isLaptop = $true
        }
        
        if ($isLaptop -and $screenCount -eq 1) {
            # Single screen on laptop = internal
            return @{
                TotalMonitors = 1
                InternalMonitors = 1
                ExternalMonitors = 0
            }
        } else {
            # Multiple screens or desktop
            return @{
                TotalMonitors = $screenCount
                InternalMonitors = if ($isLaptop) { 1 } else { 0 }
                ExternalMonitors = if ($isLaptop) { $screenCount - 1 } else { $screenCount }
            }
        }
    } catch {
        # Fallback to safe defaults
        Write-Host "Error in monitor detection: $_"
        Write-Host "Falling back to default: 1 internal monitor"
        return @{
            TotalMonitors = 1
            InternalMonitors = 1
            ExternalMonitors = 0
        }
    }
}

# Override detection with forced mode
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

# Restart Explorer to apply all changes
Write-Host "Restarting Explorer to apply changes..."
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2
Start-Process explorer.exe