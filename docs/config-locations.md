# Config locations

How each tool in this repo finds its user-level and project-level config.
The preferred layout is `.config/`, both in `~` and in a project, following
the [config-dir] proposal. Checked on macOS on 2026-10-25.

## Summary

| Tool  | User-level file                    | Project `.config/` | Combines         |
| ----- | ---------------------------------- | ------------------ | ---------------- |
| mise  | `~/.config/mise/` + `conf.d/*.toml` | Yes, + `conf.d/`  | Merges           |
| ruff  | `~/.config/ruff/ruff.toml`         | No (root only)     | User is fallback |
| ty    | `~/.config/ty/ty.toml`             | No (root only)     | Merges           |
| shuck | `~/.config/shuck/shuck.toml`       | No (root only)     | User is fallback |
| tombi | `~/.config/tombi/config.toml`      | `.config/tombi.toml` | User is fallback |
| ryl   | `<config-dir>/ryl/ryl.toml`        | `.config/ryl.toml` | User is fallback |
| vale  | `<config-dir>/vale/.vale.ini`      | `.config/vale.ini` | Merges           |
| tmux  | `~/.config/tmux/tmux.conf`         | No project config  | Loads all found  |
| git   | `~/.config/git/config`, `ignore`   | No (`.git/config`) | Merges           |
| nvim  | `~/.config/nvim/` (directory)      | No (`exrc` only)   | User only        |
| zsh   | `~/.zshenv` + `$ZDOTDIR/.z*`       | No project config  | Loads all found  |
| bash  | `~/.bash_profile`, `~/.bashrc`     | No project config  | First found      |
| sh    | `~/.profile`                       | No project config  | User only        |

- **First found:** only the first file that exists is read.
- **User only:** there is no project config to combine with.
- **Merges:** the user file is always read, and the project file overrides it
  key by key.
- **User is fallback:** the user file is read only when no project file exists.
- **Loads all found:** every default file that exists is read, in order.
- **`<config-dir>`:** `$XDG_CONFIG_HOME` when set, else the platform directory.
  On macOS that is `~/Library/Application Support`, so this repo links both.
- **Repo links:** each config is at its `~` path, such as
  `.config/tombi/config.toml`. `mise run setup` links it to the name the tool's
  project lookup expects: the repo root for root-only tools, or `.config/`
  otherwise. `.gitignore` excludes these links.

## mise

Pattern: a directory with a main file and `conf.d/` fragments.

- **User:** `~/.config/mise/config.toml`, plus `conf.d/*.toml` loaded in
  alphabetical order before `config.toml`. Also `config.local.toml`,
  `config.<env>.toml` and `config.override.toml`. `MISE_CONFIG_DIR` moves the
  directory; `MISE_GLOBAL_CONFIG_FILE` replaces it with one file.
- **Project:** `mise.toml`, `mise/config.toml`, `.mise/config.toml`,
  `.config/mise.toml`, `.config/mise/{mise,config}.toml`, and
  `conf.d/*.toml` beside each of those directories.
- **Combines:** every file from `/etc/mise` to the global config to each
  directory down to the current one, merged per tool, setting, variable and
  task.
- **This repo:** `.config/mise/conf.d/*.toml` serves the repo and, once
  linked, the user config.
- **Docs:** [mise configuration hierarchy][mise-docs].

## ruff

Pattern: `~/.config/<tool>/<tool>.toml`.

- **User:** `.ruff.toml`, `ruff.toml` or `pyproject.toml` in
  `${XDG_CONFIG_HOME:-~/.config}/ruff/` on macOS and Linux. Ruff 0.13.0
  dropped the macOS `~/Library/Application Support/ruff/` fallback.
- **Project:** `.ruff.toml`, `ruff.toml`, or `pyproject.toml` with
  `[tool.ruff]`, at the project root. No `.config/` lookup.
