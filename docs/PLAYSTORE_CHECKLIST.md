# Checklist Google Play Store - BunnyManager

**Date de création :** Décembre 2024  
**Version cible :** 1.3.0+6

---

## 1. Informations Générales

### 1.1 Métadonnées de l'application

- [x] **Nom de l'application** : BunnyManager (ou Bunny Manager)
- [x] **Version** : 1.3.0+6 (versionName: 1.3.0, versionCode: 6)
- [ ] **Catégorie principale** : Productivité / Outils
- [ ] **Catégories secondaires** : Agriculture / Gestion
- [ ] **Public cible** : Professionnels de l'élevage, éleveurs de lapins
- [ ] **Restriction d'âge** : Tous publics (ou 3+)
- [ ] **Langues supportées** : Français, Anglais

### 1.2 Description

- [ ] **Description courte** (80 caractères max) :
  ```
  Application professionnelle de gestion d'élevage de lapins avec suivi complet du cheptel, reproduction, santé et finances.
  ```

- [ ] **Description complète** (4000 caractères max) :
  ```
  [À rédiger : description détaillée des fonctionnalités, avantages, cas d'usage]
  ```

- [ ] **Mots-clés** : élevage, lapins, gestion, reproduction, santé animale, agriculture

---

## 2. Assets Visuels

### 2.1 Icônes et Graphiques

- [x] **Icône de l'application** : `assets/logo/bunny_icon.png` (512x512px)
- [x] **Icône adaptative Android** : Configurée dans `pubspec.yaml`
- [ ] **Feature Graphic** : 1024x500px (bannière Play Store)
- [ ] **Screenshots** :
  - [ ] Téléphone (minimum 2, maximum 8) : 16:9 ou 9:16
  - [ ] Tablette (optionnel) : 16:9 ou 9:16
  - [ ] Formats acceptés : PNG ou JPEG, 24 bits, sans transparence

**Screenshots recommandés :**
1. Écran d'accueil / Dashboard
2. Liste du cheptel
3. Détails d'un lapin avec photo
4. Écran de reproduction (accouplements)
5. Écran de santé (soins, pesées)
6. Écran de finances
7. Paramètres / Synchronisation

### 2.2 Vidéo (optionnel)

- [ ] **Vidéo promotionnelle** : YouTube (lien)
- [ ] Durée recommandée : 30 secondes à 2 minutes

---

## 3. Contenu et Classification

### 3.1 Classification du contenu

