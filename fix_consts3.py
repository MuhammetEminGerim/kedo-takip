import re
import sys
import os

def fix_const_errors(log_path):
    with open(log_path, 'r', encoding='utf-8') as f:
        log_content = f.read()

    pattern2 = r"(lib[\/\\][\w\.\/\\]+\.dart)\((\d+),\d+\):\s+error.*constant expression"
    matches = re.findall(pattern2, log_content)

    file_fixes = {}
    for filepath, line_str in matches:
        filepath = filepath.replace('/', '\\') # normalize for windows
        line_num = int(line_str)
        if filepath not in file_fixes:
            file_fixes[filepath] = set()
        file_fixes[filepath].add(line_num)

    for filepath, lines in file_fixes.items():
        if not os.path.exists(filepath):
            print(f"File not found: {filepath}")
            continue
            
        with open(filepath, 'r', encoding='utf-8') as f:
            file_lines = f.readlines()

        # Be more aggressive: look 5 lines above and below for any 'const ' and remove it
        for line_num in lines:
            idx = line_num - 1
            for offset in range(-5, 6):
                target_idx = idx + offset
                if 0 <= target_idx < len(file_lines):
                    # We only remove const if it's followed by a space, to avoid messing up const variables if any, 
                    # but actually we might want to remove 'const\n' too or 'const ('
                    file_lines[target_idx] = re.sub(r'\bconst\s+', '', file_lines[target_idx])
                    file_lines[target_idx] = file_lines[target_idx].replace('const(', '(')

        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(file_lines)

if __name__ == "__main__":
    fix_const_errors(sys.argv[1])
