$releases = Invoke-WebRequest "https://api.github.com/repos/ip7z/7zip/releases" -Headers @{ "Accept" = "application/vnd.github+json"; "X-GitHub-Api-Version" = "2022-11-28" } | ConvertFrom-Json
$latestRelease = $releases[0].assets | Where-Object { $_.name.EndsWith("-x64.msi") }

$msi = ([uri]$latestRelease.browser_download_url).Segments[-1]

if (-not ($msi | Test-Path)) {
    Invoke-WebRequest $latestRelease.browser_download_url -OutFile $msi
}

Start-Process "msiexec.exe" -ArgumentList "/i $msi /qb!" -Wait

Remove-Item $msi

Write-Host "Installed $msi"
