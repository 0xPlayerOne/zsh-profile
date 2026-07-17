## Custom Zsh Configuration

![Terminal Preview](/terminal_preview.png)

### 📄  Configuration Files

- [`~/.zshenv`](./zshenv)  \n  Sourced for EVERY zsh (login, interactive, AND non-interactive `zsh -c`). Minimal — only what must be on PATH for non-interactive contexts (e.g. cargo for build tools).

- [`~/.zprofile`](./zprofile)  \n  Loads terminal settings, exports, and paths on login shells.

- [`~/.zshrc`](./zshrc)  \n  Contains functions, aliases, and settings applied to interactive non-login shells.

### 🧭 Shared Config Rules

- Put PATH entries, environment exports, and machine-added CLI bootstrap in [`zprofile`](./zprofile).
- Keep prompt logic, aliases, and interactive shell functions in [`zshrc`](./zshrc).
- Use generic references such as `$HOME`; never commit username-specific absolute paths like `/Users/your-name/...`.
- Keep machine-specific hosts and usernames as environment variables such as `PI_SSH_TARGET`, and edit shared files directly when needed.

### 🔧  Helpful Tools

- [Homebrew](https://brew.sh/) - Package manager for macOS.
- [mise](https://mise.jdx.dev/) - Unified toolchain manager (Node 24.18.0 / Python 3.11.15 / Rust 1.97.1 pins). Replaces nvm + brew python.
- [jEnv](https://github.com/jenv/jenv) - Java environment manager
- [eza](https://github.com/eza-community/eza) - Modern Rust `ls` replacement (replaces colorls)
- [Dracula Theme](https://draculatheme.com/terminal/) - Dark and beautiful theme capatible with bash
- [zsh-users](https://github.com/zsh-users) - Collection of powerfull Zsh plugins such as autosuggestions, syntax-highlighting, and completions
- [thefuck](https://github.com/nvbn/thefuck) - Console command error corrector
- [cointop](https://github.com/miguelmota/cointop) - Interactive terminal based UI application for tracking cryptocurrencies
- [dockly](https://github.com/lirantal/dockly) - Docker console UI Dashboard for quickly managing and inspecting Containers
- [howdoi](https://github.com/gleitz/howdoi) - Instant code answers and examples from the command line
- [wttr.in](https://github.com/chubin/wttr.in) - Weather console app
- [fx](https://github.com/antonmedv/fx) - Command-line tool and terminal JSON viewer
- [rebound](https://github.com/shobrook/rebound) - Command-line tool that instantly fetches Stack Overflow results when an exception is thrown
