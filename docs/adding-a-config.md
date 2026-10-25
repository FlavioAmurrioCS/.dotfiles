# Adding a config

A recipe for adding a tool's config to this repo, so every config is laid out,
labelled and linked the same way. The checklist at the end summarizes it.

## 1. Research the tool

Answer these from the tool's docs, then confirm them on this Mac:

- **User-level lookup:** the paths and file names it reads. Check whether
  it honours `XDG_CONFIG_HOME`, and what it reads on macOS when that's unset.
- **Project-level lookup:** which file names it reads in a project, and
  whether `.config/` is one of them ([config-dir]).
- **Merge or fallback:** whether the user file is always read underneath the
  project file, or only when no project file exists.
- **Formats:** which formats it accepts (TOML, YAML, JSON, INI).
- **Schema:** whether a JSON schema exists, in the tool's repo or the
  [schemastore.org catalog][schemastore].
- **Check command:** a command that prints which config it loaded, such as
  `vale ls-config` or `ruff check --show-settings`.
- **Self-writing:** whether the tool rewrites its own config file, such as
  from a settings screen.

Record the answers in [`config-locations.md`](config-locations.md) (step 4).

## 2. Choose locations

Use the first option that applies.

### User target in `~`

1. `~/.config/<tool>/...` when the tool reads it on macOS with no environment
   variable set (ruff, ty, tombi).
2. `~/.config/<tool>/...` plus a macOS-only link to
   `~/Library/Application Support/<tool>/...` when the tool reads `~/.config`
   only if `XDG_CONFIG_HOME` is set (ryl, vale). Prefer the extra link over
   requiring the variable, which GUI apps and editors don't inherit.
3. The only path the tool supports.

### File name and format

- Use the name the tool documents for user config: `config.toml` for tombi,
  `<tool>.toml` for ruff and ty.
- Prefer a name without a leading dot when both work: `ryl.toml` over
  `.ryl.toml`.
- Prefer TOML when the tool accepts several formats.
- Prefer a dedicated file over a `[tool.<name>]` table in `pyproject.toml`.

### Directories and fragments

- Prefer a fragment in a `conf.d/` directory over editing a shared main file,
  such as `~/.config/mise/conf.d/tools.toml`.
- Link a whole directory when every file in it is tracked here.
- Use `mode = "symlink-each"` when the directory also holds files the repo
  doesn't own.

### Repo path

Store the file at the same path as its user target, relative to the repo root.
`~/.config/tombi/config.toml` lives at `.config/tombi/config.toml`.

### Repo link for the project lookup

The repo file should also configure this repo.

1. No link when the tool already reads the repo path, as mise does with
   `.config/mise/conf.d/`.
2. `.config/<tool>.<ext>` when the tool supports `.config/` under another
   name, as with tombi's `.config/tombi.toml`.
3. A file at the repo root only when the tool has no `.config/` support, as
   with ruff's `ruff.toml`.

### Tools that rewrite their config

A symlink lets the tool write straight into the repo. If that's unwanted, use
`mode = "copy"`, or `mise dot track` to save the file's history in place.

### Replacing an existing config

When the tool already has a config in `~`, take it out of `~`: tools such as
tmux load every config file they find. To keep it for reference, move it
unchanged to `archive/` at its path relative to `~`, and add a row to
[`archive/README.md`](../archive/README.md). Delete it instead when it's all
defaults or everything in it has moved to the new file.

## 3. Write the file

Start from [`config-header-template.md`](config-header-template.md):

1. **Schema directive** on the first line, when a schema exists.
2. **Location header**:
   - `Location Docs`: the tool's latest docs, with a heading anchor rather
     than line numbers.
   - `Location User`: the user target.
   - `Location User macOS`: only when step 2 adds the macOS link.
   - `Location Repo`: the path the tool reads in this repo.
   - `Location Check`: the check command. If there is none, write
     `none built in` and give an indirect check, as `ryl.toml` does.
3. **Secrets:** keep machine-specific or secret values out of the file. Put
   them in an untracked local file, or deploy the file with `mode = "template"`.

## 4. Wire it up

1. **Deploy:** add an entry to `.config/mise/conf.d/dotfiles.toml` with an
   absolute `~/.dotfiles/...` source. Add a `[dotfiles.<tool>-macos]` entry
   with `variants = [{ os = "macos", target = "..." }]` when step 2 needs it.
2. **Repo link:** add the `<repo path> <link path>` pair to `[vars] links` in
   `mise.toml`, and the link path to `.gitignore`.
3. **Install:** if mise installs the tool, pin it in one place only:
   `.config/mise/conf.d/tools.toml` (`mise use -g` writes there). Don't pin it in
   `pyproject.toml` as well.
4. **Document:** add a section and a summary row to `config-locations.md`.
   Cover the user and project lookup and merge behaviour, and any config-dir
   issue in the tool's tracker. Link the docs at a fixed commit, since the
   section records what was true on that date.
5. **Lint:** if the tool is a linter, add its hook to `.pre-commit-config.yaml`.

## 5. Verify

1. Run `mise dot apply` and `mise run setup`, then `mise dot status -v`. Every
   entry should be `applied`.
2. Run the `Location Check` command inside the repo and from a directory
   outside it.
3. When the docs are unclear about macOS, test with a throwaway `HOME`. Put
   the config at one candidate path, change a setting with a visible effect,
   and run the tool with `HOME` pointing at the temp directory and
   `XDG_CONFIG_HOME` unset:

   ```sh
   env -u XDG_CONFIG_HOME HOME=/tmp/foo/home vale ls-config
   ```

4. Run `pre-commit run --all-files`.

## Checklist

- [ ] Researched user and project lookup, merge behaviour, formats, schema,
      check command and self-writing.
- [ ] Chose the user target, file name, repo path and repo link.
- [ ] Archived or deleted any existing config in `~`.
- [ ] Added the schema directive and Location header.
- [ ] Added the `dotfiles.toml` entry, plus a macOS entry if needed.
- [ ] Added the `[vars] links` pair and `.gitignore` entry if needed.
- [ ] Pinned the tool in one place.
- [ ] Documented it in `config-locations.md`.
- [ ] Added a pre-commit hook if it's a linter.
- [ ] `mise dot status -v`, `Location Check` and pre-commit all pass.

[config-dir]: https://github.com/pi0/config-dir
[schemastore]: https://www.schemastore.org/json/
