# Python LSP Usage in ~/.vimrc

## Overview

The Vim configuration uses **vim-lsp** (prabirshrestha/vim-lsp) as the LSP client
and **pylsp** (python-lsp-server) as the language server for Python. Completion
is handled by **asyncomplete.vim** + **asyncomplete-lsp.vim**. Linting is
delegated to **ALE** — LSP diagnostics are intentionally disabled
(`g:lsp_diagnostics_enabled = 0`) to avoid conflicts.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌──────────────────────┐
│  vim-lsp    │────▶│    pylsp     │────▶│  Plugin: ruff        │  (if ruff config found)
│  (client)   │     │  (server)    │     │  Plugin: pycodestyle │  (if no ruff config)
└──────┬──────┘     └──────────────┘     │  Plugin: pyflakes    │  (if no ruff config)
       │                                 │  Plugin: mccabe      │  (if no ruff config)
       │                                 └──────────────────────┘
       │  navigation / completion only
       │
┌──────┴──────┐     ┌──────────────┐
│   ALE       │────▶│  pylint (uv) │
│  (linter)   │     │  pycodestyle │
└─────────────┘     │  flake8      │
                    └──────────────┘
```

**Separation of concerns:**
- **vim-lsp** → navigation (go-to-def, references, rename, hover) and completion
- **ALE** → diagnostics / linting (pylint, pycodestyle, flake8)

## pylsp Discovery (`FindPylsp()`)

The function `FindPylsp()` locates the best pylsp executable with this priority:

| Priority | Location                          | Typical Use Case                |
|----------|-----------------------------------|---------------------------------|
| 1        | `$CWD/.venv/bin/pylsp`            | Local project virtualenv        |
| 2        | `$CONDA_PREFIX/bin/pylsp`         | Active conda environment        |
| 3        | `~/.local/bin/pylsp`              | `pip install --user`            |
| 4        | `pylsp` on `$PATH`                | System-wide fallback            |

Returns an empty string if none found, which prevents LSP registration.

## Plugin Selection Logic (`HasRuffConfig()`)

`HasRuffConfig()` scans the project root for ruff configuration by searching
upward (`.;`) for:

1. `pyproject.toml` containing a `[tool.ruff]` section
2. `ruff.toml`
3. `.ruff.toml`

### When ruff config IS found:
- **enabled:** `ruff`
- **disabled:** `pycodestyle`, `pyflakes`, `mccabe`
- The ruff plugin reads `[tool.ruff]` from `pyproject.toml` automatically,
  providing a single source of truth for linting rules.

### When ruff config IS NOT found:
- **enabled:** `pycodestyle`, `pyflakes`, `mccabe`
- **disabled:** `ruff`
- Provides basic diagnostics even without a ruff setup.

## LSP Registration

`SetupPythonLsp()` is called on the `User lsp_setup` autocommand only when
`FindPylsp()` succeeds. It registers a server named `'pylsp'` with:

- **allowlist:** `['python', 'python3']`
- **cmd:** the path returned by `FindPylsp()`
- **workspace_config:** dynamically built `pylsp.plugins` dict based on ruff detection

### vim-lsp-settings conflict prevention

`pylsp-all` (which vim-lsp-settings would auto-register) is explicitly disabled:

```vim
let g:lsp_settings['pylsp-all']['disabled'] = 1
```

This prevents duplicate servers and conflicting diagnostics.

## LSP-ALE Bridge

The plugin **vim-lsp-ale** (rhysd/vim-lsp-ale) bridges vim-lsp diagnostics
into ALE, though diagnostics are currently disabled from the LSP side. This
plugin could be used to enable LSP-based linting through ALE's UI if desired.

## Keybindings

### LSP Buffer Mappings (active in Python buffers)

| Mapping              | Function                        |
|----------------------|---------------------------------|
| `<Leader>ga`         | Code action (float)             |
| `<Leader>gd`         | Go to definition                |
| `<Leader>gc`         | Go to declaration               |
| `<Leader>pd`         | Peek definition                 |
| `<Leader>pc`         | Peek declaration                |
| `<Leader>gsd`        | Document symbol search          |
| `<Leader>gsw`        | Workspace symbol search         |
| `<Leader>gr`         | Find references                 |
| `<Leader>gi`         | Go to implementation            |
| `<Leader>gt`         | Go to type definition           |
| `<Leader>gn`         | Rename symbol                   |
| `<Leader>g[`         | Previous diagnostic             |
| `<Leader>g]`         | Next diagnostic                 |
| `<Leader><Leader>`   | Hover (show doc/signature)      |
| `<C-j>` / `<C-k>`   | Scroll hover popup              |

### LSP Management Mappings

| Mapping      | Function              | Description                              |
|--------------|-----------------------|------------------------------------------|
| `<Leader>lr` | `LspRestart()`        | Hard restart: stop all servers, re-activate |
| `<Leader>lc` | `LspReconnect()`      | Soft reconnect: reset filetype, re-activate |
| `<Leader>ld` | `LspDebug()`          | Dump debug info to `:messages`           |

## Completion (asyncomplete)

- Omnifunc is set to `lsp#complete` when LSP activates.
- `completeopt=menuone,noinsert,noselect,preview`
- `<Tab>`/`<S-Tab>` navigate the popup menu; `<CR>` closes it.
- Troubleshooting functions: `ResetCompletion()`, `LspAsyncompleteDeepReset()`

