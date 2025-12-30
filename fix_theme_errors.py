#!/usr/bin/env python3
"""
Script pour corriger automatiquement les erreurs de thème dans les fichiers Dart.
"""

import os
import re
import sys

def add_missing_imports(content, filepath):
    """Ajoute l'import AppTheme si manquant"""
    if 'AppTheme.' in content and 'import' in content and 'app_theme.dart' not in content:
        # Calculer le nombre de ../ nécessaires
        depth = filepath.count(os.sep) - filepath.count('lib' + os.sep) - 1
        import_path = '../' * depth + 'theme/app_theme.dart'
        
        # Trouver où insérer l'import (après le dernier import)
        import_pattern = r"(import [^;]+;)\n"
        matches = list(re.finditer(import_pattern, content))
        if matches:
            last_import = matches[-1]
            insert_pos = last_import.end()
            new_import = f"import '{import_path}';\n"
            content = content[:insert_pos] + new_import + content[insert_pos:]
    return content

def fix_color_parameter(content):
    """Corrige les paramètres color mal placés : style: AppTheme.xxx, color: yyy -> style: AppTheme.xxx.copyWith(color: yyy)"""
    # Pattern: style: AppTheme.xxx, \n color: yyy, \n ),
    pattern = r'(style:\s*AppTheme\.\w+),(\s*)\n(\s*)color:\s*([^,\)]+),(\s*)\n(\s*)\),'
    replacement = r'\1.copyWith(\n\3  color: \4,\n\3),\2'
    content = re.sub(pattern, replacement, content)
    
    # Pattern alternatif sans virgule finale
    pattern2 = r'(style:\s*AppTheme\.\w+)(\s*)\n(\s*)color:\s*([^,\)]+)(\s*)\n(\s*)\),'
    replacement2 = r'\1.copyWith(\n\3  color: \4,\n\3),'
    content = re.sub(pattern2, replacement2, content)
    
    return content

def fix_overflow_parameter(content):
    """Corrige les paramètres overflow mal placés"""
    pattern = r'(style:\s*AppTheme\.\w+),(\s*)\n(\s*)overflow:\s*([^,\)]+),(\s*)\n(\s*)\),'
    replacement = r'\1,\n\3overflow: \4,\n\2'
    content = re.sub(pattern, replacement, content)
    return content

def fix_extra_closing_parens(content):
    """Supprime les parenthèses fermantes en trop après style"""
    # Pattern spécifique: ),  suivi de ), sur deux lignes
    pattern = r'(style:\s*AppTheme\.\w+),\s*\n\s*\),\s*\n\s*\),'
    replacement = r'\1,\n),'
    content = re.sub(pattern, replacement, content)
    return content

def fix_const_with_copywith(content):
    """Retire 'const' devant les widgets qui utilisent copyWith ou withValues"""
    # Pattern: const Text( ... copyWith ...
    pattern = r'const\s+(Text|Icon|Padding|Row|Column|Container|Center)\s*\('
    
    def check_and_replace(match):
        widget = match.group(1)
        start_pos = match.start()
        # Chercher le bloc complet du widget
        # Pour simplifier, on retire le const si copyWith ou withValues apparaît dans les 200 caractères suivants
        snippet = content[start_pos:start_pos+300]
        if 'copyWith' in snippet or 'withValues' in snippet:
            return f'{widget}('
        return match.group(0)
    
    content = re.sub(pattern, check_and_replace, content)
    return content

def process_file(filepath):
    """Traite un fichier Dart"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Appliquer les corrections
        content = add_missing_imports(content, filepath)
        content = fix_color_parameter(content)
        content = fix_overflow_parameter(content)
        content = fix_const_with_copywith(content)
        content = fix_extra_closing_parens(content)
        
        # Si le contenu a changé, sauvegarder
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'✓ Fixed: {filepath}')
            return True
        return False
    except Exception as e:
        print(f'✗ Error processing {filepath}: {e}')
        return False

def main():
    # Trouver tous les fichiers .dart dans lib/screens
    screens_dir = 'lib/screens'
    if not os.path.exists(screens_dir):
        print(f'Error: {screens_dir} not found')
        sys.exit(1)
    
    fixed_count = 0
    total_count = 0
    
    for root, dirs, files in os.walk(screens_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                total_count += 1
                if process_file(filepath):
                    fixed_count += 1
    
    print(f'\n{fixed_count}/{total_count} files fixed')

if __name__ == '__main__':
    main()
