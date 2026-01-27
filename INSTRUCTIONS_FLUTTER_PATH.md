# Instructions pour configurer Flutter dans le PATH

Flutter est installé dans `C:\Users\DELL\flutter\bin` mais n'est pas encore dans votre PATH système.

## Solution rapide (temporaire)

Pour cette session PowerShell uniquement, exécutez :
```powershell
$env:PATH += ";C:\Users\DELL\flutter\bin"
```

## Solution permanente

### Option 1 : Via l'interface Windows (Recommandé)

1. Appuyez sur `Win + X` et sélectionnez **"Système"**
2. Cliquez sur **"Paramètres système avancés"** (ou recherchez "variables d'environnement")
3. Cliquez sur **"Variables d'environnement"**
4. Dans la section **"Variables utilisateur"**, sélectionnez **"Path"** et cliquez sur **"Modifier"**
5. Cliquez sur **"Nouveau"** et ajoutez : `C:\Users\DELL\flutter\bin`
6. Cliquez sur **"OK"** pour fermer toutes les fenêtres
7. **Fermez et rouvrez** votre terminal/PowerShell
8. Testez avec : `flutter --version`

### Option 2 : Via PowerShell (en tant qu'administrateur)

Ouvrez PowerShell **en tant qu'administrateur** et exécutez :

```powershell
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";C:\Users\DELL\flutter\bin", [EnvironmentVariableTarget]::User)
```

Puis fermez et rouvrez votre terminal.

### Option 3 : Utiliser les scripts créés (Recommandé pour usage immédiat)

**Option 3a : Script d'initialisation (le plus simple)**
```powershell
. .\init_flutter.ps1
flutter --version
flutter run
```

**Option 3b : Wrapper PowerShell**
```powershell
.\flutter_wrapper.ps1 --version
.\flutter_wrapper.ps1 run
```

**Option 3c : Script batch**
```powershell
.\flutter.bat --version
.\flutter.bat run
```

## Vérification

Après avoir configuré le PATH, testez avec :
```powershell
flutter --version
flutter doctor
```
