# 🏠 Issue #001 : Tableau de bord "Aujourd'hui" - Objectif Zéro Papier

**Statut :** 📝 À faire  
**Priorité :** 🔥 P0 - Critique  
**Durée estimée :** 3 jours  
**Date de création :** 13 novembre 2025  

---

## 🎯 Objectif

Créer un **Tableau de bord "Aujourd'hui"** comme écran d'accueil principal qui **élimine totalement la paperasse** en remplaçant :

❌ **Paperasse à éliminer :**
- Cahiers d'accouplement manuscrits
- Carnets de santé papier avec dates de vaccination
- Feuilles de planning des palpations/naissances
- Post-it de rappel collés partout
- Registres de naissances et portées
- Agendas papier pour le suivi quotidien

✅ **Solution digitale :**
- **Tout centralisé** dans l'écran d'accueil
- **Notifications automatiques** pour les tâches critiques
- **Vue d'ensemble instantanée** du cheptel
- **Accès rapide** aux fonctions courantes
- **Historique consultable** sans fouiller dans les papiers

---

## 📋 Spécifications fonctionnelles

### 1. Nouvel écran `DashboardScreen`

**Sections du tableau de bord :**

#### 🚨 Section 1 : Alertes urgentes (priorité haute)
- **Mise bas imminente** (dans les 3 prochains jours)
  - Nom de la femelle
  - Date prévue de mise bas
  - Temps restant (ex: "Demain", "Dans 2 jours")
  - Bouton rapide "Préparer le nid"
  
- **Vaccinations en retard** (date dépassée)
  - Nom du lapin
  - Type de vaccin
  - Jours de retard
  - Bouton rapide "Marquer comme fait"

#### ⏰ Section 2 : Tâches du jour (priorité normale)
- **Palpations à effectuer** (10-12 jours post-accouplement)
  - Nom de la femelle
  - Date de l'accouplement
  - Bouton rapide "Enregistrer palpation"
  
- **Pesées à faire** (lapereaux < 8 semaines)
  - Nom de la portée/mère
  - Nombre de lapereaux
  - Âge actuel
  - Bouton rapide "Peser les lapereaux"
  
