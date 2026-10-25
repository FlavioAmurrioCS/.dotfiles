################################################################################
# Location Docs: https://zsh.sourceforge.io/Doc/Release/Files.html#Startup_002fShutdown-Files
# Location User: ~/.zshenv (the only zsh file in ~; the rest are in ZDOTDIR)
# Location Repo: none (zsh has no project-level config)
# Location Check: zsh -o sourcetrace -lic exit 2>&1 | grep '^+'
################################################################################
# zsh reads this file first, for every shell, scripts included. It reads the
# rest (.zprofile, .zshrc, .zlogin) from ZDOTDIR. Those are untracked stubs
# from ~/.dotfiles/stubs, so installers can append to them.
# shellcheck source=/dev/null
if [ -f "$HOME/.config/shell/trace.sh" ]; then . "$HOME/.config/shell/trace.sh"
else __trace_start() { :; }; __trace_end() { :; }; __trace_note() { :; }; fi
__trace_start "$HOME/.zshenv"

export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Installers that honour ZDOTDIR (rustup, for one) write $ZDOTDIR/.zshenv,
# which zsh only reads by itself when ZDOTDIR is already set.
if [ -f "$ZDOTDIR/.zshenv" ]; then
  __trace_start "$ZDOTDIR/.zshenv"
  # shellcheck source=/dev/null
  . "$ZDOTDIR/.zshenv"
  __trace_end "$ZDOTDIR/.zshenv"
fi

__trace_end "$HOME/.zshenv"
