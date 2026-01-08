import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/journal_entry.dart';

/// Helpers pour obtenir les labels localisés des enums
/// Utilisez ces fonctions au lieu des extensions .label hardcodées

/// Obtenir le label localisé d'un TypeEntite
String getTypeEntiteLabel(BuildContext context, TypeEntite type) {
  final l10n = AppLocalizations.of(context);
  switch (type) {
    case TypeEntite.lapin:
      return l10n.typeEntiteLapin;
    case TypeEntite.portee:
      return l10n.typeEntitePortee;
    case TypeEntite.accouplement:
      return l10n.typeEntiteAccouplement;
    case TypeEntite.soin:
      return l10n.typeEntiteSoin;
    case TypeEntite.pesee:
      return l10n.typeEntitePesee;
    case TypeEntite.depense:
      return l10n.typeEntiteDepense;
    case TypeEntite.recette:
      return l10n.typeEntiteRecette;
    case TypeEntite.vente:
      return l10n.typeEntiteVente;
    case TypeEntite.deces:
      return l10n.typeEntiteDeces;
    case TypeEntite.reforme:
      return l10n.typeEntiteReforme;
    case TypeEntite.quarantaine:
      return l10n.typeEntiteQuarantaine;
    case TypeEntite.sevrage:
      return l10n.typeEntiteSevrage;
    case TypeEntite.rituel:
      return l10n.typeEntiteRituel;
    case TypeEntite.anomalie:
      return l10n.typeEntiteAnomalie;
    case TypeEntite.aliment:
      return l10n.typeEntiteAliment;
    case TypeEntite.medicament:
      return l10n.typeEntiteMedicament;
    case TypeEntite.cage:
      return l10n.typeEntiteCage;
    case TypeEntite.clapier:
      return l10n.typeEntiteClapier;
    case TypeEntite.batiment:
      return l10n.typeEntiteBatiment;
    case TypeEntite.palpation:
      return l10n.typeEntitePalpation;
    case TypeEntite.preparationNid:
      return l10n.typeEntitePreparationNid;
    case TypeEntite.autre:
      return l10n.typeEntiteAutre;
  }
}

/// Obtenir le label localisé d'un TypeAction
String getTypeActionLabel(BuildContext context, TypeAction type) {
  final l10n = AppLocalizations.of(context);
  switch (type) {
    case TypeAction.creation:
      return l10n.typeActionCreation;
    case TypeAction.modification:
      return l10n.typeActionModification;
    case TypeAction.suppression:
      return l10n.typeActionSuppression;
    case TypeAction.validation:
      return l10n.typeActionValidation;
    case TypeAction.annulation:
      return l10n.typeActionAnnulation;
    case TypeAction.completion:
      return l10n.typeActionCompletion;
    case TypeAction.observation:
      return l10n.typeActionObservation;
    case TypeAction.anomalie:
      return l10n.typeActionAnomalie;
    case TypeAction.alerte:
      return l10n.typeActionAlerte;
    case TypeAction.rappel:
      return l10n.typeActionRappel;
  }
}

/// Obtenir le label localisé d'un StatutEvenement
String getStatutEvenementLabel(BuildContext context, StatutEvenement statut) {
  final l10n = AppLocalizations.of(context);
  switch (statut) {
    case StatutEvenement.normal:
      return l10n.statutEvenementNormal;
    case StatutEvenement.anomalie:
      return l10n.statutEvenementAnomalie;
    case StatutEvenement.action:
      return l10n.statutEvenementAction;
    case StatutEvenement.info:
      return l10n.statutEvenementInfo;
    case StatutEvenement.succes:
      return l10n.statutEvenementSucces;
  }
}
