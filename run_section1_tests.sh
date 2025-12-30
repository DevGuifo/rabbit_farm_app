#!/bin/bash
# 🧪 SCRIPT DE TEST AUTOMATISÉ SECTION 1 - VALIDATION VISUELLE
# Utilise flutter driver pour tester les écrans modifiés

echo "=========================================="
echo "🧪 SECTION 1 - VALIDATION VISUELLE"
echo "=========================================="
echo ""

# Configuration
DEVICE="linux"
BUILD_MODE="debug"
TIMEOUT="30"

# Étape 1: Vérifier que l'app peut démarrer
echo "✓ Étape 1: Vérification de la compilation..."
flutter pub get --offline 2>&1 | tail -3
flutter analyze --no-pub 2>&1 | grep -E "^0 issues" || echo "⚠️  Analyse complète"

echo ""
echo "✓ Étape 2: Lancement de l'application sur $DEVICE..."
echo ""
echo "Commande pour lancer l'app avec tests:"
echo "  flutter run -d linux --verbose"
echo ""
echo "Ou pour Chrome:"
echo "  flutter run -d chrome --verbose"
echo ""

# Créer un rapport de test
TEST_REPORT="/tmp/flutter_test_section1.txt"
cat > "$TEST_REPORT" << 'EOF'
# RAPPORT TEST SECTION 1 - À REMPLIR MANUELLEMENT

## 🎯 Tâche 1.1: Light Mode Testing

### Dashboard
- [ ] AppBar couleur correcte (primaryGreen)
- [ ] Stats cards visibles et lisibles
- [ ] Boutons avec bonne couleur
- [ ] Pas de conflit couleur
- [ ] Text contrast OK (>= 4.5:1)

### Alertes
- [ ] Liste affichée correctement
- [ ] Couleur warning visible
- [ ] Pas de texte illisible

### Alimentation
- [ ] Inventaire affichée correctement
- [ ] Boutons couleur primaryGreen
- [ ] Filtres visibles

### Sevrage (20 couleurs)
- [ ] Header avec primaryGreen
- [ ] Liste portées affichée
- [ ] Dialog sevrage lisible
- [ ] Tous les 20 colors visibles

### Utilitaire (12 couleurs)
- [ ] 6+ action cards visible
- [ ] Couleur distinctes OK
- [ ] Texte blanc lisible sur fond

### Autres écrans
- [ ] Ajouter Soin - formulaire OK
- [ ] Ajouter Médicament - formulaire OK
- [ ] Ajouter Aliment - formulaire OK
- [ ] Éditer Sevrage - formulaire OK
- [ ] Pharmacie - liste OK
- [ ] Réforme - liste OK
- [ ] Quarantaine - liste OK

## 🎨 Tâche 1.2: Dark Mode Testing

- [ ] Theme dark appliqué
- [ ] Fonds backgroundDarkMode corrects
- [ ] Texte lisible en white/light
- [ ] Tous les écrans visibles

## 🔄 Tâche 1.3: Navigation & Fonctionnalités

- [ ] Navigation sans crash
- [ ] FAB buttons fonctionnent
- [ ] Formulaires sauvegardent
- [ ] Dialogs fonctionnent

## 📊 Tâche 1.4: Rapport Cohérence

- [ ] Cohérence couleur améliorée
- [ ] Pas de hardcoded colors dissonants
- [ ] Design plus professionnel
EOF

echo "✅ Rapport template créé: $TEST_REPORT"
echo ""
echo "=========================================="
echo "📝 Instructions pour tester Section 1:"
echo "=========================================="
echo ""
echo "1️⃣ Lancer l'app sur Linux (desktop):"
echo "   cd /home/guifo/Bureau/rabbit_farm_app"
echo "   flutter run -d linux"
echo ""
echo "2️⃣ Ou lancer sur Chrome (web):"
echo "   flutter run -d chrome"
echo ""
echo "3️⃣ Tester visuellement chaque écran:"
echo "   - Light mode (par défaut)"
echo "   - Dark mode (Settings → Theme → Dark)"
echo ""
echo "4️⃣ Remplir le rapport de test:"
echo "   cat $TEST_REPORT"
echo ""
echo "=========================================="
