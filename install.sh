#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
REPO_URL="${REPO_URL:-https://github.com/FlavioAmurrioCS/.dotfiles.git}"

if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if [[ ! -d "$DOTFILES/.git" ]]; then
  git clone "$REPO_URL" "$DOTFILES"
fi

mkdir -p "$HOME/.config/mise/conf.d"
ln -sfn "$DOTFILES/.config/mise/conf.d/dotfiles.toml" "$HOME/.config/mise/conf.d/dotfiles.toml"

mise trust "$DOTFILES"
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
