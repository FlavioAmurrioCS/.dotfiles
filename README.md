# .dotfiles

The repo root mirrors `$HOME`. Configs live under `.config/` where the tool
allows it.

## Install

Pick one. Each needs only `git`, `curl` and `bash`.

Download and run the script, which clones to `~/.dotfiles`:

<!-- rumdl-disable MD013 -->
```sh
curl -fsSL https://raw.githubusercontent.com/FlavioAmurrioCS/.dotfiles/main/install.sh | bash
```
<!-- rumdl-enable MD013 -->

Clone first, then run the script from the clone:

```sh
git clone https://github.com/FlavioAmurrioCS/.dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

On Coder, clone into `/workspace` instead, and rerun the script after each
restart:

```sh
git clone https://github.com/FlavioAmurrioCS/.dotfiles.git /workspace/.dotfiles
/workspace/.dotfiles/install.sh
```

To pass `--backup` (see below) to the piped script, use
`curl -fsSL <url> | bash -s -- --backup`.

The script installs mise, clones this repo to `~/.dotfiles` (or uses the clone
it runs from), and links `.config/mise/conf.d/dotfiles.toml` into
`~/.config/mise/conf.d/`. Then it runs
`mise dotfiles apply`, `mise install`, `vale sync`, `mise run setup` and
`mise run stubs`. Re-running it is safe.

Every link goes through `~/.dotfiles`. Run from a clone elsewhere, such as
`/workspace/.dotfiles` on Coder, where a restart resets everything outside
`/workspace`, the script links `~/.dotfiles` to that clone. If `~/.dotfiles`
already exists and is a different folder, it stops.

mise won't replace an existing file or folder with a link, so on a machine
with its own configs the install stops at `mise dotfiles apply`. Run
`bash install.sh --backup` to move those files into
`~/.dotfiles-backup/<timestamp>/` first, at the same path relative to `~`.
It moves the files that block a link, and each shell startup file that differs
from its template in `stubs/`. It also moves the files below. It prints each
file it moves.

Without `--backup`, it warns about these files instead:

- `~/.zshrc`, `~/.zprofile`, `~/.zlogin` and `~/.zlogout`: `~/.zshenv`
  points zsh at `~/.config/zsh`, so zsh skips them. Move what you need into
  the same file in `~/.config/zsh/`.
- `~/.gitconfig`: git reads it after `~/.config/git/config`, and its keys win.
  Move what you need into the untracked `~/.config/git/config.local`.

## How it works

- Each config is at the same path in the repo as in `~`:
  `~/.config/tombi/config.toml` is `.config/tombi/config.toml` here.
- [`.config/mise/conf.d/dotfiles.toml`](.config/mise/conf.d/dotfiles.toml) maps
  each repo file to where it gets linked. Use absolute `~/.dotfiles/...`
  sources: mise resolves relative ones from the symlink's directory.
- The same files also configure this repo. Where a tool's project lookup
  expects another name, `mise run setup` links it there:
  `.config/tombi.toml` links to `.config/tombi/config.toml`, and `ruff.toml`
  links to `.config/ruff/ruff.toml`. The pairs are listed once in `[vars]` in
  `mise.toml`, `mise run unsetup` removes the links, and `.gitignore` excludes
  them.
- Each config starts with a Location header. It links the tool's docs, gives
  the user and repo paths, and has a `Location Check` command that shows
  whether the tool loaded it.
- [`.config/mise/conf.d/tools.toml`](.config/mise/conf.d/tools.toml) holds the
  short list of tools every machine gets, work machines included. This repo's
  linters are in [`mise.toml`](mise.toml) and install for the repo only.
  `mise use -g` writes to the untracked `~/.config/mise/config.toml`, for tools
  on one machine; move a tool to `tools.toml` by hand to share it.
- Shell startup files (`.bashrc`, `.bash_profile`, `.profile`, and zsh's
  `.zshrc` and `.zprofile`) aren't linked, because installers append to them.
  `mise run stubs` copies each template in [`stubs/`](stubs/) into `~` only if
  the file is missing. Only `~/.zshenv`, which points zsh at `~/.config/zsh`,
  is linked.
- [`.config/shell/dev.sh`](.config/shell/dev.sh) is the shared shell setup
  every stub sources: prompt, aliases, history, mise and fzf. It detects bash,
  zsh or sh itself, and sh gets a POSIX-only part. It also sources the
  untracked `~/.secretsrc` and `~/.localrc`.
- [`.config/shell/trace.sh`](.config/shell/trace.sh) prints a dimmed tree of
  the files an interactive shell sources, with timings in bash 5 and zsh.
  `DOTFILES_TRACE=0` turns it off.
- Scripts in [`.local/bin/`](.local/bin/) get one link each in `~/.local/bin`
  (`mode = "symlink-each"`), since that directory also holds mise, uv tools
  and other installs. Python scripts use a `uv run --script` shebang, and
  pre-commit runs ruff and ty on them.
- For a macOS-only link, add an entry with
  `variants = [{ os = "macos", target = "..." }]`. ryl and vale need one,
  because on macOS they ignore `~/.config` unless `XDG_CONFIG_HOME` is set.
- [`docs/config-locations.md`](docs/config-locations.md) records where each
  tool reads user and project config, with links to its docs.
- [`docs/adding-a-config.md`](docs/adding-a-config.md) is the recipe for adding
  a new config.

## Common commands

```sh
mise dot status -v   # every managed file and its state
mise dot apply       # create missing links
mise run setup       # link repo configs where each tool expects them
mise run unsetup     # remove those links
mise run stubs       # create missing shell startup files from stubs/
vale sync            # download vale packages (from ~ for the user config)
mise dot add -p ~/.dotfiles/.config/mise/conf.d/dotfiles.toml ~/.config/foo
```

`mise dot add` moves the live file into this repo and links it back, with a
new entry in the mapping file.
Whole directories work as well. Use `-m symlink-each` when only some files in a
directory belong to the repo.

## Other dotfiles repositories

A second repository, such as a work one, has its own mapping file and links it
to `~/.config/mise/conf.d/dotfiles-<name>.toml`. mise merges the entries from
every file in `conf.d`, so each target must appear in only one repository.
