$releases = Invoke-WebRequest "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" | ConvertFrom-Json
$latestDownload = $(Invoke-WebRequest "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" | ConvertFrom-Json).TBA[0].downloads.windows.link
$latestDownloadSha256 = $(Invoke-WebRequest $releases.TBA[0].downloads.windows.checksumLink).Content.Split(" ")[0]

$exe = ([uri]"$latestDownload").Segments[-1]
if (-not ($exe | Test-Path)) {
    Invoke-WebRequest "$latestDownload" -OutFile $exe
}

$exeSHA256 = $(Get-FileHash $exe -Algorithm SHA256).Hash.ToLower()
if ($exeSHA256 -ne $latestDownloadSha256) {
    Invoke-WebRequest "$latestDownload" -OutFile $exe
    $exeSHA256 = $(Get-FileHash $exe -Algorithm SHA256).Hash.ToLower()
    if ($exeSHA256 -ne $latestDownloadSha256) {
        throw "Error verifying $exe\: expected: $latestDownloadSHA256, actual: $exeSHA256"
    }
}

# Start-Process -Wait doesn't work here because the installer spawns the app itself as a child process
$installProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
$installProcessInfo.FileName = $exe
$installProcessInfo.UseShellExecute = $false
$installProcess = New-Object System.Diagnostics.Process
$installProcess.StartInfo = $pinfo
$installProcess.Start() | Out-Null
$installProcess.WaitForExit()

Remove-Item $exe

Write-Host "Installed $exe"