# shellcheck shell=bash
# Shell startup stub, created once by `mise run stubs` from ~/.dotfiles/stubs.
# This copy is not tracked: the machine owns it, and installers may append.
# Move anything worth keeping into ~/.config/shell/dev.sh or ~/.localrc.
# bash login shells read only this file, so hand off to .bashrc.
# shellcheck source=/dev/null
if [ -f "$HOME/.config/shell/trace.sh" ]; then . "$HOME/.config/shell/trace.sh"
else __trace_start() { :; }; __trace_end() { :; }; __trace_note() { :; }; fi
__trace_start "$HOME/.bash_profile"

# shellcheck source=/dev/null
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

__trace_end "$HOME/.bash_profile"
