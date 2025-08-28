#---------------------------------------------------------------------------------------------------------------------------------------
#   1.  TERMINAL SETUP
#---------------------------------------------------------------------------------------------------------------------------------------

# Set initial folder directory to dev
# Only cd if running an interactive shell, not in SSH, and not launched by a code editor
if [[ -z "$SSH_TTY" && -z "$VSCODE_PID" && "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "kiro" ]]; then
    cd ~/dev
fi

# Kiro (AWS IDE)
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Define Color Map
typeset -A COLORS=(
    black "%F{black}"
    blackb "%F{brightblack}"
    blue "%F{blue}"
    blueb "%F{brightblue}"
    cyan "%F{cyan}"
    cyanb "%F{brightcyan}"
    green "%F{green}"
    greenb "%F{brightgreen}"
    magenta "%F{magenta}"
    magentab "%F{brightmagenta}"
    red "%F{red}"
    redb "%F{brightred}"
    reset "%f"
    white "%F{white}"
    whiteb "%F{brightwhite}"
    yellow "%F{yellow}"
    yellowb "%F{brightyellow}"
)

# Count number of files/folders in current directory
parse_file_number() {
    local lsc=(colorls -A)
    "${lsc[@]}" | wc -l | tr -d ' '
}

# Set a specific color for the status of the Git repo
git_color() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "" # nothing if not a git repo
    elif [[ -n $(git status --porcelain) ]]; then
        echo "${COLORS[red]}" # red if need to commit
    elif [[ -n $(git cherry -v) ]]; then
        echo "${COLORS[yellow]}" # yellow if need to push
    else
        echo "${COLORS[green]}" # green if everything is clean
    fi
}

# Get Git branch of current directory
git_branch() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        echo "git:($(git branch --show-current))"
    else
        echo ""
    fi
}

# Modify terminal prompt and title display
precmd() {
    local date="${COLORS[cyan]}%D{%a %b %d %T}"
    local username="${COLORS[cyan]}%n"
    local gh_user="${COLORS[cyan]}$(git config --get user.name)"
    local directory="${COLORS[blue]}[%~ | $(parse_file_number) items]"
    local git_status="$(git_color)$(git_branch)"
    local prompt_line=$'\n'"${COLORS[green]}$ ${COLORS[reset]}"
    # Update the main prompt variable dynamically
    PROMPT="${date} | ${gh_user} → ${directory} ${git_status}${prompt_line}"

    # Set both the window and tab title to just the current folder name
    local folder="${PWD:t}"
    print -Pn "\e]1;$folder\a" # Tab title
    # print -Pn "\e]2;$folder\a"   # Window title
}

#---------------------------------------------------------------------------------------------------------------------------------------
#   2.  FOLDER & FILE MANAGEMENT
#---------------------------------------------------------------------------------------------------------------------------------------

