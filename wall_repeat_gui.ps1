# wall_repeat_gui.ps1 — Windows Forms GUI for wall_repeat.py
# Run with: powershell -ExecutionPolicy Bypass -File wall_repeat_gui.ps1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# ── Main window ─────────────────────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text            = "Wall Repeat"
$form.Size            = New-Object System.Drawing.Size(520, 400)
$form.StartPosition   = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox     = $false
$form.Font            = New-Object System.Drawing.Font("Segoe UI", 10)
$form.BackColor       = [System.Drawing.Color]::FromArgb(245, 245, 245)

# ── Helper: labelled row ─────────────────────────────────────────────────────
function Add-Row {
    param($label, $top)
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text     = $label
    $lbl.Location = New-Object System.Drawing.Point(20, ($top + 3))
    $lbl.Size     = New-Object System.Drawing.Size(120, 22)
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    $form.Controls.Add($lbl)
    return $lbl
}

# ── Image file row ───────────────────────────────────────────────────────────
Add-Row "Image file" 20 | Out-Null

$txtFile = New-Object System.Windows.Forms.TextBox
$txtFile.Location    = New-Object System.Drawing.Point(150, 20)
$txtFile.Size        = New-Object System.Drawing.Size(260, 26)
$txtFile.BackColor   = [System.Drawing.Color]::White
$form.Controls.Add($txtFile)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text      = "Browse..."
$btnBrowse.Location  = New-Object System.Drawing.Point(418, 19)
$btnBrowse.Size      = New-Object System.Drawing.Size(78, 28)
$btnBrowse.FlatStyle = "Flat"
$btnBrowse.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($btnBrowse)

$btnBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title  = "Select source image"
    $dlg.Filter = "Images (*.tif;*.tiff;*.jpg;*.jpeg;*.png)|*.tif;*.tiff;*.jpg;*.jpeg;*.png|All files (*.*)|*.*"
    if ($dlg.ShowDialog() -eq "OK") {
        $txtFile.Text = $dlg.FileName
    }
})

# ── Numeric inputs ───────────────────────────────────────────────────────────
function Add-NumericField {
    param($label, $top, $default, $min, $max, $dec)
    Add-Row $label $top | Out-Null
    $num = New-Object System.Windows.Forms.NumericUpDown
    $num.Location        = New-Object System.Drawing.Point(150, $top)
    $num.Size            = New-Object System.Drawing.Size(120, 26)
    $num.Minimum         = $min
    $num.Maximum         = $max
    $num.DecimalPlaces   = $dec
    $num.Value           = $default
    $num.BackColor       = [System.Drawing.Color]::White
    $form.Controls.Add($num)
    return $num
}

$numWidth  = Add-NumericField "Width (cm)"  70  2000  1  99999 1
$numHeight = Add-NumericField "Height (cm)" 110   80  1  99999 1
$numDpi    = Add-NumericField "DPI"         150  100  1   9600 0

# ── Python executable row ─────────────────────────────────────────────────────
Add-Row "Python exe" 190 | Out-Null

$txtPython = New-Object System.Windows.Forms.TextBox
$txtPython.Location  = New-Object System.Drawing.Point(150, 190)
$txtPython.Size      = New-Object System.Drawing.Size(260, 26)
$txtPython.Text      = "python"
$txtPython.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($txtPython)

$btnPyBrowse = New-Object System.Windows.Forms.Button
$btnPyBrowse.Text      = "Browse..."
$btnPyBrowse.Location  = New-Object System.Drawing.Point(418, 189)
$btnPyBrowse.Size      = New-Object System.Drawing.Size(78, 28)
$btnPyBrowse.FlatStyle = "Flat"
$btnPyBrowse.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($btnPyBrowse)

$btnPyBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title  = "Select python.exe"
    $dlg.Filter = "Python (python.exe)|python.exe|All executables (*.exe)|*.exe"
    if ($dlg.ShowDialog() -eq "OK") {
        $txtPython.Text = $dlg.FileName
    }
})

# ── Run button ────────────────────────────────────────────────────────────────
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text      = "Run"
$btnRun.Location  = New-Object System.Drawing.Point(150, 235)
$btnRun.Size      = New-Object System.Drawing.Size(346, 36)
$btnRun.FlatStyle = "Flat"
$btnRun.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$btnRun.ForeColor = [System.Drawing.Color]::White
$btnRun.Font      = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnRun)

# ── Output log ────────────────────────────────────────────────────────────────
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location   = New-Object System.Drawing.Point(20, 285)
$txtLog.Size       = New-Object System.Drawing.Size(476, 70)
$txtLog.Multiline  = $true
$txtLog.ReadOnly   = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.BackColor  = [System.Drawing.Color]::FromArgb(30, 30, 30)
$txtLog.ForeColor  = [System.Drawing.Color]::FromArgb(200, 230, 200)
$txtLog.Font       = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($txtLog)

# ── Script path (same folder as this .ps1) ───────────────────────────────────
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$pyScript  = Join-Path $scriptDir "wall_repeat.py"

# ── Run logic ─────────────────────────────────────────────────────────────────
$btnRun.Add_Click({
    $txtLog.Clear()

    if (-not $txtFile.Text -or -not (Test-Path $txtFile.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please select a valid image file.", "Missing input", "OK", "Warning")
        return
    }
    if (-not (Test-Path $pyScript)) {
        [System.Windows.Forms.MessageBox]::Show("wall_repeat.py not found next to this script.`n$pyScript", "Missing script", "OK", "Error")
        return
    }

    $btnRun.Enabled = $false
    $btnRun.Text    = "Running…"
    $form.Refresh()

    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    $args = @(
        "`"$pyScript`"",
        "`"$($txtFile.Text)`"",
        $numWidth.Value.ToString($culture),
        $numHeight.Value.ToString($culture),
        "--dpi", $numDpi.Value.ToString($culture)
    )

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName               = $txtPython.Text
        $psi.Arguments              = $args -join " "
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.UseShellExecute        = $false
        $psi.CreateNoWindow         = $true

        $proc = [System.Diagnostics.Process]::Start($psi)
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()

        $output = ($stdout + $stderr).Trim()
        $txtLog.Text = if ($output) { $output } else { "(no output)" }

        if ($proc.ExitCode -eq 0) {
            $btnRun.BackColor = [System.Drawing.Color]::FromArgb(16, 124, 16)
        } else {
            $btnRun.BackColor = [System.Drawing.Color]::FromArgb(196, 43, 28)
        }
    } catch {
        $txtLog.Text = "Error launching Python: $_"
        $btnRun.BackColor = [System.Drawing.Color]::FromArgb(196, 43, 28)
    }

    $btnRun.Enabled = $true
    $btnRun.Text    = "Run"
})

$form.ShowDialog() | Out-Null
