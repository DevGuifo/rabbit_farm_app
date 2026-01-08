# 📚 INDEX DOCUMENTATION - BunnyManager

**Version :** 1.2.0+5  
**Dernière mise à jour :** 8 janvier 2026  
**Organisation :** docs/ (4 dossiers) + guides racine

---

## 🚀 DÉMARRAGE RAPIDE (Non-Développeur)

### 📖 Lecture Obligatoire (15 min)

1. **[README.md](README.md)** - Vue d'ensemble du projet
2. **[REFERENCE_RAPIDE_GIT.md](REFERENCE_RAPIDE_GIT.md)** - 3 commandes Git essentielles (5 min/jour)
3. **[docs/guides/GUIDE_GITHUB_SIMPLE.md](docs/guides/GUIDE_GITHUB_SIMPLE.md)** - Workflow Git détaillé pour propriétaire

### ⚡ Actions Quotidiennes (5 min)

```bash
cd /home/guifo/Bureau/rabbit_farm_app
git status
git add .
git commit -m "Travail du $(date +%d/%m/%Y)"
git push
```

Voir [REFERENCE_RAPIDE_GIT.md](REFERENCE_RAPIDE_GIT.md) pour détails.

---

## 📂 STRUCTURE DOCUMENTATION

```
rabbit_farm_app/
├── README.md                              # 🌟 Vue d'ensemble projet
├── CHANGELOG.md                           # 📝 Historique versions
├── REFERENCE_RAPIDE_GIT.md               # ⚡ Aide-mémoire Git (5 min)
├── PLAN_NETTOYAGE_GIT.md                 # 🧹 Procédures nettoyage (dev)
├── RAPPORT_NETTOYAGE_GIT_DEVOPS.md       # 📊 Audit DevOps (8 jan 2026)
├── PROPOSITION_GITHUB_ACTIONS.md         # 🚀 CI/CD future (optionnel)
│
└── docs/
    ├── guides/                            # 10 guides pratiques
    ├── rapports/                          # 8 rapports audit/phase
    ├── specifications/                    # 2 cahiers charges
    └── archives/                          # 15+ documents historiques
```

---

## 📖 GUIDES UTILISATEUR (docs/guides/)

### Pour Non-Développeur

| Fichier | Description | Temps Lecture | Priorité |
|---------|-------------|---------------|----------|
| **GUIDE_GITHUB_SIMPLE.md** | Workflow Git pour propriétaire sans compétence technique | 15 min | 🔴 **HAUTE** |
| **GUIDE_UTILISATEUR.md** | Manuel complet application (fonctionnalités, écrans) | 30 min | 🟠 Moyenne |
| **GUIDE_UTILISATEUR_I18N.md** | Changement de langue FR/EN dans l'app | 5 min | 🟢 Basse |

### Pour Développeur

| Fichier | Description | Temps Lecture | Priorité |
|---------|-------------|---------------|----------|
| **GUIDE_SYNCHRONISATION_SUPABASE.md** | Configuration backend cloud Supabase | 20 min | 🟠 Moyenne |
| **GUIDE_THEME_UNIFIE.md** | Système Material 3, light/dark modes | 15 min | 🟢 Basse |
| **GUIDE_REGLES_METIER.md** | Logique métier élevage cunicole | 25 min | 🟠 Moyenne |
| **GUIDE_VERSIONING.md** | Convention versioning sémantique | 10 min | 🟢 Basse |
| **GUIDE_DASHBOARD.md** | Architecture dashboard, KPI temps réel | 20 min | 🟠 Moyenne |

### Pour Testeur

| Fichier | Description | Temps Lecture | Priorité |
|---------|-------------|---------------|----------|
| **GUIDE_TEST_APPLICATION.md** | Procédures test complètes (fonctionnel, régression) | 25 min | 🟠 Moyenne |
| **GUIDE_TEST_LANGUE.md** | Tests internationalisation FR/EN | 10 min | 🟢 Basse |

---

