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
# Zsh startup
ln -sfnT "$HOME/config/zsh/.zshrc" "$HOME/.zshrc"

# Application configs use the standard XDG paths, backed by ~/config.
mkdir -p "$HOME/.config"
for app in foot fuzzel hypr mako nvim tmux waybar wezterm; do
  ln -sfnT "$HOME/config/$app" "$HOME/.config/$app"
done

# Claude Code and Codex homes (whole folders)
ln -sfnT "$HOME/config/claude" "$HOME/.claude"
ln -sfnT "$HOME/config/codex" "$HOME/.codex"
```

Git tracks only the hand-written files in `claude/` and `codex/` (settings, CLAUDE.md, hooks, custom skills, Codex `*.config.toml` and model catalogs). Credentials, history, sessions, databases, logs and caches stay local; see `.gitignore`.

Hyprshell is launched with explicit paths to `~/config/hyprshell/config.toml` and `~/config/hyprshell/share`, so it does not need a `~/.config/hyprshell` symlink.

### Linux desktop fonts and notifications

Fuzzel, Waybar, and Mako use `Monofur Nerd Font Mono`. Install its font files
in `~/.local/share/fonts/Monofur/` on each Linux machine, then run
`fc-cache -f`. For the Nerd Fonts `Monofur.zip` download:

```bash
mkdir -p "$HOME/.local/share/fonts/Monofur"
unzip -j "$HOME/Downloads/Monofur.zip" \
  MonofurNerdFontMono-Regular.ttf MonofurNerdFontMono-Bold.ttf \
  MonofurNerdFontMono-Italic.ttf LICENSE.txt \
  -d "$HOME/.local/share/fonts/Monofur"
