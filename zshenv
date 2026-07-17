# zshenv — sourced for EVERY zsh invocation (login, interactive, AND non-interactive
# scripts like `zsh -c "..."`, cron, ssh command, build tools shelling out).
# Keep this file MINIMAL: only what must be on PATH for non-interactive contexts.
# Full environment config lives in zprofile (login) and zshrc (interactive).

# Rust toolchain — must be available even for non-interactive `cargo`/`rustc` calls
# (e.g. a Makefile or CI step invoking `zsh -c "cargo build"`).
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
