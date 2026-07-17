#---------------------------------------------------------------------------------------------------------------------------------------
#   1. CORE ENVIRONMENT SETTINGS
#---------------------------------------------------------------------------------------------------------------------------------------

# Default editor
export EDITOR="nano"

# Bump the maximum number of file descriptors
ulimit -n 10240

# Parallel native builds for Node
export JOBS=max

# Shared default directories
export DEV_DIR="${DEV_DIR:-$HOME/dev}"

#---------------------------------------------------------------------------------------------------------------------------------------
#   2. PATH CONFIGURATIONS
#---------------------------------------------------------------------------------------------------------------------------------------

# Helper to safely prepend to PATH
add_to_path() {
  [[ -d "$1" ]] || return
  case ":$PATH:" in
  *":$1:"*) ;; # already in PATH
  *) PATH="$1:$PATH" ;;
  esac
}

# Set Homebrew prefix for convenience
export BREW="/opt/homebrew" # brew --prefix

# Core paths
add_to_path "$BREW/bin"
add_to_path "$BREW/sbin"

#---------------------------------------------------------------------------------------------------------------------------------------
#   MISE — unified toolchain manager (owns Node / Python / Rust version pins)
#   Versions: Node 24.18.0, Python 3.11.15, Rust 1.97.1 (see ~/.config/mise/config.toml)
#   Replaces nvm +brew python@3.11 + manual rustup-in-shell. `mise` is the single source of truth.
#   Activated HERE (before .local/bin, HOME/bin) so mise shims always shadow local tools.
#---------------------------------------------------------------------------------------------------------------------------------------
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

add_to_path "$HOME/bin"
add_to_path "$HOME/.local/bin" # NemoClaw / local CLI tools

# jEnv (Java environment manager) — kept for Android SDK JDK dependency
add_to_path "$BREW/opt/jenv/bin"
eval "$(jenv init -)"

# pnpm (falls under Node/mise; global bin)
export PNPM_HOME="$HOME/Library/pnpm"
add_to_path "$PNPM_HOME/bin"

# Local node modules binaries (project-local, always last)
add_to_path "./node_modules/.bin"

# Bun (global bin: pi + other bun-installed CLIs)
add_to_path "$HOME/.bun/bin"

# Python — managed by mise (3.11.15). uv is the package manager.
# No brew python@3.11 path needed; mise injects the pinned interpreter onto PATH.

# Ruby — orphaned (only eza replaced colorls); kept for legacy gems
add_to_path "$BREW/opt/ruby/bin"

#---------------------------------------------------------------------------------------------------------------------------------------
#   4. MOBILE DEVELOPMENT
#---------------------------------------------------------------------------------------------------------------------------------------

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
add_to_path "$ANDROID_HOME/emulator"
add_to_path "$ANDROID_HOME/platform-tools"
add_to_path "$ANDROID_HOME/cmdline-tools/latest/bin"

# Flutter
add_to_path "$DEV_DIR/flutter/bin"

#---------------------------------------------------------------------------------------------------------------------------------------
#   5. OTHER TOOLS & FRAMEWORKS
#---------------------------------------------------------------------------------------------------------------------------------------

# Algorand node
export ALGORAND_DATA="$HOME/node/data"
alias goal="$HOME/node/goal"

# Ruby gem bin dir (colorls was replaced by eza; other gems may still use this)
add_to_path "$(ruby -e 'puts Gem.bindir')"

# Google Antigravity IDE
add_to_path "$HOME/.antigravity/antigravity/bin"

# LM Studio CLI
add_to_path "$HOME/.lmstudio/bin"

# MTPLX terminal command
add_to_path "$HOME/.mtplx/bin"

# TensorFlow (ML Framework) - hide log warnings
export TF_CPP_MIN_LOG_LEVEL=3

# Windsurf (AI IDE)
add_to_path "$HOME/.codeium/windsurf/bin"


#---------------------------------------------------------------------------------------------------------------------------------------
#   6. SYSTEM UTILS & PACKAGE MANAGERS
#---------------------------------------------------------------------------------------------------------------------------------------

# Homebrew path (should come after everything else)
eval "$($BREW/bin/brew shellenv)"
