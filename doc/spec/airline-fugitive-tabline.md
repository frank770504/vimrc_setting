# Airline + Fugitive Tabline/Statusline in ~/.vimrc

## Overview

The configuration renders Git-aware labels in two places using
**vim-airline** (statusline + tabline) and **vim-fugitive** (Git wrapper):

- **tabline** — the top bar showing one entry per open buffer. Fugitive
  buffers (whose name starts with `fugitive://`) get a Git-context label via a
  custom formatter.
- **statusline filename** — the filename slot (`airline_section_c`), produced
  by `CleanFugitivePath()`. Fugitive blob/index files get a distinct hint.

## Files

| File | Role |
|------|------|
| `~/.vimrc` | Airline config, hint defaults, parser + label builder + statusline function |
| `~/.vim/autoload/airline/extensions/tabline/formatters/fugitive.vim` | The `#`-named tabline formatter (must live here — see gotchas) |

## Architecture

```
fugitive://<git-dir>//<rev>/<file>
        │
        ▼
FugitiveTabParse() ──▶ { git_dir, repo, rev, file }
        │
        ├──▶ FugitiveTabLabel()      ──▶ tab label  (formatter prepends tab hint)
        │
        └──▶ CleanFugitivePath()     ──▶ statusline filename (prepends file hint)
```

- `FugitiveTabLabel()` and `CleanFugitivePath()` are global functions in
  `~/.vimrc` (no `#` in their names, so they may live there).
- `airline#extensions#tabline#formatters#fugitive#format()` contains `#`, so it
  **must** live in the matching autoload path.

## Airline configuration

```vim
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#formatter = 'fugitive'
let g:airline_section_c = '%{CleanFugitivePath()}'
```

Powerline separators and symbols:

| Setting | Glyph | Code point |
|---------|-------|------------|
| `g:airline_left_sep` | right separator  | U+E0B0 |
| `g:airline_left_alt_sep` | right separator (alt)  | U+E0B1 |
| `g:airline_right_sep` | left separator  | U+E0B2 |
| `g:airline_right_alt_sep` | left separator (alt)  | U+E0B3 |
| `g:airline_symbols.branch` | branch  | U+E0A0 |
| `g:airline_symbols.readonly` | readonly/padlock  | U+E0A2 |
| `g:airline_symbols.linenr` | line number  | U+E0A1 |

These are Powerline private-use-area glyphs; they render only with a patched
font (`g:airline_powerline_fonts = 1`, `guifont=MesloLGSDZForPowerline`).

## Fugitive hints

| Variable | Prepended to | Default |
|----------|--------------|---------|
| `g:fugitive_tab_hint` | tab label | `nr2char(0xe0a0) . ' '` (branch glyph + space) |
| `g:fugitive_file_hint` | statusline filename of a blob/index file | `nr2char(0xe0a2) . ' '` (readonly glyph + space) |

Both are set with a `get(g:, ..., default)` guard, so users can override them
without editing `~/.vimrc`.

## Parser — `FugitiveTabParse(url)`

Splits a fugitive URL into a dict:

```
{ 'git_dir': <git-dir>, 'repo': <work-tree basename>, 'rev': <rev>, 'file': <file> }
```

Algorithm (deliberately avoids `matchstr()` + `\zs\ze\{-\}`):

1. Strip the `fugitive://` prefix with `substitute(a:url, '^fugitive://', '', '')`.
2. `stridx(rest, '//')` → `git_dir = strpart(rest, 0, sep)`, `tail = strpart(rest, sep + 2)`.
3. `stridx(tail, '/')` → if found, `rev = tail[:slash]`, `file = tail[slash+1:]`; else `rev = tail`, `file = ''`.
4. `repo = fnamemodify(git_dir, ':h:t')` — the work-tree basename (parent of `.git`).

> [!NOTE]
> The function is named `FugitiveTabParse()`, **not** `FugitiveParse()`.
> vim-fugitive already defines a global `FugitiveParse()` (returns a 2-element
> list `[rev, dir]`) that `airline#extensions#branch.vim` calls via
> `FugitiveParse()[0]`. Redefining it would break that extension.

## Label builder — `FugitiveTabLabel(bufname)`

Maps the parsed fields to a tab label. Uses `if` blocks (not ternaries) to
avoid `E730`/`E116` in Vim 8.2.

| Buffer type | Condition | Label |
|-------------|-----------|-------|
| status page (`:Git`) | `file` and `rev` empty | `<repo>` |
| commit page (`:Gedit <commit>`) | `file` empty, `rev` set | `<repo>@<short-rev>` |
| blob/index (`:Gedit <rev>:<file>`) | `file` non-empty | `<repo>:<file-tail>` |

**Short hashes:** if `rev =~# '^\x\+$'` and `strlen(rev) > 8`, truncate to the
first 8 characters via `strpart(rev, 0, 8)`. A full 40-char hash never renders.

## Statusline — `CleanFugitivePath()`

Wired into `g:airline_section_c`:

```vim
let g:airline_section_c = '%{CleanFugitivePath()}'
```

| Buffer type | Statusline filename |
|-------------|---------------------|
| non-fugitive | `expand('%:t')` |
| fugitive, `file` empty (status/commit page) | `GIT: <repo>` |
| fugitive, `file` non-empty (blob/index) | `<file-hint><file-tail>` |

## Formatter — `airline#...formatters#fugitive#format(bufnr, buffers)`

For each buffer in the tabline:

1. If `bufname(bufnr)` matches `^fugitive://`, call `FugitiveTabLabel()`.
2. If the label is non-empty, return
   `wrap_name(bufnr, g:fugitive_tab_hint . label)`.
3. Otherwise fall back to `unique_tail_improved` for non-fugitive buffers.

The fallback keeps normal buffers rendering exactly as before the custom
formatter was introduced.

## Debug logging

`FugitiveDebugLog()` writes timestamped messages to
`/home/ywchen/vim_airline_debug.log` when `g:fugitive_debug` is `1`
(default `0`). Consecutive identical messages are deduped to avoid redraw spam.

| Setting | Default | Purpose |
|---------|---------|---------|
| `g:fugitive_debug` | `0` | Master switch for debug logging |
| log path | `/home/ywchen/vim_airline_debug.log` | Output file |

Logged stages: `formatter`, `FugitiveTabParse`, `FugitiveTabLabel`,
`CleanFugitivePath` — including raw `bufname('%')`, `expand('%:p')`, parsed
dict, and final label/text.

## Gotchas (Vim 8.2)

- A function name containing `#` must live in the matching autoload file, or
  Vim raises `E746: Function name does not match script file name`.
- Avoid `empty(x.y) ? a : b` ternaries (dict member access combined with
  `empty()` in `?:`) — they trigger `E730`/`E116`. Use `if` blocks.
- Avoid `matchstr()` patterns with `\zs`/`\ze` and non-greedy `\{-\}` for URL
  parsing — they produced `:::` in earlier attempts. Use `substitute()` +
  `stridx()` + `strpart()`.
- Do not name a local function `FugitiveParse()` — it collides with
  vim-fugitive's public API.
