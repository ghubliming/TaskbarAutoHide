# Taskbar Auto-Hide Script

## Overview
This PowerShell script automatically controls the auto-hide feature of the Windows taskbar based on the number of connected monitors. The taskbar will be set to **auto-hide** when only the **internal monitor** is connected (useful for laptops with limited screen space) and will remain **always visible** when an **external monitor** is detected.

## What the Script Does
- **Detects the number of active monitors** (internal and external).
- **Modifies the registry settings** to enable or disable the taskbar auto-hide feature based on the number of monitors.
- Restarts **Explorer** to immediately apply the changes to the taskbar.

### Key Function:
- When **only the internal monitor** is connected, the taskbar auto-hide is **enabled** (to save screen space).
- When an **external monitor** is connected, the taskbar auto-hide is **disabled** (since more screen space is available).
- When **multiple monitos** are connected, the taskbar auto-hide is **disabled** (since more screen space is available).

## Test Code
Some useful test code is provided in the `test.md` file to help you verify the behavior of the script.

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

