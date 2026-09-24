$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Startup = [Environment]::GetFolderPath('Startup')
$ShortcutPath = Join-Path $Startup 'tableware-vision-localhost.lnk'
$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = Join-Path $Root 'start-localhost.cmd'
$Shortcut.WorkingDirectory = $Root
$Shortcut.Description = '开机启动商用餐具 AI 视觉工作台 LAN:5500'
$Shortcut.WindowStyle = 1
$Shortcut.Save()
Write-Output "已安装开机启动: $ShortcutPath"
Write-Output '本机地址: http://localhost:5500/index.html'
Write-Output '局域网地址: 请运行 start-localhost.cmd 查看本机 IP'
