# Shell startup stub, created once by `mise run stubs` from ~/.dotfiles/stubs.
# This copy is not tracked: the machine owns it, and installers may append.
# Move anything worth keeping into ~/.config/shell/dev.sh or ~/.localrc.
# zsh login shells. PATH changes go here rather than in .zshenv, because
# /etc/zprofile's path_helper moves earlier entries behind the system folders.
# shellcheck source=/dev/null
if [ -f "$HOME/.config/shell/trace.sh" ]; then . "$HOME/.config/shell/trace.sh"
else __trace_start() { :; }; __trace_end() { :; }; __trace_note() { :; }; fi
__trace_start "$ZDOTDIR/.zprofile"


__trace_end "$ZDOTDIR/.zprofile"
