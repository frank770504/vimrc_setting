#!/usr/bin/env bash
# =============================================================================
# install.sh — deploy this Vim configuration on Ubuntu/Debian or macOS
#
# Usage:
#   ./install.sh                 full install: deps + config + plugins
#   ./install.sh --config-only   deploy config and plugins only, skip system deps
#   ./install.sh --lite          deploy vimrc.lite instead of the full vimrc
#   ./install.sh --uninstall     remove deployed config (leaves ~/.vim/bundle)
#
# The script is idempotent: safe to run repeatedly. It never overwrites an
# existing ~/.vimrc without confirmation (--force to overwrite, --yes to
# accept all prompts).
#
# The config is COPIED to ~/.vimrc (not symlinked), so the deployed file is
# independent of this repository afterwards.
# =============================================================================
set -euo pipefail

# --- Options -------------------------------------------------------------------
CONFIG_ONLY=0
LITE=0
UNINSTALL=0
FORCE=0
ASSUME_YES=0

for arg in "$@"; do
    case "$arg" in
        --config-only) CONFIG_ONLY=1 ;;
        --lite)        LITE=1 ;;
        --uninstall)   UNINSTALL=1 ;;
        --force)       FORCE=1 ;;
        -y|--yes)      ASSUME_YES=1 ;;
        -h|--help)     grep '^#' "$0" | head -20; exit 0 ;;
        *) echo "Unknown option: $arg (see --help)" >&2; exit 1 ;;
    esac
done

# --- Paths ----------------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIMRC_SRC="$REPO_DIR/vimrc"
LITE_SRC="$REPO_DIR/vimrc.lite"
FORMATTER_SRC="$REPO_DIR/autoload/airline/extensions/tabline/formatters/fugitive.vim"
FORMATTER_DST="$HOME/.vim/autoload/airline/extensions/tabline/formatters/fugitive.vim"
VIMRC_DST="$HOME/.vimrc"

if [[ $LITE -eq 1 ]]; then
    VIMRC_SRC="$LITE_SRC"
fi

# --- Output helpers ---------------------------------------------------------------
info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m ==\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m !!\033[0m %s\n' "$*"; }
abort() { printf '\033[1;31m !!\033[0m %s\n' "$*"; exit 1; }

confirm() {
    [[ $ASSUME_YES -eq 1 ]] && return 0
    read -r -p "$1 [y/N] " reply
    [[ $reply =~ ^[Yy] ]]
}

# --- Uninstall ---------------------------------------------------------------------
if [[ $UNINSTALL -eq 1 ]]; then
    info "Removing deployed Vim configuration"
    rm -f "$VIMRC_DST" "$FORMATTER_DST"
    rm -rf "$HOME/.vim/bundle" "$HOME/.vim/autoload/airline"
    ok "Removed ~/.vimrc, the fugitive formatter, and ~/.vim/bundle"
    exit 0
fi

# --- OS detection -------------------------------------------------------------------
OS="$(uname -s)"
case "$OS" in
    Darwin) PKG="brew" ;;
    Linux)
        if command -v apt-get >/dev/null 2>&1; then
            PKG="apt"
        else
            abort "Unsupported Linux distribution: only apt-based systems are supported."
        fi
        ;;
    *) abort "Unsupported OS: $OS" ;;
esac