# Clear a directory (zsh-safe, removes all except . and ..)
cleardir() {
    while true; do
        read "response?Completely clear current directory? [y/N] "
        case $response in
        [Yy]*)
            # Enable extended globbing for hidden files in zsh
            setopt EXTENDED_GLOB
            # Remove all files and dirs, including dotfiles except . and ..
            rm -rfv -- ./* .[^.]* ..?* 2>/dev/null
            unsetopt EXTENDED_GLOB
            break
            ;;
        *)
            echo 'Skipped clearing the directory...'
            break
            ;;
        esac
    done
}

# Archive creation
mktar() { tar cvzf "${1%%/}.tar.gz" "${1%%/}/"; } # Creates a *.tar.gz archive of a file or folder
mkzip() { zip -r "${1%%/}.zip" "$1"; }            # Create a *.zip archive of a file or folder

# File extract helper
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz) tar xzf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.rar) unrar x "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xf "$1" ;;
        *.tbz2) tar xjf "$1" ;;
        *.tgz) tar xzf "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z x "$1" ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Start a web server to share the files in the current directory
sharefolder() {
    local path="$1"
    if [[ -z "$path" ]]; then
        path="."
    fi
    php -t "$path" -S localhost:5555
}

# Directory management
alias mkdir='mkdir -p'                                     # Make a new directory (safe: -p avoids error if exists)
alias rmdir='rm -rf'                                       # Remove a directory (dangerous: 'rm -rf' deletes recursively and forcefully, not just empty dirs)
alias perm="stat -f '%Lp'"                                 # View permissions as octal (macOS-specific 'stat' syntax)
disk-usage() { du -hs "$@" | sort -nr; }                   # List disk usage, human-readable, sorted (safe, but 'du -hs' only shows summary for each arg)
dirdiff() { diff -u <(ls "$1" | sort) <(ls "$2" | sort); } # Compare directory listings (safe, but only compares names, not file contents)

# Navigation Shortcuts
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias desktop='clear && cd ~/Desktop && ls'     # Desktop directory
alias developer='clear && cd ~/dev && ls'       # Development directory
alias downloads='clear && cd ~/Downloads && ls' # Downloads directory
alias home='clear && cd ~ && ll'                # Home directory
cs() { cd "$@" && ls; }                         # Enter directory and list contents

# List files
alias ls='colorls -A --sort-dirs --report' # Override ls to colorls | default list all with directories first + add report
alias lsh='colorls --help'                 # Displays help prompt for colorls
alias lsd='ls --dirs'                      # List directories only
alias lsf='ls --files'                     # List files only
alias lst='ls --tree'                      # List directory tree
alias lsg='ls --git-status'                # Lists all with git status
alias lsl='ls --long'                      # Long list all by default sorting
alias lsls='lsl -S'                        # Long list all by size, largest first
alias lslt='lsl -t'                        # Long list all by modification time, newest first
alias lslx='lsl -X'                        # Long list all by extension

#---------------------------------------------------------------------------------------------------------------------------------------
#   3.  PACKAGE MANAGERS
#---------------------------------------------------------------------------------------------------------------------------------------

# Homebrew
alias brewclean='brew autoremove && brew cleanup --prune=all --scrub'
alias brewdr='brew doctor'
alias brewup='brew update && brew upgrade && brewclean && brewdr'
alias brewout='brew outdated'
alias brewls='brew list'
alias brewsr='brew search'
alias brewi='brew install'

# npm
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrb='npm run build'

# pnpm
alias pn='pnpm'
alias recycle="sudo rm -rf node_modules/ && pnpm i"

# yarn
alias yarni='yarn add'
alias yarnup='yarn upgrade'
alias yarnup-all='npx yarn-upgrade-all'
alias yarnrm='yarn remove'
alias yarnout='yarn outdated'

# Node environments
alias node-dev='export NODE_ENV=development'
alias node-prod='export NODE_ENV=production'
alias nvmrc='node -v > .nvmrc'

# Python
alias python="python3"
alias py='python'
alias pip="pip3"

#---------------------------------------------------------------------------------------------------------------------------------------
#   4.  GIT SHORTCUTS
#---------------------------------------------------------------------------------------------------------------------------------------

# Simple status and stats
alias gitstats='git-stats'
alias gits='git status -s'

# Add and commit helpers
alias gaa='git add .'
alias gcm='git commit -m'
alias gita='git add -A && git status -s'
alias gitcom='git commit -am'
alias gitacom='git add -A && git commit -am'
alias gitundo='git reset --soft HEAD~1' # Undo last commit (soft reset)\

# Branch and checkout
alias gitc='git checkout'
alias gitcm='git checkout master'
alias gitb='git branch'
alias gitcb='git checkout -b'
alias gitdb='git branch -d'
alias gitDb='git branch -D'
alias gitdr='git push origin --delete' # Delete remote branch (usage: gitdr branchname)

# Fetch, rebase, pull, push
alias gitf='git fetch'
alias gitr='git rebase'
alias gitpl='git pull'
alias gitfr='git fetch && git rebase'
alias gitpo='git push -u origin'

# Merge / Rebase
alias gitm='git merge'
alias gitmm='git merge master'
alias git-rebase-main='git checkout main && git pull && git checkout staging && git rebase main && git push -f'

# Clone
alias gitcl='git clone'

# Remote helpers
alias gitrao='git remote add origin'
alias gitrso='git remote set-url origin'

# Remove files from index (not a true "remove remote")
alias gitremoveremote='git rm -r --cached'

# Logs
alias gitlog="git log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)'"
alias gitlog-changes="git log --oneline --decorate --stat --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)'"

# Delete branch locally and remotely
gitdbr() { git branch -d "$@" && git push origin --delete "$@"; }

# Set upstream for current branch (usage: gitupstream origin/branch)
gitupstream() { git branch --set-upstream-to="$@"; }

# Confirmed hard reset HEAD
gitreset() {
    while true; do
        read -ep 'Reset HEAD? [y/N] ' response
        case $response in
        [Yy]*)
            git reset --hard HEAD
            break
            ;;
        *)
            echo 'Skipped reseting the HEAD...'
            break
            ;;
        esac
    done
}

#---------------------------------------------------------------------------------------------------------------------------------------
#   5.  DOCKER COMMANDS
#---------------------------------------------------------------------------------------------------------------------------------------

# Docker core aliases
alias dk='docker'
alias dco='docker-compose'

# Container management
alias dkps='docker ps'                               # List running containers
alias dkpsa='docker ps -a'                           # List all containers
alias dklc='docker ps -l'                            # Last container
alias dklcid='docker ps -l -q'                       # Last container ID
alias dkelc='docker exec -it $(dklcid) bash --login' # Shell into last container
alias dkbash='dkelc'                                 # Alias for shell into last container
alias dkex='docker exec -it '                        # Run command in container
alias dkrmflast='docker rm -f $(dklcid)'             # Remove last container
alias dkrmac='docker rm $(docker ps -a -q)'          # Remove all containers

# Get IP of last container
alias dklcip='docker inspect -f "{{.NetworkSettings.IPAddress}}" $(dklcid)'

# Image management
alias dki='docker images'                                           # List images
alias dkip='docker image prune -a -f'                               # Prune all images
alias dkrmui='docker images -q -f dangling=true | xargs docker rmi' # Remove untagged images (dangling)

# Volume/system cleanup
alias dkvp='docker volume prune -f'                 # Prune volumes
alias dksp='docker system prune -a -f'              # Prune system (all)
alias dkclean='docker system prune -a --volumes -f' # Prune all + volumes

# Run
alias dkri='docker run --rm -i '
alias dkrit='docker run --rm -it '

# Docker Compose
alias dcol='docker-compose logs -f --tail 100'
alias dcou='docker-compose up'
alias dcofresh='docker-compose-fresh'

# ================================= PROJECT SPECIFIC DOCKER COMMANDS ================================= #

# Devzone container
alias dz-run='make docker run-devzone run-celery'
alias dz-stop='docker-compose stop'
alias dz-start='docker-compose start'
alias dz-kill='docker-compose down'

# Playpants
alias pp-test='make -f Makefile.rpmvenv run-dev-platform-api.tests.playpants'
alias pp-build='docker exec -it devzone_app_1 /bin/bash -c "python ./devzone/manage.py dumpdata playpants.ProjectSettingGroup --indent 4 > ./devzone/playpants/fixtures/initial_project_settings.json"'

# Activity Launcher / LSG/MMP / Redis / Ab Testing / Achievement Engine
alias dz-al='make run-activity-launcher'
alias dz-lsg='make run-lsgmmp20'
alias dz-ab='make run-abtesting'
alias dz-ae='make run-ae'
alias dz-redis='make run-redis'
alias dz-flower='make run-flower'
alias dz-sls='make run-sls'

# Run all Devzone
alias dz-run-all='dz-run && dz-al && dz-lsg && dz-ab && dz-ae'

# Devzone Utils
alias dz-help='make all'
alias dz-shell='make docker-shell'
alias dz-lint='make -f Makefile.rpmvenv py-lint'
alias dz-log='docker logs -f devzone_app_1'
alias dz-mm='docker exec devzone_app_1 python ./devzone/manage.py makemigrations'
alias dz-migrate='docker exec devzone_app_1 python ./devzone/manage.py migrate'
alias dz-req='docker exec -it devzone_app_1 /bin/bash -c "source /usr/share/venvs/devzone/bin/activate && pip install -r rpm/requirements.txt && service httpd restart"'
alias docker-prune='docker system prune --volumes -f'

# Crypto Bot
alias build-bot='docker build -t bot-img .'
alias run-bot='docker run -d -ti --name crypto-bot bot-img'
alias kill-bot='docker stop crypto-bot'
alias bot-logs='docker logs crypto-bot'
alias bot-shell='docker attach crypto-bot'

#---------------------------------------------------------------------------------------------------------------------------------------
#   6.  OS X COMMANDS
#---------------------------------------------------------------------------------------------------------------------------------------

alias shutdown='sudo shutdown -h now'                                                                                               # Shut down Mac immediately
alias restart='sudo shutdown -r now'                                                                                                # Restart Mac immediately
alias add-dock-spacer='defaults write com.apple.dock persistent-apps -array-add "{\"tile-type\"=\"spacer-tile\";}" && killall Dock' # Add a spacer to the Dock
alias show-hidden-files='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'                            # Show hidden files in Finder
alias hide-hidden-files='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'                           # Hide hidden files in Finder
alias show-dashboard='defaults write com.apple.dashboard mcx-disabled -bool false && killall Dock'                                  # Show the Dashboard
alias hide-dashboard='defaults write com.apple.dashboard mcx-disabled -bool true && killall Dock'                                   # Hide the Dashboard
alias show-spotlight='sudo mdutil -a -i on'                                                                                         # Enable Spotlight
alias hide-spotlight='sudo mdutil -a -i off'                                                                                        # Disable Spotlight
alias mergepdf='echo "Deprecated: Use pdfunite or gs to merge PDFs"'                                                                # Merge PDF files - Usage: pdfunite input1.pdf input2.pdf output.pdf
alias dsclean='find . -type f -name .DS_Store -delete'                                                                              # Get rid of those pesky .DS_Store files recursively
alias flush='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'                                                              # Flush your DNS cache (modern macOS)
alias mute="osascript -e 'set volume output muted true'"                                                                            # Mute the system volume
alias unmute="osascript -e 'set volume output muted false'"                                                                         # Unmute the system volume
alias task-complete='say -v "Zarvox" "Task complete"'                                                                               # Text-to-speech alert for task completion
alias fix-audio='sudo launchctl kickstart -k system/com.apple.audio.coreaudiod'                                                     # Fix audio control issues

#-----------------------------------------------------------------------------------------------------------------------
#   7.  SSH
#-----------------------------------------------------------------------------------------------------------------------

# SSH Aliases
alias ping-pi='ping pi.local'
alias ssh-pi='ssh andrewmahoney-fernandes@192.168.1.208'
alias getsshkey='pbcopy < ~/.ssh/id_rsa.pub' # Copy SSH public key to clipboard

# Helper functions for SSH config management

add_ssh() {
    # Usage: add_ssh <host> <hostname> <user>
    if [[ $# -ne 3 ]]; then
        echo "Usage: add_ssh <host> <hostname> <user>"
        return 1
    fi
    {
        echo ""
        echo "Host $1"
        echo "  HostName $2"
        echo "  User $3"
        echo "  ServerAliveInterval 30"
        echo "  ServerAliveCountMax 120"
    } >>~/.ssh/config
    echo "Added SSH config for host '$1'"
}

sshlist() {
    # List hosts defined in SSH config (ignores wildcards and Match blocks)
    awk '/^Host / && !/\*/ && !/^Host[[:space:]]+$/ {for (i=2; i<=NF; i++) print $i}' ~/.ssh/config
}

