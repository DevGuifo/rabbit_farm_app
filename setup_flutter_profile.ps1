# Script pour configurer le profil PowerShell afin d'ajouter Flutter au PATH automatiquement
# Exécutez ce script une seule fois

$flutterPath = "C:\Users\DELL\flutter\bin"
$profilePath = $PROFILE.CurrentUserAllHosts

# Créer le répertoire du profil s'il n'existe pas
$profileDir = Split-Path -Parent $profilePath
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Vérifier si Flutter est déjà dans le profil
$profileContent = ""
if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw
}

if ($profileContent -notlike "*flutter\bin*") {
    $flutterLine = '$env:PATH += ";' + $flutterPath + '"'
    
    if ($profileContent) {
        Add-Content -Path $profilePath -Value ""
        Add-Content -Path $profilePath -Value "# Ajout de Flutter au PATH"
        Add-Content -Path $profilePath -Value $flutterLine
    }
    else {
        $content = "# Ajout de Flutter au PATH`r`n$flutterLine"
        Set-Content -Path $profilePath -Value $content
    }
    
    Write-Host "Flutter a ete ajoute a votre profil PowerShell!" -ForegroundColor Green
    Write-Host "Le PATH sera mis a jour automatiquement dans chaque nouvelle session PowerShell." -ForegroundColor Cyan
    
    # Ajouter pour la session actuelle
    $env:PATH += ";$flutterPath"
    Write-Host "Flutter est maintenant disponible dans cette session." -ForegroundColor Green
}
else {
    Write-Host "Flutter est deja configure dans votre profil PowerShell." -ForegroundColor Green
    $env:PATH += ";$flutterPath"
}

Write-Host ""
Write-Host "Testez avec: flutter --version" -ForegroundColor Yellow
