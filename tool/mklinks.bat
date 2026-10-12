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
echo   0. Open ALL projects
for /L %%i in (1,1,!xpr_count!) do (
    echo   %%i. !xpr_%%i!
)
echo.
set /p choice="Select project to open [0-!xpr_count!], 0=ALL: "
if not defined choice (
    echo No selection made.
    pause
    exit /b 0
)

:launch
if "!choice!" equ "0" goto :launch_all
set "sel_xpr=!xpr_%choice%!"
set "sel_dir=!xpr_dir_%choice%!"

call :resolve_vivado "!sel_xpr!" || (pause & exit /b 1)
echo.
echo Opening: !sel_xpr!
echo Vivado : !VIV_VER!  ^(!VIV_BAT!^)
echo Working dir: !sel_dir!
pushd "!sel_dir!"
call :start_vivado "!sel_xpr!"
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

:launch_all
echo Opening ALL !xpr_count! project(s)...
set "viv_fail="
for /L %%i in (1,1,!xpr_count!) do (
    echo   [%%i/!xpr_count!] !xpr_%%i!
    call :resolve_vivado "!xpr_%%i!" || set "viv_fail=1"
    if defined VIV_BAT (
        echo         Vivado !VIV_VER!
        pushd "!xpr_dir_%%i!"
        call :start_vivado "!xpr_%%i!"
        popd
    )
)
echo.
echo All projects started at %date% %time%
echo Skipping vivado.log tail (multiple projects)
if defined viv_fail pause
exit

:: %1=xpr -> VIV_VER/VIV_BAT; override: VIVADO_VER=2018.3 or VIVADO_BAT=path\vivado.bat
:resolve_vivado
set "VIV_VER="
set "VIV_BAT="
for /f "tokens=5" %%v in ('findstr /c:"Product Version: Vivado v" "%~1" 2^>nul') do if not defined VIV_VER set "VIV_VER=%%v"
if defined VIV_VER set "VIV_VER=!VIV_VER:v=!"
if defined VIVADO_VER set "VIV_VER=%VIVADO_VER%"
if defined VIVADO_BAT (
    set "VIV_BAT=%VIVADO_BAT%"
    exit /b 0
)
if not defined VIV_VER (
    echo ERROR: Cannot read Vivado version from %~1
    echo        set VIVADO_VER=xxxx.x or VIVADO_BAT=...\vivado.bat
    exit /b 1
)
for %%d in (C D E F G H) do (
    if not defined VIV_BAT if exist "%%d:\Xilinx\Vivado\!VIV_VER!\bin\vivado.bat" set "VIV_BAT=%%d:\Xilinx\Vivado\!VIV_VER!\bin\vivado.bat"
    if not defined VIV_BAT if exist "%%d:\AMDDesignTools\!VIV_VER!\Vivado\bin\vivado.bat" set "VIV_BAT=%%d:\AMDDesignTools\!VIV_VER!\Vivado\bin\vivado.bat"
)
if defined VIV_BAT exit /b 0
echo ERROR: Vivado !VIV_VER! not installed. Found:
for %%d in (C D E F G H) do for /d %%p in ("%%d:\Xilinx\Vivado\*" "%%d:\AMDDesignTools\*") do echo          %%p
echo        set VIVADO_BAT=...\vivado.bat to force one
exit /b 1

:: %1=xpr; vvgl.exe hides the console like the Start menu shortcut
:: vvgl.exe drops quoted args, so use it only when paths have no spaces
:start_vivado
for %%b in ("!VIV_BAT!") do set "VIV_VVGL=%%~dpbunwrapped\win64.o\vvgl.exe"
set "VIV_ARGS=!VIV_BAT!%~1"
if exist "!VIV_VVGL!" if "!VIV_ARGS: =!"=="!VIV_ARGS!" (
    start "" "!VIV_VVGL!" !VIV_BAT! %~1
    exit /b 0
)
start "Vivado !VIV_VER!" cmd /c ""!VIV_BAT!" "%~1""
exit /b 0