ssh-add-all() {
    # Add all SSH private keys in ~/.ssh to the agent (excluding .pub files)
    setopt extended_glob
    for key in ~/.ssh/id_*(.N); do
        [[ "$key" != *.pub ]] && ssh-add "$key"
    done
    unsetopt extended_glob
}

#-----------------------------------------------------------------------------------------------------------------------
#   8.  TAB COMPLETION & AUTO-SUGGESTIONS
#-----------------------------------------------------------------------------------------------------------------------

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Load Homebrew Zsh plugins
if type brew &>/dev/null; then
    # Load Zsh third-party tab completions
    FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
    # Activate Zsh's native completion system
    autoload -Uz compinit && compinit

    # Load Zsh syntax highlighting plugin
    source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    # Load Zsh history substring search plugin (Note: need to load after syntax-highlighting)
    source "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
    # Load Zsh autosuggestions plugin
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Keybindings
bindkey -e                                   # Use Emacs keybindings https://quickref.me/emacs.html
bindkey '^[[A' history-substring-search-up   # Up arrow for history substring search
bindkey '^[[B' history-substring-search-down # Down arrow for history substring search
bindkey '^ ' autosuggest-accept              # Accept autosuggestion with ctrl + space
bindkey '^[ ' autosuggest-accept             # Accept autosuggestion with alt + space

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Disable annoying corrections for common typos
setopt nocorrect