- **Combines:** the user file is used only when no project file is found.
- **This repo:** root `ruff.toml` link to `.config/ruff/ruff.toml`.
- **Docs:** [ruff FAQ][ruff-faq], [ruff 0.13.0 breaking change][ruff-breaking].
- **config-dir:** [astral-sh/ruff#10493] asked for `.config/ruff.toml`. It was
  closed as not planned until a standard location has wider support.

## ty

Pattern: `~/.config/<tool>/<tool>.toml`.

- **User:** `${XDG_CONFIG_HOME:-~/.config}/ty/ty.toml` on macOS and Linux. It
  must be `ty.toml`, not `pyproject.toml`.
- **Project:** `ty.toml`, or `pyproject.toml` with `[tool.ty]`, in the current
  directory or the nearest parent. `ty.toml` wins. No `.config/` lookup.
- **Combines:** merged. Project scalars win and arrays are concatenated.
- **This repo:** root `ty.toml` link to `.config/ty/ty.toml`.
- **Docs:** [ty configuration][ty-docs].
- **config-dir:** no open issue found.

## shuck

Pattern: `~/.config/<tool>/<tool>.toml`.

- **User:** `.shuck.toml` or `shuck.toml` in `$SHUCK_CONFIG_HOME` when set,
  else `${XDG_CONFIG_HOME:-~/.config}/shuck/`, on macOS too. Only the source
  documents this lookup.
- **Project:** `.shuck.toml` or `shuck.toml`, searched upward from each file.
  `.shuck.toml` wins. No `.config/` lookup.
- **Combines:** the user file is used only when no project file is found.
  Project files don't merge with each other either: shuck reads only the
  nearest one.
  `--isolated` skips them all.
- **This repo:** root `shuck.toml` link to `.config/shuck/shuck.toml`.
- **Docs:** [shuck config discovery][shuck-docs], [user config lookup][shuck-user].
- **config-dir:** no open issue found.

## tombi

Pattern: `~/.config/<tool>/config.toml`.

- **User:** `$XDG_CONFIG_HOME/tombi/config.toml`, then
  `~/.config/tombi/config.toml` on every platform, then
  `~/Library/Application Support/tombi/config.toml` on macOS.
- **Project:** `.tombi.toml`, `tombi.toml`, `.config/tombi.toml`, or
  `pyproject.toml` with `[tool.tombi]`, searched upward from the current
  directory. tombi's docs link to the config-dir proposal.
- **Combines:** the user file is used only when no project file is found.
- **This repo:** `.config/tombi/config.toml`, linked to the same path in `~`.
  `mise run setup` links `.config/tombi.toml` to it for the repo.
- **Docs:** [tombi configuration][tombi-docs].

## ryl

Pattern: `<config-dir>/<tool>/<tool>.toml`.

- **User:** `<config-dir>/ryl/.ryl.toml`, then `ryl.toml`, then the legacy
  `<config-dir>/yamllint/config`. `<config-dir>` is `$XDG_CONFIG_HOME` when
  set, else `~/Library/Application Support` on macOS.
- **Project:** `.ryl.toml`, `ryl.toml`, `.config/.ryl.toml`,
  `.config/ryl.toml`, or `pyproject.toml` with `[tool.ryl]`, searched upward.
- **Combines:** the user file is used only when no project file is found.
- **This repo:** `.config/ryl/ryl.toml` (repo link `.config/ryl.toml`), linked
  to `~/.config/ryl/ryl.toml` and, on macOS, to
  `~/Library/Application Support/ryl/ryl.toml`.
- **Tested:** with a throwaway `HOME` and `XDG_CONFIG_HOME` unset, ryl ignored
  `~/.config/ryl/ryl.toml` and read the Application Support file.
- **Docs:** [ryl user-global config][ryl-docs].

## vale

Pattern: `<config-dir>/<tool>/.<tool>.ini`.

- **User:** `<config-dir>/vale/.vale.ini`. `<config-dir>` is
  `$XDG_CONFIG_HOME` when set, else `~/Library/Application Support` on macOS.
  `vale ls-dirs` prints the path in use.
- **Project:** `--config`, then `VALE_CONFIG_PATH`, then the first of
  `.vale.ini`, `_vale.ini`, `vale.ini`, `.vale`, `_vale` or `.config/vale.ini`,
  searched upward and then in `~`. A root-level file beats `.config/`.
- **Combines:** the user file is always read with the project file. `--no-global`
  skips it.
- **This repo:** `.config/vale/.vale.ini`, linked to `~/.config/vale/.vale.ini`
  and, on macOS, to `~/Library/Application Support/vale/.vale.ini`. It has
  only [vale-ai-tells], because vale merges it into every repo.
- **Repo-only:** `.config/vale.ini` adds Vale and Google for this repo's
  docs, with `StylesPath = ../styles` and the `Project` Vocab in
  `styles/config/vocabularies/`. mise doesn't link it, and git ignores the
  synced styles. A repo link can't do this: vale resolves a relative
  `StylesPath` from the path it found the config at and doesn't expand `~`.
- **Packages:** `vale sync` downloads the styles in `Packages` to that
  config's `StylesPath`. Run it from `~` for the user config (default
  `StylesPath`, outside this repo) and from the repo for `.config/vale.ini`.
