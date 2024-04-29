$releases = Invoke-WebRequest "https://api.github.com/repos/git-for-windows/git/releases" -Headers @{ "Accept" = "application/vnd.github+json"; "X-GitHub-Api-Version" = "2022-11-28" } | ConvertFrom-Json
$latestRelease = $releases[0].assets | Where-Object { $_.name.EndsWith("-64-bit.exe") }
# TODO: SHA256 is in body field, grep it out and verify

$exe = ([uri]$latestRelease.browser_download_url).Segments[-1]

if (-not ($exe | Test-Path)) {
    Invoke-WebRequest $latestRelease.browser_download_url -OutFile $exe
}

Start-Process "$exe" -ArgumentList "/VERYSILENT" -Wait

Remove-Item $exe

Write-Host "Installed $exe"
