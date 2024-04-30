$appName = "DevToys"
Start-Process "winget" -ArgumentList "install $appName" -Wait -NoNewWindow
Write-Host "Installed $appName"