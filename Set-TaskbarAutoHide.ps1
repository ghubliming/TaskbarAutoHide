param([switch]$ForceInternal = $false)

function Get-TaskbarRegistryPath {
    $paths = @(
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects2'
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    throw "Taskbar registry path not found"
}

function Test-ExternalDisplay {
    if ($ForceInternal) { return $false }
    
    try {
        # Try WMI method first (more reliable)
        $monitors = Get-WmiObject -Namespace root\wmi -Class WmiMonitorConnectionParams -ErrorAction Stop
        foreach ($monitor in $monitors) {
            # Check for external connections: VGA, DVI, HDMI, DisplayPort, etc.
            if ($monitor.VideoOutputTechnology -in @(0, 4, 5, 9, 10)) {
                return $true
            }
        }
        
        # Fallback to screen count method
        Add-Type -AssemblyName System.Windows.Forms
        return ([System.Windows.Forms.Screen]::AllScreens.Count -gt 1)
    }
    catch {
        Write-Warning "Error detecting displays: $_"
        # Fallback to screen count method
        try {
            Add-Type -AssemblyName System.Windows.Forms
            return ([System.Windows.Forms.Screen]::AllScreens.Count -gt 1)
        }
        catch {
            Write-Warning "Screen detection failed: $_"
            return $false
        }
    }
}

function Update-TaskbarSettings {
    param(
        [string]$Path,
        [bool]$EnableAutoHide
    )
    
    $settings = (Get-ItemProperty -Path $Path).Settings
    $settingsArray = [byte[]]$settings.Clone()
    
    # Check current auto-hide setting (byte 8)
    $currentAutoHide = ($settingsArray[8] -eq 3)

    if ($currentAutoHide -eq $EnableAutoHide) {
        Write-Host "Taskbar setting is already correct. No changes needed."
        return
    }

    # Set auto-hide flag
    $settingsArray[8] = if ($EnableAutoHide) { 3 } else { 2 }
    
    # Make sure taskbar is visible
    $settingsArray[12] = 1
    
    # Apply changes
    Set-ItemProperty -Path $Path -Name Settings -Value $settingsArray

    # Restart Explorer only if changes were made
    Restart-Explorer
}

function Restart-Explorer {
    Write-Host "Restarting Explorer to apply changes..."
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Start-Process explorer.exe
}

# Main script
try {
    $path = Get-TaskbarRegistryPath
    $hasExternalMonitor = Test-ExternalDisplay
    $enableAutoHide = -not $hasExternalMonitor
    
    Write-Host "External monitor: $hasExternalMonitor"
    Write-Host "Auto-hide setting: $enableAutoHide"
    
    Update-TaskbarSettings -Path $path -EnableAutoHide $enableAutoHide
}
catch {
    Write-Error "Failed to update taskbar settings: $_"
    exit 1
}
