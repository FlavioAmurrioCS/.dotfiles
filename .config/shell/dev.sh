#!/usr/bin/env bash
# shellcheck disable=SC3033
# shellcheck disable=SC2317
# TODO: Add shims for fzf and gum
# TODO: Use gum for enhanced user experience

###############################################################################
# region: SHELL DETECTION (POSIX sh up to the sh return below)
###############################################################################
# Detected, not passed in: bash reads ~/.profile when there's no
# ~/.bash_profile, and macOS /bin/sh is bash. Bash already in POSIX mode
# (`set -o posix`, or /bin/sh after its startup files) lacks process
# substitution, and ksh doesn't share bash's syntax, so both get the sh setup.
if [ -n "${ZSH_VERSION:-}" ]; then
  __DEV_SH_CURRENT_SHELL__='zsh'
elif [ -n "${BASH_VERSION:-}" ]; then
  case ":${SHELLOPTS:-}:" in
  *:posix:*) __DEV_SH_CURRENT_SHELL__='sh' ;;
  *) __DEV_SH_CURRENT_SHELL__='bash' ;;
  esac
else
  __DEV_SH_CURRENT_SHELL__='sh'
fi

# The stubs source trace.sh first. When dev.sh runs as a script, or trace.sh
# is missing, the trace calls do nothing.
if ! command -v __trace_start >/dev/null 2>&1; then
  __trace_start() { :; }
  __trace_end() { :; }
  __trace_note() { :; }
fi

# Whether this file is sourced, and its path. sh can't tell its own path, so
# the ~/.profile stub passes it in __DEV_SH_SCRIPT__.
__DEV_SH_IS_SOURCED__='false'
case "${__DEV_SH_CURRENT_SHELL__}" in
bash)
  # shellcheck disable=SC3028,SC3054
  [ "${BASH_SOURCE[0]}" != "${0}" ] && __DEV_SH_IS_SOURCED__='true'
  # shellcheck disable=SC3028,SC3054
  __DEV_SH_SCRIPT__="${BASH_SOURCE[0]}"
  ;;
zsh)
  case "${ZSH_EVAL_CONTEXT:-}" in *:file) __DEV_SH_IS_SOURCED__='true' ;; esac
  # %x is the file being read, even inside a function, unlike %N.
  # shellcheck disable=SC2296
  __DEV_SH_SCRIPT__="${(%):-%x}"  # shuck: ignore=X049 # zsh-only branch
  ;;
*)
  # Not `(return 0)`: dash allows return at the top of a script, so that test
  # always says sourced. Run directly, $0 is this file; sourced, it's the shell.
  case "${0##*/}" in
  dev.sh) __DEV_SH_SCRIPT__="${0}" ;;
  *) __DEV_SH_IS_SOURCED__='true' ;;
  esac
  ;;
esac

__DEV_SH_TRACE_NAME__="${__DEV_SH_SCRIPT__}"
__trace_start "${__DEV_SH_TRACE_NAME__}" "${__DEV_SH_CURRENT_SHELL__}"

# Parameter expansion instead of dirname, basename and uname: each external
# command costs a fork, about 1-2ms, on every new shell.
case "${__DEV_SH_SCRIPT__}" in
*/*) __DEV_SH_SCRIPT_DIR__="${__DEV_SH_SCRIPT__%/*}" ;;
*) __DEV_SH_SCRIPT_DIR__='.' ;;
esac
__DEV_SH_SCRIPT_DIR__="$(cd "${__DEV_SH_SCRIPT_DIR__}" >/dev/null 2>&1 && pwd -P)"
__DEV_SH_SCRIPT__="${__DEV_SH_SCRIPT_DIR__}/${__DEV_SH_SCRIPT__##*/}"

if [ -z "${RUNNING_OS:-}" ]; then
  case "${OSTYPE:-}" in
  darwin*) RUNNING_OS='Darwin' ;;
  linux*) RUNNING_OS='Linux' ;;
  *) RUNNING_OS="$(uname -s)" ;;
  esac
