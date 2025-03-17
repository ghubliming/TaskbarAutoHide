
Here are four separate PowerShell test scripts for different scenarios:

### **1. Detect External Monitor Connected → Hide Taskbar**

```powershell
if ((Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.PNPClass -eq "Monitor" }).Count -gt 1) {
    $path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    $settings = (Get-ItemProperty -Path $path).Settings
    $settingsArray = [byte[]]$settings.Clone()
    $settingsArray[8] = 3  # Enable auto-hide
    Set-ItemProperty -Path $path -Name Settings -Value $settingsArray
    Stop-Process -ProcessName explorer -Force
}

```

### **2. Detect External Monitor Connected → Do NOT Hide Taskbar**

```powershell
if ((Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.PNPClass -eq "Monitor" }).Count -gt 1) {
    $path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    $settings = (Get-ItemProperty -Path $path).Settings
    $settingsArray = [byte[]]$settings.Clone()
    $settingsArray[8] = 2  # Disable auto-hide
    Set-ItemProperty -Path $path -Name Settings -Value $settingsArray
    Stop-Process -ProcessName explorer -Force
}

```

### **3. Detect Internal Monitor Only → Hide Taskbar**

```powershell
if ((Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.PNPClass -eq "Monitor" }).Count -eq 1) {
    $path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    $settings = (Get-ItemProperty -Path $path).Settings
    $settingsArray = [byte[]]$settings.Clone()
    $settingsArray[8] = 3  # Enable auto-hide
    Set-ItemProperty -Path $path -Name Settings -Value $settingsArray
    Stop-Process -ProcessName explorer -Force
}

```

### **4. Detect Internal Monitor Only → Do NOT Hide Taskbar**

```powershell
if ((Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.PNPClass -eq "Monitor" }).Count -eq 1) {
    $path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    $settings = (Get-ItemProperty -Path $path).Settings
    $settingsArray = [byte[]]$settings.Clone()
    $settingsArray[8] = 2  # Disable auto-hide
    Set-ItemProperty -Path $path -Name Settings -Value $settingsArray
    Stop-Process -ProcessName explorer -Force
}

```

### **How to Use These Tests**

1. **Run each script separately** and verify the expected taskbar behavior.
2. **Unplug/plug in the external monitor** before running the test again.
3. **Check the `Settings[8]` value** using:
    
    ```powershell
    ($settings = (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3').Settings)[8]
    
    ```
    
    - `3` = Taskbar Auto-Hide **Enabled**
    - `2` = Taskbar Auto-Hide **Disabled**

Let me know if you need adjustments! 🚀