- **Tested:** with a throwaway `HOME` and `XDG_CONFIG_HOME` unset, vale ignored
  `~/.config/vale/.vale.ini` and a flat `~/.config/vale.ini`, and read the
  Application Support file.
- **Docs:** [vale config search][vale-docs].
- **config-dir:** [vale-cli/vale#1212] added `.config/vale.ini`. It is closed
  as completed.

## tmux

Pattern: `~/.config/<tool>/<tool>.conf`.

- **User:** tmux reads every one of these that exists, in this order:
  `/etc/tmux.conf`, `~/.tmux.conf`, `$XDG_CONFIG_HOME/tmux/tmux.conf`, then
  `~/.config/tmux/tmux.conf`. The last one works on macOS without
  `XDG_CONFIG_HOME`. `-f <file>` replaces the list.
- **Versions:** `~/.config/tmux/tmux.conf` arrived in tmux 3.1 and
  `$XDG_CONFIG_HOME/tmux/tmux.conf` in 3.2 ([CHANGES][tmux-changes]). They
  exist only in portable tmux, the GitHub build that mise and Homebrew
  install. The OpenBSD man page documents OpenBSD's own build, which only
  reads `~/.tmux.conf`.
- **Project:** none. tmux has no project-level config.
- **Combines:** all found files run in sequence, so a leftover `~/.tmux.conf`
  runs before this one. Remove it.
- **This repo:** `.config/tmux/tmux.conf`, linked to the same path in `~`. No
  repo link, since there is no project lookup.
- **Docs:** [tmux FILES][tmux-docs]. Source: the [default list][tmux-default]
  and the [loading loop][tmux-load].

## git

Pattern: `~/.config/<tool>/config` plus sibling files (`ignore`, `attributes`).

- **User:** `$XDG_CONFIG_HOME/git/config` (default `~/.config/git/config`),
  then `~/.gitconfig`. Both are read and `~/.gitconfig` wins, and
  `git config --global` writes to `~/.gitconfig` whenever it exists. Keep it
  out of `~`. `ignore` and `attributes` in the same directory are the defaults
  for `core.excludesFile` and `core.attributesFile`.
- **Project:** none in the sense used here. Each repo has its own
  `.git/config`, plus `.gitignore` and `.gitattributes` files.
- **Combines:** system, then global, then repo config, merged key by key.
- **This repo:** `.config/git/config` and `.config/git/ignore`, linked to the
  same paths in `~`. Machine-specific values such as a work email go in the
  untracked `~/.config/git/config.local`, pulled in last with `[include]`.
- **Docs:** [git-config FILES][git-docs].

## nvim

Pattern: one symlink for a whole directory whose files are all tracked here.

- **User:** `stdpath("config")`, which is `$XDG_CONFIG_HOME/nvim` or
  `~/.config/nvim` on macOS too, with `init.lua` or `init.vim` (not both).
  `NVIM_APPNAME` swaps the `nvim` part for another name.
- **Project:** only `.nvim.lua`, `.nvimrc` or `.exrc` in the working
  directory and its parents, when the `exrc` option is on (off by default)
  and the file is trusted with `:trust`. No `.config/` lookup.
- **This repo:** `.config/nvim/`, the [LazyVim starter] without its `.git`,
  `LICENSE` and `README.md`. The directory is linked whole, so `:Lazy update`
  writes `lazy-lock.json` and `lazyvim.json` straight into the repo, and those
  changes show up in `git status`.
- **Docs:** [starting.txt `config`][nvim-config] and
  [`base-directories`][nvim-dirs].

## zsh

Pattern: one file in `~` that points the rest at `~/.config/zsh`.

- **User:** `/etc/zshenv` then `$ZDOTDIR/.zshenv` for every shell, then
  `.zprofile` for login shells, `.zshrc` for interactive shells and `.zlogin`
  for login shells. `.zlogout` runs on exit. Each `/etc/` file runs just before
  its `$ZDOTDIR` file. `ZDOTDIR` defaults to `$HOME`, so `~/.zshenv` sets it
  to `~/.config/zsh` and the later files are read from there. Files in
  `ZDOTDIR` keep their leading dot.
- **Project:** none.
- **macOS:** `/etc/zprofile` runs `path_helper`, which moves `PATH` entries
  added earlier (in `.zshenv`) behind the system folders, so `PATH` changes
  go in `.zprofile`. `/etc/zshrc` puts `HISTFILE` at `$ZDOTDIR/.zsh_history`
  and Terminal.app's `.zsh_sessions/` in `$ZDOTDIR` too.
- **This repo:** only `.zshenv` is tracked and linked. It sets `ZDOTDIR` and
  sources `$ZDOTDIR/.zshenv` if an installer created one. `.zprofile` and
  `.zshrc` are untracked stubs from `stubs/`, created once by
  `mise run stubs`, so installers (including work ones) append to this
  machine's copy rather than the repo. See [Shell stubs](#shell-stubs).
- **Docs:** zsh's [Startup/Shutdown Files][zsh-docs].

## bash and sh

Pattern: fixed paths in `~`. bash has no `ZDOTDIR` equivalent.

- **bash login shells** read `/etc/profile`, then the first of
  `~/.bash_profile`, `~/.bash_login` and `~/.profile` that exists.
- **bash interactive non-login shells** read only `~/.bashrc`, so
  `.bash_profile` usually sources it.
- **sh login shells** (dash, ash, bash as `sh`) read `/etc/profile` and
  `~/.profile`. Interactive non-login `sh` reads the file named by `$ENV`.
- **Scripts** read none of them.
- **This repo:** all three are untracked stubs. See
  [Shell stubs](#shell-stubs).
- **Docs:** [bash Startup Files][bash-docs].

## hushlogin

- **User:** `~/.hushlogin`. `login` only checks that it exists. The file is
  empty, so it has no Location header. It hides the "Last login" line that Terminal
  and SSH logins print.
- **This repo:** `.hushlogin`, linked to `~/.hushlogin`.
- **Docs:** `man login` (macOS) and `man login.defs` (Linux, `HUSHLOGIN_FILE`).

## Shell stubs

Installers append to shell startup files, and work tools most of all.
Through a symlink, `>>` writes into the repo, and `sed -i` replaces the link
with a plain file. So the startup files are owned by each machine:

- `stubs/` holds a template for each: `.bash_profile` (sources `.bashrc`),
  `.bashrc`, `.profile`, `.config/zsh/.zprofile` and `.config/zsh/.zshrc`.
  Each sources the shared shell code, `.config/shell/dev.sh`, which is linked
  to `~/.config/shell/dev.sh` like any other config.
- Each stub, `.zshenv` and `dev.sh` call `.config/shell/trace.sh`, which prints
  a dimmed tree of the files sourced, with timings in bash 5 and zsh, in
  interactive shells only. `DOTFILES_TRACE=0` turns it off.
- `mise run stubs` copies a template only when the file doesn't exist, and
  never overwrites. `install.sh` runs it.
- Lines that installers add stay on that machine. Move anything you want everywhere
  into the shared shell code, or into the untracked `~/.localrc` when it's
  machine-specific.

[config-dir]: https://github.com/pi0/config-dir
[mise-docs]: https://mise.jdx.dev/configuration.html#configuration-hierarchy
[ruff-faq]: https://github.com/astral-sh/ruff/blob/bfa2407e98ee1343caeefd02b4b69043509baa8c/docs/faq.md?plain=1#L589-L599
[ruff-breaking]: https://github.com/astral-sh/ruff/blob/bfa2407e98ee1343caeefd02b4b69043509baa8c/BREAKING_CHANGES.md?plain=1#L229-L236
[astral-sh/ruff#10493]: https://github.com/astral-sh/ruff/issues/10493
[ty-docs]: https://github.com/astral-sh/ty/blob/9aaec9ba5896c759e8e93000d0a1dec51f2bae57/docs/configuration.md?plain=1#L32-L36
[shuck-docs]: https://github.com/ewhauser/shuck/blob/ed4930b2f3483ff9e954ce8725362b1cb14a6a92/website/content/configuration/index.mdx?plain=1#L34-L43
[shuck-user]: https://github.com/ewhauser/shuck/blob/ed4930b2f3483ff9e954ce8725362b1cb14a6a92/crates/shuck-config/src/lib.rs#L2512-L2534
[tombi-docs]: https://github.com/tombi-toml/tombi/blob/8630efc37d2d9fcac2114fc58b6f9c56fc12b265/docs/src/routes/docs/configuration.mdx?plain=1#L10-L27
[ryl-docs]: https://ryl-docs.pages.dev/getting-started/migrating-from-yamllint/#ryl-native-user-global-config
[vale-docs]: https://github.com/vale-cli/vale.sh/blob/ccceb5e80fbc34bc2bdb8ec3f6a594223a4bb356/docs/topics/.vale.ini.md?plain=1#L171-L185
[vale-cli/vale#1212]: https://github.com/vale-cli/vale/issues/1212
[tmux-docs]: https://github.com/tmux/tmux/blob/95a3b63cc1f7ffab8cc47ef0eea945029f262121/tmux.1?plain=1#L9438-L9447
[tmux-default]: https://github.com/tmux/tmux/blob/42374342711adfe3d39bb60d0bb9b45240ed5b06/Makefile.am?plain=1#L14
[tmux-load]: https://github.com/tmux/tmux/blob/92e14631d321c9a34c0b3ac39c7e576c1f4f97bf/cfg.c?plain=1#L113-L114
[tmux-changes]: https://github.com/tmux/tmux/blob/5a820e63b72f05c121441149c72327aeeb16dfa4/CHANGES?plain=1#L1681-L1682
[git-docs]: https://git-scm.com/docs/git-config/2.50.1#FILES
[LazyVim starter]: https://github.com/LazyVim/starter/tree/803bc181d7c0d6d5eeba9274d9be49b287294d99
[nvim-config]: https://github.com/neovim/neovim/blob/779c36969e31080503be2dfccbcc3f999e289606/runtime/doc/starting.txt?plain=1#L465-L472
[nvim-dirs]: https://github.com/neovim/neovim/blob/779c36969e31080503be2dfccbcc3f999e289606/runtime/doc/starting.txt?plain=1#L1374-L1389
[zsh-docs]: https://github.com/zsh-users/zsh/blob/7e57394d42e20160158364929c7bf68f7969f72b/Doc/Zsh/files.yo#L4-L56
[bash-docs]: https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
[vale-ai-tells]: https://github.com/tbhb/vale-ai-tells/tree/v1.37.0
