

eval "$(starship init zsh)"

if [[ "$CLAUDECODE" != "1" ]]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# eval $(keychain --eval --quiet --gpg2 --agents ssh,gpg mac_mkra_dev markasena_gmail_com)

#Load secret API keys
if [ -f ~/.zsh_secrets ]; then
    source ~/.zsh_secrets
fi

# Intercept 'bun test' and redirect it to 'bun run test'

bun() {
  case "$1" in
    check|test|build)
      local cmd="$1"
      shift
      command bun run "$cmd" "$@"
      ;;
    *)
      command bun "$@"
      ;;
  esac
}



vp () {
    # 1. The native environment hook (keep this so vp doesn't break)
    if [ "$1" = "env" ] && [ "$2" = "use" ]; then
        case " $* " in
            (*" -h "* | *" --help "*) command vp "$@"
                return ;;
        esac
        __vp_out="$(VP_ENV_USE_EVAL_ENABLE=1 VP_SHELL=sh command vp "$@")"  || return $?
        eval "$__vp_out"
        return
    fi

    # 2. Your custom run intercepts
    case "$1" in
        check|test|build|fix)
            local cmd="$1"
            shift
            command vp run "$cmd" "$@"
            ;;
        *)
            # 3. Standard fallback
            command vp "$@"
            ;;
    esac
}

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"


eval "$(mise activate zsh)"
