# shellcheck shell=sh
# Shell startup trace: a dimmed tree of the files a shell sources, with how
# long each took where the shell has a sub-second clock (bash 5, zsh).
#
#   __trace_start <file> [note]   before sourcing a file
#   __trace_end <file>            after it
#   __trace_note <text>           a line inside the current file
#
# With a clock, it ends with "first prompt +Nms": the time from the startup
# files ending to the first prompt, which the tree doesn't cover.
#
# Prints only in interactive shells, to stderr. DOTFILES_TRACE=0 silences it.
# Plain POSIX sh so sh, bash 3.2, bash 5 and zsh can all source it, and no
# $(...), whose forks would show up in the timings.

[ -n "${ZSH_VERSION:-}" ] && zmodload zsh/datetime 2>/dev/null
__TRACE_DEPTH=${__TRACE_DEPTH:-0}

__trace_on() {
    case $- in
        *i*) [ "${DOTFILES_TRACE:-1}" != 0 ] ;;
        *) return 1 ;;
    esac
}

# Sets __TRACE_NOW to microseconds since the epoch, or empty without a clock.
__trace_now() {
    __TRACE_NOW=
    [ -n "${EPOCHREALTIME:-}" ] || return 0
    __trace_frac="${EPOCHREALTIME#*[.,]}000000"
    __trace_frac=${__trace_frac%"${__trace_frac#??????}"}
    __TRACE_NOW="${EPOCHREALTIME%[.,]*}${__trace_frac}"
}

__trace_line() {
    __trace_i=0
    __trace_bars=
    while [ "${__trace_i}" -lt "${__TRACE_DEPTH}" ]; do
        __trace_bars="${__trace_bars}│ "
        __trace_i=$((__trace_i + 1))
    done
    if [ -t 2 ]; then
        printf '\033[2m%s%s\033[0m\n' "${__trace_bars}" "$1" >&2
    else
        printf '%s%s\n' "${__trace_bars}" "$1" >&2
    fi
}

# Sets __TRACE_PATH to $1 with $HOME shown as ~.
__trace_path() {
    case $1 in
        "${HOME}"/*) __TRACE_PATH="~${1#"${HOME}"}" ;;
        *) __TRACE_PATH=$1 ;;
    esac
}

__trace_start() {
    __trace_on || return 0
    __trace_path "$1"
    __trace_line "┌ ${__TRACE_PATH}${2:+ ($2)}"
    __trace_now
    eval "__TRACE_T_${__TRACE_DEPTH}=\$__TRACE_NOW"
    __TRACE_DEPTH=$((__TRACE_DEPTH + 1))
}

__trace_end() {
    __trace_on || return 0
    [ "${__TRACE_DEPTH}" -gt 0 ] && __TRACE_DEPTH=$((__TRACE_DEPTH - 1))
    eval "__trace_t=\${__TRACE_T_${__TRACE_DEPTH}:-}"
    __trace_took=
    if [ -n "${__trace_t}" ]; then
        __trace_now
        __trace_took=" $(((__TRACE_NOW - __trace_t) / 1000))ms"
    fi
    __trace_path "$1"
    __trace_line "└ ${__TRACE_PATH}${__trace_took}"
    if [ "${__TRACE_DEPTH}" -eq 0 ]; then
        __trace_hook_prompt
    fi
}

# Runs when an outermost file ends. The last one to end sets the start of the
# "first prompt" time. The hook is added once, after what PROMPT_COMMAND
# already holds, so it times cmux's bootstrap but not hooks added later
# (Ghostty's) or the PS1 expansion.
__trace_hook_prompt() {
    __trace_now
    __TRACE_DONE=${__TRACE_NOW}
    [ -n "${__TRACE_DONE}" ] && [ -z "${__TRACE_HOOKED:-}" ] || return 0
    __TRACE_HOOKED=1
    if [ -n "${ZSH_VERSION:-}" ]; then
        eval 'precmd_functions+=(__trace_first_prompt)'
    elif [ -n "${BASH_VERSION:-}" ]; then
        PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND};}__trace_first_prompt"
    fi
}

__trace_first_prompt() {
    [ -n "${__TRACE_DONE:-}" ] || return 0
    __trace_now
    __trace_note "first prompt +$(((__TRACE_NOW - __TRACE_DONE) / 1000))ms"
    __TRACE_DONE=
}

__trace_note() {
    __trace_on || return 0
    __trace_line "· $*"
}
