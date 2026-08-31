@echo off
REM ============================================================
REM  VBC — VIBE Control  |  Windows Binary Installer
REM  Created by Pratham Kumar Uikey — github.com/pratham1kruk
REM
REM  Installs the compiled vbc.exe — no source code exposed,
REM  no Node.js required on the target machine. This is the
REM  Windows counterpart to vbc-install.sh (Linux/macOS).
REM
REM  Usage:
REM    vbc-install.bat
REM    vbc-install.bat --uninstall
REM    vbc-install.bat --update
REM    vbc-install.bat --help
REM ============================================================

set "VBC_VERSION=1.0.1"
set "VBC_AUTHOR=Pratham Kumar Uikey"
set "VBC_GITHUB=https://github.com/pratham1kruk"
set "VBC_INSTALL_DIR=%LOCALAPPDATA%\vbc-cli"
set "SCRIPT_DIR=%~dp0"
set "BINARY_SRC=%SCRIPT_DIR%vbc-win-x64-v%VBC_VERSION%.exe"
set "VSIX_FILE=%SCRIPT_DIR%vbc-vibe-control-0.1.0.vsix"

if /I "%~1"=="--uninstall" goto :do_uninstall
if /I "%~1"=="-u"          goto :do_uninstall
if /I "%~1"=="--update"    goto :do_update
if /I "%~1"=="-U"          goto :do_update
if /I "%~1"=="--help"      goto :do_help
if /I "%~1"=="-h"          goto :do_help
if "%~1"=="" goto :do_install
echo   Unknown option: %~1. Use --help.
exit /b 1

REM ── Shared: banner ────────────────────────────────────────────
:print_banner
echo.
echo   VV      VV BBBBBB    CCCCC
echo   VV      VV BB   BB  CC
echo    VV    VV  BBBBBB   CC
echo     VV  VV   BB   BB  CC
echo      VVVV    BBBBBB    CCCCC
echo.
echo   VIBE Control  v%VBC_VERSION%
echo   Created by %VBC_AUTHOR%  --  %VBC_GITHUB%
echo.
exit /b 0

REM ── Shared: verify the binary is sitting next to this script ──
:check_binary
if not exist "%BINARY_SRC%" (
  echo   X  Binary not found: vbc-win-x64-v%VBC_VERSION%.exe
  echo      Make sure this installer is in the same folder as the binary.
  exit /b 1
)
exit /b 0

REM ── Shared: add %VBC_INSTALL_DIR% to the User PATH and notify ─
REM   running processes of the change, mirroring exactly what
REM   vbc_installer.nsi already does via the Win32 registry +
REM   WM_SETTINGCHANGE broadcast.
:add_to_path
set "PS1=%TEMP%\vbc_addpath_%RANDOM%.ps1"
echo $dir = '%VBC_INSTALL_DIR%' > "%PS1%"
echo $p = [Environment]::GetEnvironmentVariable('PATH','User') >> "%PS1%"
echo $parts = @() >> "%PS1%"
echo if ($p) { $parts = $p.Split(';') ^| Where-Object { $_ } } >> "%PS1%"
echo if ($parts -notcontains $dir) { >> "%PS1%"
echo   $new = ($parts + $dir) -join ';' >> "%PS1%"
echo   [Environment]::SetEnvironmentVariable('PATH', $new, 'User') >> "%PS1%"
echo   Write-Host '  v  Added to User PATH' >> "%PS1%"
echo } else { Write-Host '  v  Already on PATH' } >> "%PS1%"
echo $sig = '[DllImport("user32.dll")] public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);' >> "%PS1%"
echo Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition $sig -ErrorAction SilentlyContinue >> "%PS1%"
echo $result = [UIntPtr]::Zero >> "%PS1%"
echo [Win32.NativeMethods]::SendMessageTimeout([IntPtr]0xffff, 0x1a, [UIntPtr]::Zero, 'Environment', 2, 5000, [ref]$result) ^| Out-Null >> "%PS1%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
del /Q "%PS1%" >nul 2>nul
exit /b 0

REM ── Shared: locate VS Code's CLI, same known locations vbc_installer.nsi
REM   checks, plus a PATH fallback for a "code" command already on it.
REM   Single-line IF forms only — %PROGRAMFILES(X86)% contains literal
REM   parens, which can confuse cmd.exe's paren-matching if used inside
REM   an IF ( block ) instead. ──
:find_code
set "CODE_CMD="
if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd" set "CODE_CMD=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd"
if defined CODE_CMD exit /b 0
if exist "%PROGRAMFILES%\Microsoft VS Code\bin\code.cmd" set "CODE_CMD=%PROGRAMFILES%\Microsoft VS Code\bin\code.cmd"
if defined CODE_CMD exit /b 0
if exist "%PROGRAMFILES(X86)%\Microsoft VS Code\bin\code.cmd" set "CODE_CMD=%PROGRAMFILES(X86)%\Microsoft VS Code\bin\code.cmd"
if defined CODE_CMD exit /b 0
where code >nul 2>nul
if not errorlevel 1 set "CODE_CMD=code"
exit /b 0