## Logging

| Log                      | Path                     |
|--------------------------|--------------------------|
| vim-lsp verbose log      | `~/vim-lsp.log`          |
| asyncomplete log         | `~/asyncomplete.log`     |

Verbose LSP logging is disabled by default (`g:lsp_log_verbose = 0`).

## Per-Project Setup

### For a project using ruff

1. Create a `pyproject.toml` with a `[tool.ruff]` section (or a `ruff.toml` /
   `.ruff.toml`).
2. Install `python-lsp-server` and `python-lsp-ruff` in the project's
   `.venv`:
   ```
   uv pip install python-lsp-server python-lsp-ruff
   ```
   Or with pip:
   ```
   pip install python-lsp-server python-lsp-ruff
   ```
3. Open a Python file — `FindPylsp()` picks up `.venv/bin/pylsp`,
   `HasRuffConfig()` returns true, and the ruff plugin is enabled while
   pycodestyle/pyflakes/mccabe are disabled.

### For a project without ruff

1. Install `python-lsp-server` in `.venv` (or conda env, or user site).
2. No ruff config file needed.
3. The standard linters (pycodestyle, pyflakes, mccabe) are enabled with
   their default settings. Customize ignores per project via `pyproject.toml`
   (see the next chapter).

### ALE integration per project

ALE is configured to use the project's `.venv/bin/python` for linting, and
`uv` as the pylint executable:

```vim
let g:ale_python_executable = getcwd() . '/.venv/bin/python'
let g:ale_python_pylint_executable = 'uv'
```

This means you need `pylint` available via `uv run pylint` (i.e., installed
as a dev dependency in the project).

## Local Project Configuration for Ignore Flags

The ignore flags are no longer applied globally in `~/.vimrc`. To opt into
them on a per-project basis, add the relevant config to the project's
`pyproject.toml` (or `setup.cfg` / `tox.ini` for some tools).

The flags in question:

```
W191, E111, E114, E117, E121, E125, E126, E127, E128, E129, E131, E101
```

### 1. ruff (when a ruff config is detected)

Add an `ignore` key to the `[tool.ruff.lint]` table (modern ruff) or to
`[tool.ruff]` directly (ruff < 0.4):

```toml
[tool.ruff.lint]
ignore = [
    "W191", "E111", "E114", "E117", "E121", "E125",
    "E126", "E127", "E128", "E129", "E131", "E101",
]
```

Legacy form (ruff < 0.4):

```toml
[tool.ruff]
ignore = [
    "W191", "E111", "E114", "E117", "E121", "E125",
    "E126", "E127", "E128", "E129", "E131", "E101",
]
```

### 2. pylsp pycodestyle and flake8 plugins (when no ruff config)

python-lsp-server reads plugin configurations from `pyproject.toml` under `[tool.pylsp.plugins.<plugin_name>]`. 

> [!IMPORTANT]
> Be sure to use `[tool.pylsp.plugins.pycodestyle]` and `[tool.pylsp.plugins.flake8]` (including the `.plugins.` segment). Using `[tool.pylsp.pycodestyle]` will not be recognized by `pylsp`.

```toml
[tool.pylsp.plugins.pycodestyle]
enabled = true
ignore = [
    "W191", "E111", "E114", "E117", "E121", "E125",
    "E126", "E127", "E128", "E129", "E131", "E101",
]

[tool.pylsp.plugins.flake8]
enabled = true
ignore = [
    "W191", "E111", "E114", "E117", "E121", "E125",
    "E126", "E127", "E128", "E129", "E131", "E101",
]
```

### 3. flake8 (via ALE or pylsp plugin)

flake8 does **not** read `.pycodestyle` or `[pycodestyle]` sections. It looks for configuration in `.flake8`, `setup.cfg`, or `tox.ini` under the explicit `[flake8]` section:

```ini
[flake8]
ignore = W191,E111,E114,E117,E121,E125,E126,E127,E128,E129,E131,E101
max-line-length = 90
```

If ALE or `pylsp` runs `flake8` and no `[flake8]` section exists in `setup.cfg` or `.flake8`, `flake8` falls back to its default ignore list (which does **not** include `W191`), causing `W191` warnings to appear.

### 4. pycodestyle & pep8 (via ALE or setup.cfg)

pycodestyle reads its configuration from `setup.cfg`, `.pycodestyle`, or `tox.ini` under `[pycodestyle]` and `[pep8]` sections:

```ini
[pycodestyle]
ignore = W191,E111,E114,E117,E121,E125,E126,E127,E128,E129,E131,E101

[pep8]
ignore = W191,E111,E114,E117,E121,E125,E126,E127,E128,E129,E131,E101
```

### Notes & Troubleshooting

- **Why W191 still appeared**: 
  1. `setup.cfg` had `[pycodestyle]` but lacked `[flake8]` and `[pep8]` sections, so `flake8` continued to report `W191`.
  2. `pyproject.toml` used `[tool.pylsp.pycodestyle]` instead of `[tool.pylsp.plugins.pycodestyle]`.
- After updating any config file (`pyproject.toml`, `setup.cfg`, or `.flake8`), restart `pylsp` in Vim using `<Leader>lr` (`:call LspRestart()`) or `:e` to reload the file.
- You only need to list the codes you actually want to suppress — the list can be customized per project.