fc-cache -f "$HOME/.local/share/fonts/Monofur"
```

The font files stay local; Git tracks the application settings. Fuzzel uses
12 points, Waybar 12 pixels, and Mako 10 points. Mako's config lives in
`mako/config`, linked through `~/.config/mako` like the other application folders.
Move any existing real `~/.config/mako` directory aside before creating that
link. Run `makoctl reload` after editing it; Fuzzel reads its config on each
launch, and `systemctl --user kill --signal=SIGUSR2 hypr-waybar.service` reloads
this machine's Waybar configuration and style.

### Zen Browser

Open Zen once to create its profile, then link the shared shortcuts and startup settings:

```bash
sh "$HOME/config/zen/setup.sh"
```

The script finds Zen's default profile on macOS or Linux and links its `customKeys.json` and `user.js` to the matching files in `~/config/zen`. Existing files are backed up beside the originals.

On Linux, it checks `${XDG_CONFIG_HOME:-$HOME/.config}/zen` first, then the
legacy `~/.zen` location. On macOS, it uses `~/Library/Application Support/zen`.

For another profile, pass its root directory (shown in `about:profiles`):

```bash
sh "$HOME/config/zen/setup.sh" "/path/to/zen/profile"
```

Edit shortcuts in `zen/customKeys.json` and startup preferences in `zen/user.js`, then restart Zen to load them. The startup preferences restore your previous windows and tabs, including regular unpinned tabs. Tabs you close yourself stay closed; private browsing tabs are not restored.

Zen's shortcut editor can replace the symlink when saving; rerun the setup script to restore the repository configuration. Browser history, logins, sessions, and the rest of the profile stay local.

### Toshy keyboard configuration

Install Toshy before linking its folder on a new machine. On this machine,
`~/.config/toshy` links to `~/config/toshy`, including its local Python runtime.
Git tracks `toshy/toshy_config.py`; application files, the virtual environment,
preferences database and caches are ignored.

The editable sections select the K380, the Compx receiver keyboard, and keyd's
virtual keyboard. keyd keeps handling the built-in keyboard's Copilot chord;
Toshy reads its output instead of competing for the physical device. The keyd
config uses the full physical-keyboard ID, because Toshy's virtual keyboard has
the same vendor/product ID. Its source is `keyd/default.conf`; deploy changes
with `sudo install -m 0644 ~/config/keyd/default.conf /etc/keyd/default.conf`
and `sudo systemctl restart keyd`. Foot's
`foot` app identifier is added to the terminal list. The editable shortcut rules
also map physical Ctrl+Left/Right to Hyprland workspace navigation in both
terminal and GUI contexts, excluding remote desktop/VM windows. Other shortcut
rules remain upstream defaults.

Hyprland provides the native backend shortcuts that Toshy emits: Super+D opens
fuzzel, Alt+F4 closes a window, and Alt+F10 toggles maximization. hyprshell handles
Alt+Tab for Command+Tab; `scripts/cycle-app-window` handles Alt+grave for cycling
the same application's windows. The former Super+letter and Super+number bindings are
removed. Media/brightness keys, Print screenshots and touchpad gestures remain.
Ctrl+Left/Right uses a private Super+Ctrl+Alt+arrow backend to cycle existing
Hyprland workspaces in order, including workspaces on other monitors. This is
desktop navigation. Ctrl+1–9 selects a numbered workspace, creating it when
missing. Ctrl+Shift+Left/Right moves the focused window to the previous/next
existing workspace (wrapping and including other monitors) and follows it.
Ctrl+Shift+1–9 moves the focused window to that numbered workspace, creating it
when missing, and follows it. The Shift-to-move shortcuts are custom Linux
bindings, not default macOS shortcuts. These work in GUI apps and terminals,
including tmux/Codex inside Foot, and exclude remote desktop/VM windows.
Command+number remains available to applications. The compositor receives
private Super+Ctrl+Alt shortcuts, with Shift for window moves.

In Zen, physical Ctrl+grave selects the next browser Space,
and Ctrl+Shift+grave selects the previous one. Toshy emits Ctrl+grave and
Ctrl+Shift+grave to match the shared `zen/customKeys.json` shortcuts used on
macOS and Linux. Command+grave keeps its same-app window switching behavior.

Control+Command+Q locks the screen with swaylock in both terminals (including
tmux/Codex inside Foot) and GUI apps, matching macOS. Toshy handles this before
application shortcut rules and emits the private Super+Ctrl+Alt+L compositor
shortcut. Command+L follows the upstream application shortcut rules again;
native Control+L in terminals is unchanged.

Command+left-button drag moves/reorders a window, including across monitors;
Command+right-button drag resizes it (adjusting the split for tiled windows).
These use Hyprland's Ctrl+mouse bindings because Toshy's held Command is right
Ctrl. Hyprland treats both Ctrl sides alike, so native Control+drag in terminals
also moves/resizes windows. H/J/K/L navigation is not configured.
There is no Hyprland implementation of Command+H in the upstream preset.

Foot uses its native shortcuts with no custom key bindings. Its config lives in
`foot/`. Zen's shared shortcut overrides live in `zen/customKeys.json`,
linked from the active profile. Restart Zen after updating that file.

Use the managed wrapper for Toshy updates, because the upstream installer
replaces its config directory and cannot replace a directory symlink directly:

```bash
ln -sfn "$HOME/config/scripts/toshy-reinstall" "$HOME/.local/bin/toshy-reinstall"
ln -sfn "$HOME/config/scripts/start-hyprshell" "$HOME/.local/bin/start-hyprshell"
toshy-reinstall
```

The wrapper backs up the installation, temporarily restores the conventional
directory layout, runs the upstream bootstrap installer, and restores the link.
If the installer fails, it restores the previous installation. Initial migration
backups are in `~/.local/state/toshy/backups/20261123-132153/`; system-file backups
are in `/var/backups/toshy-20261123-131920/`.

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

Restart the current shell to load the configuration and unload any old prompt hooks:

```bash
exec zsh
```

## Structure

- `zsh/.zshrc` - Zsh configuration with aliases and functions
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
- `foot/` - Foot config, using native terminal key bindings
- `fuzzel/` - Application launcher configuration
- `mako/` - Notification configuration, linked from `~/.config/mako`
- `toshy/toshy_config.py` - Toshy keyboard configuration
- `scripts/` - Managed hyprshell startup and Toshy update helpers
- `waybar/` - Waybar status bar configuration

## Commands

### Shell
- `cglm` - Claude Code with GLM API
- `cc` - Claude Code with Anthropic API (requires secrets)
- `c1-c9` - Codex agents
- `cn <id>` - Codex agent by ID
- `lg` - Lazygit

### Keybindings
- Linux: Ctrl + 1–9 - Switch to/create numbered workspace
- Linux: Ctrl + Shift + Left/Right - Move focused window to previous/next existing workspace and follow
- Linux: Ctrl + Shift + 1–9 - Move focused window to numbered workspace and follow
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
