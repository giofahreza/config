# giofahreza-config

Personal configuration files for zsh, Claude Code, nvim, tmux, and wezterm.

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

**Note:** This modifies the LazyVim Neo-tree extra file. Re-run this script after LazyVim updates.

### Reload shell

```bash
source ~/.zshrc
```

## Structure

- `zsh/.zshrc` - Zsh configuration with aliases and functions
- `.claude/settings.json` - Claude Code CLI status line
- `nvim/` - Neovim configuration
- `tmux/` - Tmux configuration
- `wezterm/` - WezTerm configuration
- `setup-neo-tree-hidden-files.sh` - Script to configure Neo-tree hidden files

## Commands

- `cglm` - Claude Code with GLM API
- `cc` - Claude Code with Anthropic API (requires secrets)
- `c1-c9` - Codex agents
- `cn <id>` - Codex agent by ID
- `lg` - Lazygit
