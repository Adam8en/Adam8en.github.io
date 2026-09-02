@echo off
setlocal
title Hexo Blog Deployment
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\deploy-blog.ps1"
set "deploy_exit=%ERRORLEVEL%"

echo.
if not "%deploy_exit%"=="0" (
    echo Deployment failed with exit code %deploy_exit%.
    echo Review the error message above before trying again.
    pause
    exit /b %deploy_exit%
)

echo Deployment completed successfully.
pause
exit /b 0
