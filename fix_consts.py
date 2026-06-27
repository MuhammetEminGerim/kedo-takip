import re
import sys
import os

def fix_const_errors(log_path):
    with open(log_path, 'r', encoding='utf-8') as f:
        log_content = f.read()

    # Matches both formats:
    # Format 1: - lib\file.dart:line:col - const_eval
    # Format 2: lib/file.dart(line,col): error
    
    pattern1 = r"(lib[\/\\][\w\.\/\\]+\.dart):(\d+):\d+\s+-\s+const_eval"
    pattern2 = r"(lib[\/\\][\w\.\/\\]+\.dart)\((\d+),\d+\):\s+error.*constant expression"
    
    matches1 = re.findall(pattern1, log_content)
    matches2 = re.findall(pattern2, log_content)
    
    matches = matches1 + matches2

    file_fixes = {}
    for filepath, line_str in matches:
        filepath = filepath.replace('/', '\\') # normalize for windows
        line_num = int(line_str)
        if filepath not in file_fixes:
            file_fixes[filepath] = set()
        file_fixes[filepath].add(line_num)

    for filepath, lines in file_fixes.items():
        if not os.path.exists(filepath):
            continue
            
        with open(filepath, 'r', encoding='utf-8') as f:
            file_lines = f.readlines()

        for line_num in lines:
            idx = line_num - 1
            if idx < len(file_lines):
                # We simply remove 'const ' from that line
                file_lines[idx] = file_lines[idx].replace('const ', '')
                file_lines[idx] = file_lines[idx].replace('const\n', '\n')

        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(file_lines)

if __name__ == "__main__":
    fix_const_errors(sys.argv[1])
