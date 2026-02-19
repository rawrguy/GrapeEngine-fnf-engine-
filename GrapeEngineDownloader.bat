@echo off
setlocal enabledelayedexpansion

REM Build helper for packaging Funkin into GrapeEngine.exe on Windows.

set REPO_URL=https://github.com/FunkinCrew/Funkin
set SRC_DIR=Funkin
set DIST_DIR=dist
set OUT_EXE=GrapeEngine.exe

where git >nul 2>nul || (
  echo [ERROR] git is not installed or not in PATH.
  exit /b 1
)

where haxe >nul 2>nul || (
  echo [ERROR] haxe is not installed or not in PATH.
  exit /b 1
)

if not exist "%SRC_DIR%" (
  echo [INFO] Cloning source: %REPO_URL%
  git clone %REPO_URL% %SRC_DIR% || exit /b 1
) else (
  echo [INFO] Using existing source folder: %SRC_DIR%
)

pushd "%SRC_DIR%"

echo [INFO] Installing haxelib dependencies (if missing)...
haxelib install lime --quiet
haxelib install openfl --quiet
haxelib install hxcpp --quiet

echo [INFO] Building Windows release...
lime test windows -release || (
  popd
  echo [ERROR] Build failed.
  exit /b 1
)

set BUILT_EXE=export\release\windows\bin\Funkin.exe
if not exist "%BUILT_EXE%" (
  popd
  echo [ERROR] Expected output not found: %BUILT_EXE%
  exit /b 1
)

popd

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"
copy /Y "%SRC_DIR%\%BUILT_EXE%" "%DIST_DIR%\%OUT_EXE%" >nul || exit /b 1

echo [OK] Packaged executable: %DIST_DIR%\%OUT_EXE%
exit /b 0
