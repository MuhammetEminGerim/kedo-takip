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
            continue
            
        with open(filepath, 'r', encoding='utf-8') as f:
            file_lines = f.readlines()

        for line_num in lines:
            idx = line_num - 1
            if idx < len(file_lines):
                # We simply remove 'const ' from that line
                file_lines[idx] = file_lines[idx].replace('const ', '')
                file_lines[idx] = file_lines[idx].replace('const\n', '\n')
                
                # Check up to 3 lines above for a floating 'const'
                for offset in range(1, 4):
                    if idx - offset >= 0:
                        if 'const ' in file_lines[idx - offset] or 'const\n' in file_lines[idx - offset]:
                            file_lines[idx - offset] = file_lines[idx - offset].replace('const ', '').replace('const\n', '\n')
                            # Don't break, might be multiple consts, though usually one

        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(file_lines)

if __name__ == "__main__":
    fix_const_errors(sys.argv[1])
