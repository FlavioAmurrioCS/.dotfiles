# Config header template

Copy the block for the file's format, then fill in or delete each line. See
[`adding-a-config.md`](adding-a-config.md) for what each line means.

## TOML

<!-- rumdl-disable MD013 -->
```toml
#:schema <schema url>
################################################################################
# Location Docs: <latest docs url>#<heading-anchor>
# Location User: ~/.config/<tool>/<file>
# Location User macOS: ~/Library/Application Support/<tool>/<file> (needed unless XDG_CONFIG_HOME is set)
# Location Repo: ./<path the tool reads in this repo>
# Location Check: <command that shows the loaded config>
################################################################################
```
<!-- rumdl-enable MD013 -->

## YAML

```yaml
# yaml-language-server: $schema=<schema url>
################################################################################
# Location Docs: <latest docs url>#<heading-anchor>
# Location User: ~/.config/<tool>/<file>
# Location Repo: ./<path the tool reads in this repo>
# Location Check: <command that shows the loaded config>
################################################################################
---
```

## INI

INI files have no schema directive.

```ini
################################################################################
# Location Docs: <latest docs url>#<heading-anchor>
# Location User: ~/.config/<tool>/<file>
# Location Repo: ./<path the tool reads in this repo>
# Location Check: <command that shows the loaded config>
################################################################################
```

## JSON

JSON has no comments. Put the schema in a `$schema` key, and the Location
details only in [`config-locations.md`](config-locations.md). If the tool
accepts JSONC, use `//` comments with the same lines as above.

```json
{
  "$schema": "<schema url>"
}
```

## Example

[`.config/tombi/config.toml`](../.config/tombi/config.toml):

```toml
#:schema https://www.schemastore.org/tombi.json
################################################################################
# Location Docs: https://github.com/tombi-toml/tombi/blob/main/docs/src/routes/docs/configuration.mdx#search-priority
# Location User: ~/.config/tombi/config.toml
# Location Repo: ./.config/tombi.toml
# Location Check: tombi lint -v 2>&1 | grep 'found at'
################################################################################
```
