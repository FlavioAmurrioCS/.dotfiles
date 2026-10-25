# Shell startup stub, created once by `mise run stubs` from ~/.dotfiles/stubs.
# This copy is not tracked: the machine owns it, and installers may append.
# Move anything worth keeping into ~/.config/shell/dev.sh or ~/.localrc.
# shellcheck source=/dev/null
if [ -f "${HOME}/.config/shell/trace.sh" ]; then . "${HOME}/.config/shell/trace.sh"
else __trace_start() { :; }; __trace_end() { :; }; __trace_note() { :; }; fi
__trace_start "${ZDOTDIR}/.zshrc"

[ -f "${HOME}/.config/shell/dev.sh" ] && . "${HOME}/.config/shell/dev.sh"

__trace_end "${ZDOTDIR}/.zshrc"
