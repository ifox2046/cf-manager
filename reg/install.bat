@echo off
setlocal EnableDelayedExpansion

set "REPO=hefy2027/cf-manager"
set "RAW_URL=https://raw.githubusercontent.com/%REPO%/master/reg"
set "INSTALL_DIR=%USERPROFILE%\.cf-reg"
set "MIN_NODE_VERSION=20"

echo ==================================================
echo  Cloudflare Batch Registration Tool - Installer
echo ==================================================
echo.

REM ── 检测 Node.js ──────────────────────────────────────
echo [1/5] Checking Node.js...
where node >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js not found. Please install Node.js ^>= %MIN_NODE_VERSION%
    echo    Visit: https://nodejs.org
    pause
    exit /b 1
)

for /f "tokens=1 delims=." %%v in ('node -v') do set "NODE_VER=%%v"
set "NODE_VER=%NODE_VER:v=%"
if %NODE_VER% LSS %MIN_NODE_VERSION% (
    echo ❌ Node.js v%NODE_VER% is too old. Requires ^>= v%MIN_NODE_VERSION%
    echo    Visit: https://nodejs.org
    pause
    exit /b 1
)

echo ✅ Node.js %NODE_VER% detected

REM ── 检测 npm ───────────────────────────────────────────
echo [2/5] Checking npm...
where npm >nul 2>&1
if errorlevel 1 (
    echo ❌ npm not found. Please reinstall Node.js
    pause
    exit /b 1
)
echo ✅ npm detected

REM ── 创建安装目录 ──────────────────────────────────────
echo [3/5] Creating install directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM ── 下载文件 ───────────────────────────────────────────
echo [4/5] Downloading cf-reg...

echo    Downloading cf-reg.mjs...
powershell -Command "Invoke-WebRequest -Uri '%RAW_URL%/cf-reg.mjs' -OutFile '%INSTALL_DIR%\cf-reg.mjs'"

REM 下载 config.example.json
powershell -Command "Invoke-WebRequest -Uri '%RAW_URL%/config.example.json' -OutFile '%INSTALL_DIR%\config.json'"

echo ✅ Downloaded

REM ── 创建 cf-reg.cmd 包装器 ─────────────────────────────
echo Creating cf-reg.cmd wrapper...
(
echo @echo off
echo node "%~dp0cf-reg.mjs" %%*
) > "%INSTALL_DIR%\cf-reg.cmd"

echo ✅ Wrapper created

REM ── 安装依赖 ───────────────────────────────────────────
echo [5/5] Installing dependencies...
cd /d "%INSTALL_DIR%"
echo {"name":"cf-reg-local","version":"1.0.0","type":"module"} > package.json
call npm install --no-save cloakbrowser commander node-fetch playwright-core 2>nul
if errorlevel 1 (
    echo ⚠️  Failed to install some dependencies. Run manually:
    echo    cd %INSTALL_DIR% ^&^& npm install cloakbrowser commander node-fetch playwright-core
) else (
    echo ✅ Dependencies installed
)

REM ── 添加到 PATH ────────────────────────────────────────
echo.
echo Checking PATH...
set "CURRENT_PATH=%PATH%"
echo %CURRENT_PATH% | find /i "%INSTALL_DIR%" >nul 2>&1
if errorlevel 1 (
    setx PATH "%PATH%;%INSTALL_DIR%"
    echo ✅ Added %INSTALL_DIR% to PATH
    echo    (restart terminal to apply)
) else (
    echo ✅ Already in PATH
)

echo.
echo ==================================================
echo  Installation complete!
echo ==================================================
echo.
echo Usage:
echo   cf-reg --help
echo   cf-reg --count 5
echo.
echo Config:
echo   Edit %INSTALL_DIR%\config.json to customize settings
echo.
echo CF Manager: https://github.com/%REPO%
echo.
pause