fi
case "${RUNNING_OS}" in
Darwin)
  # export APPLICATION_DIR="${HOME}/Applications"
  # export HOMEBREW_HOME="${APPLICATION_DIR}/brew"
  # export HOMEBREW_PREFIX="${HOMEBREW_HOME}"
  # export HOMEBREW_CASK_OPTS="--appdir=${APPLICATION_DIR}"
  # export PATH="${HOMEBREW_HOME}/bin:${PATH}"
  ;;
Linux)
  : Do nothing
  ;;
*)
  : "${RUNNING_OS} is not configured." >&2
  ;;
esac

# export TOOL_INSTALLER_OPT_DIR="${TOOL_INSTALLER_OPT_DIR:-${HOME}/opt/runtool}"
# export TOOL_INSTALLER_BIN_DIR="${TOOL_INSTALLER_BIN_DIR:-${TOOL_INSTALLER_OPT_DIR}/bin}"
# export TOOL_INSTALLER_PIPX_HOME="${TOOL_INSTALLER_PIPX_HOME:-${TOOL_INSTALLER_OPT_DIR}/pipx_home}"
# export TOOL_INSTALLER_PACKAGE_DIR="${TOOL_INSTALLER_PACKAGE_DIR:-${TOOL_INSTALLER_OPT_DIR}/packages}"
# export TOOL_INSTALLER_GIT_PROJECT_DIR="${TOOL_INSTALLER_GIT_PROJECT_DIR:-${TOOL_INSTALLER_OPT_DIR}/git_projects}"
# export PIPX_BIN_DIR="${PIPX_BIN_DIR:-${TOOL_INSTALLER_BIN_DIR}}"
# export PIPX_HOME="${PIPX_HOME:-${TOOL_INSTALLER_PIPX_HOME}}"
export PATH="${HOME}/.local/bin:${PATH}"
# export PATH="${TOOL_INSTALLER_BIN_DIR}:${HOME}/.local/bin:${PATH}"
# export HATCH_ENV_TYPE_VIRTUAL_PATH="venv"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --exact"

# Setup every shell gets, sh included: ~/.secretsrc, ~/.localrc and aliases.
__dev_sh_posix_setup() {
  for __rc in "${HOME}/.secretsrc" "${HOME}/.localrc"; do
    [ -f "${__rc}" ] || continue
    __trace_start "${__rc}"
    # shellcheck disable=SC1090
    . "${__rc}"
    __trace_end "${__rc}"
  done
  unset __rc

  # shellcheck disable=SC2139
  alias ,source=". ${__DEV_SH_SCRIPT__}"
  alias ,dotfiles='git -C "${HOME}/.dotfiles"'
  alias ,dotfiles_code='code "${HOME}/.dotfiles"'
  alias ..='cd ..'
  alias ...='cd ../..'
  alias ....='cd ../../..'
  alias .....='cd ../../../..'
  alias ......='cd ../../../../..'
  alias .......='cd ../../../../../..'
}

# sh stops here, before the first line of bash syntax, which sh can't parse.
# sh reads a sourced file one command at a time, so it never reaches the rest.
# Non-interactive shells stop here too: bash reads ~/.bashrc for
# `ssh host cmd`, scp and rsync, which need PATH but not the prompt setup.
__dev_sh_minimal='false'
[ "${__DEV_SH_CURRENT_SHELL__}" = 'sh' ] && __dev_sh_minimal='true'
case $- in *i*) ;; *) __dev_sh_minimal='true' ;; esac
if [ "${__dev_sh_minimal}" = 'true' ]; then
  unset __dev_sh_minimal
  if [ "${__DEV_SH_IS_SOURCED__}" = 'true' ]; then
    # mise has no sh activation, but its shims are a plain directory.
    export PATH="${MISE_DATA_DIR:-${XDG_DATA_HOME:-${HOME}/.local/share}/mise}/shims:${PATH}"
    __dev_sh_posix_setup
    __trace_end "${__DEV_SH_TRACE_NAME__}"
    return 0
  fi
  if [ "${__DEV_SH_CURRENT_SHELL__}" = 'sh' ]; then
    echo "dev.sh: run it with bash: bash ${__DEV_SH_SCRIPT__} [function] [args]" >&2
    exit 1
  fi
fi
unset __dev_sh_minimal

###############################################################################
# endregion: SHELL DETECTION
###############################################################################

