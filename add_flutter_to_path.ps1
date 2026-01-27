# Script pour ajouter Flutter au PATH de manière permanente
# Exécutez ce script en tant qu'administrateur ou ajoutez son contenu à votre profil PowerShell

Write-Host "Ajout de Flutter au PATH..." -ForegroundColor Yellow

$flutterPath = "C:\Users\DELL\flutter\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

if ($userPath -notlike "*$flutterPath*") {
    try {
        $newPath = if ($userPath) { "$userPath;$flutterPath" } else { $flutterPath }
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
        Write-Host "✓ Flutter a été ajouté au PATH utilisateur avec succès!" -ForegroundColor Green
        Write-Host "Veuillez redémarrer votre terminal pour que les changements prennent effet." -ForegroundColor Cyan
    }
    catch {
        Write-Host "✗ Erreur: $_" -ForegroundColor Red
        Write-Host "Essayez d'exécuter ce script en tant qu'administrateur." -ForegroundColor Yellow
    }
}
else {
    Write-Host "✓ Flutter est déjà dans le PATH utilisateur." -ForegroundColor Green
}

# Ajouter aussi pour la session actuelle
$env:PATH += ";$flutterPath"
Write-Host "✓ Flutter a été ajouté au PATH de la session actuelle." -ForegroundColor Green
