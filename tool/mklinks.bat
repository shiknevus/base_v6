@echo off
cd /d "%~dp0"

echo ========================================
echo Creating Symbolic Links
echo ========================================
echo Current directory: %CD%
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Administrator privileges required!
    echo Please right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)
echo Admin check: PASS
echo.

setlocal EnableDelayedExpansion

:: This script lives in tool\, so the repo root is its parent directory
for %%i in ("%~dp0..") do set "BASE=%%~fi\"

:: Ensure syn\src exists
if not exist "%BASE%syn\src" (
    echo   syn\src not found, creating...
    mkdir "%BASE%syn\src"
)

echo [1/4] Processing rtl...
if exist "%BASE%syn\src\rtl\" (
    echo   Removing existing directory/symlink syn\src\rtl
    rmdir "%BASE%syn\src\rtl" >nul 2>&1
) else if exist "%BASE%syn\src\rtl" (
    echo   Removing existing file syn\src\rtl
    del /f /q "%BASE%syn\src\rtl" >nul 2>&1
)
pushd "%BASE%syn\src" || (echo ERROR: Cannot enter syn\src & pause & exit /b 1)
mklink /D rtl ..\..\rtl
popd
echo.

echo [2/4] Processing sim...
if exist "%BASE%syn\src\sim\" (
    echo   Removing existing directory/symlink syn\src\sim
    rmdir "%BASE%syn\src\sim" >nul 2>&1
) else if exist "%BASE%syn\src\sim" (
    echo   Removing existing file syn\src\sim
    del /f /q "%BASE%syn\src\sim" >nul 2>&1
)
pushd "%BASE%syn\src" || (echo ERROR: Cannot enter syn\src & pause & exit /b 1)
mklink /D sim ..\..\sim
popd
echo.

echo [3/4] Processing ip...
if exist "%BASE%syn\src\ip\" (
    echo   Removing existing directory/symlink syn\src\ip
    rmdir "%BASE%syn\src\ip" >nul 2>&1
) else if exist "%BASE%syn\src\ip" (
    echo   Removing existing file syn\src\ip
    del /f /q "%BASE%syn\src\ip" >nul 2>&1
)
pushd "%BASE%syn\src" || (echo ERROR: Cannot enter syn\src & pause & exit /b 1)
mklink /D ip ..\..\ip
popd
echo.

echo [4/4] Processing xdc...
if exist "%BASE%syn\src\xdc\" (
    echo   Removing existing directory/symlink syn\src\xdc
    rmdir "%BASE%syn\src\xdc" >nul 2>&1
) else if exist "%BASE%syn\src\xdc" (
    echo   Removing existing file syn\src\xdc
    del /f /q "%BASE%syn\src\xdc" >nul 2>&1
)
pushd "%BASE%syn\src" || (echo ERROR: Cannot enter syn\src & pause & exit /b 1)
mklink /D xdc ..\..\xdc
popd
echo.

echo ========================================
echo Symlinks Done!
echo ========================================
dir "%BASE%syn\src"
echo.

echo ========================================
echo Launching Vivado Project
echo ========================================
echo.

set /a xpr_count=0
for /r "%BASE%syn" %%f in (*.xpr) do (
    set /a xpr_count+=1
    set "xpr_!xpr_count!=%%f"
    set "xpr_dir_!xpr_count!=%%~dpf"
)

if !xpr_count! equ 0 (
    echo WARNING: No .xpr files found under syn\
    echo.
    pause
    exit /b 0
)

if !xpr_count! equ 1 (
    echo Found 1 project, launching directly:
    echo   !xpr_1!
    set "choice=1"
    goto :launch
)

echo Found !xpr_count! project(s):
for /L %%i in (1,1,!xpr_count!) do (
    echo   %%i. !xpr_%%i!
)
echo.
set /p choice="Select project to open [1-!xpr_count!]: "
if not defined choice (
    echo No selection made.
    pause
    exit /b 0
)

:launch
set "sel_xpr=!xpr_%choice%!"
set "sel_dir=!xpr_dir_%choice%!"

echo.
echo Opening: !sel_xpr!
echo Working dir: !sel_dir!
pushd "!sel_dir!"
start "" "!sel_xpr!"
echo   Started at %date% %time%
echo.

echo Waiting for vivado gui start ...
:wait_log
if not exist "vivado.log" (
    timeout /t 2 /nobreak >nul
    goto :wait_log
)
echo.
echo ========================================
echo Tailing vivado.log 
echo ========================================
powershell -NoProfile -Command "Get-Content -Path 'vivado.log' -Wait | ForEach-Object { Write-Host $_; if ($_ -match 'open_project') { Write-Host ''; Write-Host 'Detected open_project - closing terminal...'; exit } }"
popd
exit