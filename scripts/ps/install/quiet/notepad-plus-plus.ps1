$releases = Invoke-WebRequest "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases" -Headers @{ "Accept" = "application/vnd.github+json"; "X-GitHub-Api-Version" = "2022-11-28" } | ConvertFrom-Json
$latestRelease = $releases[0].assets | Where-Object { $_.name.EndsWith("Installer.x64.exe") }
$latestReleaseSig = $releases[0].assets | Where-Object { $_.name.EndsWith("Installer.x64.exe.sig") }

$exe = ([uri]$latestRelease.browser_download_url).Segments[-1]
$exeSig = ([uri]$latestReleaseSig.browser_download_url).Segments[-1]

if (-not ($exe | Test-Path)) {
    Invoke-WebRequest $latestRelease.browser_download_url -OutFile $exe
}

if (-not ($exeSig | Test-Path)) {
    Invoke-WebRequest $latestReleaseSig.browser_download_url -OutFile $exeSig
}

# TODO: use the sig file to verify the download (looks like it needs gpg)

Start-Process "$exe" -ArgumentList "/S" -Wait

Remove-Item $exe
Remove-Item $exeSig

Write-Host "Installed $exe"