###############################################################################
# region: SCRIPT SETUP DO NOT EDIT
###############################################################################
# The public functions in this file, for running it as a script and for
# `dev.sh [tab][tab]`. Built on first use: the sed costs a fork per new shell.
__dev_sh_function_list() {
  [ -n "${__DEV_SH_FUNCTION_LIST__+set}" ] && return 0
  __DEV_SH_FUNCTION_LIST__=()
  while IFS='' read -r line; do
    __DEV_SH_FUNCTION_LIST__+=("$line")
  done < <(sed -n 's/^\([^ _][^ ]*\)() {.*/\1/p' "${__DEV_SH_SCRIPT__}")
}

###############################################################################
# endregion: SCRIPT SETUP DO NOT EDIT
###############################################################################

###############################################################################
# region: FUNCTIONS THAT ARE COMMON FOR BOTH SOURCED AND EXECUTED
###############################################################################
_select_project() {
  __selected="$(find ~/{dev,worktrees,projects,dev/*git*/*} -maxdepth 3 \( -name .git -or -name packed-refs \) -prune -exec dirname {} \; 2>/dev/null | grep -v /trash/ | fzf --keep-right)"
  [ -n "${__selected}" ] && echo "${__selected}" && return 0
  return 1
}

,noerror() { "${@}" 2>/dev/null; }
,nooutput() { "${@}" >/dev/null 2>&1; }
,cache_clear() { ,nooutput rm -rf "${HOME}/.cache/dev.sh"; }
,uniq() { awk '!x[$0]++' "${@}"; }
grep() { command grep --color=auto --line-buffered "${@}"; }

,cache() {
  if [ -n "${NO_CACHE}" ]; then
    "${@}"
    return $?
  fi
  local cache_dir="${HOME}/.cache/dev.sh" \
    cache_file \
    temp_cache_file \
    temp_return_code \
    cmd_exit_code
  # TODO: Consider adding cache expiration
  # case "${1}" in
  # --permanent) shift 1 && cmd_str_to_be_hash="${*}" ;;
  # --hourly) shift 1 && cmd_str_to_be_hash="$(date +'%Y_%m_%d_%H') ${*}" ;;
  # *) cmd_str_to_be_hash="$(date +'%Y_%m_%d') ${*}" ;;
  # esac
  # command_hash=$(echo "${cmd_str_to_be_hash}" | md5sum | grep -oE '[a-z0-9]+')
  # cache_file="${cache_dir}/$(shUtil.joinBy '_' "${@}")_${command_hash}"
  cache_file="${cache_dir}/$(echo "${@}" | { md5sum 2>/dev/null || md5; } | cut -d' ' -f1)"

  if [ -f "${cache_file}" ]; then
    cat "${cache_file}"
    return 0
  fi

  temp_return_code=$(mktemp)
  temp_cache_file=$(mktemp)
  {
    echo -n "1" >"${temp_return_code}"
    "${@}"
    echo -n "$?" >"${temp_return_code}"
  } | tee "${temp_cache_file}"
  cmd_exit_code="$(head -n 1 "${temp_return_code}")"
  if [ "${cmd_exit_code}" -eq 0 ]; then
    mkdir -p "${cache_dir}"
    mv "${temp_cache_file}" "${cache_file}"
  fi

  return "${cmd_exit_code}"
}

__get_repos__() {
  local domain user repo api_url complete_url_user complete_url_org curl_cmd
  read -r domain user repo <<<"$(echo "${1}" | awk -F[/:] '{print $4,$5,$6}')"
  curl_cmd=(curl --silent --fail)

  case "${domain}" in
  github.com) api_url="https://api.github.com" ;;
  *)
    api_url="https://${domain}/api/v3"
    curl_cmd+=(-H "Authorization: token ${GITHUB_TOKEN}")
    ;;
  esac
  complete_url_user="${api_url}/users/${user}/repos?per_page=99999"
  complete_url_org="${api_url}/orgs/${user}/repos?per_page=99999"
  "${curl_cmd[@]}" "${complete_url_org}" || "${curl_cmd[@]}" "${complete_url_user}"
}

