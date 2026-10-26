# Agent rules

- The repo root mirrors `$HOME`. Configs live under `.config/` at the same
  path they have in `~`.
- To add a config, follow
  [`docs/adding-a-config.md`](docs/adding-a-config.md).
- `archive/` holds old configs for reference. Never deploy, reformat or edit
  them; see [`archive/README.md`](archive/README.md).
- Shell startup files are untracked stubs on each machine; edit the templates
  in `stubs/`, which `mise run stubs` copies only when a file is missing.
- `.vscode/` configures this repo only. Never add it to
  `.config/mise/conf.d/dotfiles.toml`: `~/.vscode` holds VS Code's installed
  extensions.
- Never stage or commit unless the user asks.
- Don't create or edit the generated repo links (`ruff.toml`,
  `.config/tombi.toml` and so on). Edit `[vars] links` in `mise.toml`, then run
  `mise run setup`.
- Use absolute `~/.dotfiles/...` sources in
  `.config/mise/conf.d/dotfiles.toml`.
- Run `pre-commit run --all-files` before reporting work as done.
