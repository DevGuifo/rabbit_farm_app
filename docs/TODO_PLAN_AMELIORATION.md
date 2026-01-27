# 📋 TODO - Plan d'Amélioration BunnyManager

**Créé le** : 13 janvier 2026  
**Basé sur** : [AUDIT_EXPERT_JANVIER_2026.md](./AUDIT_EXPERT_JANVIER_2026.md)  
**Objectif** : Stabiliser et améliorer l'application progressivement  
**Dernière mise à jour** : Janvier 2026

---

## 🎯 LÉGENDE

- 🔴 **CRITIQUE** - À faire en premier, risque élevé
- 🟠 **IMPORTANT** - Fort impact, à planifier rapidement  
- 🟢 **NORMAL** - Amélioration utile, peut attendre
- ⚪ **OPTIONNEL** - Nice to have

**Statuts** : `[ ]` À faire | `[~]` En cours | `[x]` Terminé | `[!]` Bloqué

---

## 📅 PHASE 1 : STABILISATION (Semaines 1-2)

### 1.1 Qualité du code
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| 🔴 | Exécuter `flutter analyze` et lister tous les warnings | Projet entier | [ ] |
| 🔴 | Corriger les warnings critiques (unused imports, deprecated) | Multiples | [ ] |
| 🟠 | Nettoyer les `// TODO` dans `notification_action_handler.dart` | `lib/services/notification_action_handler.dart` | [ ] |
| 🟠 | Nettoyer les `// TODO` dans `upcoming_tasks_section.dart` | `lib/widgets/dashboard/upcoming_tasks_section.dart` | [ ] |
| 🟢 | Vérifier que tous les `print()` ont été remplacés par `logger` | Projet entier | [ ] |

### 1.2 Tests unitaires (premiers pas) ✅ TERMINÉ
| Priorité | Tâche | Fichier(s) à créer | Statut |
|----------|-------|-------------------|--------|
| 🔴 | Créer le dossier `test/` avec structure de base | `test/` | [x] ✅ |
| 🔴 | Premier test : `LapinProvider` - chargerLapins() | `test/providers/lapin_provider_simple_test.dart` | [x] ✅ |
| 🟠 | Test : `LapinProvider` - ajouterLapin() | `test/providers/lapin_provider_simple_test.dart` | [x] ✅ |
| 🟠 | Test : `ReproductionProvider` - logique métier | `test/providers/reproduction_provider_test.dart` | [x] ✅ |
| 🟢 | Test : Modèle `Lapin` - toMap() / fromMap() | `test/models/lapin_test.dart` | [x] ✅ |
| 🟢 | Test : Modèle `Accouplement` - toMap() / fromMap() | `test/models/accouplement_test.dart` | [x] ✅ |
| 🟢 | Test : Modèle `Portee` - toMap() / fromMap() | `test/models/portee_test.dart` | [x] ✅ |

**📊 Progression tests : 87 tests passants**
- 15 tests `Lapin` (création, toMap/fromMap, âge, copyWith)
- 23 tests `Accouplement` (dates calculées, statuts)
- 25 tests `Portee` (tauxSurvie, sevrage)
- 12 tests `LapinProvider` (CRUD, filtres)
- 12 tests `ReproductionProvider` (mises bas, palpations, sevrages)

### 1.3 Documentation
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| 🟠 | Créer README utilisateur simplifié | `docs/README_UTILISATEUR.md` | [ ] |
| 🟢 | Documenter le flux "Ajouter un lapin" | `docs/guides/FLUX_AJOUT_LAPIN.md` | [ ] |
| 🟢 | Documenter le flux "Enregistrer une portée" | `docs/guides/FLUX_PORTEE.md` | [ ] |

---

## 📅 PHASE 2 : QUALITÉ DE CODE (Semaines 3-4) ✅ EN COURS

