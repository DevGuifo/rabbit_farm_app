# Script d'initialisation Flutter pour PowerShell
# Chargez ce script dans votre session avec: . .\init_flutter.ps1
# Puis utilisez: flutter --version, flutter run, etc.

$flutterPath = "C:\Users\DELL\flutter\bin"

# Ajouter au PATH de cette session
if ($env:PATH -notlike "*$flutterPath*") {
    $env:PATH = "$flutterPath;$env:PATH"
}

# Créer une fonction Flutter
function flutter {
    param([Parameter(ValueFromRemainingArguments=$true)]$arguments)
    & "$flutterPath\flutter.bat" $arguments
}

Write-Host "Flutter est maintenant disponible dans cette session!" -ForegroundColor Green
Write-Host "Testez avec: flutter --version" -ForegroundColor Cyan
