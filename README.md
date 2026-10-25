# .dotfiles

The repo root mirrors `$HOME`. Configs live under `.config/` where the tool
allows it.

## Install

```sh
bash install.sh
```

The script installs mise, clones this repo to `~/.dotfiles`, and links
`.config/mise/conf.d/dotfiles.toml` into `~/.config/mise/conf.d/`. Then it runs
`mise dotfiles apply`, `mise install`, `vale sync`, `mise run setup` and
`mise run stubs`. Re-running it is safe.

It warns about any `~/.zshrc`, `~/.zprofile`, `~/.zlogin` or `~/.zlogout` it
finds: `~/.zshenv` points zsh at `~/.config/zsh`, so zsh skips those files.
Move what you need from them into the same file in `~/.config/zsh/`.

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
- [`.config/mise/conf.d/tools.toml`](.config/mise/conf.d/tools.toml) declares
  every tool once, linters included, for this repo and, once linked, for every
  directory. `mise use -g` writes to it.
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
