@echo off
setlocal
cd /d "%~dp0"

git rev-parse --is-inside-work-tree >nul 2>nul
if errorlevel 1 (
  echo This folder is not a Git repository yet.
  echo Complete the one-time setup in online deployment instructions first.
  pause
  exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-web.ps1"
if errorlevel 1 (
  pause
  exit /b 1
)

git add -A
git diff --cached --quiet
if not errorlevel 1 (
  echo No web changes to publish.
  exit /b 0
)

for /f "tokens=1-2 delims=/:. " %%a in ("%date% %time%") do set stamp=%%a-%%b
git commit -m "Update web app %stamp%"
if errorlevel 1 exit /b 1
git push
if errorlevel 1 (
  echo Push failed. Check the remote repository and your GitHub login.
  pause
  exit /b 1
)
echo Published. The hosted web page will update after deployment finishes.
endlocal