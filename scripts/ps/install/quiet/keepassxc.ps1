$releases = Invoke-WebRequest "https://api.github.com/repos/keepassxreboot/keepassxc/releases" -Headers @{ "Accept" = "application/vnd.github+json"; "X-GitHub-Api-Version" = "2022-11-28" } | ConvertFrom-Json
$latestRelease = $releases[0].assets | Where-Object { $_.name.EndsWith("-Win64.msi") }
$latestReleaseSig = $releases[0].assets | Where-Object { $_.name.EndsWith("-Win64.msi.sig") }

$msi = ([uri]$latestRelease.browser_download_url).Segments[-1]
$msiSig = ([uri]$latestReleaseSig.browser_download_url).Segments[-1]

if (-not ($msi | Test-Path)) {
    Invoke-WebRequest $latestRelease.browser_download_url -OutFile $msi
}

if (-not ($msiSig | Test-Path)) {
    Invoke-WebRequest $latestReleaseSig.browser_download_url -OutFile $msiSig
}

# TODO: add a way to use the sig to verify
Start-Process "msiexec.exe" -ArgumentList "/i $msi /qb!" -Wait

Remove-Item $msi
Remove-Item $msiSig

Write-Host "Installed $msi"
