#!/bin/bash
# Script to configure Neo-tree to show hidden files by default

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/giofahreza-config"
NEO_TREE_FILE="$CONFIG_DIR/nvim/lua/plugins/extras/editor/neo-tree.lua"
LAZYVIM_NEO_TREE="$HOME/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/editor/neo-tree.lua"

if [ ! -f "$NEO_TREE_FILE" ]; then
    echo "Neo-tree config not found: $NEO_TREE_FILE"
    exit 1
fi

# Copy to LazyVim location
cp "$NEO_TREE_FILE" "$LAZYVIM_NEO_TREE"
echo "Neo-tree configured to show hidden files by default"
