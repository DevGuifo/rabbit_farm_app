import 'package:flutter/material.dart';
import '../../models/portee.dart';
import '../../models/lapin.dart';
import '../../models/sevrage.dart';
import '../../models/cage.dart';
import '../../services/database_helper.dart';
import '../../services/localisation_service.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/cage_selector.dart';
import '../../theme/app_theme.dart';
import 'widgets/sevrage/sevrage_header.dart';
import 'widgets/sevrage/sevrage_info_section.dart';
import 'widgets/sevrage/sevrage_options.dart';
import 'widgets/sevrage/sevrage_petit_card.dart';
import 'widgets/sevrage/sevrage_extra_fields.dart';
import 'widgets/sevrage/sevrage_resume.dart';
import 'widgets/sevrage/sevrage_validation_button.dart';
import 'widgets/sevrage/sevrage_confirmation_dialog.dart';

/// Écran détaillé de sevrage d'une portée avec sélection individuelle des cages
class SevrageDetailScreen extends StatefulWidget {
  final Portee portee;
  final Lapin mere;

  const SevrageDetailScreen({
    super.key,
    required this.portee,
    required this.mere,
  });

  @override
  State<SevrageDetailScreen> createState() => _SevrageDetailScreenState();
}

class _SevrageDetailScreenState extends State<SevrageDetailScreen> {
  final _dbHelper = DatabaseHelper.instance;
  final _observationsController = TextEditingController();
  final _alimentationController = TextEditingController();

