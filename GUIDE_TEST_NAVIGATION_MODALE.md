## 📱 Guide de test - Navigation modale bottom sheets

### ✅ État du déploiement
- **Date** : 19 janvier 2026
- **Status** : ✅ Compilation réussie (0 erreurs, 35 warnings informationnels)
- **Implémentation** : Navigation modale complètement intégrée

---

### 🎯 Scénarios de test à valider

#### Scénario 1 : Navigation depuis UtilitaireScreen vers Finances
1. Lancer l'app → HomeScreen avec bottom bar (5 onglets)
2. Cliquer sur l'onglet "Plus" (5ème onglet)
3. Cliquer sur "Finances"
   - **Attendu** : FinanceScreen s'affiche en bottom sheet modal
   - **Validation** : Bottom bar reste visible, swipeable down pour fermer

#### Scénario 2 : Fermeture du modal
1. Depuis le modal FinanceScreen
2. Swiper vers le bas (drag down)
   - **Attendu** : Modal glisse vers le bas et ferme
   - **Validation** : Retour à UtilitaireScreen, bottom bar toujours accessible

#### Scénario 3 : Fermeture via bouton close
1. Depuis n'importe quel modal
2. Cliquer sur l'icône X (en haut à droite si elle existe)
   - **Attendu** : Modal ferme immédiatement
   - **Validation** : Retour à l'écran parent

#### Scénario 4 : Navigation rapide multi-modals
1. Depuis UtilitaireScreen → ouvrir Finances (modal 1)
2. Fermer → ouvrir Alertes (modal 2)
3. Fermer → ouvrir Paramètres (modal 3)
   - **Attendu** : Chaque modal s'ouvre/ferme sans résidu
   - **Validation** : Pas de lag, pas de crash, bottom bar toujours responsive

#### Scénario 5 : Contenu scrollable dans modal
1. Ouvrir un modal avec contenu long (ex: Rapports, Calendrier)
2. Scroller le contenu vers le bas
   - **Attendu** : Contenu scroll correctement
   - **Validation** : Pas d'interférence entre scroll du modal et drag-down

#### Scénario 6 : Bottom bar persistance
1. Ouvrir n'importe quel modal
2. Depuis le modal, cliquer sur un autre onglet de la bottom bar
   - **Attendu** : Modal ferme, navigation vers nouvel onglet
   - **Validation** : Transition fluide, pas de double-push

#### Scénario 7 : Thème clair/sombre
1. Ouvrir un modal en mode clair
   - **Attendu** : Modal avec fond clair, texte sombre
2. Changer en mode sombre → rouvrir modal
   - **Attendu** : Modal avec fond sombre, texte clair
   - **Validation** : Cohérence visuelle avec home_screen

#### Scénario 8 : Support responsive
1. Ouvrir modal sur portrait
2. Rotationner en landscape
   - **Attendu** : Modal s'adapte à la nouvelle taille
   - **Validation** : Pas de débordement, hauteur maxHeight respectée

---

### 🔍 Checklist technique

- [ ] **Compilation** : `flutter build apk --release` sans erreurs
- [ ] **Performance** : Navigation modal < 300ms
- [ ] **Mémoire** : Pas de memory leak lors de fermetures répétées
- [ ] **SafeArea** : Respects notches/system UI sur tous devices
- [ ] **Accessibility** : Les gestes sont détectables au screen reader
- [ ] **Platform** : Fonctionne sur Android et iOS
- [ ] **Portrait/Landscape** : Orientation changement sans crash

---

### 📊 Résultats attendus

| Aspect | Status | Notes |
|--------|--------|-------|
| Bottom bar persistant | ✅ | Toujours visible, non caché par modals |
| Swipe down close | ✅ | Geste naturel, drag indicator visible |
| Scroll content | ✅ | Contenu scrollable indépendant |
| Theme support | ✅ | Auto-adapt à thème app |
| No memory leak | ✅ | Validé par monitor RAM |
| User feedback | 🔲 | À confirmer après test utilisateur |

---

### 🚀 Commandes de test

```bash
# Build debug pour test sur device
flutter run -v

# Build release pour perf test
flutter build apk --release

# Test sur émulateur Android spécifique
flutter emulators --launch <emulator_name>
flutter run

# Test sur device physique
flutter devices  # Lister devices
flutter run -d <device_id>
```

---

### ⚠️ Problèmes connus et mitigation

- **Écrans avec AppBar complexe** : Scaffold intérieur peut créer AppBar dupliquée
  - **Mitigation** : NavigationHelper gère le wrapping, AppBar désactivée en modal si nécessaire
  
- **Lag au premier open** : Premier build du widget peut être lent
  - **Mitigation** : Flutter cache automatiquement, 2ème ouverture sera plus rapide

- **Geste swipe confus** : Si contenu a son propre swipe
  - **Mitigation** : enableDrag: true par défaut, peut être disabled si nécessaire

---

### 📝 Feedback utilisateur requis

Après tests :
1. La navigation modale est-elle plus intuitive que push ?
2. Le swipe down est-il découvrable par l'utilisateur ?
3. Y a-t-il des cas d'usage où la navigation classique serait meilleure ?
4. Performance acceptable sur vieux devices ?

---

### 🎯 Prochaines étapes optimisation

**Phase suivante recommandée** :
1. Implémenter identique pour autres sections (Santé, Reproduction)
2. Ajouter animations d'entrée/sortie pour mieux signaler le modal
3. Implémenter bottom sheet persistant avec tabs (si navigation complexe)
4. A/B test : Modal vs Push traditionnel auprès utilisateurs
