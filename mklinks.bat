@echo off
setlocal EnableDelayedExpansion
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

set "BASE=%~dp0"

echo [1/3] Processing bd...
if exist "%BASE%syn\src\bd" (
    echo   Removing existing symlink syn\src\bd
    del /F /Q "%BASE%syn\src\bd" >nul 2>&1
    rmdir "%BASE%syn\src\bd" >nul 2>&1
    if exist "%BASE%syn\src\bd" (
        echo   ERROR: Cannot remove syn\src\bd - is it a real directory?
        echo   Aborting to protect source files.
        pause
        exit /b 1
    )
)
pushd "%BASE%syn\src"
mklink /D bd ..\..\rtl\bd
popd
if errorlevel 1 echo   ERROR: Failed to create symlink bd
echo.

echo [2/3] Processing hdl...
if exist "%BASE%syn\src\hdl" (
    echo   Removing existing symlink syn\src\hdl
    del /F /Q "%BASE%syn\src\hdl" >nul 2>&1
    rmdir "%BASE%syn\src\hdl" >nul 2>&1
    if exist "%BASE%syn\src\hdl" (
        echo   ERROR: Cannot remove syn\src\hdl - is it a real directory?
        echo   Aborting to protect source files.
        pause
        exit /b 1
    )
)
pushd "%BASE%syn\src"
mklink /D hdl ..\..\rtl\hdl
popd
if errorlevel 1 echo   ERROR: Failed to create symlink hdl
echo.

echo [3/3] Processing new_v6...
if exist "%BASE%syn\src\new_v6" (
    echo   Removing existing symlink syn\src\new_v6
    del /F /Q "%BASE%syn\src\new_v6" >nul 2>&1
    rmdir "%BASE%syn\src\new_v6" >nul 2>&1
    if exist "%BASE%syn\src\new_v6" (
        echo   ERROR: Cannot remove syn\src\new_v6 - is it a real directory?
        echo   Aborting to protect source files.
        pause
        exit /b 1
    )
)
pushd "%BASE%syn\src"
mklink /D new_v6 ..\..\rtl\new_v6
popd
if errorlevel 1 echo   ERROR: Failed to create symlink new_v6
echo.

echo ========================================
echo Launching Vivado Project
echo ========================================
echo.

set /a xpr_count=0
for /r "syn" %%f in (*.xpr) do (
    set /a xpr_count+=1
    set "xpr_!xpr_count!=%%f"
    set "xpr_dir_!xpr_count!=%%~dpf"
)

if %xpr_count%==0 (
    echo WARNING: No .xpr files found under syn\
    echo.
    goto :done
)

echo Found %xpr_count% project(s):
for /L %%i in (1,1,%xpr_count%) do (
    echo   %%i. !xpr_%%i!
)
echo.

set /p choice="Select project to open [1-%xpr_count%]: "
if not defined choice goto :done
if %choice% lss 1 goto :done
if %choice% gtr %xpr_count% goto :done

set "sel_xpr=!xpr_%choice%!"
set "sel_dir=!xpr_dir_%choice%!"

echo.
echo Opening: %sel_xpr%
echo Working dir: %sel_dir%
pushd "%sel_dir%"
start "" "%sel_xpr%"
echo   Started at %date% %time%
echo.

echo Waiting for vivado.log ...
:wait_log
if not exist "vivado.log" (
    timeout /t 2 /nobreak >nul
    goto :wait_log
)
echo.
echo ========================================
echo Tailing vivado.log (Ctrl+C to exit)
echo ========================================
powershell -Command "Get-Content -Path 'vivado.log' -Wait -Tail 0"
popd

:done
echo ========================================
echo Done!
echo ========================================
dir syn\src
echo.
pause