  List<Lapin> _petits = [];
  final Map<int, String?> _cagesSelectionnees = {}; // lapinId -> cage.numero
  final Map<int, double?> _poids = {};
  final Map<int, String> _sexes = {}; // lapinId -> sexe
  bool _separerParSexe = true;
  bool _utiliserCagesCollectives = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerPetits();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    _alimentationController.dispose();
    super.dispose();
  }

  /// Charger les enfants de la mère
  Future<void> _chargerPetits() async {
    setState(() => _loading = true);

    try {
      final petits = await _dbHelper.getEnfants(widget.mere.id!);

      // Filtrer pour garder seulement ceux de cette portée (date de naissance = date mise bas)
      final petitsPortee = petits.where((p) {
        final diff = p.dateNaissance
            .difference(widget.portee.dateMiseBasReelle)
            .inDays
            .abs();
        return diff <= 1; // Tolérance de 1 jour
      }).toList();

      setState(() {
        _petits = petitsPortee;
        // Initialiser les poids et sexes avec les valeurs actuelles
        for (var petit in _petits) {
          _poids[petit.id!] = petit.poids;
          _sexes[petit.id!] = petit.sexe;
          _cagesSelectionnees[petit.id!] = null;
        }
      });

      // Proposer des cages automatiquement
      if (_separerParSexe) {
        await _proposerCagesAutomatiques();
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Erreur: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Proposer des cages automatiquement selon le sexe et les disponibilités
  Future<void> _proposerCagesAutomatiques() async {
    try {
      final cagesDisponibles = await _dbHelper.getCagesDisponibles();

      if (_separerParSexe) {
        // Séparer mâles et femelles
        final males = _petits.where((p) {
          final sexe = _sexes[p.id!] ?? p.sexe;
          return sexe.toLowerCase() == 'male' ||
              sexe.toLowerCase() == 'm' ||
              sexe.toLowerCase() == 'mâle';
        }).toList();
        final femelles = _petits.where((p) {
          final sexe = _sexes[p.id!] ?? p.sexe;
          return sexe.toLowerCase() == 'femelle' || sexe.toLowerCase() == 'f';
        }).toList();

        // Trouver une cage collective pour les mâles
        if (males.isNotEmpty) {
          final cageMales = cagesDisponibles.firstWhere((c) {
            final occupants = c['occupants_actuels'] as int? ?? 0;
            final capacite = c['capacite'] as int? ?? 1;
            return (capacite - occupants) >= males.length;
          }, orElse: () => {});

          if (cageMales.isNotEmpty) {
            final cage = Cage.fromMap(cageMales);
            for (var male in males) {
              _cagesSelectionnees[male.id!] = cage.numero;
            }
          }
        }

        // Trouver une cage collective pour les femelles
        if (femelles.isNotEmpty) {
          final cageFemelles = cagesDisponibles.firstWhere((c) {
            final occupants = c['occupants_actuels'] as int? ?? 0;
            final capacite = c['capacite'] as int? ?? 1;
            final cageObj = Cage.fromMap(c);
            return (capacite - occupants) >= femelles.length &&
                cageObj.numero != _cagesSelectionnees[males.firstOrNull?.id];
          }, orElse: () => {});

          if (cageFemelles.isNotEmpty) {
            final cage = Cage.fromMap(cageFemelles);
            for (var femelle in femelles) {
              _cagesSelectionnees[femelle.id!] = cage.numero;
            }
          }
        }
      } else {
        // Mode cages individuelles : proposer une cage par petit
        for (var petit in _petits) {
          final cageIndiv = cagesDisponibles.firstWhere((c) {
            final occupants = c['occupants_actuels'] as int? ?? 0;
            final capacite = c['capacite'] as int? ?? 1;
            return (capacite - occupants) >= 1;
          }, orElse: () => {});

          if (cageIndiv.isNotEmpty) {
            final cage = Cage.fromMap(cageIndiv);
            _cagesSelectionnees[petit.id!] = cage.numero;
          }
        }
      }

      setState(() {});
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Erreur proposition: $e');
      }
    }
  }

  /// Valider que toutes les cages sont sélectionnées et ont la capacité
  Future<bool> _validerCages() async {
    // Vérifier que tous les petits ont une cage
    for (var petit in _petits) {
      if (_cagesSelectionnees[petit.id] == null ||
          _cagesSelectionnees[petit.id]!.isEmpty) {
        SnackbarHelper.showWarning(
          context,
          'Veuillez sélectionner une cage pour ${petit.nom}',
        );
        return false;
      }
    }

    // Vérifier les capacités de chaque cage
    final cagesUtilisees = _cagesSelectionnees.values.toSet();
    for (var numeroCage in cagesUtilisees) {
      if (numeroCage == null) continue;

      // Compter combien de petits vont dans cette cage
      final nbPetits = _cagesSelectionnees.values
          .where((c) => c == numeroCage)
          .length;

      // Récupérer les infos de la cage
      final cage = await _dbHelper.getCageByNumero(numeroCage);
      if (cage == null) {
        if (!mounted) return false;
        SnackbarHelper.showError(context, 'Cage $numeroCage introuvable');
        return false;
      }

      // Vérifier la capacité
      final occupantsActuels = await _dbHelper.getOccupantsCageByNumero(
        numeroCage,
      );
      final capaciteRestante = cage.capacite - occupantsActuels;

      if (nbPetits > capaciteRestante) {
        if (!mounted) return false;
        SnackbarHelper.showError(
          context,
          'Cage $numeroCage : capacité insuffisante ($nbPetits petits, $capaciteRestante places disponibles)',
        );
        return false;
      }
    }

    return true;
  }

  /// Enregistrer le sevrage complet
  Future<void> _validerSevrage() async {
    // Validation
    if (!await _validerCages()) return;

    // Confirmer avec l'utilisateur
    final males = _petits.where((p) {
      final sexe = _sexes[p.id!] ?? p.sexe;
      return sexe.toLowerCase() == 'male' ||
          sexe.toLowerCase() == 'm' ||
          sexe.toLowerCase() == 'mâle';
    }).length;
    final femelles = _petits.where((p) {
      final sexe = _sexes[p.id!] ?? p.sexe;
      return sexe.toLowerCase() == 'femelle' || sexe.toLowerCase() == 'f';
    }).length;
    if (!mounted) return;
    final confirm = await SevrageConfirmationDialog.show(
      context,
      totalPetits: _petits.length,
      nbMales: males,
      nbFemelles: femelles,
    );
    if (!mounted) return;
    if (confirm != true) return;

    try {
      final db = await _dbHelper.database;

      // 1. Mettre à jour chaque petit : statut + localisation + poids + sexe
      for (var petit in _petits) {
        final cageNumero = _cagesSelectionnees[petit.id];
        final poids = _poids[petit.id];
        final sexe = _sexes[petit.id] ?? petit.sexe;

        await db.update(
          'lapins',
          {
            'statut': 'Sevre',
            'localisation': cageNumero,
            'poids': poids,
            'sexe': sexe,
          },
          where: 'id = ?',
          whereArgs: [petit.id],
        );
      }

      // 2. Mettre à jour la mère (statut post-sevrage)
      await db.update(
        'lapins',
        {'statut': 'Post-sevrage'},
        where: 'id = ?',
        whereArgs: [widget.mere.id],
      );

      // 3. Créer l'enregistrement de sevrage
      final poidsMoyen = _calculerPoidsMoyen();
      final sevrage = Sevrage(
        porteeId: widget.portee.id!,
        dateSevrage: DateTime.now(),
        nombreLapereaux: _petits.length,
        poidsMoyenSevrage: poidsMoyen,
        nouvelleCage: _cagesSelectionnees.values.toSet().join(', '),
        observations: _observationsController.text.isNotEmpty
            ? _observationsController.text
            : null,
        alimentationPostSevrage: _alimentationController.text.isNotEmpty
            ? _alimentationController.text
            : null,
      );

      await db.insert('sevrages', sevrage.toMap());

      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Sevrage enregistré avec succès !');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Erreur lors de l\'enregistrement: $e',
        );
      }
    }
  }

  /// Calculer le poids moyen des petits
  double? _calculerPoidsMoyen() {
    final poidsListe = _poids.values.whereType<double>().toList();
    if (poidsListe.isEmpty) return null;
    return poidsListe.reduce((a, b) => a + b) / poidsListe.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            SevrageHeader(
              portee: widget.portee,
              onBack: () => Navigator.pop(context),
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SevrageInfoSection(
                        portee: widget.portee,
                        mere: widget.mere,
                      ),
                      const SizedBox(height: 20),
                      SevrageOptions(
                        separerParSexe: _separerParSexe,
                        utiliserCagesCollectives: _utiliserCagesCollectives,
                        onSeparateurChanged: (value) {
                          setState(() => _separerParSexe = value);
                          _proposerCagesAutomatiques();
                        },
                        onCollectivesChanged: (value) {
                          setState(() => _utiliserCagesCollectives = value);
                          _proposerCagesAutomatiques();
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildListePetits(),
                      const SizedBox(height: 20),
                      SevrageExtraFields(
                        observationsController: _observationsController,
                        alimentationController: _alimentationController,
                      ),
                      const SizedBox(height: 20),
                      SevrageResume(
                        totalPetits: _petits.length,
                        nbMales: _petits.where((p) {
                          final sexe = _sexes[p.id!] ?? p.sexe;
                          return sexe.toLowerCase() == 'male' ||
                              sexe.toLowerCase() == 'm' ||
                              sexe.toLowerCase() == 'mâle';
                        }).length,
                        nbFemelles: _petits.where((p) {
                          final sexe = _sexes[p.id!] ?? p.sexe;
                          return sexe.toLowerCase() == 'femelle' ||
                              sexe.toLowerCase() == 'f';
                        }).length,
                        nbCagesUtilisees: _cagesSelectionnees.values
                            .toSet()
                            .where((c) => c != null)
                            .length,
                        poidsMoyen: _calculerPoidsMoyen(),
                        tousCagesSelectionnees: _petits.every(
                          (p) => _cagesSelectionnees[p.id] != null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SevrageValidationButton(
                        enabled: _petits.every(
                          (p) => _cagesSelectionnees[p.id] != null,
                        ),
                        onValidate: _validerSevrage,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListePetits() {
    if (_petits.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isDark ? AppTheme.stitchBorderDark : AppTheme.border,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: isDark
                    ? AppTheme.textLight.withValues(alpha: 0.5)
                    : AppTheme.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun petit trouvé pour cette portée',
                style: AppTheme.bodyMedium.copyWith(
                  color: isDark
                      ? AppTheme.textLight.withValues(alpha: 0.7)
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lapereaux à sevrer',
          style: AppTheme.titleSmall.copyWith(
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_petits.length, (index) {
          final petit = _petits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SevragePetitCard(
              petit: petit,
              cageSelectionnee: _cagesSelectionnees[petit.id],
              poids: _poids[petit.id],
              sexe: _sexes[petit.id] ?? petit.sexe,
              onPoidsChanged: (p) => setState(() => _poids[petit.id!] = p),
              onSexeChanged: (s) => setState(() {
                _sexes[petit.id!] = s;
                // Re-proposer les cages si séparation par sexe activée
                if (_separerParSexe) {
                  _proposerCagesAutomatiques();
                }
              }),
              onSelectCage: () => _selectionnerCage(petit),
            ),
          );
        }),
      ],
    );
  }

  /// Sélectionner une cage pour un petit
  Future<void> _selectionnerCage(Lapin petit) async {
    final cageInitiale = _cagesSelectionnees[petit.id];

    final cageSelectionnee = await showCageSelector(
      context,
      cageInitiale: cageInitiale,
    );

    if (cageSelectionnee != null) {
      setState(() {
        _cagesSelectionnees[petit.id!] = cageSelectionnee;
      });
    }
  }
}
