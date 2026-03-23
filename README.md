# Wall Repeat - Setup Guide (Windows)

## 1. Install Python

Open **PowerShell** or **Command Prompt** and run:

```powershell
winget install Python.Python.3.12
```

After installation, close and reopen your terminal, then verify it worked:

```powershell
python --version
```

> If `winget` is not available, download the installer from [python.org/downloads](https://www.python.org/downloads/).
> During installation, make sure to tick **"Add python.exe to PATH"** before clicking Install.

---

## 2. Install Pillow

```powershell
pip install Pillow
```

---

## 3. Enable PowerShell Scripts

Windows blocks `.ps1` scripts from running by default. To allow them, open
**PowerShell as Administrator** (right-click the Start menu > "Windows PowerShell (Admin)") and run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Type `Y` and press Enter to confirm.

> `RemoteSigned` allows local scripts to run freely while still blocking
> unsigned scripts downloaded from the internet.

---

## 4. Create a Desktop Shortcut (optional)

Run this once to place a shortcut on your Desktop:

```powershell
powershell -ExecutionPolicy Bypass -File create_shortcut.ps1
```

A popup will confirm it worked. Then:

1. Find **Wall Repeat** on your Desktop
2. Right-click it
3. Click **"Pin to taskbar"**

---

## 5. Run the App

Navigate to the folder containing the files and launch the GUI:

```powershell
powershell -ExecutionPolicy Bypass -File wall_repeat_gui.ps1
```

Or simply right-click `wall_repeat_gui.ps1` and choose **"Run with PowerShell"**.

---

## Files

| File | Description |
|---|---|
| `wall_repeat.py` | Core script that tiles and exports the image |
| `wall_repeat_gui.ps1` | Windows GUI for running the script |
| `create_shortcut.ps1` | Run once to create a Desktop shortcut (pinnable to taskbar) |
