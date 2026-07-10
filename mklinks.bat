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

echo [1/3] Processing bd...
if exist "syn\src\bd" (
    echo   Deleting existing syn\src\bd
    del /F /Q "syn\src\bd" >nul 2>&1
    rmdir /S /Q "syn\src\bd" >nul 2>&1
)
pushd syn\src
mklink /D bd ..\..\rtl\bd
popd
echo.

echo [2/3] Processing hdl...
if exist "syn\src\hdl" (
    echo   Deleting existing syn\src\hdl
    del /F /Q "syn\src\hdl" >nul 2>&1
    rmdir /S /Q "syn\src\hdl" >nul 2>&1
)
pushd syn\src
mklink /D hdl ..\..\rtl\hdl
popd
echo.

echo [3/3] Processing new_v6...
if exist "syn\src\new_v6" (
    echo   Deleting existing syn\src\new_v6
    del /F /Q "syn\src\new_v6" >nul 2>&1
    rmdir /S /Q "syn\src\new_v6" >nul 2>&1
)
pushd syn\src
mklink /D new_v6 ..\..\rtl\new_v6
popd
echo.

echo ========================================
echo Done! Results:
echo ========================================
dir syn\src
echo.
pause
