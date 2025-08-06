@echo off
setlocal enabledelayedexpansion

REM === Set version requirements here ===
set MIN_PYTHON_VERSION=3.12
set EXACT_PYTHON_VERSION=
REM Set EXACT_PYTHON_VERSION to empty string if exact version is not required
REM Example: set EXACT_PYTHON_VERSION=
REM =========================================

echo Checking for Python installations on this Windows machine...
echo.

REM Initialize variables
set PYTHON_VERSIONS_FOUND=0
set BEST_PYTHON_VERSION=
set BEST_PYTHON_PATH=

REM Check Python installations from PATH
echo [INFO] Checking Python installations in PATH...
where python >nul 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "delims=" %%i in ('where python') do (
        call :check_python_version "%%i"
    )
)

where python3 >nul 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "delims=" %%i in ('where python3') do (
        call :check_python_version "%%i"
    )
)

REM Check Python installations in Program Files
echo [INFO] Checking Python installations in Program Files...
if exist "C:\Program Files\Python*" (
    for /d %%i in ("C:\Program Files\Python*") do (
        if exist "%%i\python.exe" (
            call :check_python_version "%%i\python.exe"
        )
    )
)

if exist "C:\Program Files (x86)\Python*" (
    for /d %%i in ("C:\Program Files (x86)\Python*") do (
        if exist "%%i\python.exe" (
            call :check_python_version "%%i\python.exe"
        )
    )
)

REM Check Python installations in user directory
echo [INFO] Checking Python installations in user directory...
if exist "%USERPROFILE%\AppData\Local\Programs\Python*" (
    for /d %%i in ("%USERPROFILE%\AppData\Local\Programs\Python*") do (
        if exist "%%i\python.exe" (
            call :check_python_version "%%i\python.exe"
        )
    )
)

REM Check Windows Registry for Python installations
echo [INFO] Checking Windows Registry for Python installations...
for /f "tokens=2 delims= " %%i in ('reg query "HKLM\SOFTWARE\Python\PythonCore" /s /f "InstallPath" 2^>nul ^| findstr "InstallPath"') do (
    if exist "%%i\python.exe" (
        call :check_python_version "%%i\python.exe"
    )
)

for /f "tokens=2 delims= " %%i in ('reg query "HKCU\SOFTWARE\Python\PythonCore" /s /f "InstallPath" 2^>nul ^| findstr "InstallPath"') do (
    if exist "%%i\python.exe" (
        call :check_python_version "%%i\python.exe"
    )
)

REM Check for Python Launcher installations
echo [INFO] Checking Python Launcher installations...
if exist "C:\Windows\py.exe" (
    echo [FOUND] Python Launcher found at C:\Windows\py.exe
    echo [INFO] Available Python versions via launcher:
    C:\Windows\py.exe --list 2>nul
    echo.
)

REM Summary
echo ========================================
echo SUMMARY OF PYTHON INSTALLATIONS
echo ========================================
if !PYTHON_VERSIONS_FOUND! equ 0 (
    echo [ERROR] No Python installations found on this machine.
    echo [INFO] Please install Python %MIN_PYTHON_VERSION% or higher from https://www.python.org/downloads/
    exit /b 1
) else (
    echo [INFO] Found !PYTHON_VERSIONS_FOUND! Python installation(s)
    if defined BEST_PYTHON_VERSION (
        echo [BEST] Recommended Python version: !BEST_PYTHON_VERSION! at !BEST_PYTHON_PATH!
    )
)

