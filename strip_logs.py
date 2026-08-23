import os
import re

def strip_sqf_logs(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        # Ignore les lignes contenant diag_log, systemChat ou hint
        if not re.search(r'\b(diag_log|systemChat|hint)\b', line):
            new_lines.append(line)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print(f'Stripped logs: {filepath}')

for root, dirs, files in os.walk('.'):
    for name in files:
        if name.endswith('.sqf'):
            strip_sqf_logs(os.path.join(root, name))
