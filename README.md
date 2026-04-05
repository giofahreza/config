# giofahreza-config

Personal configuration files for zsh, nvim, tmux, wezterm, hyprland, and waybar.

## Setup

Clone this repository:
```bash
git clone https://github.com/giofahreza/config.git ~/.config/giofahreza-config
cd ~/.config/giofahreza-config
```

### Create symlinks

```bash
# zsh config
ln -sf ~/.config/giofahreza-config/zsh/.zshrc ~/.zshrc

# Claude Code config
mkdir -p ~/.claude
ln -sf ~/.config/giofahreza-config/.claude/settings.json ~/.claude/settings.json
```

### Create secrets file

Create `~/.zshrc.secret` with your API keys (never commit this):

```bash
cat > ~/.zshrc.secret << 'EOF'
# Claude Code (cglm) - GLM API
export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"
export ANTHROPIC_API_KEY="your-api-key-here"

# Claude Code (cc) - Optional Anthropic API
# export ANTHROPIC_BASE_URL="https://api.anthropic.com"
# export ANTHROPIC_API_KEY="your-key-here"
EOF
```

### Configure Neo-tree to show hidden files

```bash
~/.config/giofahreza-config/setup-neo-tree-hidden-files.sh
```

**Note:** This copies the Neo-tree extra config to your nvim LazyVim cache. Re-run this script after LazyVim updates.

### Reload shell

```bash
source ~/.zshrc
```

## Structure

- `zsh/.zshrc` - Zsh configuration with aliases and functions
- `zsh/p10k.zsh` - P10k powerlevel10k theme
- `.claude/settings.json` - Claude Code CLI status line
- `.gitignore` - Git ignore rules for secret files
- `nvim/` - Neovim configuration (LazyVim based)
  - `lua/plugins/extras/editor/neo-tree.lua` - Neo-tree extra with hidden files enabled
  - `lazyvim.json` - LazyVim configuration
  - `lua/plugins/` - Custom plugins (nvim-jdtls, etc.)
- `tmux/` - Tmux configuration
- `wezterm/` - WezTerm configuration
- `hypr/` - Hyprland window manager configuration
- `hyprshell/` - Hyprland shell configuration
- `waybar/` - Waybar status bar configuration
- `setup-neo-tree-hidden-files.sh` - Script to configure Neo-tree hidden files

## Commands

### Shell
- `cglm` - Claude Code with GLM API
- `cc` - Claude Code with Anthropic API (requires secrets)
- `c1-c9` - Codex agents
- `cn <id>` - Codex agent by ID
- `lg` - Lazygit

### Keybindings
- `<leader>fe` - Toggle Neo-tree (root directory)
- `<leader>fE` - Toggle Neo-tree (current directory)
- `<leader>e` - Toggle Neo-tree (root directory)
- `<leader>E` - Toggle Neo-tree (current directory)
- `<leader>ge` - Git explorer
- `<leader>be` - Buffer explorer

## Features

- **Centralized configuration** - All configs in one git repository
- **Secret management** - API keys in local `.zshrc.secret` (not committed)
- **Claude Code status line** - Shows `parent/current @ git-branch`
- **Neo-tree hidden files** - Shows hidden files by default
- **Zsh aliases** - Codex agents, Git operations, Lazygit
- **LazyVim-based nvim** - Modern Neovim configuration with Lua
- **Hyprland + Waybar** - Complete Wayland desktop environment setup