### 2.1 Refactoring DatabaseHelper (CRITIQUE) ✅ Phase 1 terminée
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| 🔴 | Créer `DatabaseBase` classe abstraite | `lib/services/database/database_base.dart` | [x] ✅ |
| 🔴 | Faire hériter `DatabaseHelper` de `DatabaseBase` | `lib/services/database_helper.dart` | [x] ✅ |
| 🔴 | Créer `lib/services/database/lapin_database_mixin.dart` | Extraction méthodes lapins | [x] ✅ |
| 🔴 | Créer `lib/services/database/reproduction_database_mixin.dart` | Extraction accouplements/portées | [x] ✅ |
| 🟠 | Créer `lib/services/database/sante_database_mixin.dart` | Extraction pesées/soins | [x] ✅ |
| 🟠 | Créer `lib/services/database/finance_database_mixin.dart` | Extraction recettes/dépenses | [x] ✅ |
| 🟠 | Appliquer les mixins à `DatabaseHelper` | Migration progressive | [ ] |
| 🟠 | Supprimer les méthodes dupliquées | Après application des mixins | [ ] |
| 🟢 | Documenter la migration | `docs/DATABASE_MIXINS_MIGRATION.md` | [x] ✅ |

**📊 Progression mixins : 4/4 mixins créés (~1460 lignes extraites)**
**📚 Documentation : [DATABASE_MIXINS_MIGRATION.md](./DATABASE_MIXINS_MIGRATION.md)**

### 2.2 Gestion des erreurs
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| 🟠 | Créer `ErrorService` centralisé | `lib/services/error_service.dart` (améliorer existant) | [ ] |
| 🟠 | Ajouter logging systématique dans les catch | Providers principaux | [ ] |
| 🟢 | Créer des exceptions métier personnalisées | `lib/core/exceptions/` | [ ] |
| 🟢 | Afficher messages d'erreur user-friendly | Widgets erreur | [ ] |

### 2.3 Migration vers Repositories
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| 🟠 | Finaliser `LapinRepository` avec toutes les méthodes | `lib/repositories/lapin_repository.dart` | [ ] |
| 🟠 | Migrer `LapinProvider` vers Repository | `lib/providers/lapin_provider.dart` | [ ] |
| 🟢 | Créer `SanteRepository` complet | `lib/repositories/sante_repository.dart` | [ ] |
| 🟢 | Créer `FinanceRepository` complet | `lib/repositories/finance_repository.dart` | [ ] |

---

## 📅 PHASE 3 : UX UTILISATEUR (Semaines 5-6)

### 3.1 Recherche globale
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| 🟠 | Créer `SearchService` pour recherche multi-entités | `lib/services/search_service.dart` | [ ] |
| 🟠 | Ajouter barre de recherche dans Dashboard header | `lib/screens/dashboard/dashboard_screen.dart` | [ ] |
| 🟠 | Créer écran résultats de recherche | `lib/screens/search/search_results_screen.dart` | [ ] |
| 🟢 | Ajouter recherche dans Cheptel | `lib/screens/cheptel/cheptel_screen.dart` | [ ] |

### 3.2 Quick Actions
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| 🟠 | Ajouter bouton "Pesée rapide" sur fiche lapin | `lib/screens/cheptel/lapin_detail_screen.dart` | [ ] |
| 🟠 | Ajouter bouton "Soin rapide" sur fiche lapin | `lib/screens/cheptel/lapin_detail_screen.dart` | [ ] |
| 🟢 | Créer widget `QuickActionBar` réutilisable | `lib/widgets/quick_action_bar.dart` | [ ] |
| 🟢 | Ajouter quick actions sur Dashboard | `lib/screens/dashboard/dashboard_screen.dart` | [ ] |

