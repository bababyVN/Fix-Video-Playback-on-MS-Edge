@echo off
chcp 65001 >nul
title Edge Optimizer For Video
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
taskkill /F /IM msedge.exe >nul 2>&1
timeout /t 2 /nobreak >nul

set "PS_SCRIPT=%temp%\EdgeOptimize.ps1"

:: Tao script PowerShell tam thoi de doc/ghi an toan vao file JSON cua Edge
echo $Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Local State" > "%PS_SCRIPT%"
echo if (-Not (Test-Path $Path)) { Write-Host "Khong tim thay cau hinh Edge tren may nay!" -ForegroundColor Red; exit } >> "%PS_SCRIPT%"
echo $Json = Get-Content -Raw -Encoding UTF8 $Path ^| ConvertFrom-Json >> "%PS_SCRIPT%"
echo if (-Not $Json.browser) { Add-Member -InputObject $Json -MemberType NoteProperty -Name 'browser' -Value @{} } >> "%PS_SCRIPT%"
echo if (-Not $Json.browser.enabled_labs_experiments) { Add-Member -InputObject $Json.browser -MemberType NoteProperty -Name 'enabled_labs_experiments' -Value @() } >> "%PS_SCRIPT%"
echo [System.Collections.ArrayList]$Flags = $Json.browser.enabled_labs_experiments >> "%PS_SCRIPT%"
:: Danh sach cac Flags dang chuoi string ma Chromium hieu (@1 la Index 1, @2 la Index 2...)
echo $NewFlags = @('edge-playready-drm-win10@2', 'use-angle@1', 'ignore-gpu-blocklist@1', 'enable-zero-copy@1', 'force-color-profile@1') >> "%PS_SCRIPT%"
echo foreach ($Flag in $NewFlags) { >> "%PS_SCRIPT%"
echo     $Base = $Flag.Split('@')[0] >> "%PS_SCRIPT%"
echo     $Flags = @($Flags ^| Where-Object { $_ -notmatch "^$Base@" }) >> "%PS_SCRIPT%"
echo     $Flags += $Flag >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"
echo $Json.browser.enabled_labs_experiments = $Flags >> "%PS_SCRIPT%"
echo $Json ^| ConvertTo-Json -Depth 100 -Compress ^| Set-Content -Path $Path -Encoding UTF8 >> "%PS_SCRIPT%"

:: Chay script PowerShell bang quyen Bypass va xoa sau khi xong
powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
del "%PS_SCRIPT%"

echo Done. You can now open Microsoft Edge...
echo.
pause >nul