if [ -z "${ZSH_VERSION:-}" ]; then
  echo "This file is for zsh. Start zsh with: exec zsh" >&2
  return 0 2>/dev/null || exit 0
fi

# Powerlevel10k instant prompt. Keep this near the top of ~/.zshrc.
if [[ -r "$HOME/.cache/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$HOME/.cache/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi

export SHELL=/usr/bin/zsh
export EDITOR=nvim
export VISUAL=nvim

# Clear any pre-existing `cx` alias (from older versions of this file or
# from the running shell) so the function defined below can take over. Done
# unconditionally on every source so that re-sourcing .zshrc does not
# trigger zsh's "defining function based on alias" parse error.
unalias cx 2>/dev/null

# Only load interactive shell customizations in interactive sessions.
if [[ -o interactive ]]; then
  # Keep inherited no-color environments from muting terminal TUIs.
  unset NO_COLOR

  export PATH="$HOME/.local/bin:$HOME/.local/scripts:$PATH"
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
  alias grep='grep --color=auto'
  alias md2pdf='md-to-pdf --config-file ~/.config/md2pdf-config.json'

  # cx: smart Claude CLI wrapper. Mirrors the routing in
  # web-ai-cli's server/claude-sdk.js so that running `cx` locally behaves
  # the same as the app:
  #   - MiniMax-M3 / minimax-* → MiniMax provider (api.minimax.io/anthropic)
  #   - everything else (opus / sonnet / haiku / default) → Claude subscription
  #     (api.anthropic.com via OAuth or ANTHROPIC_API_KEY env)
  #
  # We pass --setting-sources project,local so the MiniMax env block in
  # ~/.claude/settings.json (written by web-ai-cli for its own sessions)
  # does not leak into direct `claude` invocations.
  cx() {
    local model=""
    local args=()
    while (( $# > 0 )); do
      case "$1" in
        --model|-m)
          model="$2"
          shift 2
          ;;
        --model=*)
          model="${1#--model=}"
          shift
          ;;
        -m=*)
          model="${1#-m=}"
          shift
          ;;
        *)
          args+=("$1")
          shift
          ;;
      esac
    done

    if [[ "${model:l}" == *minimax* ]]; then
      local minimax_key
      minimax_key=$(jq -r '.env.ANTHROPIC_API_KEY // empty' /home/giofahreza/.claude/settings.json 2>/dev/null)
      if [[ -z "$minimax_key" ]]; then
        minimax_key="${MINIMAX_API_KEY:-}"
      fi
      if [[ -z "$minimax_key" ]]; then
        echo "MiniMax key not found in ~/.claude/settings.json or \$MINIMAX_API_KEY" >&2
        return 1
      fi

      (
        unset ANTHROPIC_AUTH_TOKEN \
          ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL \
          ANTHROPIC_DEFAULT_HAIKU_MODEL ANTHROPIC_SMALL_FAST_MODEL
        ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" \
        ANTHROPIC_AUTH_TOKEN="$minimax_key" \
        command claude \
          --setting-sources project,local \
          --dangerously-skip-permissions \
          --model "$model" \
          "${args[@]}"
      )
    else
      command claude \
        --setting-sources project,local \
        --dangerously-skip-permissions \
        ${model:+--model "$model"} \
        "${args[@]}"
    fi
  }

  cox() {
    if [[ "$1" == "resume" ]]; then
      shift
      local argument session_id
      local include_all=0
      local use_last=0
      local expects_value=0
      local -a picker_args resume_options positionals

      for argument in "$@"; do
        if [[ "$argument" == "-h" || "$argument" == "--help" ]]; then
          codex --yolo --profile default resume "$@"
          return
        fi
      done

      while (( $# > 0 )); do
        argument="$1"
        shift
        if (( expects_value )); then
          resume_options+=("$argument")
          expects_value=0
          continue
        fi
        case "$argument" in
          --all)
            include_all=1
            ;;
          --last)
            use_last=1
            ;;
          --include-non-interactive)
            ;;
          -c|--config|--enable|--disable|--remote|--remote-auth-token-env|-i|--image|-m|--model|-p|--profile|-s|--sandbox|-C|--cd|--add-dir|-a|--ask-for-approval)
            resume_options+=("$argument")
            expects_value=1
            ;;
          --config=*|--enable=*|--disable=*|--remote=*|--remote-auth-token-env=*|--image=*|--model=*|--profile=*|--sandbox=*|--cd=*|--add-dir=*|--ask-for-approval=*)
            resume_options+=("$argument")
            ;;
          -*)
            resume_options+=("$argument")
            ;;
          *)
            positionals+=("$argument")
            ;;
        esac
      done

      if (( expects_value )); then
        codex --yolo --profile default resume "${resume_options[@]}"
        return
      fi

      if (( ! use_last && ${#positionals[@]} > 0 )); then
        codex --yolo --profile default resume "${resume_options[@]}" "${positionals[@]}"
        return
      fi

      (( include_all )) && picker_args+=(--all)
      (( use_last )) && picker_args+=(--last)
      session_id="$(cox-resume-picker "${picker_args[@]}")" || return
      [[ -n "$session_id" ]] || return
      codex --yolo --profile default resume \
        "${resume_options[@]}" "$session_id" "${positionals[@]}"
    else
      codex --yolo --profile default "$@"
    fi
  }

  # Inject the IO Gateway URL for the aiproxy provider (kept out of codex/config.toml).
  codex() {
    if [[ -n "${IOGW_BASE_URL:-}" ]]; then
      local gateway_base="${IOGW_BASE_URL%/}"
      [[ "$gateway_base" == */codex ]] || gateway_base="$gateway_base/codex"
      command codex -c "model_providers.aiproxy.base_url=\"$gateway_base\"" "$@"
    else
      command codex "$@"
    fi
  }

  coxd() {
    codex --yolo --profile deepseek
  }

  coxm() {
     codex --yolo --profile minimax
  }


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
    if [[ -z "${IOGW_BASE_URL:-}" || -z "${IOGW_GATEWAY_KEY:-}" ]]; then
      echo "Set IOGW_BASE_URL and IOGW_GATEWAY_KEY before using cc." >&2
      return 1
    fi

    local gateway_base="${IOGW_BASE_URL%/}"
    if [[ "$gateway_base" != */claude ]]; then
      gateway_base="$gateway_base/claude"
    fi

    (
      unset ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL ANTHROPIC_DEFAULT_MODEL \
        ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL \
        ANTHROPIC_DEFAULT_HAIKU_MODEL ANTHROPIC_SMALL_FAST_MODEL
      ANTHROPIC_BASE_URL="$gateway_base" \
      ANTHROPIC_API_KEY="$IOGW_GATEWAY_KEY" \
      command claude --dangerously-skip-permissions "$@"
    )
  }

  cdps(){
    if [[ -z "${DEEPSEEK_API_KEY:-}" ]]; then
      echo "Set DEEPSEEK_API_KEY before using cglm." >&2
      return 1
    fi

    IS_SANDBOX=1 \
    ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic" \
    ANTHROPIC_AUTH_TOKEN="${DEEPSEEK_API_KEY:-}" \
    ANTHROPIC_MODEL="deepseek-v4-pro[1m]" \
    ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]" \
    ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]" \
    ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash" \
    CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash" \
    CLAUDE_CODE_EFFORT_LEVEL="max" \
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
    if (( $# )); then
      GH_CONFIG_DIR="$HOME/.config/gh-nikel" gh "$@"
    fi
  }

  if [[ -r "$HOME/.powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    source "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"
    if [[ -r "$HOME/config/zsh/p10k.zsh" ]]; then
      source "$HOME/config/zsh/p10k.zsh"
    elif [[ -r "$HOME/.p10k.zsh" ]]; then
      source "$HOME/.p10k.zsh"
    fi
  else
    PROMPT='%F{39}%~%f %# '
    RPROMPT=
    unsetopt promptcr
    unsetopt promptsp
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
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

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

export PATH="/usr/local/go/bin:$PATH"

# >>> LazyDB installer >>>
case ":$PATH:" in
    *:/home/giofahreza/.local/bin:*) ;;
    *) export PATH=/home/giofahreza/.local/bin:"$PATH" ;;
esac
#<<< LazyDB installer <<<


GOPRIVATE="go.ulyssestwo.com/*"

# Load and unload project environment variables when changing directories.
eval "$(direnv hook zsh)"

# strix
export PATH=/home/giofahreza/.strix/bin:$PATH

# Strix via the IOGW OpenAI-compatible gateway
if [[ -n "${IOGW_BASE_URL:-}" && -n "${IOGW_GATEWAY_KEY:-}" ]]; then
    export STRIX_LLM="openai/cop:gpt-4o"
    export STRIX_API_TYPE="responses"
    export LLM_API_BASE="${IOGW_BASE_URL%/}"
    if [[ "$LLM_API_BASE" != */v1 ]]; then
        export LLM_API_BASE="$LLM_API_BASE/v1"
    fi
    export LLM_API_KEY="$IOGW_GATEWAY_KEY"
fi


source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^[[A' history-beginning-search-backward   # optional: ↑ prefix search
bindkey '^[[B' history-beginning-search-forward
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # must be last
