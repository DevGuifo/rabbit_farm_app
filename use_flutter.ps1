# Script pour utiliser Flutter dans cette session
# Exécutez: . .\use_flutter.ps1
# Puis vous pourrez utiliser: flutter --version, flutter run, etc.

$flutterBinPath = "C:\Users\DELL\flutter\bin"

# Ajouter au PATH de cette session
if ($env:PATH -notlike "*$flutterBinPath*") {
    $env:PATH = "$flutterBinPath;$env:PATH"
    Write-Host "Flutter a ete ajoute au PATH de cette session." -ForegroundColor Green
    Write-Host "Vous pouvez maintenant utiliser: flutter --version" -ForegroundColor Cyan
}
else {
    Write-Host "Flutter est deja dans le PATH." -ForegroundColor Green
}

# Créer une fonction Flutter pour cette session
function flutter {
    & "C:\Users\DELL\flutter\bin\flutter.bat" $args
}

Write-Host "Fonction flutter creee. Testez avec: flutter --version" -ForegroundColor Yellow
