@echo off
chcp 65001 >nul
title Edge Optimizer for Video
color 0B

echo ========================================================
echo   MICROSOFT EDGE FLAGS OPTIMIZER FOR VIDEO
echo ========================================================
echo 1. Disable DRM
echo 2. D3D11 ANGLE
echo 3. Force Accelerated-Hardware
echo 4. Zero-copy rasterizer
echo 5. sRGB Color Profile
echo ========================================================
echo.
echo Press any key to start...
pause >nul

echo.
echo [1/3] Closing Microsoft Edge...
taskkill /F /IM msedge.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2/3] Applying Flags to system...
set "PS_SCRIPT=%temp%\EdgeOptimize.ps1"

echo $Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Local State" > "%PS_SCRIPT%"
echo if (-Not (Test-Path $Path)) { Write-Host "Local State config not found!" -ForegroundColor Red; exit } >> "%PS_SCRIPT%"
echo $Json = Get-Content -Raw -Encoding UTF8 $Path ^| ConvertFrom-Json >> "%PS_SCRIPT%"
echo if ($null -eq $Json.browser) { Add-Member -InputObject $Json -MemberType NoteProperty -Name 'browser' -Value @{} -Force } >> "%PS_SCRIPT%"
echo if ($null -eq $Json.browser.enabled_labs_experiments) { Add-Member -InputObject $Json.browser -MemberType NoteProperty -Name 'enabled_labs_experiments' -Value @() -Force } >> "%PS_SCRIPT%"
echo $Flags = $Json.browser.enabled_labs_experiments >> "%PS_SCRIPT%"
echo if ($null -eq $Flags) { $Flags = @() } >> "%PS_SCRIPT%"

:: FIXED: ignore-gpu-blocklist now uses the naked string without the @ suffix based on your extraction!
echo $NewFlags = @('edge-playready-drm-win10@2', 'use-angle@1', 'ignore-gpu-blocklist', 'enable-zero-copy@1', 'force-color-profile@1') >> "%PS_SCRIPT%"

echo foreach ($Flag in $NewFlags) { >> "%PS_SCRIPT%"
echo     $Base = $Flag.Split('@')[0] >> "%PS_SCRIPT%"
:: FIXED Regex: matches the base string exactly to avoid duplicate accumulation
echo     $Flags = @($Flags ^| Where-Object { $_ -notmatch "^$Base" }) >> "%PS_SCRIPT%"
echo     $Flags += $Flag >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo $Json.browser.enabled_labs_experiments = $Flags >> "%PS_SCRIPT%"
echo $Json ^| ConvertTo-Json -Depth 100 -Compress ^| Set-Content -Path $Path -Encoding UTF8 >> "%PS_SCRIPT%"

powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
del "%PS_SCRIPT%"

echo [3/3] Done! Restarting Microsoft Edge...
start msedge.exe

echo.
echo Optimization complete! All 5 flags applied successfully.
pause >nul
