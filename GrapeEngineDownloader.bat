@echo off
setlocal enableextensions enabledelayedexpansion

REM Build helper for packaging Funkin into GrapeEngine.exe on Windows.
REM Works even when lime/openfl are not preinstalled globally.

set "DIST_DIR=dist"
set "OUT_EXE=GrapeEngine.exe"
set "REPO_URL=https://github.com/FunkinCrew/Funkin"
set "FALLBACK_SRC_DIR=Funkin"

where git >nul 2>nul || (
  echo [ERROR] git is not installed or not in PATH.
  exit /b 1
)

where haxe >nul 2>nul || (
  echo [ERROR] haxe is not installed or not in PATH.
  echo [INFO] Install Haxe first: https://haxe.org/download/
  exit /b 1
)

where haxelib >nul 2>nul || (
  echo [ERROR] haxelib is not available in PATH.
  exit /b 1
)

REM Initialize haxelib repo if first run.
haxelib config >nul 2>nul
if errorlevel 1 (
  set "HAXELIB_REPO=%USERPROFILE%\.haxelib"
  echo [INFO] Running first-time haxelib setup: !HAXELIB_REPO!
  haxelib setup "!HAXELIB_REPO!" || (
    echo [ERROR] haxelib setup failed.
    exit /b 1
  )
)

REM Prefer local source if this folder already contains a Haxe/OpenFL project.
set "SRC_DIR=%CD%"
if exist "%CD%\Project.xml" goto :have_source
if exist "%CD%\source\Main.hx" goto :have_source

REM Fall back to cloned source if current repo doesn't contain the game source.
set "SRC_DIR=%FALLBACK_SRC_DIR%"
if not exist "%SRC_DIR%" (
  echo [INFO] No local project detected. Cloning source: %REPO_URL%
  git clone %REPO_URL% "%SRC_DIR%" || exit /b 1
) else (
  echo [INFO] Using existing source folder: %SRC_DIR%
)

:have_source
pushd "%SRC_DIR%" || (
  echo [ERROR] Could not enter source directory: %SRC_DIR%
  exit /b 1
)

if not exist "Project.xml" (
  echo [ERROR] Project.xml not found in "%CD%".
  echo [INFO] Put this script in the root of the Funkin source repo, or keep cloned folder "%FALLBACK_SRC_DIR%".
  popd
  exit /b 1
)

echo [INFO] Installing/repairing Haxe dependencies...
haxelib install lime --quiet
haxelib install openfl --quiet
haxelib install hxcpp --quiet

REM Use haxelib run so this works even when lime/openfl are not on PATH.
echo [INFO] Running lime/openfl setup...
haxelib run lime setup -y >nul 2>nul
haxelib run openfl setup -y >nul 2>nul

echo [INFO] Building Windows release...
haxelib run lime build windows -release || (
  echo [ERROR] Build failed.
  popd
  exit /b 1
)

set "BUILT_EXE=export\release\windows\bin\Funkin.exe"
if not exist "%BUILT_EXE%" (
  echo [ERROR] Expected output not found: %CD%\%BUILT_EXE%
  popd
  exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"
copy /Y "%BUILT_EXE%" "%DIST_DIR%\%OUT_EXE%" >nul || (
  echo [ERROR] Failed to copy exe to %DIST_DIR%\%OUT_EXE%
  popd
  exit /b 1
)

popd

echo [OK] Packaged executable: %SRC_DIR%\%DIST_DIR%\%OUT_EXE%
exit /b 0
