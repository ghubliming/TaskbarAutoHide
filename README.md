# Taskbar Auto-Hide Script

This PowerShell script automatically manages Windows taskbar auto-hide settings based on your monitor configuration.

## Features

- Detects internal (built-in) and external monitors
- Applies taskbar auto-hide settings based on monitor configuration:
  - When only using internal monitor: Auto-hide enabled (saves screen space)
  - When external monitor(s) connected: Auto-hide disabled (more screen space available)
  - When multiple monitors connected: Auto-hide disabled (more screen space available)
- Works with different Windows versions (checks for both StuckRects3 and StuckRects2 registry keys)
- Includes notification area cleanup to prevent auto-hide issues
- Provides helpful console output about detected monitors and applied settings

## Requirements

- Windows 10 or Windows 11
- PowerShell 5.1 or higher
- Administrator privileges (for registry modifications)

## Installation

1. Save the script as `TaskbarAutoHideManager.ps1` to a location of your choice
2. Optionally, create a shortcut to run the script

## Usage

### Basic Usage

Right-click the script and select "Run with PowerShell" or run it from a PowerShell prompt:

```powershell
.\TaskbarAutoHideManager.ps1
```

## Startup Method : Adding the Script to Startup Folder

1. **Save the script (`Set-TaskbarAutoHide.ps1`)** to your desired location (e.g., `C:\misc\TaskbarAutoHide\Set-TaskbarAutoHide.ps1`).

2. **Create a Shortcut**:
   - Right-click on your **Desktop** or in any folder, then select **New > Shortcut**.
   - In the **Location** field, type the following command:
     ```
     powershell -ExecutionPolicy Bypass -File "C:\misc\TaskbarAutoHide\Set-TaskbarAutoHide.ps1"
     ```
   - Click **Next**, name the shortcut (e.g., **Auto-Hide Taskbar**), and click **Finish**.

3. **Move the Shortcut to the Startup Folder**:
   - Press `Win + R`, type `shell:startup`, and press **Enter**.
   - Move the **shortcut** (not the `.ps1` file) into the **Startup folder**.

With this setup, the script will **automatically run** each time you log in, ensuring the taskbar behavior is adjusted based on the connected monitors. The shortcut is ready to use and can be run manually anytime as well.


## Troubleshooting

If the script doesn't work as expected:

1. Run PowerShell as Administrator
2. Check if you have execution policy restrictions:
   ```powershell
   Get-ExecutionPolicy
   ```
3. If restricted, try running with bypass:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File "path\to\TaskbarAutoHideManager.ps1"
   ```

## Contributing

Feel free to submit issues or pull requests to improve this script.

## License

See the [LICENSE](LICENSE) file for details.

