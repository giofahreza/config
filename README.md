# giofahreza-config

Personal configuration files for zsh, nvim, tmux, wezterm, Zen Browser, hyprland, and waybar.

## Setup

This repository is stored at `~/config` and is the source of truth for the personal configs below. On a new machine, clone it there:
```bash
git clone https://github.com/giofahreza/config.git ~/config
cd ~/config
```

### Link the configurations

```bash
# Zsh startup and Powerlevel10k theme
ln -sfnT "$HOME/config/zsh/.zshrc" "$HOME/.zshrc"
ln -sfnT "$HOME/config/zsh/p10k.zsh" "$HOME/.p10k.zsh"

# Application configs use the standard XDG paths, backed by ~/config.
mkdir -p "$HOME/.config"
for app in fuzzel hypr nvim tmux waybar; do
  ln -sfnT "$HOME/config/$app" "$HOME/.config/$app"
done

# Claude Code and Codex homes (whole folders)
ln -sfnT "$HOME/config/claude" "$HOME/.claude"
ln -sfnT "$HOME/config/codex" "$HOME/.codex"
```

Git tracks only the hand-written files in `claude/` and `codex/` (settings, CLAUDE.md, hooks, custom skills, Codex `*.config.toml` and model catalogs). Credentials, history, sessions, databases, logs and caches stay local; see `.gitignore`.

Hyprshell is launched with explicit paths to `~/config/hyprshell/config.toml` and `~/config/hyprshell/share`, so it does not need a `~/.config/hyprshell` symlink.

### Zen Browser

Open Zen once to create its profile, then link the shared shortcuts and startup settings:

```bash
sh "$HOME/config/zen/setup.sh"
```

The script finds Zen's default profile on macOS or Linux and links its `customKeys.json` and `user.js` to the matching files in `~/config/zen`. Existing files are backed up beside the originals. For another profile, pass its root directory (shown in `about:profiles`):

```bash
sh "$HOME/config/zen/setup.sh" "/path/to/zen/profile"
```

Edit shortcuts in `zen/customKeys.json` and startup preferences in `zen/user.js`, then restart Zen to load them. The startup preferences restore your previous windows and tabs, including regular unpinned tabs. Tabs you close yourself stay closed; private browsing tabs are not restored.

Zen's shortcut editor can replace the symlink when saving; rerun the setup script to restore the repository configuration. Browser history, logins, sessions, and the rest of the profile stay local.

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

# IO Gateway, used by cc and by Codex's aiproxy provider (cox)
export IOGW_BASE_URL="https://your-gateway-host"
export IOGW_GATEWAY_KEY="your-gateway-key"
EOF
```

### Reload shell

```bash
source ~/.zshrc
```

## Structure

- `zsh/.zshrc` - Zsh configuration with aliases and functions
- `zsh/p10k.zsh` - P10k powerlevel10k theme
- `claude/` - Claude Code home (`~/.claude`): settings, CLAUDE.md, hooks, custom skills
- `codex/` - Codex home (`~/.codex`): config profiles and model catalogs
- `.gitignore` - Git ignore rules for secret files
- `nvim/` - Neovim configuration (LazyVim based)
  - `lua/plugins/neo-tree.lua` - Neo-tree override that shows hidden files
  - `lazyvim.json` - LazyVim configuration
  - `lua/plugins/` - Custom plugins (nvim-jdtls, etc.)
- `tmux/` - Tmux configuration
- `wezterm/` - WezTerm configuration
- `zen/` - Zen Browser shortcuts, session-restore preferences, and profile-link setup script
- `hypr/` - Hyprland window manager configuration
- `hyprshell/` - Hyprland shell configuration
- `waybar/` - Waybar status bar configuration

## Commands

### Shell
- `cglm` - Claude Code with GLM API
- `cc` - Claude Code with Anthropic API (requires secrets)
- `c1-c9` - Codex agents
- `cn <id>` - Codex agent by ID
- `lg` - Lazygit

### Keybindings
- Zen: Ctrl + grave (\`) - Next Space
- Zen: Ctrl + Shift + grave (\`) - Previous Space
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