# Load color support
autoload -U colors && colors

# Completion case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Optional: colorls flags tab completion
if type colorls &>/dev/null; then
    COLORLS_COMPLETION="$(dirname "$(which colorls)")/tab_complete.sh"
    [[ -f "$COLORLS_COMPLETION" ]] && source "$COLORLS_COMPLETION"
fi

#---------------------------------------------------------------------------------------------------------------------------------------
#   9.  MISC UTILITY ALIASES & FUNCTIONS
#---------------------------------------------------------------------------------------------------------------------------------------

# Misc Commands
alias _='sudo'
alias q='exit'
alias json='fx'
alias crypto='cointop'
alias h='history'
alias network-ip='ipconfig getifaddr en0'
alias public-ip='curl ipecho.net/plain; echo'
alias zprofile='code ~/.zprofile'
alias zshrc='code ~/.zshrc'
alias cleanports='kill -9 $(lsof -ti :3000,3001,3002,3003) 2>/dev/null || echo "No processes found"'
re-source() {
    local original_dir=$PWD
    source ~/.zprofile
    source ~/.zshrc
    cd "$original_dir"
}
bash-as() { sudo -u "$1" /bin/bash; }

# Terminal auto correction
eval "$(thefuck --alias --shell=zsh)"
alias please='fuck'

# Display the weather using wttr.in
weather() {
    local location="$1"
    if [[ -z "$location" ]]; then
        location="San+Juan"
    fi
    curl -fsSL "http://wttr.in/${location}?lang=en"
}