## 📊 RAPPORTS & AUDITS (docs/rapports/)

### Rapports Finaux (Publication V1)

| Fichier | Description | Date | Pages |
|---------|-------------|------|-------|
| **RAPPORT_FINAL_GO_NOGO_V1.md** | 🌟 Évaluation publication V1 - Score 8.0/10 GO | 8 jan 2026 | 15 |
| **RAPPORT_PHASE_P1.1_I18N_DIALOGUES.md** | Phase P1.1 : Internationalisation 15 dialogues | 7 jan 2026 | 12 |
| **RAPPORT_PHASE_P1.2_I18N_COMPLETE.md** | Phase P1.2 : i18n 100% (7 chaînes finales) | 8 jan 2026 | 10 |

### Audits Techniques

| Fichier | Description | Date | Pages |
|---------|-------------|------|-------|
| **RAPPORT_FINAL_AUDIT.md** | Audit technique complet (architecture, code) | Déc 2025 | 20 |
| **RAPPORT_FINAL_CORRECTIONS.md** | Corrections post-audit (bugs, optimisations) | Déc 2025 | 18 |
| **RAPPORT_AUDIT_*.md** | Audits spécialisés (UX, i18n, langage) | Nov-Déc 2025 | 10-15 |

---

## 📋 SPÉCIFICATIONS (docs/specifications/)

| Fichier | Description | Lignes | Priorité |
|---------|-------------|--------|----------|
| **cahier_charges_app_elevage.md** | 🌟 Cahier des charges complet V1 | 1200+ | 🔴 **HAUTE** |
| **cahier_charges_v2.md** | Extensions prévues V2 (Supabase, multi-ferme) | 800+ | 🟢 Basse |

---

## 🗄️ ARCHIVES (docs/archives/)

**Contenu :** Documentation historique, audits obsolètes, rapports intermédiaires

**Exemples :**
- INVENTAIRE_*.md (5 fichiers) - Phases refactoring
- AUDIT_*.md (3 fichiers) - Audits préliminaires
- PHASE*.md (4 fichiers) - Rapports phases 1-4
- ANALYSE_*.md, PROBLEMES_*.md, RESUME_*.md, etc.

**Usage :** Référence historique, ne pas lire en priorité

---

## 📜 FICHIERS RACINE IMPORTANTS

### Documentation Git/DevOps

| Fichier | Description | Cible | Temps |
|---------|-------------|-------|-------|
| **REFERENCE_RAPIDE_GIT.md** | ⚡ Aide-mémoire 3 commandes Git | Non-dev | 2 min |
| **PLAN_NETTOYAGE_GIT.md** | 🧹 Procédures nettoyage repository | Dev | 15 min |
| **RAPPORT_NETTOYAGE_GIT_DEVOPS.md** | 📊 Audit intervention DevOps (8 jan 2026) | Audit | 20 min |
| **PROPOSITION_GITHUB_ACTIONS.md** | 🚀 CI/CD automatique (optionnel futur) | Dev Senior | 15 min |

### Documentation Projet

| Fichier | Description | Cible | Priorité |
|---------|-------------|-------|----------|
| **README.md** | 🌟 Vue d'ensemble, installation, stack technique | Tous | 🔴 **HAUTE** |
| **CHANGELOG.md** | 📝 Historique versions (1.0.0 → 1.2.0+5) | Tous | 🟠 Moyenne |

---

## 🎯 PARCOURS LECTURE RECOMMANDÉS

### 👤 Propriétaire Non-Développeur (1h total)

**Objectif :** Autonomie Git + Connaissance fonctionnalités app

1. ✅ **[README.md](README.md)** (10 min) - Vue d'ensemble
2. ✅ **[REFERENCE_RAPIDE_GIT.md](REFERENCE_RAPIDE_GIT.md)** (5 min) - Workflow quotidien
3. ✅ **[docs/guides/GUIDE_GITHUB_SIMPLE.md](docs/guides/GUIDE_GITHUB_SIMPLE.md)** (15 min) - Formation Git complète
4. ✅ **[docs/guides/GUIDE_UTILISATEUR.md](docs/guides/GUIDE_UTILISATEUR.md)** (30 min) - Fonctionnalités app

