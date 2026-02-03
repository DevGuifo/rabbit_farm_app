@echo off
REM Script de lancement BunnyManager avec configuration Supabase
REM 
REM Usage: run.bat [debug|release|profile]

setlocal enabledelayedexpansion

REM Charger les variables depuis .env si le fichier existe
if exist .env (
    echo Chargement de la configuration depuis .env...
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        REM Ignorer les commentaires et lignes vides
        set "line=%%a"
        if not "!line:~0,1!"=="#" (
            if not "%%a"=="" (
                set "%%a=%%b"
            )
        )
    )
) else (
    echo [WARNING] Fichier .env non trouve. Mode offline uniquement.
    echo Creez .env a partir de .env.example pour activer Supabase.
    echo.
)

REM Mode de build (debug par defaut)
set MODE=%1
if "%MODE%"=="" set MODE=debug

REM Verifier si les variables sont definies
if defined SUPABASE_URL (
    echo Configuration Supabase detectee.
    set DART_DEFINES=--dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY%
) else (
    echo Mode offline - Supabase non configure.
    set DART_DEFINES=
)

echo.
echo Lancement de BunnyManager en mode %MODE%...
echo.

if "%MODE%"=="release" (
    flutter run --release %DART_DEFINES%
) else if "%MODE%"=="profile" (
    flutter run --profile %DART_DEFINES%
) else (
    flutter run %DART_DEFINES%
)

endlocal
