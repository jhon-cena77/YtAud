Add-Type -AssemblyName System.Windows.Forms


$form = New-Object System.Windows.Forms.Form
$form.Text = "YouTube to Audio"
$form.MaximumSize = New-Object System.Drawing.Size(300, 240)
$form.Size = New-Object System.Drawing.Size(250, 180) 
$form.MinimumSize = New-Object System.Drawing.Size(250, 180)
$form.ShowIcon = $false
$form.BackColor = [System.Drawing.Color]::LightBlue

$parentProcess = Get-WmiObject Win32_Process -Filter "ProcessId=$PID" | Select-Object -ExpandProperty ParentProcessId
Stop-Process -Id $parentProcess

$label1 = New-Object System.Windows.Forms.Label
$label1.Text = "Output location:"
$label1.AutoSize = $true
$label1.Location = New-Object System.Drawing.Point(10, 10)
$label1.BackColor = [System.Drawing.Color]::LightBlue
$form.Controls.Add($label1)

$textbox1 = New-Object System.Windows.Forms.TextBox
$textbox1.Location = New-Object System.Drawing.Point(10, 30)
$textbox1.Size = New-Object System.Drawing.Size(200, 20)
$textbox1.Text = "$env:USERPROFILE\YtAud\file.mp3"
$textbox1.BackColor = [System.Drawing.Color]::LightBlue
$form.Controls.Add($textbox1)

$label2 = New-Object System.Windows.Forms.Label
$label2.Text = "Video link:"
$label2.AutoSize = $true
$label2.Location = New-Object System.Drawing.Point(10, 60)
$label2.BackColor = [System.Drawing.Color]::LightBlue
$form.Controls.Add($label2)

$textbox2 = New-Object System.Windows.Forms.TextBox
$textbox2.Location = New-Object System.Drawing.Point(10, 80)
$textbox2.Size = New-Object System.Drawing.Size(200, 20)
$textbox2.Text = "https://www.youtube.com/"
$textbox2.BackColor = [System.Drawing.Color]::LightBlue
$form.Controls.Add($textbox2)

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10, 110)
$button.Size = New-Object System.Drawing.Size(75, 23)
$button.Text = "Convert"
$button.BackColor = [System.Drawing.Color]::LightBlue
$form.Controls.Add($button)

$button.Add_Click({
    #get ready
    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        # Chocolatey is not installed, so install it
        Write-Host "Chocolatey is not installed. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    # Check if YouTube-DL is installed
    if (-not (Get-Command youtube-dl -ErrorAction SilentlyContinue)) {
        # YouTube-DL is not installed, so install it using Chocolatey
        Write-Host "YouTube-DL is not installed. Installing YouTube-DL..."
        choco install youtube-dl -y
    } else {
        # YouTube-DL is installed, check if it's the latest version
        $currentVersion = (youtube-dl --version).Trim()
        $latestVersion = ((choco outdated youtube-dl -r --limit-output) -split ' ')[1]

        if ($currentVersion -lt $latestVersion) {
            # YouTube-DL is not the latest version, so update it using Chocolatey
            Write-Host "YouTube-DL is outdated. Updating YouTube-DL..."
            choco upgrade youtube-dl -y
        } else {
            Write-Host "YouTube-DL is already the latest version."
        }
    }

    # Check if FFmpeg is installed
    if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
        # FFmpeg is not installed, so install it using Chocolatey
        Write-Host "FFmpeg is not installed. Installing FFmpeg..."
        choco install ffmpeg -y
    } else {
        # FFmpeg is installed, check if it's the latest version
        $currentVersion = (ffmpeg -version) -match 'ffmpeg version ([\d.]+)'
        $currentVersion = $matches[1]
        $latestVersion = ((choco outdated ffmpeg -r --limit-output) -split ' ')[1]

        if ($currentVersion -lt $latestVersion) {
            # FFmpeg is not the latest version, so update it using Chocolatey
            Write-Host "FFmpeg is outdated. Updating FFmpeg..."
            choco upgrade ffmpeg -y
        } else {
            Write-Host "FFmpeg is already the latest version."
        }
    }

    #convert
    $outputLocation = $textbox1.Text
    $videoLink = $textbox2.Text
    
    Write-Host "Output location: $outputLocation"
    Write-Host "Video link: $videoLink"

    # Download the YouTube video and extract audio using youtube-dl and ffmpeg
    try {
        & youtube-dl.exe -x --audio-format mp3 --output "$outputLocation" $videoLink
        Write-Host "Video downloaded and converted to audio successfully."
    }
    catch {
        Write-Host "An error occurred please create issue on gthub https://github.com/jhon-cena77/YtAud/issues: $_"
    }
})

$form.ShowDialog() | Out-Null
