# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path
export PATH="$HOME/.local/bin:$HOME/.local/scripts:$PATH"
export SHELL="$HOME/.local/bin/zsh"
export NNN_OPENER=xdg-open

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space

# Zsh completion
autoload -Uz compinit
compinit

# Powerlevel10k theme
[[ -r ~/.powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/.powerlevel10k/powerlevel10k.zsh-theme

# Plugins
[[ -r ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Zoxide (smarter cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Aliases
alias ls='eza --icons'
alias ll='eza -la --icons'
alias la='eza -a --icons'
alias lt='eza --tree --icons'
alias lg='lazygit'
alias c='claude --model sonnet'
alias cx='claude --dangerously-skip-permissions'
alias hyprland='start-hyprland'
alias hl='start-hyprland'
alias grep='grep --color=auto'

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

gh() {
  git config user.email "giofahreza2000@gmail.com" &&
  printf 'git user.email=%s\n' "$(git config user.email)"
}

gh-nikel() {
  git config user.email "giofahreza@ulyssestwo.com" &&
  printf 'git user.email=%s\n' "$(git config user.email)"
}

# Markdown to PDF converter (with Mermaid support)
# Usage: md2pdf file.md  (simple markdown to PDF)
# Usage: mermaid2pdf file.md  (markdown with Mermaid diagrams rendered)
alias md2pdf='md-to-pdf --config-file ~/.config/md2pdf-config.json'

# To customize prompt, run `p10k configure` or edit ~/config/zsh/p10k.zsh
[[ ! -f ~/config/zsh/p10k.zsh ]] || source ~/config/zsh/p10k.zsh

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