REM ── Install ─────────────────────────────────────────────────
:do_install
call :print_banner
echo   Installing VBC
echo   ----------------------------------------
echo.

call :check_binary
if errorlevel 1 exit /b 1

echo   -^>  Installing to %VBC_INSTALL_DIR%
if not exist "%VBC_INSTALL_DIR%" mkdir "%VBC_INSTALL_DIR%"
copy /Y "%BINARY_SRC%" "%VBC_INSTALL_DIR%\vbc.exe" >nul
echo   v  Binary installed

if exist "%VSIX_FILE%" (
  call :find_code
  if defined CODE_CMD (
    echo   -^>  Installing VS Code extension...
    "%CODE_CMD%" --install-extension "%VSIX_FILE%" >nul 2>nul
    if errorlevel 1 (
      echo   !  Extension install failed. Run manually:
      echo        code --install-extension "%VSIX_FILE%"
    ) else (
      echo   v  VS Code extension installed
    )
  ) else (
    echo   !  VS Code not found.
    echo      Install VS Code, then run: code --install-extension "%VSIX_FILE%"
  )
)

call :add_to_path

REM Write metadata
(
  echo VBC_VERSION=%VBC_VERSION%
  echo VBC_AUTHOR=%VBC_AUTHOR%
  echo VBC_GITHUB=%VBC_GITHUB%
  echo INSTALL_DIR=%VBC_INSTALL_DIR%
) > "%VBC_INSTALL_DIR%\.vbc-meta"

echo.
echo   ============================================
echo   VBC v%VBC_VERSION% installed
echo   ============================================
echo.
echo   Open a NEW terminal and run:  vbc help
echo.
echo   %VBC_AUTHOR%  --  %VBC_GITHUB%
echo.
exit /b 0

REM ── Update ──────────────────────────────────────────────────
:do_update
call :print_banner
echo   Updating VBC
echo   ----------------------------------------
echo.

call :check_binary
if errorlevel 1 exit /b 1

if not exist "%VBC_INSTALL_DIR%\vbc.exe" (
  echo   !  Not installed. Running fresh install...
  goto :do_install
)

copy /Y "%BINARY_SRC%" "%VBC_INSTALL_DIR%\vbc.exe" >nul
echo   v  Binary updated
echo.
echo   v  VBC updated to v%VBC_VERSION%
echo.
exit /b 0

REM ── Uninstall ───────────────────────────────────────────────
:do_uninstall
call :print_banner
echo   Uninstalling VBC
echo   ----------------------------------------
echo.
echo   This will remove:
echo     %VBC_INSTALL_DIR%
echo     %VBC_INSTALL_DIR% from your User PATH
echo.
set /p "CONFIRM=  Are you sure? (y/N) "
if /I not "%CONFIRM%"=="y" (
  echo   Cancelled.
  exit /b 0
)

if exist "%VBC_INSTALL_DIR%" (
  rmdir /S /Q "%VBC_INSTALL_DIR%"
  echo   v  Removed %VBC_INSTALL_DIR%
)

set "PS1=%TEMP%\vbc_rmpath_%RANDOM%.ps1"
echo $dir = '%VBC_INSTALL_DIR%' > "%PS1%"
echo $p = [Environment]::GetEnvironmentVariable('PATH','User') >> "%PS1%"
echo if ($p) { >> "%PS1%"
echo   $parts = $p.Split(';') ^| Where-Object { $_ -and $_ -ne $dir } >> "%PS1%"
echo   [Environment]::SetEnvironmentVariable('PATH', ($parts -join ';'), 'User') >> "%PS1%"
echo   Write-Host '  v  Removed from User PATH' >> "%PS1%"
echo } >> "%PS1%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
del /Q "%PS1%" >nul 2>nul

call :find_code
if defined CODE_CMD "%CODE_CMD%" --uninstall-extension vbc.vbc-vibe-control >nul 2>nul

echo.
echo   v  VBC uninstalled.
echo   Thank you for using VBC -- %VBC_AUTHOR%
echo.
exit /b 0

REM ── Help ────────────────────────────────────────────────────
:do_help
echo.
echo   VBC Windows Binary Installer  v%VBC_VERSION%
echo   %VBC_AUTHOR%  --  %VBC_GITHUB%
echo.
echo   vbc-install.bat              Install
echo   vbc-install.bat --update     Update
echo   vbc-install.bat --uninstall  Remove
echo.
exit /b 0