@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-web.ps1"
if errorlevel 1 (
	pause
	exit /b 1
)
where node.exe >nul 2>nul
if errorlevel 1 (
	echo Node.js is required. Install Node.js, then run this file again.
	pause
	exit /b 1
)
node.exe "%~dp0serve-lan.cjs"
