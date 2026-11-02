#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
REPO_URL="${REPO_URL:-https://github.com/FlavioAmurrioCS/.dotfiles.git}"
BACKUP=0
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y-%m-%d-%H%M%S)"

for arg in "$@"; do
    case "$arg" in
        --backup) BACKUP=1 ;;
        *)
            echo "usage: install.sh [--backup]" >&2
            exit 2
            ;;
    esac
done

if ((BACKUP)) && ! command -v jq >/dev/null 2>&1; then
    echo "error: --backup needs jq" >&2
    exit 1
fi

# Move a path under ~ into the backup folder, at the same path relative to ~.
backup() {
    local rel="${1#"$HOME"/}"
    mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    mv "$1" "$BACKUP_DIR/$rel"
    echo "moved ~/$rel to $BACKUP_DIR/$rel"
}

# mise refuses to replace real files and folders, but replaces wrong symlinks.
backup_dotfiles() {
    local mode target source rel
    mise dot status --json |
        jq -r '.files[] | select(.state == "differs")
            | [.mode, (.target | sub("^~/"; env.HOME + "/")), .origin.source] | @tsv' |
        while IFS=$'\t' read -r mode target source; do
            case "$mode" in
                symlink)
                    if [[ -e "$target" && ! -L "$target" ]]; then backup "$target"; fi
                    ;;
                symlink-each)
                    (cd "$source" && find . \( -type f -o -type l \)) | while read -r rel; do
                        rel="${rel#./}"
                        if [[ -e "$target/$rel" && ! -L "$target/$rel" ]]; then backup "$target/$rel"; fi
                    done
                    ;;
            esac
        done
}

# Stubs are edited per machine, so only move ones that differ from the template.
backup_stubs() {
    local f
    (cd "$DOTFILES/stubs" && find . -type f) | while read -r f; do
        f="${f#./}"
        if [[ -e "$HOME/$f" || -L "$HOME/$f" ]] && ! cmp -s "$DOTFILES/stubs/$f" "$HOME/$f"; then
            backup "$HOME/$f"
        fi
    done
}

if ! command -v mise >/dev/null 2>&1; then
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

if [[ ! -d "$DOTFILES/.git" ]]; then
    git clone "$REPO_URL" "$DOTFILES"
fi

mkdir -p "$HOME/.config/mise/conf.d"
mapping="$HOME/.config/mise/conf.d/dotfiles.toml"
if ((BACKUP)) && [[ -e "$mapping" && ! -L "$mapping" ]]; then backup "$mapping"; fi
ln -sfn "$DOTFILES/.config/mise/conf.d/dotfiles.toml" "$mapping"

mise trust "$DOTFILES"
if ((BACKUP)); then
    backup_dotfiles
    backup_stubs
fi
mise dotfiles apply --yes
mise -C "$DOTFILES" install
# Download vale packages: from ~ for the user config, from the repo for its own.
(cd "$HOME" && mise -C "$DOTFILES" exec -- vale sync)
(cd "$DOTFILES" && mise exec -- vale sync)
mise -C "$DOTFILES" run setup
mise -C "$DOTFILES" run stubs

# ~/.zshenv sets ZDOTDIR=~/.config/zsh, so zsh no longer reads these from ~.
for f in .zshrc .zprofile .zlogin .zlogout; do
    if [[ -f "$HOME/$f" && ! -L "$HOME/$f" ]]; then
        echo "warning: zsh now skips ~/$f; move what you need into ~/.config/zsh/$f" >&2
    fi
done

if [[ -d "$BACKUP_DIR" ]]; then
    echo "Backed up existing files to $BACKUP_DIR"
fi
