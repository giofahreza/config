#!/bin/bash
# Script to configure Neo-tree to show hidden files by default
# This modifies the LazyVim Neo-tree extra file

NEO_TREE_FILE="$HOME/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/editor/neo-tree.lua"

if [ ! -f "$NEO_TREE_FILE" ]; then
    echo "Neo-tree extra file not found: $NEO_TREE_FILE"
    exit 1
fi

# Check if already configured
if grep -q "filtered_items" "$NEO_TREE_FILE"; then
    echo "Neo-tree already configured to show hidden files"
    exit 0
fi

# Add filtered_items to filesystem section
python3 << PYTHON_EOF
with open('$NEO_TREE_FILE', 'r') as f:
    content = f.read()

old_line = '      filesystem = {\n        bind_to_cwd = false,'
new_line = '      filesystem = {\n        bind_to_cwd = false,\n        filtered_items = {\n          hide_dotfiles = false,\n          hide_hidden = false,\n        },'

if old_line in content and 'filtered_items' not in content:
    content = content.replace(old_line, new_line)
    with open('$NEO_TREE_FILE', 'w') as f:
        f.write(content)
    print("Modified successfully")
else:
    print("Already modified or pattern not found")
PYTHON_EOF

echo "Neo-tree configured to show hidden files by default"
