@echo off
setlocal EnableDelayedExpansion
title Java Version Switcher

:: ---- Needs Administrator (machine-wide variable) ----
net session >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Please run this script as Administrator.
    echo         Right-click the file and choose "Run as administrator".
    echo.
    pause
    exit /b 1
)

:: ---- Edit these paths if your versions change ----
set "BASE=C:\Program Files\Eclipse Adoptium"
set "JDK8=%BASE%\jdk-8.0.504.1-hotspot"
set "JDK17=%BASE%\jdk-17.0.21.9-hotspot"
set "JDK21=%BASE%\jdk-21.0.12.101-hotspot"

set "ENVKEY=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"

:menu
cls
echo ========================================
echo            Java Version Switcher
echo ========================================
call :getcurrent
echo   Current JAVA_HOME: !CUR!
echo ----------------------------------------
echo   1. Java 8
echo   2. Java 17
echo   3. Java 21
echo   4. Show current version (java -version)
echo   0. Exit
echo ========================================
choice /c 12340 /n /m "Enter your choice: "
set "C=%errorlevel%"
if "%C%"=="1" call :apply "%JDK8%"
if "%C%"=="2" call :apply "%JDK17%"
if "%C%"=="3" call :apply "%JDK21%"
if "%C%"=="4" goto :show
if "%C%"=="5" exit /b 0
goto :menu

:apply
set "TARGET=%~1"
if not exist "%TARGET%\bin\java.exe" (
    echo.
    echo [ERROR] java.exe not found in: %TARGET%
    pause
    goto :eof
)
echo.
echo Setting JAVA_HOME to: %TARGET%
setx JAVA_HOME "%TARGET%" /M >nul
if errorlevel 1 (
    echo [ERROR] Failed to set JAVA_HOME.
    pause
    goto :eof
)

:: Path is NOT modified by this script. Only check that it already uses JAVA_HOME.
reg query "%ENVKEY%" /v Path | find /i "%%JAVA_HOME%%\bin" >nul
if errorlevel 1 (
    echo.
    echo [WARNING] System Path does not contain %%JAVA_HOME%%\bin
    echo           Add it once: System Properties - Environment Variables - Path - New
    echo           Value: %%JAVA_HOME%%\bin   and move it to the top.
)

echo.
echo Done. Close this window and open a NEW terminal for the change to apply.
echo.
pause
goto :eof

:show
echo.
if "!CUR!"=="(not set)" (
    echo JAVA_HOME is not set.
) else (
    "!CUR!\bin\java.exe" -version
)
echo.
pause
goto :menu

:getcurrent
set "CUR=(not set)"
for /f "tokens=2,*" %%a in ('reg query "%ENVKEY%" /v JAVA_HOME 2^>nul ^| find "JAVA_HOME"') do set "CUR=%%b"
goto :eof