**Bonus (optionnel) :**
- [CHANGELOG.md](CHANGELOG.md) (5 min) - Historique évolutions
- [docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md](docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md) (10 min) - État publication V1

---

### 💻 Nouveau Développeur (3h total)

**Objectif :** Setup environnement + Comprendre architecture

1. ✅ **[README.md](README.md)** (10 min) - Installation, stack
2. ✅ **[docs/specifications/cahier_charges_app_elevage.md](docs/specifications/cahier_charges_app_elevage.md)** (45 min) - Spécifications complètes
3. ✅ **[docs/guides/GUIDE_REGLES_METIER.md](docs/guides/GUIDE_REGLES_METIER.md)** (25 min) - Logique métier élevage
4. ✅ **[CHANGELOG.md](CHANGELOG.md)** (15 min) - Historique évolutions
5. ✅ **[docs/rapports/RAPPORT_FINAL_AUDIT.md](docs/rapports/RAPPORT_FINAL_AUDIT.md)** (30 min) - Architecture technique
6. ✅ **[docs/guides/GUIDE_THEME_UNIFIE.md](docs/guides/GUIDE_THEME_UNIFIE.md)** (15 min) - Système thème
7. ✅ **[docs/guides/GUIDE_SYNCHRONISATION_SUPABASE.md](docs/guides/GUIDE_SYNCHRONISATION_SUPABASE.md)** (20 min) - Backend Supabase

**Bonus (optionnel) :**
- [PLAN_NETTOYAGE_GIT.md](PLAN_NETTOYAGE_GIT.md) (15 min) - Maintenance Git
- [PROPOSITION_GITHUB_ACTIONS.md](PROPOSITION_GITHUB_ACTIONS.md) (15 min) - CI/CD future

---

### 🧪 Testeur QA (2h total)

**Objectif :** Procédures test + Comprendre fonctionnalités

1. ✅ **[README.md](README.md)** (10 min) - Installation app
2. ✅ **[docs/guides/GUIDE_UTILISATEUR.md](docs/guides/GUIDE_UTILISATEUR.md)** (30 min) - Fonctionnalités complètes
3. ✅ **[docs/guides/GUIDE_TEST_APPLICATION.md](docs/guides/GUIDE_TEST_APPLICATION.md)** (25 min) - Procédures test fonctionnel
4. ✅ **[docs/guides/GUIDE_TEST_LANGUE.md](docs/guides/GUIDE_TEST_LANGUE.md)** (10 min) - Tests i18n FR/EN
5. ✅ **[docs/specifications/cahier_charges_app_elevage.md](docs/specifications/cahier_charges_app_elevage.md)** (45 min) - Spécifications référence

**Bonus (optionnel) :**
- [docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md](docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md) (10 min) - Critères acceptance V1
- [docs/rapports/RAPPORT_PHASE_P1.2_I18N_COMPLETE.md](docs/rapports/RAPPORT_PHASE_P1.2_I18N_COMPLETE.md) (10 min) - Tests i18n

---

### 📊 Auditeur / Manager (1h30 total)

**Objectif :** Évaluer qualité projet + Roadmap

1. ✅ **[README.md](README.md)** (10 min) - Vue d'ensemble
2. ✅ **[docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md](docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md)** (15 min) - État publication V1
3. ✅ **[RAPPORT_NETTOYAGE_GIT_DEVOPS.md](RAPPORT_NETTOYAGE_GIT_DEVOPS.md)** (20 min) - Audit DevOps
4. ✅ **[CHANGELOG.md](CHANGELOG.md)** (15 min) - Historique versions
5. ✅ **[docs/specifications/cahier_charges_app_elevage.md](docs/specifications/cahier_charges_app_elevage.md)** (30 min) - Conformité specs

