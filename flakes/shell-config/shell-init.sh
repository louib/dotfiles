# shellcheck shell=sh
alias ll='ls -alF'
alias la='ls -A'

alias vi="nvim"
alias vim="nvim"
export VISUAL="nvim"

GIT_DEFAULT_BRANCH_CACHE_KEY="cache.default-branch"

# This function will use the git config file as a local cache for the default branch.
get_default_git_branch () {
    default_branch=$(git config --get "$GIT_DEFAULT_BRANCH_CACHE_KEY")
    if [ -n "$default_branch" ]; then
        echo "$default_branch"
    else
        # Taken from https://stackoverflow.com/questions/28666357/git-how-to-get-default-branch
        default_branch=$(git remote show origin | grep "HEAD branch" | cut -d ":" -f 2 | xargs)
        git config --add "$GIT_DEFAULT_BRANCH_CACHE_KEY" "$default_branch"
        echo "$default_branch"
    fi
}

# checkout the default git branch.
# (git checkout default)
gcd () {
    default_branch=$(get_default_git_branch)
    git checkout "$default_branch"
}
# git commit amend
gca () {
    git commit --amend --no-edit
}
# git commit amend, but without the commit hooks
gcan () {
    git commit --amend --no-edit -n
}
# git new branch
gnb () {
    git checkout -b "$1"
}
# git checkout
gco () {
    branch_name=$1
    # If no branch name is provided, checkout the HEAD
    if [ -z "$branch_name" ]; then
        git checkout .
    else
        git checkout "$1"
    fi
}
alias gst="git status"
alias gdf="git diff"
grb () {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    git fetch -a
    git rebase "origin/$current_branch"
}
# Rebase on the default branch
grm () {
    default_branch=$(get_default_git_branch)
    git pull --rebase origin "$default_branch"
}
gp () {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    git push origin "$current_branch"
}
gpf () {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    git push --force-with-lease origin "$current_branch"
}

# Cargo stuff
alias ci="cargo install --force --path ."
alias cb="cargo build"
alias ct="cargo test"
alias cf="find . -name '*.rs' -exec rustfmt {} \;"
export RUSTFLAGS="$RUSTFLAGS -A warnings"
# Default commands for a meson and ninja build.
meb () {
    meson . _build
    ninja -C _build
}
mei () {
    meson . _build
    ninja -C _build
    ninja -C _build install
}

# Nix stuff
alias nsc="nix search nixpkgs"
alias nfc="nix flake check"
ndv () {
    flake_path=$1
    # If no path is provided, use the current directory
    if [ -z "$flake_path" ]; then
        nix develop .
    else
        nix develop "$flake_path"
    fi
}
nfu () {
    input_name=$1
    # If no input name is provided, we update all the inputs.
    if [ -z "$input_name" ]; then
        nix flake update
    else
        nix flake lock --update-input "$input_name"
    fi
}

# function to send an emojified message to git commit
emocommit () { emojify "$1" | git commit -n -F -; }
# function to search emojies
emosearch () { emojify --list | grep "$1"; }
# function to clip an emoji
emoclip () {
    login_info=$(loginctl)
    # Taken from https://unix.stackexchange.com/questions/202891/how-to-know-whether-wayland-or-x11-is-being-used
    session_id=$(echo "$login_info" | awk '/tty/ {print $1}')
    session_type=$(loginctl show-session "$session_id" -p Type | awk -F= '{print $2}')
    emoji_best_match=$(emojify --list | grep ":$1:" | head -n 1 | tr -d '\n')
    emoji_character=$(echo "$emoji_best_match" | sed 's/:.*://' | sed 's/ //g')
    if [ -z "$emoji_best_match" ]; then
        echo "No emoji matching $1"
        return
    fi
    echo "Clipping $emoji_best_match"

    if [ "$session_type" = "x11" ]; then
        echo "$emoji_character" | tr -d '\n' | xclip -i -selection clipboard;
    else
        # FIXME wl-copy add a newline to the output, even though there is none in the input. There is an option
        # for no newline on wl-paste, but not on wl-copy. See https://github.com/bugaevc/wl-clipboard/issues/63
        echo "$emoji_character" | tr -d '\n' | wl-copy;
    fi
}

# Search the current project for the specific term
sp () {
    grep \
        --binary-files=without-match \
        --recursive \
        --line-number \
        --color=always \
        --exclude-dir=.git/ \
        --exclude-dir=node_modules/ \
        --exclude-dir=target/ \
        --exclude-dir=dist/ \
        --exclude-dir=build/ \
        --exclude-dir=_build/ \
        "$1"
}

# For find and replace
# Usage example:
# sar "s/allo/Allo/g"
far () {
    find . -type f -exec sed -i "$1" {} +
}
# Find a file
ff () {
    if [ -z "$1" ]; then
        echo "Please provide a file name."
    else
        find . -name "*$1*"
    fi
}

if [ -f "$HOME/.shell-extras" ]; then
    # Taken from https://www.shellcheck.net/wiki/SC1090
    # shellcheck source=/dev/null
    . "$HOME/.shell-extras"
fi
