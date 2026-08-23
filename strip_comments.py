import os
import re

def strip_sqf_comments(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # Pattern ultra-robuste qui matche d'abord les chaînes de caractères pour ne pas y toucher, 
    # PUIS les commentaires blocs, PUIS les commentaires ligne.
    # Les chaînes en SQF peuvent utiliser " ou ' et s'échappent en les doublant ("" ou '').
    pattern = r'("([^"]|"")*"|\'([^\']|\'\')*\')|/\*[\s\S]*?\*/|//.*'
    
    def replacer(match):
        # Si c'est une chaîne de caractères (groupe 1), on la conserve telle quelle.
        # Si c'est un commentaire (pas de groupe 1), on le supprime en renvoyant rien.
        if match.group(1) is not None:
            return match.group(1)
        else:
            return ''
            
    content = re.sub(pattern, replacer, content)
    
    # Nettoyage des espaces et lignes vides superflues
    content = re.sub(r'^[ \t]+$', '', content, flags=re.MULTILINE)
    content = re.sub(r'\n{3,}', '\n\n', content)
    content = content.strip() + '\n'

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Stripped: {filepath}')

for root, dirs, files in os.walk('.'):
    for name in files:
        if name.endswith('.sqf') or name.endswith('.ext') or name.endswith('.hpp'):
            strip_sqf_comments(os.path.join(root, name))