**Bonus (optionnel) :**
- [docs/rapports/RAPPORT_FINAL_AUDIT.md](docs/rapports/RAPPORT_FINAL_AUDIT.md) (30 min) - Audit technique complet
- [PROPOSITION_GITHUB_ACTIONS.md](PROPOSITION_GITHUB_ACTIONS.md) (15 min) - Roadmap CI/CD

---

## 🔍 RECHERCHE RAPIDE PAR BESOIN

### ❓ "Comment faire un commit Git ?"

➡️ [REFERENCE_RAPIDE_GIT.md](REFERENCE_RAPIDE_GIT.md) - Section "Workflow Quotidien"

### ❓ "Quelles fonctionnalités a l'app ?"

➡️ [README.md](README.md) - Section "Fonctionnalités"  
➡️ [docs/guides/GUIDE_UTILISATEUR.md](docs/guides/GUIDE_UTILISATEUR.md) - Détails complets

### ❓ "Comment changer la langue FR/EN ?"

➡️ [docs/guides/GUIDE_UTILISATEUR_I18N.md](docs/guides/GUIDE_UTILISATEUR_I18N.md)

### ❓ "Quelle est la version actuelle ?"

➡️ [CHANGELOG.md](CHANGELOG.md) - Première ligne : **1.2.0+5**

### ❓ "Comment builder l'APK ?"

➡️ [README.md](README.md) - Section "Build Production"

### ❓ "Où sont les spécifications ?"

➡️ [docs/specifications/cahier_charges_app_elevage.md](docs/specifications/cahier_charges_app_elevage.md)

### ❓ "L'app est-elle prête pour publication ?"

➡️ [docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md](docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md) - **Score 8.0/10 GO**

### ❓ "Comment configurer Supabase ?"

➡️ [docs/guides/GUIDE_SYNCHRONISATION_SUPABASE.md](docs/guides/GUIDE_SYNCHRONISATION_SUPABASE.md)

### ❓ "Quels tests faire avant release ?"

➡️ [docs/guides/GUIDE_TEST_APPLICATION.md](docs/guides/GUIDE_TEST_APPLICATION.md)

### ❓ "Comment nettoyer le repository Git ?"

➡️ [PLAN_NETTOYAGE_GIT.md](PLAN_NETTOYAGE_GIT.md) - 7 étapes détaillées

---

## 📞 SUPPORT & CONTACTS

### Documentation Complète

**Repository GitHub :** https://github.com/DevGuifo/rabbit_farm_app

### Contributeurs

- **Développeur Principal :** DevGuifo
- **Lead DevOps :** Lead Flutter Developer (intervention 8 jan 2026)

### Signaler Problème

**GitHub Issues :** https://github.com/DevGuifo/rabbit_farm_app/issues

---

## 📅 MAINTENANCE DOCUMENTATION

### Prochaines Révisions

- **Février 2026** : Mise à jour guides après 1 mois usage quotidien Git
- **Avril 2026** : Évaluation GitHub Actions (PROPOSITION_GITHUB_ACTIONS.md)
- **Juin 2026** : Audit documentation exhaustivité

### Changelog Documentation

| Date | Action | Fichiers Modifiés |
|------|--------|-------------------|
| 8 jan 2026 | 🧹 Nettoyage Git, organisation docs/ | 40+ fichiers déplacés |
| 8 jan 2026 | 📖 Création guides Git propriétaire | +3 fichiers (GUIDE_GITHUB_SIMPLE, REFERENCE_RAPIDE, RAPPORT_NETTOYAGE) |
| 8 jan 2026 | 📚 Création INDEX_DOCUMENTATION.md | Ce fichier |

---

**Version Index :** 1.0  
**Dernière mise à jour :** 8 janvier 2026 - 16h00  
**Prochaine révision :** Février 2026

---

💡 **Astuce :** Marquez ce fichier en favori pour accès rapide à toute la documentation !