,clone() {
  local project domain owner repo project_path projects
  projects=${1:-"$({
    for i in $(echo "${GITHUB_FOLLOW}" | tr ' ' '\n' | sort -u); do
      ,cache __get_repos__ "${i}" &
    done
  } | grep "ssh_url" | cut -d '"' -f4 | sort -u | fzf --multi --exit-0)"}

  if [ -z "${projects}" ] && [ -z "${GITHUB_FOLLOW}" ]; then
    echo "Set GITHUB_FOLLOW to a list of github users/orgs to follow or pass in clone url directly. If github enterprise, set GITHUB_TOKEN as well." >&2
    return 1
  fi

  for project in ${projects}; do
    case "${project}" in
    https*) read -r domain owner repo <<<"$(echo "${project}" | sed -E 's|https://([^/]+)/(.+)\/(.+).*|\1 \2 \3|')" ;;
    *) read -r domain owner repo <<<"$(echo "${project}" | sed -E 's/.*@(.+):(.+)\/(.+)\.git/\1 \2 \3/')" ;;
    esac

    project_path="${HOME}/dev/${domain}/${owner}/${repo}"
    if [ ! -d "${project_path}" ]; then
      git clone "${project}" "${project_path}"
    fi
  done
}

,mv-project() {
  local domain owner repo new_project_path git_remote original_project_path
  for original_project_path in "${@}"; do
    echo "- ${original_project_path}"
    original_project_path=$(realpath "${original_project_path}")
    git_remote=$(git -C "${original_project_path}" remote get-url origin 2>/dev/null)
    if [ -z "${git_remote}" ]; then
      echo "${original_project_path} does not have a remote origin" >&2
      continue
    fi
    case "${git_remote}" in
    https*) read -r domain owner repo <<<"$(echo "${git_remote}" | sed -E 's|https://([^/]+)/(.+)\/(.+).*|\1 \2 \3|')" ;;
    *) read -r domain owner repo <<<"$(echo "${git_remote}" | sed -E 's/.*@(.+):(.+)\/(.+)\.git/\1 \2 \3/')" ;;
    esac
    new_project_path="${HOME}/dev/${domain}/${owner}/$(basename "${original_project_path}")"
    if [ ! -d "${new_project_path}" ]; then
      mkdir -p "$(dirname "${new_project_path}")"
      mv "${original_project_path}" "${new_project_path}"
    else
      echo "${new_project_path} already exists. Skipping..." >&2
    fi
  done
}

,runtool() { command runtool "${@}"; }

###############################################################################
# endregion: FUNCTIONS THAT ARE COMMON FOR BOTH SOURCED AND EXECUTED
###############################################################################