SUDO=""
if [[ $PKG == "apt" && $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

have() { command -v "$1" >/dev/null 2>&1; }

# --- Dependency installation ----------------------------------------------------------
install_brew() {
    if ! have brew; then
        info "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Make brew available in the current shell (Apple Silicon default prefix).
        [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
        [[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
    fi
    info "Installing Homebrew packages: vim python fzf ripgrep llvm node uv astyle"
    brew install vim python fzf ripgrep llvm node uv astyle

    # Persist PATH adjustments for future shells (idempotent).
    local shellrc="$HOME/.zshrc"
    [[ -n "${BASH_VERSION:-}" ]] && shellrc="$HOME/.bashrc"
    if ! grep -qs 'brew shellenv' "$shellrc"; then
        echo 'eval "$(brew shellenv)"' >> "$shellrc"
        ok "Added brew shellenv line to $shellrc"
    fi
    if ! grep -qs 'brew --prefix llvm' "$shellrc"; then
        {
            echo '# LLVM (clangd/clang++) from Homebrew'
            echo "export PATH=\"\$(brew --prefix llvm)/bin:\$PATH\""
        } >> "$shellrc"
        ok "Added LLVM PATH line to $shellrc"
    fi
}

install_apt() {
    info "Installing apt packages: vim git curl fzf ripgrep nodejs npm clangd astyle clang-tidy"
    $SUDO apt-get update -y
    $SUDO apt-get install -y vim git curl fzf ripgrep nodejs npm clangd astyle clang-tidy
}

install_uv_tools() {
    have uv || { warn "uv not found; skipping Python LSP installation"; return 0; }
    if ! have pylsp; then
        info "Installing python-lsp-server with ruff plugin (user level)"
        uv tool install --python 3.13 --with python-lsp-ruff python-lsp-server \
            || warn "Installation failed; install manually: uv tool install --with python-lsp-ruff python-lsp-server"
    else
        ok "pylsp already installed"
    fi
}

install_vundle() {
    local bundle_dir="$HOME/.vim/bundle/Vundle.vim"
    if [[ -d $bundle_dir ]]; then
        ok "Vundle already present"
    else
        info "Cloning Vundle"
        git clone --depth 1 https://github.com/VundleVim/Vundle.vim.git "$bundle_dir"
    fi
}

# --- Config deployment -------------------------------------------------------------------
deploy_config() {
    if [[ -e $VIMRC_DST && ! -f $VIMRC_DST ]]; then
        abort "$VIMRC_DST exists and is not a regular file; resolve it manually."
    fi
    if [[ -e $VIMRC_DST && $FORCE -eq 0 ]]; then
        if [[ -L $VIMRC_DST ]]; then
            info "~/.vimrc is a symlink; it will be replaced by a copy"
            confirm "Replace symlink at ~/.vimrc with a copy of $(basename "$VIMRC_SRC")?" \
                || abort "Aborted by user"
        else
            info "~/.vimrc already exists"
            confirm "Overwrite ~/.vimrc with $(basename "$VIMRC_SRC")?" || abort "Aborted by user"
        fi
    fi
    cp "$VIMRC_SRC" "$VIMRC_DST"
    ok "Copied $(basename "$VIMRC_SRC") -> ~/.vimrc"

    # The airline fugitive formatter must live on the runtime path.
    # If it is already a symlink into this repo, leave it as-is: a plain cp
    # would replace the symlink with a static copy and future repo updates
    # (git pull) would no longer reach ~/.vim.
    if [[ -L $FORMATTER_DST ]]; then
        ok "Formatter is a symlink into the repo (left as-is)"
    else
        mkdir -p "$(dirname "$FORMATTER_DST")"
        cp "$FORMATTER_SRC" "$FORMATTER_DST"
        ok "Copied fugitive tabline formatter -> ~/.vim/autoload/airline/.../fugitive.vim"
    fi

    # Machine-local overrides: created once, never overwritten.
    if [[ -f $HOME/.vimrc.local ]]; then
        ok "~/.vimrc.local already exists (left untouched)"
    else
        {
            echo '" ~/.vimrc.local - machine-local overrides (never overwritten by install.sh)'
            echo '" Anything here is sourced AFTER the repo vimrc, so it can override it.'
            echo '" Re-copying the repo config will not touch this file.'
            echo ''
            echo '" Example: GUI font (font names/availability differ per machine)'
            echo '" if has('"'"'gui_running'"'"')'
            echo '"     set guifont=MesloLGSDZForPowerline-Regular:h16'
            echo '" endif'
            echo ''
            echo '" Example: host-specific paths'
            echo '" let g:vim_ai_token_file_path = '"'"'~/path/to/gemini.token'"'"''
        } > "$HOME/.vimrc.local"
        ok "Created ~/.vimrc.local template"
    fi
}

install_plugins() {
    info "Installing Vim plugins (headless)"
    vim -es +'PluginInstall' +'qa!' >/dev/null 2>&1 || true
    warn "Run :PluginInstall inside Vim if any plugin shows [X] in :PluginStatus"
    info "Installing markdown-preview UI (one-time, may take a while)"
    vim -es +'call mkdp#util#install()' +'qa!' >/dev/null 2>&1 || true
}

# --- Main ------------------------------------------------------------------------------------
info "Detected OS: $OS ($PKG)"

if [[ $CONFIG_ONLY -eq 0 ]]; then
    case "$PKG" in
        brew) install_brew ;;
        apt)  install_apt ;;
    esac
    install_uv_tools
fi

install_vundle
deploy_config
install_plugins

cat <<'EOF'

Installation complete. Optional next steps:

1. Gemini AI mappings (<Leader>a, <Leader>s): set GEMINI_API_KEY in your
   shell, or save the key to ~/.config/gemini.token and add a [gemini]
   section to ~/.config/vim-ai-roles.ini (see README.md).
2. Verify clangd resolution:  command -v clangd clang++ c++
3. Open Vim and check plugins with :PluginStatus

EOF
