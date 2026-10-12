@echo off
setlocal enabledelayedexpansion

REM ================================================
REM Anclar rutas a la ubicación de este script
REM para poder ejecutarlo desde cualquier carpeta.
REM %~dp0   = carpeta del .bat (build\win\) con barra final
REM %%~fI   = normaliza a ruta absoluta sin ".."
REM La raíz del proyecto está dos niveles arriba (build\win).
REM ================================================
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "ROOT_DIR=%%~fI"

REM ================================================
REM Cambiar página de códigos a UTF‑8 para acentos
REM ================================================

REM ================================================
REM Función de ayuda
REM ================================================
if "%1"=="--help" (
    echo Uso:
    echo   build.bat PROXYLESS=N HTTP_PROXY=http://1.1.1.1:80 HTTPS_PROXY=http://1.1.1.1:80
    echo.
    echo Argumentos disponibles:
    echo   PROXYLESS=N     Desactiva proxy si es N ^(no sensible a mayúsculas^)
    echo   HTTP_PROXY=     Proxy HTTP para el build
    echo   HTTPS_PROXY=    Proxy HTTPS para el build
    echo.
    echo Ejemplos:
    echo   build.bat
    echo   build.bat PROXYLESS=N HTTP_PROXY=http://10.0.0.1:8080 HTTPS_PROXY=http://10.0.0.1:8080
    exit /b 0
)

REM ================================================
REM 1. Leer versión
REM ================================================
set VERSION_FILE=%ROOT_DIR%\version\version.txt

if not exist "%VERSION_FILE%" (
    echo ERROR: No existe el archivo de versión: %VERSION_FILE%
    exit /b 1
)

for /f "usebackq delims=" %%v in ("%VERSION_FILE%") do (
    set VERSION=%%v
)

REM ================================================
REM 2. Valores por defecto
REM ================================================
set PROXYLESS=N
set HTTP_PROXY=http://1.1.1.1:80
set HTTPS_PROXY=http://1.1.1.1:80

REM ================================================
REM 3. Procesar argumentos clave=valor
REM ================================================
:parse
if "%~1"=="" goto :endparse
if /i "%~1"=="PROXYLESS" (
    set "PROXYLESS=%~2"
) else if /i "%~1"=="HTTP_PROXY" (
    set "HTTP_PROXY=%~2"
) else if /i "%~1"=="HTTPS_PROXY" (
    set "HTTPS_PROXY=%~2"
) else (
    echo Parametro desconocido: %~1
    exit /b 1
)
echo Procesando argumento: %~1 = %~2
shift
shift
goto :parse
:endparse

REM ================================================
REM 4. Validación sintáctica
REM ================================================
set LOWER=%PROXYLESS%
set LOWER=%LOWER:Y=y%
set LOWER=%LOWER:N=n%

if not "%LOWER%"=="y" if not "%LOWER%"=="n" (
    echo ERROR: PROXYLESS debe ser Y o N
    exit /b 1
)

echo ================================================
echo VERSION: %VERSION%
echo PROXYLESS: %PROXYLESS%
echo HTTP_PROXY: %HTTP_PROXY%
echo HTTPS_PROXY: %HTTPS_PROXY%
echo ================================================

REM ================================================
REM 5. Ejecutar docker build
REM ================================================
echo Ejecutando docker build...
rem echo docker build --build-arg PROXYLESS=%PROXYLESS% --build-arg HTTP_PROXY=%HTTP_PROXY% --build-arg HTTPS_PROXY=%HTTPS_PROXY% -t ogdivan/appmin-py:%VERSION% "%ROOT_DIR%"

docker build --build-arg PROXYLESS=%PROXYLESS% --build-arg HTTP_PROXY=%HTTP_PROXY% --build-arg HTTPS_PROXY=%HTTPS_PROXY% -t ogdivan/appmin-py:%VERSION% "%ROOT_DIR%"

REM Verificar código de salida
if %ERRORLEVEL%==0 (
    echo Build completado exitosamente.
) else (
    echo Build fallo.
    exit /b 1
)