if [ "${__DEV_SH_IS_SOURCED__}" = 'true' ]; then
  : File is being sourced
  ###############################################################################
  # region: FUNCTIONS THAT SHOULD ONLY BE AVAILABLE WHEN FILE IS BEING SOURCED
  ###############################################################################
  # Sources the script a tool generates (`mise activate bash`), cached per
  # binary path. A new install path (mise installs by version) or a binary
  # newer than the cache (a self-update) regenerates it. The temp file is per
  # process, so shells starting together don't write over each other.
  # The path lookup skips functions and aliases: once `mise activate` defines a
  # `mise` function, `command -v mise` prints `mise` instead of a path.
  enable_autocomplete() {
    if [ "${__DEV_SH_CURRENT_SHELL__}" = 'zsh' ]; then
      _bin="$(whence -p "${1}")"
    else
      _bin="$(type -P "${1}")"
    fi
    # A mise shim stays the same when its tool is upgraded, so key the cache
    # on the real install path instead.
    case "${_bin}" in
    */mise/shims/*) _bin="$(command mise which "${1}" 2>/dev/null)" ;;
    esac
    [ -n "${_bin}" ] || return 1
    _dir="${XDG_CACHE_HOME:-${HOME}/.cache}/dev.sh/autocomplete"
    _filename="${*}${_bin}"
    _filename="${_dir}/${_filename//[ \/]/_}.sh"
    _note=
    if [ ! -s "${_filename}" ] || [ "${_bin}" -nt "${_filename}" ]; then
      _note='regenerated'
    fi
    __trace_start "${*}" "${_note}"
    if [ -n "${_note}" ]; then
      [ -d "${_dir}" ] || mkdir -p "${_dir}"
      "${@}" >"${_filename}.$$" || { rm -f "${_filename}.$$"; __trace_end "${*}"; return 1; }
      mv "${_filename}.$$" "${_filename}"
    fi
    # shellcheck disable=SC1090
    . "${_filename}"
    __trace_end "${*}"
  }

  # mise's shims by default: tools resolve, with no `mise hook-env` at startup
  # or at each prompt (about 30ms on an M3, 100ms on a Raspberry Pi 4).
  # `,mise-activate` turns on full activation in this shell: uv_venv_auto and
  # the env vars from mise config.
  export PATH="${MISE_DATA_DIR:-${XDG_DATA_HOME:-${HOME}/.local/share}/mise}/shims:${PATH}"
  ,mise-activate() {
    enable_autocomplete mise activate "${__DEV_SH_CURRENT_SHELL__}"
  }

  ,cd() {
    __selected="$(_select_project)"
    [ -n "${__selected}" ] && cd "${__selected}" && return 0
    return 1
  }

  ,activate() {
    __walker=${PWD}
    while true; do
      __found="$(find . -type f -name activate -not -path './.tox/*' -print -quit)"
      # shellcheck disable=SC1090
      [ -n "${__found}" ] && source "${__found}" && return 0
      [ "${__walker}" = "/" ] && return 1
      __walker="$(dirname "${__walker}")"
    done
  }

  ,code() {
    __selected="$(_select_project)"
    [ -n "${__selected}" ] && code "${__selected}" "${@}" && return 0
    return 1
  }

  ,env() { env | fzf --multi; }
  ,web() {
    __git_url=$(git remote get-url origin) || return 1
    case "${__git_url}" in
    https*) : ;;
    *) __git_url="$(echo "${__git_url}" | sed -E 's|.*@(.+):(.+)\/(.+)\.git|https://\1/\2/\3|')" ;;
    esac
    ,runtool run rifle "${__git_url}"
  }

  __dev_sh_posix_setup
  # theme.sh writes the colors straight to /dev/tty, so it needs a terminal.
  # THEME_SH_THEME='atelier-sulphurpool'
  # [ -n "${THEME_SH_THEME}" ] && [ -t 1 ] && command -v theme.sh >/dev/null 2>&1 && theme.sh "${THEME_SH_THEME}"

  # Git branch and dirty marker for the prompt. Runs once per prompt, with a
  # single git call. Colors sit between __PS1_NP_OPEN and __PS1_NP_CLOSE, which
  # each shell sets so its line editor leaves them out of the prompt's width:
  # \001 and \002 for bash's readline, %{ and %} for zsh.
  # --ignore-submodules=dirty: don't scan submodules' files, but still flag a
  # submodule moved to another commit. --no-optional-locks: never take
  # .git/index.lock, which would collide with git in another terminal.
  # A variable and <<< rather than < <(...): bash in POSIX mode (macOS
  # /bin/sh) can't run process substitution. The variable is `out` because
  # zsh reserves `status` for the last exit code.
  __ps1_git() {
    local out line branch oid dirty="" o="${__PS1_NP_OPEN}" c="${__PS1_NP_CLOSE}"
    out=$(git --no-optional-locks status --porcelain=v2 --branch --ignore-submodules=dirty 2>/dev/null) || return 0
    while IFS= read -r line; do
      case ${line} in
      "# branch.head "*) branch=${line#\# branch.head } ;;
      "# branch.oid "*) oid=${line#\# branch.oid } ;;
      "#"*) ;;
      *) dirty=" ${o}"$'\e[1;93m'"${c}✗" && break ;;
      esac
    done <<<"${out}"
    [ -n "${branch}" ] || return 0
    [ "${branch}" = "(detached)" ] && branch=${oid:0:7}
    # zsh would read a % in a branch name as a prompt escape.
    [ "${__DEV_SH_CURRENT_SHELL__}" = 'zsh' ] && branch=${branch//\%/%%}
    printf '%s\e[1;96m%s[%s\e[1;91m%s%s%s%s\e[1;96m%s]' "${o}" "${c}" "${o}" "${c}" "${branch}" "${dirty}" "${o}" "${c}"
  }

  # fzf's key bindings and completion load on first use, not at startup: the
  # first `fzf`, or the first Ctrl-R (bound below for each shell).
  __dev_sh_fzf_load() {
    unset -f fzf
    enable_autocomplete fzf "--${__DEV_SH_CURRENT_SHELL__}"
  }
  # Inside $(...) or a pipe, as in ,cd, the load would be thrown away.
  fzf() {
    [ "${BASH_SUBSHELL:-${ZSH_SUBSHELL:-0}}" -eq 0 ] && __dev_sh_fzf_load
    command fzf "${@}"
  }

  case "$__DEV_SH_CURRENT_SHELL__" in
  bash)
    export BASH_SILENCE_DEPRECATION_WARNING=1

    # ================================== history ===================================
    # https://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
    export HISTSIZE=9000
    export HISTFILESIZE="${HISTSIZE}"
    export HISTCONTROL=ignorespace:ignoredups

    _bash_history_sync() {
      builtin history -a         #1
      HISTFILESIZE="${HISTSIZE}" #2
      builtin history -c         #3
      builtin history -r         #4
    }

    history() { #5
      _bash_history_sync
      builtin history "$@"
    }
    PROMPT_COMMAND=_bash_history_sync
    ## reedit a history substitution line if it failed
    shopt -s histreedit
    ## edit a recalled history line before executing
    shopt -s histverify

    shopt -s extglob

    [[ $- == *i* ]] &&
      bind '"\e[A": history-search-backward' &&
      bind '"\e[B": history-search-forward'

    __PS1_NP_OPEN=$'\001'
    __PS1_NP_CLOSE=$'\002'
    PS1="$(
      __TPUT_BOLD="\[\e[1m\]"
      __TPUT_RED="\[\e[1;91m\]"
      __TPUT_GREEN="\[\e[1;92m\]"
      __TPUT_YELLOW="\[\e[1;93m\]"
      __TPUT_BLUE="\[\e[1;94m\]"
      __TPUT_MAGENTA="\[\e[1;95m\]"
      __TPUT_RESET="\[\e[0m\]"
      __PS1_WRAPPER_START="${__TPUT_RESET}\n${__TPUT_RED}["
      __PS1_USERNAME="${__TPUT_YELLOW}\u"
      __PS1_AT="${__TPUT_GREEN}@"
      __PS1_HOSTNAME="${__TPUT_BLUE}\${MACHINE_NAME:-\h}"
      __PS1_WORKSPACE="${__TPUT_MAGENTA}\w"
      __PS1_WRAPPER_END="${__TPUT_RED}]"
      __PS1_PROMPT="\n${__TPUT_RESET}${__TPUT_BOLD}\\$ ${__TPUT_RESET}"

      # shellcheck disable=SC2016 # expanded at each prompt, not now
      __PS1_GIT='$(__ps1_git)'

      echo "${__PS1_WRAPPER_START}${__PS1_USERNAME}${__PS1_AT}${__PS1_HOSTNAME} ${__PS1_WORKSPACE}${__PS1_WRAPPER_END}${__PS1_GIT}${__PS1_PROMPT}"
    )"
    # Ctrl-R loads fzf, then opens its history search. Loading rebinds Ctrl-R
    # to fzf's own widget. bash 3.2 binds it differently, so it keeps the
    # plain history search there until the first `fzf`.
    if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
      __dev_sh_fzf_history() {
        DOTFILES_TRACE=0 __dev_sh_fzf_load
        __fzf_history__
      }
      bind -m emacs-standard -x '"\C-r": __dev_sh_fzf_history'
      bind -m vi-command -x '"\C-r": __dev_sh_fzf_history'
      bind -m vi-insert -x '"\C-r": __dev_sh_fzf_history'
    fi
    ;;
  zsh)
    # compinit's permission audit (compaudit) is half its cost. Run it only
    # when the dump is missing or over a day old, and trust the dump otherwise.
    # eval because the glob qualifier is zsh syntax that bash can't parse.
    autoload -U +X compinit
    eval '__dev_sh_dump=( "${ZDOTDIR:-$HOME}"/.zcompdump(N.mh-24) )'
    if [ -n "${__dev_sh_dump[*]}" ]; then
      compinit -C
    else
      compinit && touch "${ZDOTDIR:-$HOME}/.zcompdump"
    fi
    unset __dev_sh_dump
    autoload -U +X bashcompinit && bashcompinit
    # The same layout and colors as the bash prompt. PROMPT_SUBST runs
    # $(__ps1_git) at each prompt; %(!.#.$) is bash's \$.
    setopt PROMPT_SUBST
    __PS1_NP_OPEN='%{'
    __PS1_NP_CLOSE='%}'
    # shellcheck disable=SC2025 # zsh marks zero-width codes with %{ %}, not \[ \]
    PS1=$'\n%{\e[0m%}%{\e[1;91m%}[%{\e[1;93m%}%n%{\e[1;92m%}@%{\e[1;94m%}${MACHINE_NAME:-%m} %{\e[1;95m%}%~%{\e[1;91m%}]$(__ps1_git)\n%{\e[0m%}%{\e[1m%}%(!.#.$) %{\e[0m%}'  # shuck: ignore=X049 # zsh-only branch
    # Ctrl-R loads fzf, then opens its history search. Loading rebinds Ctrl-R
    # to fzf's own widget.
    __dev_sh_fzf_history() {
      DOTFILES_TRACE=0 __dev_sh_fzf_load
      zle fzf-history-widget
    }
    zle -N __dev_sh_fzf_history
    bindkey -M emacs '^R' __dev_sh_fzf_history
    bindkey -M vicmd '^R' __dev_sh_fzf_history
    bindkey -M viins '^R' __dev_sh_fzf_history
    ;;
  *)
    PS1="dev.sh: ${__DEV_SH_CURRENT_SHELL__} not supported"
    ;;
  esac

  ###############################################################################
  # endregion: FUNCTIONS THAT SHOULD ONLY BE AVAILABLE WHEN FILE IS BEING SOURCED
  ###############################################################################

  ###############################################################################
  # region: DO NOT EDIT THE BLOCK BELOW
  ###############################################################################
  dev.sh() {
    "${__DEV_SH_SCRIPT__}" "${@}"
  }
  # $2 is the word being completed, in bash and in zsh's bashcompinit.
  __dev_sh_complete() {
    __dev_sh_function_list
    COMPREPLY=()
    while IFS='' read -r line; do
      COMPREPLY+=("$line")
    done < <(compgen -W "${__DEV_SH_FUNCTION_LIST__[*]}" -- "${2}")
  }
  complete -F __dev_sh_complete dev.sh ./dev.sh
  __trace_note "dev.sh [tab][tab] for autocomplete"
  __trace_end "${__DEV_SH_TRACE_NAME__}"
  return 0
  ###############################################################################
  # endregion: DO NOT EDIT THE BLOCK ABOVE
  ###############################################################################
fi

###############################################################################
# region: FUNCTIONS THAT SHOULD ONLY BE ACCESS WHEN FILE IS BEING EXECUTED
###############################################################################

# shellcheck disable=SC2329 # called through "$@" when executed
hello_world() {
  echo "Hello World!"
}

###############################################################################
# endregion: FUNCTIONS THAT SHOULD ONLY BE ACCESS WHEN FILE IS BEING EXECUTED
###############################################################################

###############################################################################
# region: SCRIPT SETUP DO NOT EDIT
###############################################################################
: File is being executed
[ "${1}" = 'debug' ] && set -x && shift 1
__dev_sh_function_list

# shellcheck disable=SC1009
# shellcheck disable=SC1058
# shellcheck disable=SC1073
# shellcheck disable=SC1072
if [ -n "${1}" ] && [[ ${__DEV_SH_FUNCTION_LIST__[*]} =~ ${1} ]]; then
  "${@}"
  exit $?
else
  echo "Usage: ${0} [function_name] [args]" >&2
  echo "Available functions:" >&2
  for function in "${__DEV_SH_FUNCTION_LIST__[@]}"; do
    echo "    ${function}" >&2
  done
  exit 1
fi
###############################################################################
# endregion: SCRIPT SETUP DO NOT EDIT
###############################################################################
