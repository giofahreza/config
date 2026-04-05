if [ -z "${ZSH_VERSION:-}" ]; then
  echo "This file is for zsh. Start zsh with: exec zsh" >&2
  return 0 2>/dev/null || exit 0
fi

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi

export SHELL=/usr/bin/zsh

if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${TMUX:-}" ]; then
  export PATH="$HOME/.local/bin:$HOME/.local/scripts:$HOME/.opencode/bin:$PATH"
  export NNN_OPENER=xdg-open
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

  HISTFILE=~/.zsh_history
  HISTSIZE=10000
  SAVEHIST=10000
  setopt appendhistory
  setopt sharehistory
  setopt hist_ignore_dups
  setopt hist_ignore_space

  autoload -Uz compinit
  compinit

  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

  alias ls='eza --icons'
  alias ll='eza -la --icons'
  alias la='eza -a --icons'
  alias lt='eza --tree --icons'
  alias lg='lazygit'
  alias c='claude --model sonnet'
  alias cx='claude --dangerously-skip-permissions'
  alias grep='grep --color=auto'
  alias md2pdf='md-to-pdf --config-file ~/.config/md2pdf-config.json'

  codex-agent() {
    local agent_id="$1"
    shift || true

    if [[ -z "${agent_id}" ]]; then
      echo "usage: codex-agent <id> [codex args...]" >&2
      return 1
    fi

    CODEX_PLAYWRIGHT_PROFILE="agent-${agent_id}" codex "$@"
  }

  for _codex_agent_id in {1..9}; do
    eval "c${_codex_agent_id}() { codex-agent ${_codex_agent_id} \"\$@\"; }"
  done
  unset _codex_agent_id

  cn() {
    if [[ -z "${1:-}" ]]; then
      echo "usage: cn <id> [codex args...]" >&2
      return 1
    fi

    local agent_id="$1"
    shift
    codex-agent "${agent_id}" "$@"
  }

  cc() {
    if [[ -z "${ANTHROPIC_BASE_URL:-}" || -z "${ANTHROPIC_API_KEY:-}" ]]; then
      echo "Set ANTHROPIC_BASE_URL and ANTHROPIC_API_KEY before using cc." >&2
      return 1
    fi

    ANTHROPIC_DEFAULT_HAIKU_MODEL="${ANTHROPIC_DEFAULT_HAIKU_MODEL:-gpt-4.1}" \
    ANTHROPIC_DEFAULT_SONNET_MODEL="${ANTHROPIC_DEFAULT_SONNET_MODEL:-gemini-2.5-pro}" \
    ANTHROPIC_DEFAULT_OPUS_MODEL="${ANTHROPIC_DEFAULT_OPUS_MODEL:-claude-sonnet-4}" \
    claude --dangerously-skip-permissions "$@"
  }

  cglm() {
    if [[ -z "${ANTHROPIC_BASE_URL:-}" || -z "${ANTHROPIC_API_KEY:-}" ]]; then
      echo "Set ANTHROPIC_BASE_URL and ANTHROPIC_API_KEY before using cglm." >&2
      return 1
    fi

    IS_SANDBOX=1 \
    ANTHROPIC_DEFAULT_HAIKU_MODEL="${ANTHROPIC_DEFAULT_HAIKU_MODEL:-glm-4.5-air}" \
    ANTHROPIC_DEFAULT_SONNET_MODEL="${ANTHROPIC_DEFAULT_SONNET_MODEL:-glm-4.7}" \
    ANTHROPIC_DEFAULT_OPUS_MODEL="${ANTHROPIC_DEFAULT_OPUS_MODEL:-glm-5.1}" \
    claude --dangerously-skip-permissions "$@"
  }

  gh-personal() {
    git config user.email "giofahreza2000@gmail.com" &&
    printf 'git user.email=%s\n' "$(git config user.email)"
  }

  gh-nikel() {
    git config user.email "giofahreza@ulyssestwo.com" &&
    printf 'git user.email=%s\n' "$(git config user.email)"
  }

  PROMPT='%F{39}%~%f %# '
  RPROMPT=
  unsetopt promptcr
  unsetopt promptsp
else
  if [ -f "$HOME/.config/giofahreza-config-20260324/zsh/.zshrc" ]; then
    source "$HOME/.config/giofahreza-config-20260324/zsh/.zshrc"
  fi
fi

if ! command -v eza >/dev/null 2>&1; then
  unalias ls ll la lt 2>/dev/null
fi

if ! command -v lazygit >/dev/null 2>&1; then
  unalias lg 2>/dev/null
fi

# Load local secrets (not committed to git)
if [ -f "$HOME/.zshrc.secret" ]; then
  source "$HOME/.zshrc.secret"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/root/.sdkman"
[[ -s "/root/.sdkman/bin/sdkman-init.sh" ]] && source "/root/.sdkman/bin/sdkman-init.sh"

# Prefer normal completion behavior over menu-style cycling/listing on first Tab.
unsetopt menucomplete
unsetopt bashautolist
setopt autolist
setopt completeinword
setopt nolistbeep

bindkey '^I' expand-or-complete
bindkey '^[[Z' reverse-menu-complete

zstyle ':completion:*' menu no
zstyle ':completion:*' list-prompt '%S%M matches%s'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