- [ ] **Contenu pour adultes** : Non
- [ ] **Contenu médical** : Non (application de gestion, pas de diagnostic vétérinaire)
- [ ] **Contenu financier** : Oui (suivi des recettes/dépenses)
- [ ] **Contenu éducatif** : Oui (conseils d'élevage intégrés)

### 3.2 Restrictions

- [ ] **Restriction géographique** : Aucune (ou spécifier les pays si nécessaire)
- [ ] **Restriction d'âge** : Tous publics (ou 3+)

---

## 4. Données et Confidentialité (Data Safety)

### 4.1 Types de données collectées

- [x] **Données personnelles** :
  - [x] Email (pour authentification locale)
  - [x] Identifiants (userId local)
- [x] **Données financières** :
  - [x] Informations financières (recettes, dépenses)
- [x] **Photos et fichiers** :
  - [x] Photos (photos des lapins)
  - [x] Fichiers et documents (exports Excel/PDF)
- [x] **Données d'application** :
  - [x] Données d'élevage (lapins, reproduction, santé)
  - [x] Préférences utilisateur (thème, langue)

### 4.2 Utilisation des données

- [x] **Stockage** : Local (SQLite) + Optionnel (Supabase cloud)
- [x] **Partage** : Non (sauf synchronisation optionnelle avec consentement)
- [x] **Vente** : Non
- [x] **Publicité** : Non

### 4.3 Sécurité des données

- [x] **Chiffrement en transit** : Oui (HTTPS/TLS pour Supabase)
- [x] **Chiffrement au repos** : Oui (SQLite chiffrée, SecureStorage)
- [x] **Suppression des données** : Oui (utilisateur peut supprimer à tout moment)

### 4.4 Privacy Policy

- [x] **URL de la Privacy Policy** : [À héberger et fournir l'URL publique]
- [x] **Fichier source** : `docs/PRIVACY_POLICY.md`

---

## 5. Permissions

### 5.1 Permissions déclarées

- [x] **Notifications** :
  - `POST_NOTIFICATIONS` (Android 13+)
  - Justification : Rappels de tâches importantes (mises bas, soins, pesées)
- [x] **Alarmes** :
  - `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`
  - Justification : Planification précise des notifications
- [x] **Démarrage** :
  - `RECEIVE_BOOT_COMPLETED`
  - Justification : Réinitialisation des notifications après redémarrage
- [x] **Vibration** :
  - `VIBRATE`
  - Justification : Retour haptique pour les notifications
- [x] **Caméra** (runtime) :
  - Justification : Prise de photos des lapins pour identification
- [x] **Stockage** (runtime) :
  - Justification : Sauvegarde des photos et fichiers d'export

### 5.2 Justifications pour Google Play

Pour chaque permission, préparer une justification claire expliquant :
- Pourquoi la permission est nécessaire
- Comment elle est utilisée
- Ce qui se passe si l'utilisateur la refuse

**Exemple pour la caméra :**
```
La permission caméra est nécessaire pour prendre des photos des lapins afin de faciliter leur identification visuelle. Si l'utilisateur refuse cette permission, il peut toujours utiliser l'application mais ne pourra pas ajouter de photos aux fiches des lapins.
```

---

## 6. Build et Signature

### 6.1 Configuration du build

- [x] **Version** : 1.3.0+6
- [ ] **Signature** : Keystore configuré et sécurisé
- [ ] **ProGuard/R8** : Règles de minification configurées
- [ ] **App Bundle** : Générer un `.aab` (recommandé) plutôt qu'un `.apk`

### 6.2 Commandes de build

```bash
# Build release
flutter build appbundle --release

# Ou APK (moins recommandé)
flutter build apk --release --split-per-abi
```

### 6.3 Vérifications pré-build

- [ ] Tous les tests passent : `flutter test`
- [ ] Analyse statique : `flutter analyze` (aucune erreur)
- [ ] Formatage : `dart format .` (code formaté)
- [ ] Mode release testé sur device réel
- [ ] Clés Supabase neutralisées dans le code (valeurs fictives)

---

## 7. Tests et Qualité

### 7.1 Tests fonctionnels

- [ ] **Tests sur différents appareils** :
  - [ ] Téléphone Android (API 21+)
  - [ ] Tablette Android (optionnel)
  - [ ] Différentes tailles d'écran
- [ ] **Tests de régression** :
  - [ ] Authentification locale
  - [ ] Création/modification/suppression de lapins
  - [ ] Notifications fonctionnent correctement
  - [ ] Export/Import Excel
  - [ ] Synchronisation (si activée)
- [ ] **Tests de performance** :
  - [ ] Dashboard avec 100+ lapins
  - [ ] Listes volumineuses (pas de lag)
  - [ ] Temps de démarrage acceptable

### 7.2 Tests de sécurité

- [ ] Aucune clé API en clair dans le code
- [ ] Base de données chiffrée
- [ ] PIN stocké de manière sécurisée
- [ ] Permissions demandées uniquement au runtime

---

## 8. Documentation Utilisateur

### 8.1 Aide intégrée

- [ ] **FAQ** : Section FAQ dans l'application (si disponible)
- [ ] **Tutoriels** : Guide de démarrage rapide (onboarding)
- [ ] **Support** : Email de contact accessible depuis l'application

### 8.2 Documentation externe

- [ ] **Site web** (optionnel) : URL du site avec documentation
- [ ] **Vidéo tutorielle** (optionnel) : Lien YouTube

---

## 9. Conformité et Politiques

### 9.1 Politiques Google Play

- [x] **Privacy Policy** : Créée et accessible
- [ ] **Politique de remboursement** : Si application payante
- [ ] **Politique de contenu** : Respect des guidelines Google Play

### 9.2 Conformité légale

- [x] **RGPD** : Conformité respectée (voir Privacy Policy)
- [ ] **Mentions légales** : Si nécessaire selon votre juridiction
- [ ] **CGU** (Conditions Générales d'Utilisation) : Si nécessaire

---

## 10. Soumission

### 10.1 Avant la soumission

- [ ] Tous les éléments ci-dessus sont complétés
- [ ] Build release testé et validé
- [ ] Privacy Policy hébergée et accessible publiquement
- [ ] Screenshots et assets préparés
- [ ] Description rédigée et relue

### 10.2 Processus de soumission

1. [ ] Se connecter à [Google Play Console](https://play.google.com/console)
2. [ ] Créer une nouvelle application (ou sélectionner l'existante)
3. [ ] Remplir toutes les sections :
   - [ ] Store listing (description, screenshots, etc.)
   - [ ] Content rating (classification)
   - [ ] Data safety (formulaire de sécurité des données)
   - [ ] Pricing & distribution (gratuit/payant, pays)
   - [ ] App access (restrictions si nécessaire)
4. [ ] Uploader le fichier `.aab` ou `.apk`
5. [ ] Créer une version de test interne (optionnel)
6. [ ] Soumettre pour révision

### 10.3 Après la soumission

- [ ] Surveiller les emails de Google Play Console
- [ ] Répondre rapidement aux demandes de clarification
- [ ] Corriger les problèmes signalés si nécessaire
- [ ] Préparer les mises à jour futures

---

## 11. Checklist Finale

### Critères bloquants (DOIT être complété)

- [x] Privacy Policy créée et accessible
- [x] Clés Supabase neutralisées dans le code
- [ ] Build release fonctionnel testé
- [ ] Permissions justifiées dans Data Safety
- [ ] Version et versionCode corrects
- [ ] Signature de l'application configurée

### Critères recommandés (devrait être complété)

- [ ] Screenshots de qualité
- [ ] Description complète et attrayante
- [ ] Tests sur plusieurs appareils
- [ ] Documentation utilisateur disponible
- [ ] Support utilisateur configuré

---

## 12. Ressources Utiles

- [Google Play Console](https://play.google.com/console)
- [Documentation Google Play](https://support.google.com/googleplay/android-developer)
- [Data Safety Form Guide](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Privacy Policy Generator](https://www.privacypolicygenerator.info/) (optionnel)

---

**Date de dernière mise à jour :** Décembre 2024  
**Statut :** En préparation