### 3.3 Amélioration Dashboard
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| 🟠 | Rendre les KPIs critiques plus visibles (couleurs) | `lib/widgets/dashboard/` | [ ] |
| 🟢 | Ajouter widget "Alertes urgentes" en haut | `lib/widgets/dashboard/urgent_alerts_widget.dart` | [ ] |
| 🟢 | Améliorer la section rituels quotidiens | `lib/widgets/rituel_card.dart` | [ ] |

---

## 📅 PHASE 4 : PRODUCTION (Semaines 7-8)

### 4.1 Tests complets
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| 🔴 | Atteindre 30% coverage sur providers | `test/providers/` | [ ] |
| 🟠 | Atteindre 50% coverage global | `test/` | [ ] |
| 🟠 | Tests d'intégration écrans principaux | `test/integration/` | [ ] |
| 🟢 | Tests widgets critiques | `test/widgets/` | [ ] |

### 4.2 Tests sur appareils réels
| Priorité | Tâche | Appareil | Statut |
|----------|-------|----------|--------|
| 🔴 | Tester sur Android physique (bas de gamme) | Android 10+ | [ ] |
| 🔴 | Tester sur Android physique (haut de gamme) | Android 13+ | [ ] |
| 🟠 | Vérifier performances avec 100+ lapins | Tous | [ ] |
| 🟢 | Tester mode hors-ligne prolongé (24h) | Tous | [ ] |

### 4.3 Préparation Play Store
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| 🔴 | Vérifier toutes les permissions Android | `android/app/src/main/AndroidManifest.xml` | [ ] |
| 🔴 | Générer APK release signé | Build pipeline | [ ] |
| 🟠 | Créer screenshots pour le store | Marketing | [ ] |
| 🟠 | Rédiger description Play Store FR/EN | Marketing | [ ] |
| 🟢 | Préparer politique de confidentialité | `docs/PRIVACY_POLICY.md` (existe) | [ ] |
| 🟢 | Créer icône et feature graphic | Assets | [ ] |

---

## 📅 PHASE 5 : OPTIONNEL (Futur)

### 5.1 Synchronisation Supabase
| Priorité | Tâche | Fichier(s) concerné(s) | Statut |
|----------|-------|------------------------|--------|
| ⚪ | Finaliser `SyncService` | `lib/services/sync_service.dart` | [ ] |
| ⚪ | Tester sync bidirectionnelle | Tests intégration | [ ] |
| ⚪ | Gérer les conflits de données | `lib/services/conflict_resolver.dart` | [ ] |

### 5.2 Fonctionnalités avancées
| Priorité | Tâche | Description | Statut |
|----------|-------|-------------|--------|
| ⚪ | Export PDF amélioré | Rapports personnalisables | [ ] |
| ⚪ | Statistiques avancées | Graphiques de tendance | [ ] |
| ⚪ | Mode multi-utilisateur | Plusieurs éleveurs | [ ] |
| ⚪ | Backup automatique cloud | Sauvegarde programmée | [ ] |

---

## 📊 SUIVI DE PROGRESSION

### Résumé par phase
| Phase | Tâches totales | Terminées | Progression |
|-------|---------------|-----------|-------------|
| Phase 1 - Stabilisation | 15 | 0 | 0% |
| Phase 2 - Qualité | 14 | 0 | 0% |
| Phase 3 - UX | 11 | 0 | 0% |
| Phase 4 - Production | 12 | 0 | 0% |
| Phase 5 - Optionnel | 7 | 0 | 0% |
| **TOTAL** | **59** | **0** | **0%** |

### Prochaines actions immédiates (cette semaine)
1. [ ] `flutter analyze` - lister les warnings
2. [ ] Créer `test/providers/lapin_provider_test.dart`
3. [ ] Identifier les 3 `// TODO` les plus critiques

---

## 📝 NOTES DE SUIVI

### Semaine du 13 janvier 2026
- Audit initial complété
- Plan TODO créé
- Prochaine étape : Phase 1.1 (flutter analyze)

---

*Dernière mise à jour : 13 janvier 2026*
