# create_shortcut.ps1 - Creates a Desktop shortcut for Wall Repeat
# Run once to set up. After it finishes, right-click the shortcut and pin to taskbar.

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$guiScript  = Join-Path $scriptDir "wall_repeat_gui.ps1"
$shortcutPath = [System.IO.Path]::Combine(
    [System.Environment]::GetFolderPath("Desktop"),
    "Wall Repeat.lnk"
)

$wsh      = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($shortcutPath)

$shortcut.TargetPath       = "powershell.exe"
$shortcut.Arguments        = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$guiScript`""
$shortcut.WorkingDirectory = $scriptDir
$shortcut.WindowStyle      = 1
$shortcut.IconLocation     = "powershell.exe,0"
$shortcut.Description      = "Wall Repeat - tile and export wall images"
$shortcut.Save()

[System.Windows.Forms.MessageBox]::Show(
    "Shortcut created on your Desktop.`n`nTo pin it to the taskbar:`n1. Find 'Wall Repeat' on your Desktop`n2. Right-click it`n3. Click 'Pin to taskbar'",
    "Done",
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Information
) | Out-Null

Write-Host "Shortcut created: $shortcutPath"
