#---------------------------------------------------------------------------------------------------------------------------------------
#   1. CORE ENVIRONMENT SETTINGS
#---------------------------------------------------------------------------------------------------------------------------------------

# Default editor
export EDITOR="nano"

# Bump the maximum number of file descriptors
ulimit -n 10240

# Parallel native builds for Node
export JOBS=max

#---------------------------------------------------------------------------------------------------------------------------------------
#   2. PATH CONFIGURATIONS
#---------------------------------------------------------------------------------------------------------------------------------------

# Helper to safely prepend to PATH
add_to_path() {
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
add_to_path "$HOME/bin"

#---------------------------------------------------------------------------------------------------------------------------------------
#   3. DEVELOPER TOOLING (Languages, Runtimes, Version/Package Managers)
#---------------------------------------------------------------------------------------------------------------------------------------

# Bun (JavaScript runtime)
export BUN_INSTALL="$HOME/.bun"
add_to_path "$BUN_INSTALL/bin"

# Composer (PHP dependency manager)
add_to_path "$HOME/.composer/vendor/bin"

# Go (Golang)
add_to_path "$BREW/opt/go/libexec/bin"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
add_to_path "$GOBIN"

# jEnv (Java environment manager - now using Homebrew)
add_to_path "$BREW/opt/jenv/bin"
eval "$(jenv init -)"

# Local node modules binaries
add_to_path "./node_modules/.bin"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$BREW/opt/nvm/nvm.sh" ] && \. "$BREW/opt/nvm/nvm.sh"
[ -s "$BREW/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$BREW/opt/nvm/etc/bash_completion.d/nvm"

# pnpm (Node package manager)
export PNPM_HOME="$HOME/Library/pnpm"
add_to_path "$PNPM_HOME"

# Python
add_to_path "$BREW/opt/python/libexec/bin"

# Ruby
add_to_path "$BREW/opt/ruby/bin"
export LDFLAGS="-L$BREW/opt/ruby/lib"
export CPPFLAGS="-I$BREW/opt/ruby/include"
export PKG_CONFIG_PATH="$BREW/opt/ruby/lib/pkgconfig"

# SQLite (SQL/Database)
add_to_path "$BREW/opt/sqlite/bin"
export LDFLAGS="$LDFLAGS -L$BREW/opt/sqlite/lib"
export CPPFLAGS="$CPPFLAGS -I$BREW/opt/sqlite/include"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$BREW/opt/sqlite/lib/pkgconfig"

#---------------------------------------------------------------------------------------------------------------------------------------
#   4. MOBILE DEVELOPMENT
#---------------------------------------------------------------------------------------------------------------------------------------

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
add_to_path "$ANDROID_HOME/emulator"
add_to_path "$ANDROID_HOME/platform-tools"
add_to_path "$ANDROID_HOME/cmdline-tools/latest/bin"

# Flutter
add_to_path "$HOME/Development/flutter/bin"

#---------------------------------------------------------------------------------------------------------------------------------------
#   5. OTHER TOOLS & FRAMEWORKS
#---------------------------------------------------------------------------------------------------------------------------------------

# Algorand node
export ALGORAND_DATA="$HOME/node/data"
alias goal="$HOME/node/goal"

# colorls (Ruby gem)
add_to_path "$(ruby -e 'puts Gem.bindir')"

# TensorFlow (ML Framework) - hide log warnings
export TF_CPP_MIN_LOG_LEVEL=3

# Windsurf (AI IDE)
add_to_path "$HOME/.codeium/windsurf/bin"

#---------------------------------------------------------------------------------------------------------------------------------------
#   6. SYSTEM UTILS & PACKAGE MANAGERS
#---------------------------------------------------------------------------------------------------------------------------------------

# Set Homebrew Cask application directory
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Homebrew path (should come after everything else)
eval "$($BREW/bin/brew shellenv)"