REM Validate version requirements
if defined BEST_PYTHON_VERSION (
    echo.
    echo ========================================
    echo VERSION VERIFICATION
    echo ========================================

    REM Check minimum version requirement
    for /f "tokens=1,2 delims=." %%a in ("!BEST_PYTHON_VERSION!") do (
        set PY_MAJOR=%%a
        set PY_MINOR=%%b
    )
    for /f "tokens=1,2 delims=." %%a in ("%MIN_PYTHON_VERSION%") do (
        set MIN_PY_MAJOR=%%a
        set MIN_PY_MINOR=%%b
    )
    if !PY_MAJOR!.!PY_MINOR! LSS !MIN_PY_MAJOR!.!MIN_PY_MINOR! (
        echo [WARNING] Best Python version !BEST_PYTHON_VERSION! is below minimum required %MIN_PYTHON_VERSION%.x
        echo [INFO] Consider upgrading to Python %MIN_PYTHON_VERSION% or higher for optimal compatibility.
        exit /b 1
    ) else (
        echo [OK] Best Python version !BEST_PYTHON_VERSION! meets minimum requirement of %MIN_PYTHON_VERSION%.x
    )

    REM Check exact version requirement if specified
    if defined EXACT_PYTHON_VERSION (
        if not "!EXACT_PYTHON_VERSION!"=="" (
            echo.
            echo [INFO] Checking for exact Python version: %EXACT_PYTHON_VERSION%

            REM Check if exact version is found among all installations
            set EXACT_VERSION_FOUND=0
            set EXACT_VERSION_PATH=

            REM Search through all found Python installations for exact version
            for /f "tokens=2 delims= " %%i in ('where python 2^>nul') do (
                call :check_exact_version "%%i"
            )
            for /f "tokens=2 delims= " %%i in ('where python3 2^>nul') do (
                call :check_exact_version "%%i"
            )

            REM Check Program Files
            if exist "C:\Program Files\Python*" (
                for /d %%i in ("C:\Program Files\Python*") do (
                    if exist "%%i\python.exe" (
                        call :check_exact_version "%%i\python.exe"
                    )
                )
            )
            if exist "C:\Program Files (x86)\Python*" (
                for /d %%i in ("C:\Program Files (x86)\Python*") do (
                    if exist "%%i\python.exe" (
                        call :check_exact_version "%%i\python.exe"
                    )
                )
            )

            REM Check user directory
            if exist "%USERPROFILE%\AppData\Local\Programs\Python*" (
                for /d %%i in ("%USERPROFILE%\AppData\Local\Programs\Python*") do (
                    if exist "%%i\python.exe" (
                        call :check_exact_version "%%i\python.exe"
                    )
                )
            )

            REM Check registry
            for /f "tokens=2 delims= " %%i in ('reg query "HKLM\SOFTWARE\Python\PythonCore" /s /f "InstallPath" 2^>nul ^| findstr "InstallPath"') do (
                if exist "%%i\python.exe" (
                    call :check_exact_version "%%i\python.exe"
                )
            )
            for /f "tokens=2 delims= " %%i in ('reg query "HKCU\SOFTWARE\Python\PythonCore" /s /f "InstallPath" 2^>nul ^| findstr "InstallPath"') do (
                if exist "%%i\python.exe" (
                    call :check_exact_version "%%i\python.exe"
                )
            )

            if !EXACT_VERSION_FOUND! equ 0 (
                echo [ERROR] Exact Python version %EXACT_PYTHON_VERSION% not found on this machine.
                echo [INFO] Found versions: !BEST_PYTHON_VERSION! (recommended)
                echo [INFO] Please install Python %EXACT_PYTHON_VERSION% for exact compatibility.
                echo [INFO] Download from: https://www.python.org/downloads/release/python-%EXACT_PYTHON_VERSION:.=%-/
                exit /b 1
            ) else (
                echo [OK] Exact Python version %EXACT_PYTHON_VERSION% found at !EXACT_VERSION_PATH!
                echo [INFO] Using exact version for optimal compatibility.
            )
        )
    )
)

echo.
echo All Python installations have been checked.
exit /b 0

REM Function to check Python version at a specific path
:check_python_version
set PYTHON_PATH=%~1
if not exist !PYTHON_PATH! goto :eof

REM Get Python version
for /f "tokens=2 delims= " %%v in ('"!PYTHON_PATH!" --version 2^>nul') do set PY_VER=%%v
if "!PY_VER!"=="" goto :eof

REM Extract major and minor version
for /f "tokens=1,2 delims=." %%a in ("!PY_VER!") do (
    set PY_MAJOR=%%a
    set PY_MINOR=%%b
)

REM Skip if version extraction failed
if "!PY_MAJOR!"=="" goto :eof

set /a PYTHON_VERSIONS_FOUND+=1
echo [FOUND] Python !PY_VER! at !PYTHON_PATH!

REM Check if this is the best version (highest that meets minimum requirement)
for /f "tokens=1,2 delims=." %%a in ("%MIN_PYTHON_VERSION%") do (
    set MIN_PY_MAJOR=%%a
    set MIN_PY_MINOR=%%b
)

if !PY_MAJOR!.!PY_MINOR! geq !MIN_PY_MAJOR!.!MIN_PY_MINOR! (
    if not defined BEST_PYTHON_VERSION (
        set BEST_PYTHON_VERSION=!PY_VER!
        set BEST_PYTHON_PATH=!PYTHON_PATH!
    ) else (
        REM Compare with current best version
        for /f "tokens=1,2 delims=." %%a in ("!BEST_PYTHON_VERSION!") do (
            set BEST_PY_MAJOR=%%a
            set BEST_PY_MINOR=%%b
        )
        if !PY_MAJOR! gtr !BEST_PY_MAJOR! (
            set BEST_PYTHON_VERSION=!PY_VER!
            set BEST_PYTHON_PATH=!PYTHON_PATH!
        ) else if !PY_MAJOR! equ !BEST_PY_MAJOR! (
            if !PY_MINOR! gtr !BEST_PY_MINOR! (
                set BEST_PYTHON_VERSION=!PY_VER!
                set BEST_PYTHON_PATH=!PYTHON_PATH!
            )
        )
    )
)

goto :eof

REM Function to check for exact Python version at a specific path
:check_exact_version
set PYTHON_PATH=%~1
if not exist !PYTHON_PATH! goto :eof

REM Get Python version
for /f "tokens=2 delims= " %%v in ('"!PYTHON_PATH!" --version 2^>nul') do set PY_VER=%%v
if "!PY_VER!"=="" goto :eof

REM Check if this is the exact version we're looking for
if "!PY_VER!"=="%EXACT_PYTHON_VERSION%" (
    set EXACT_VERSION_FOUND=1
    set EXACT_VERSION_PATH=!PYTHON_PATH!
    echo [FOUND] Exact version %EXACT_PYTHON_VERSION% at !PYTHON_PATH!
)

goto :eof