- **Sevrages prévus** (5-6 semaines d'âge)
  - Nom de la portée
  - Date de sevrage recommandée
  - Nombre de lapereaux
  - Bouton rapide "Effectuer le sevrage"

#### 📊 Section 3 : Vue d'ensemble du cheptel
- **Statistiques rapides** (cards avec icônes)
  - 🐰 Nombre total de lapins
  - ♂️ Nombre de reproducteurs mâles
  - ♀️ Nombre de reproductrices femelles
  - 🤰 Femelles gestantes actuellement
  - 🍼 Lapereaux en cours de sevrage
  - 💀 Rappel : dernier décès (si < 7 jours)

#### 🎯 Section 4 : Accès rapides (boutons d'action)
- ➕ **Ajouter un lapin**
- ❤️ **Planifier un accouplement**
- 💉 **Enregistrer un soin**
- 📸 **Ajouter une pesée**
- 📊 **Voir tous les rapports**

---

## 🔧 Modifications techniques à effectuer

### Étape 1 : Créer le nouveau fichier `dashboard_screen.dart`

**Fichier :** `lib/screens/dashboard/dashboard_screen.dart`

**Structure du widget :**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/sante_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  Future<void> _chargerDonnees() async {
    // Rafraîchir les données des providers
    await context.read<LapinProvider>().chargerLapins();
    await context.read<ReproductionProvider>().chargerAccouplements();
    await context.read<SanteProvider>().chargerSoins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tableau de bord'),
            Text(
              _obtenirDateDuJour(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          // Icône paramètres déplacée ici
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParametresScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _chargerDonnees,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🚨 Section Alertes urgentes
            _buildSectionTitle(
              context,
              '🚨 Urgent',
              Colors.red,
            ),
            _buildAlertesUrgentes(),
            const SizedBox(height: 24),

            // ⏰ Section Tâches du jour
            _buildSectionTitle(
              context,
              '⏰ Aujourd\'hui',
              Colors.orange,
            ),
            _buildTachesDuJour(),
            const SizedBox(height: 24),

            // 📊 Section Vue d'ensemble
            _buildSectionTitle(
              context,
              '📊 Mon cheptel',
              Colors.blue,
            ),
            _buildVueEnsemble(),
            const SizedBox(height: 24),

            // 🎯 Section Accès rapides
            _buildSectionTitle(
              context,
              '🎯 Actions rapides',
              Colors.green,
            ),
            _buildAccesRapides(),
          ],
        ),
      ),
    );
  }

  // Méthodes de construction des sections (à implémenter)
  Widget _buildAlertesUrgentes() { /* TODO */ }
  Widget _buildTachesDuJour() { /* TODO */ }
  Widget _buildVueEnsemble() { /* TODO */ }
  Widget _buildAccesRapides() { /* TODO */ }
  
  String _obtenirDateDuJour() {
    // Format: "Mercredi 13 novembre 2025"
    return DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(DateTime.now());
  }
}
```

### Étape 2 : Modifier `home_screen.dart`

**Changement de navigation :**

**Avant (5 onglets) :**
```dart
final List<Widget> _screens = const [
  CheptelScreen(),
  ReproductionScreen(),
  SanteScreen(),
  FinanceScreen(),
  ParametresScreen(), // ← À retirer
];
```

**Après (5 onglets avec Dashboard) :**
```dart
final List<Widget> _screens = const [
  DashboardScreen(),     // 🏠 NOUVEAU
  CheptelScreen(),       // 🐰
  ReproductionScreen(),  // ❤️
  SanteScreen(),         // 💉
  FinanceScreen(),       // 💰
];
```

**Nouvelle BottomNavigationBar :**
```dart
destinations: const [
  NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    selectedIcon: Icon(Icons.dashboard),
    label: 'Tableau de bord',
  ),
  NavigationDestination(
    icon: Icon(Icons.pets),
    selectedIcon: Icon(Icons.pets),
    label: 'Cheptel',
  ),
  NavigationDestination(
    icon: Icon(Icons.favorite_border),
    selectedIcon: Icon(Icons.favorite),
    label: 'Reproduction',
  ),
  NavigationDestination(
    icon: Icon(Icons.health_and_safety_outlined),
    selectedIcon: Icon(Icons.health_and_safety),
    label: 'Santé',
  ),
  NavigationDestination(
    icon: Icon(Icons.account_balance_wallet_outlined),
    selectedIcon: Icon(Icons.account_balance_wallet),
    label: 'Finances',
  ),
],
```

**⚠️ Important :** Supprimer l'onglet "Paramètres" de la barre de navigation. Les paramètres seront accessibles via l'icône ⚙️ en haut à droite du tableau de bord.

### Étape 3 : Ajouter un Splash Screen avec le logo

**Fichier :** `lib/screens/splash_screen.dart`

```dart
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de l'application
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            const Text(
              'Mon Élevage Lapins',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Zéro papier, 100% digital',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Modifier `main.dart` :**
```dart
// Dans MaterialApp
home: const SplashScreen(), // Au lieu de HomeScreen()
```

### Étape 4 : Utiliser les assets existants

**Assets disponibles :**
- `assets/icons/icon.png` - Icône de l'application
- `assets/icons/logscreen.png` - Logo pour splash screen
- `assets/images/logo.png` - Logo principal
- `assets/images/banier.png` - Bannière
- `assets/images/logscreem.png` - Autre logo

**Utilisation dans le code :**
```dart
// Dans le splash screen
Image.asset('assets/images/logo.png', width: 150)

// Dans le dashboard (en-tête optionnel)
Image.asset('assets/images/banier.png', fit: BoxFit.cover)

// Dans l'AppBar (optionnel)
leading: Image.asset('assets/icons/icon.png', width: 32)
```

---

## 📊 Données à calculer automatiquement

### Logique métier pour le Dashboard

#### 1. Alertes urgentes

**Mise bas imminente :**
```dart
List<Accouplement> getMisesBasImminentes() {
  final maintenant = DateTime.now();
  return accouplements.where((acc) {
    if (acc.dateMiseBasPrevue == null) return false;
    final joursRestants = acc.dateMiseBasPrevue!.difference(maintenant).inDays;
    return joursRestants >= 0 && joursRestants <= 3;
  }).toList();
}
```

**Vaccinations en retard :**
```dart
List<Soin> getVaccinationsEnRetard() {
  final maintenant = DateTime.now();
  return soins.where((soin) {
    if (soin.type != 'Vaccination') return false;
    if (soin.dateRappel == null) return false;
    return soin.dateRappel!.isBefore(maintenant);
  }).toList();
}
```

#### 2. Tâches du jour

**Palpations à effectuer :**
```dart
List<Accouplement> getPalpationsAFaire() {
  final maintenant = DateTime.now();
  return accouplements.where((acc) {
    if (acc.palpationEffectuee == true) return false;
    final joursDepuisAccouplement = maintenant.difference(acc.dateAccouplement).inDays;
    return joursDepuisAccouplement >= 10 && joursDepuisAccouplement <= 12;
  }).toList();
}
```

**Pesées à faire (lapereaux < 8 semaines) :**
```dart
List<Portee> getPeseesAFaire() {
  final maintenant = DateTime.now();
  return portees.where((portee) {
    if (portee.dateSevrage != null) return false; // Déjà sevrés
    final ageEnSemaines = maintenant.difference(portee.dateNaissance).inDays ~/ 7;
    return ageEnSemaines < 8;
  }).toList();
}
```

**Sevrages prévus (5-6 semaines) :**
```dart
List<Portee> getSevragePrevus() {
  final maintenant = DateTime.now();
  return portees.where((portee) {
    if (portee.dateSevrage != null) return false; // Déjà sevré
    final ageEnSemaines = maintenant.difference(portee.dateNaissance).inDays ~/ 7;
    return ageEnSemaines >= 5 && ageEnSemaines <= 6;
  }).toList();
}
```

#### 3. Statistiques du cheptel

```dart
Map<String, int> getStatistiquesCheptel() {
  final lapins = Provider.of<LapinProvider>(context, listen: false).lapins;
  
  return {
    'total': lapins.length,
    'males': lapins.where((l) => l.sexe == 'Mâle' && l.statut == 'Reproducteur').length,
    'femelles': lapins.where((l) => l.sexe == 'Femelle' && l.statut == 'Reproducteur').length,
    'gestantes': accouplements.where((a) => a.resultat == 'Gestation confirmée').length,
    'lapereauxSevrage': portees.where((p) => p.dateSevrage == null && p.nombreVivants > 0).length,
  };
}
```

---

## 🎨 Design UI/UX

### Wireframe du Dashboard

```
┌─────────────────────────────────────┐
│ 🏠 Tableau de bord          ⚙️       │
│ Mercredi 13 novembre 2025           │
├─────────────────────────────────────┤
│                                     │
│ 🚨 URGENT                           │
│ ┌─────────────────────────────────┐ │
│ │ 🐰 Caramel - Mise bas demain    │ │
│ │ ⏰ 31 jours de gestation         │ │
│ │ [Préparer le nid] ──────────────►│ │
│ └─────────────────────────────────┘ │
│                                     │
│ ⏰ AUJOURD'HUI                       │
│ ┌─────────────────────────────────┐ │
│ │ 🔎 Palpation Noisette (J+11)    │ │
│ │ [Enregistrer] ──────────────────►│ │
│ ├─────────────────────────────────┤ │
│ │ ⚖️ Peser portée Flocon (3 sem.) │ │
│ │ 8 lapereaux                      │ │
│ │ [Peser] ────────────────────────►│ │
│ └─────────────────────────────────┘ │
│                                     │
│ 📊 MON CHEPTEL                      │
│ ┌───────┬───────┬───────┬─────────┐│
│ │ 🐰 6  │ ♂️ 2  │ ♀️ 3  │ 🤰 1    ││
│ │Lapins │Mâles  │Femelles│Gestantes││
│ └───────┴───────┴───────┴─────────┘│
│                                     │
│ 🎯 ACTIONS RAPIDES                  │
│ ┌───────────┬───────────┬─────────┐│
│ │➕ Lapin   │❤️ Accoupl │💉 Soin  ││
│ └───────────┴───────────┴─────────┘│
│                                     │
└─────────────────────────────────────┘
🏠 ───── 🐰 ───── ❤️ ───── 💉 ───── 💰
```

### Palette de couleurs

**Alertes urgentes :**
- Fond : `Colors.red[50]`
- Bordure : `Colors.red[300]`
- Icône : `Colors.red[700]`

**Tâches du jour :**
- Fond : `Colors.orange[50]`
- Bordure : `Colors.orange[300]`
- Icône : `Colors.orange[700]`

**Vue d'ensemble :**
- Fond : `Colors.blue[50]`
- Bordure : `Colors.blue[300]`
- Icône : `Colors.blue[700]`

**Actions rapides :**
- Fond : `Colors.green[50]`
- Bordure : `Colors.green[300]`
- Icône : `Colors.green[700]`

---

## ✅ Checklist d'implémentation

### Phase 1 : Structure de base (Jour 1)
- [ ] Créer `lib/screens/dashboard/dashboard_screen.dart`
- [ ] Créer `lib/screens/splash_screen.dart`
- [ ] Modifier `lib/screens/home_screen.dart` (nouvelle navigation)
- [ ] Modifier `lib/main.dart` (ajouter SplashScreen)
- [ ] Retirer l'onglet "Paramètres" de la BottomNavigationBar
- [ ] Ajouter icône ⚙️ dans l'AppBar du Dashboard

### Phase 2 : Logique métier (Jour 2)
- [ ] Ajouter méthodes dans `ReproductionProvider` :
  - `getMisesBasImminentes()`
  - `getPalpationsAFaire()`
  - `getSevragePrevus()`
- [ ] Ajouter méthodes dans `SanteProvider` :
  - `getVaccinationsEnRetard()`
  - `getPeseesAFaire()`
- [ ] Ajouter méthode dans `LapinProvider` :
  - `getStatistiquesCheptel()`
- [ ] Implémenter le calcul de la date du jour formatée

### Phase 3 : Interface utilisateur (Jour 3)
- [ ] Implémenter `_buildAlertesUrgentes()` :
  - Widget pour mises bas imminentes
  - Widget pour vaccinations en retard
  - Boutons d'action rapide
- [ ] Implémenter `_buildTachesDuJour()` :
  - Widget pour palpations
  - Widget pour pesées
  - Widget pour sevrages
- [ ] Implémenter `_buildVueEnsemble()` :
  - Cards avec statistiques (Grid 2x2 ou 2x3)
  - Icônes et chiffres clés
- [ ] Implémenter `_buildAccesRapides()` :
  - Boutons d'action avec navigation
  - Icônes personnalisées
- [ ] Ajouter RefreshIndicator (pull-to-refresh)
- [ ] Tester le SplashScreen avec le logo

### Phase 4 : Tests et polish (Jour 3)
- [ ] Tester avec données de test
- [ ] Tester cas sans données (état vide)
- [ ] Vérifier les performances (chargement < 1s)
- [ ] Vérifier le design responsive (tablette)
- [ ] Tester la navigation vers les autres écrans
- [ ] Vérifier l'accès aux Paramètres depuis l'icône ⚙️

---

## 📸 Résultat attendu

**Avant (situation actuelle) :**
- 📋 Cahier papier avec dates d'accouplement
- 📅 Calendrier mural avec post-it de rappel
- 📒 Carnet de santé papier
- 📝 Feuilles volantes pour les portées
- ⏰ Alarmes téléphone non reliées aux données

**Après (avec le Dashboard) :**
- ✅ **Écran d'accueil intelligent** qui remplace TOUT le papier
- ✅ **Alertes automatiques** calculées depuis la BDD
- ✅ **Notifications locales** pour ne rien oublier
- ✅ **Actions rapides** sans chercher dans les menus
- ✅ **Vue temps réel** du cheptel sans compter manuellement
- ✅ **Objectif zéro papier atteint** 🎯

---

## 🚀 Impact métier

### Temps gagné par jour
- ❌ **Avant :** 20-30 min de vérification manuelle des cahiers
- ✅ **Après :** 2-3 min sur le Dashboard (gain de 90%)

### Erreurs évitées
- Oubli de palpation → détection précoce de gestation ratée
- Retard de vaccination → risque sanitaire réduit
- Mise bas surprise → préparation du nid à temps
- Sevrage trop précoce/tardif → optimisation de la croissance

### Valeur ajoutée
- **Professionnalisation** de l'élevage
- **Traçabilité complète** sans paperasse
- **Anticipation** grâce aux calculs automatiques
- **Conformité** réglementaire (registre numérique)

---

## 📦 Assets requis

**Assets existants à utiliser :**
- ✅ `assets/images/logo.png` - Logo principal (splash screen)
- ✅ `assets/icons/icon.png` - Icône de l'app
- ✅ `assets/images/banier.png` - Bannière (optionnel)

**Assets à créer (optionnel) :**
- Icône personnalisée pour "Zéro papier" (♻️ ou 🚫📄)
- Illustrations pour état vide du dashboard

---

## 🔗 Liens entre les écrans

**Navigation depuis le Dashboard :**
- "Préparer le nid" → `ReproductionScreen` (tab reproduction)
- "Marquer comme fait" → Modal + `SanteProvider.marquerVaccinFait()`
- "Enregistrer palpation" → `ReproductionScreen` (détail accouplement)
- "Peser les lapereaux" → `AjouterPeseeScreen`
- "Effectuer le sevrage" → `ReproductionScreen` (détail portée)
- "Ajouter un lapin" → `AddLapinScreen`
- "Planifier un accouplement" → `PlanifierAccouplementScreen`
- "Enregistrer un soin" → `AjouterSoinScreen`

**Navigation vers le Dashboard :**
- Depuis tous les écrans : Tap sur l'onglet 🏠 "Tableau de bord"

---

## ⚠️ Points d'attention

1. **Performance :**
   - Ne pas charger TOUTES les données au démarrage
   - Utiliser `addPostFrameCallback` pour charger les providers
   - Limiter les requêtes BDD (LIMIT 10 pour les alertes)

2. **État vide :**
   - Afficher un message si aucune alerte urgente
   - Ex: "✅ Aucune urgence aujourd'hui !"
   - Proposer des actions de découverte (onboarding)

3. **Accessibilité :**
   - Tailles de texte adaptatives
   - Contraste suffisant pour les alertes
   - Boutons de taille minimale 48x48 dp

4. **Localisation :**
   - Dates en français (`DateFormat` avec locale 'fr_FR')
   - Pluriels gérés ("1 lapin" vs "6 lapins")

---

## 📚 Documentation à mettre à jour

Après implémentation, mettre à jour :

1. **README.md :**
   - Ajouter une capture d'écran du Dashboard
   - Mentionner l'objectif "Zéro papier"

2. **cahier_charges_app_elevage.md :**
   - Marquer la fonctionnalité "Tableau de bord" comme ✅ complétée
   - Ajouter une section sur l'élimination de la paperasse

3. **.github/copilot-instructions.md :**
   - Ajouter la logique de calcul des alertes/tâches
   - Documenter la nouvelle navigation (5 onglets avec Dashboard)

4. **CHANGELOG.md (à créer) :**
   ```markdown
   ## [1.1.0] - 2025-11-13
   ### Added
   - 🏠 Nouveau tableau de bord "Aujourd'hui" comme écran d'accueil
   - 🚨 Alertes urgentes automatiques (mise bas, vaccinations)
   - ⏰ Tâches quotidiennes calculées (palpations, pesées, sevrage)
   - 📊 Statistiques en temps réel du cheptel
   - 🎯 Accès rapides aux actions fréquentes
   - 🌅 Splash screen avec logo de l'application
   
   ### Changed
   - 🔄 Réorganisation de la navigation (Dashboard en 1er onglet)
   - ⚙️ Déplacement de "Paramètres" vers icône dans l'AppBar
   - 🎨 Utilisation des assets existants (logo, bannière)
   
   ### Impact
   - 📉 90% de réduction du temps de vérification quotidienne
   - ✅ Objectif "Zéro papier" atteint
   ```

---

## 🎓 Bonnes pratiques respectées

- ✅ **Architecture MVVM** : Providers pour la logique métier
- ✅ **Widget composition** : Sections réutilisables
- ✅ **Performance** : Chargement différé avec `addPostFrameCallback`
- ✅ **Accessibilité** : Tailles adaptatives, contrastes
- ✅ **Localisation** : Dates en français
- ✅ **Design Material 3** : NavigationBar, Cards arrondies
- ✅ **State management** : Provider avec ChangeNotifier
- ✅ **Responsive** : Layout adaptatif (ListView)

---

## 🏁 Définition de "Terminé"

L'issue est considérée comme terminée quand :

1. ✅ Le Dashboard est l'écran d'accueil par défaut
2. ✅ Toutes les 4 sections sont affichées et fonctionnelles
3. ✅ Les calculs automatiques renvoient des données correctes
4. ✅ Les boutons d'action naviguent vers les bons écrans
5. ✅ Le Splash Screen s'affiche pendant 2 secondes
6. ✅ L'onglet "Paramètres" a été retiré de la BottomNavigationBar
7. ✅ L'icône ⚙️ dans l'AppBar ouvre l'écran Paramètres
8. ✅ L'état vide est géré gracieusement
9. ✅ Les assets (logo, icône) sont utilisés correctement
10. ✅ Le RefreshIndicator fonctionne (pull-to-refresh)
11. ✅ Les tests manuels passent sur un appareil Android réel
12. ✅ La documentation est mise à jour

---

## 💬 Notes supplémentaires

**Citation de l'utilisateur :**
> "Éliminer la paperasse traditionnelle [...] Tout digitalisé, automatisé et centralisé dans l'app"

Cette issue répond directement à l'objectif principal du cahier des charges :
- ❌ Plus de cahiers d'accouplement manuscrits
- ❌ Plus de post-it de rappel
- ❌ Plus de calendrier papier
- ✅ **100% digital, 100% automatisé, 100% intelligent**

**Slogan de l'app :**
> "Zéro papier, 100% digital" 🎯

---

**Créé par :** GitHub Copilot  
**Date :** 13 novembre 2025  
**Version de l'app :** 1.0.0 → 1.1.0  
**Dépendances :** Aucune nouvelle dépendance requise (utilise packages existants)
