# Vim Configuration

A comprehensive and efficient Vim setup tailored for development, featuring LSP support, fuzzy finding, Git integration, and AI-powered coding assistance.

---

## 🪶 Lightweight Server Configuration (`vimrc.lite`)

A minimal, dependency-light variant for remote servers. It drops all LSP, AI,
linting, and completion plugins (nothing runs in the background) and keeps only:

- [vim-better-whitespace](https://github.com/ntpeters/vim-better-whitespace) — trailing whitespace
- [vim-airline](https://github.com/vim-airline/vim-airline) — status/tabline (ASCII, no powerline fonts)
- [vim-fugitive](https://github.com/tpope/vim-fugitive) — Git wrapper (`:Git`, `:Gblame`, ...)
- [fzf](https://github.com/junegunn/fzf) + [fzf.vim](https://github.com/junegunn/fzf.vim) — fuzzy finding

It uses **vim-plug** as the plugin manager.

### Deploy

```bash
scp vimrc.lite user@server:~/.vimrc
```

### Install on the server

1. **Install vim-plug** (single file):
   ```bash
   curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   ```

2. **Install the fzf binary** (the Vim plugin is only a wrapper around it):
   ```bash
   # Option A: install script (recommended)
   git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
   ~/.fzf/install --bin
   # then add ~/.fzf/bin to your PATH in ~/.bashrc

   # Option B: distro package (if available)
   sudo apt install fzf
   ```

3. **Install ripgrep** (only needed for `<Leader>ps` / `:Rg` fuzzy search):
   ```bash
   sudo apt install ripgrep
   ```

4. **Install the plugins**: open Vim and run:
   ```vim
   :PlugInstall
   ```

5. **Persistent undo directory** (the vimrc auto-creates it, but doing it manually is harmless):
   ```bash
   mkdir -p ~/.vim/undodir
   ```

### Requirements

- Vim 8.2+ on Linux (written for Vim 8.2.280+; avoids `<Cmd>` mappings).
- Connect with `ssh -X` for clipboard support (`clipboard=unnamedplus`); it degrades gracefully otherwise.
- `encoding=utf-8` (set in the file) for the tab/space `listchars` glyphs.

### What's removed vs. the full `vimrc`

- Plugin manager: Vundle → **vim-plug**
- Plugins dropped: indentLine, vim-flog, undotree, csv.vim, ALE, vim-lsp,
  vim-lsp-settings, asyncomplete.vim, asyncomplete-lsp.vim, vim-lsp-ale,
  vim-ai, vim-ai-provider-google, scratch.vim, markdown-preview.nvim
- Custom fugitive tabline machinery: `FugitiveTabParse`, `CleanFugitivePath`,
  `FugitiveDebugLog`, `:Gclean`, and the fugitive tabline formatter autoload file

---

## 🛠️ Full Configuration (`vimrc`)

The complete setup: LSP (`vim-lsp` + `vim-lsp-settings`), fuzzy finding
(`fzf` + `fzf.vim`), Git (`vim-fugitive` + `vim-flog`), linting (`ALE`),
autocompletion (`asyncomplete`), AI assistance (`vim-ai` / Gemini), a powerline
statusline (`vim-airline`), and QoL plugins (indentLine, better-whitespace,
undotree, csv, scratch, markdown-preview).

Uses **Vundle** as the plugin manager.

### Deploy

```bash
git clone https://github.com/your-username/vimrc_setting.git ~/vimrc_setting

# Symlink the vimrc
ln -sf ~/vimrc_setting/vimrc ~/.vimrc

# Symlink the custom airline tabline formatter (required for fugitive tab labels)
mkdir -p ~/.vim/autoload/airline/extensions/tabline/formatters
ln -sf ~/vimrc_setting/autoload/airline/extensions/tabline/formatters/fugitive.vim \
  ~/.vim/autoload/airline/extensions/tabline/formatters/fugitive.vim
```

> **Note:** `g:airline#extensions#tabline#formatter = 'fugitive'` requires the
> autoload file symlinked above. See
> [`doc/spec/airline-fugitive-tabline.md`](doc/spec/airline-fugitive-tabline.md).

### Install on the machine

1. **Vim + git + curl** — Vim 8.2+ compiled with `+job`, `+channel`, `+lambda`,
   `+clipboard`, and `+python3` (all used by LSP/ALE/asyncomplete/clipboard):
   ```bash
   sudo apt install vim git curl
   ```

2. **Vundle** (plugin manager):
   ```bash
   git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
   ```

3. **fzf binary** (the `fzf` Vim plugin is only a wrapper):
   ```bash
   # Option A: install script (recommended)
   git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
   ~/.fzf/install --bin
   # then add ~/.fzf/bin to your PATH in ~/.bashrc

   # Option B: distro package
   sudo apt install fzf
   ```
   > **Note:** the vimrc hardcodes `set rtp+=/home/ywchen/.fzf/bin/fzf` —
   > change it to your own `$HOME` if it differs.

4. **ripgrep** (for `<Leader>ps` / `:Rg`):
   ```bash
   sudo apt install ripgrep
   ```

5. **Node.js + npm** (for `markdown-preview.nvim`):
   ```bash
   sudo apt install nodejs npm
   ```

6. **Python LSP** (for Python IDE features; the vimrc auto-detects `.venv`,
   `CONDA_PREFIX`, `~/.local/bin`, or `pylsp` on `PATH`):
   ```bash
   # In the project venv, or globally:
   pip install python-lsp-server python-lsp-ruff
   ```
   See [`doc/spec/python-lsp-usage.md`](doc/spec/python-lsp-usage.md) for how
   ruff config is auto-detected.

7. **ALE linters** (optional, per language):
   ```bash
   # Python (ALE runs pylint via uv)
   pip install pylint flake8 pycodestyle
   # C/C++
   sudo apt install clangd astyle clang-tidy
   # uv (ALE python runner): https://docs.astral.sh/uv/
   ```

8. **AI providers** (optional; for `vim-ai`):
   ```bash
   # OpenAI token (referenced by g:vim_ai_token_file_path)
   echo "sk-..." > ~/.config/openai.token
   # Optional roles file
   touch ~/.config/vim-ai-roles.ini
   ```

9. **Install the plugins** — open Vim and run:
   ```vim
   :PluginInstall
   ```

10. **Markdown preview** (one-time) — in Vim run:
    ```vim
    :call mkdp#util#install()
    ```

### Requirements

- Vim 8.2+ with `+job`, `+channel`, `+lambda`, `+clipboard`, `+python3`.
- `git`, `curl` (vim-ai uses curl for API calls).
- `fzf` binary + `ripgrep` on `PATH`.
- A display (or `ssh -X`) for `clipboard=unnamedplus`.
- `encoding=utf-8` (set in the file) for powerline glyphs and `listchars`.

---

## 🚀 Detailed Command List

The `<Leader>` key is mapped to **Space**.

### 🛠️ General Editor Mappings
| Mapping | Mode | Description |
|---------|------|-------------|
| `<Leader>pv` | Normal | **File Explorer**: Opens Vim's built-in `:Ex` (netrw) explorer. |
| `<Leader>nn` | Normal | **Buffer Switch**: Rapidly toggle between the two most recent buffers. |
| `<Leader>sd` | Normal | **Clear Highlights**: Removes the yellow search highlight from the screen. |
| `J` | Normal | **Join Lines**: Joins the line below to the current one while keeping the cursor in place (using mark `z`). |
| `Ctrl + d` | Normal | **Scroll Down**: Scrolls half a page down and centers the cursor on the screen (`zz`). |
| `Ctrl + u` | Normal | **Scroll Up**: Scrolls half a page up and centers the cursor on the screen (`zz`). |
| `n` | Normal | **Search Next**: Goes to next match and centers the screen. |
| `N` | Normal | **Search Prev**: Goes to previous match and centers the screen. |
| `J` | Visual | **Move Selection Down**: Moves the highlighted block of text down one line. |
| `K` | Visual | **Move Selection Up**: Moves the highlighted block of text up one line. |
| `Ctrl + j` | Normal | **Quickfix Next**: Move to the next item in the quickfix list and center screen. |
| `Ctrl + k` | Normal | **Quickfix Prev**: Move to the previous item in the quickfix list and center screen. |
| `<Leader>h` | Normal | **Word Highlight**: Toggles a persistent highlight on the word under the cursor. |

### 📋 Clipboard & Registers
| Mapping | Mode | Description |
|---------|------|-------------|
| `<Leader>y` | Normal | **Yank to Clipboard**: Copies the selection to the system clipboard (`"+y`). |
| `<Leader>Y` | Normal | **Yank Line to Clipboard**: Copies the entire line to the system clipboard. |
| `<Leader>yap`| Normal | **Yank Paragraph**: Copies the current paragraph to the system clipboard. |
| `<Leader>p` | Normal | **Paste from Clipboard**: Pastes text from the system clipboard. |
| `<Leader>dp` | N/V | **Safe Paste**: Pastes from the default register without overwriting it with the deleted text. Uses the black hole register (`"_dp`). |
| `<Leader>d` | N/V | **Delete to Black Hole**: Deletes text without moving it to the yank register. |
| `<Leader>o` | Normal | **Smart New Line Below**: Creates an empty line below without moving the cursor or affecting registers. |
| `<Leader>O` | Normal | **Smart New Line Above**: Creates an empty line above without moving the cursor or affecting registers. |
| `<Leader>%` | Normal | **Copy Relative Path**: Copies the relative path of the current file to the clipboard. |
| `<Leader>%%`| Normal | **Copy Absolute Path**: Copies the full system path of the current file to the clipboard. |

### 🔍 Fuzzy Finding (FZF)
| Mapping | Mode | Description |
|---------|------|-------------|
| `Ctrl + p` | Normal | **Git Files**: Search for files tracked by Git in the current repository. |
| `<Leader>pf` | Normal | **All Files**: Search for any file in the current directory. |
| `<Leader>ps` | Normal | **Grep Search**: Prompt for a string and search through all files using `ripgrep`. |
| `<Leader>pb` | Normal | **Buffers**: Search and switch between open buffers. |
| `<Leader>pg` | Normal | **Commits**: Browse Git commit history. |
| `<Leader>pc` | Normal | **Command History**: Search through your previous Vim commands. |
| `Ctrl + x / v`| FZF | **Split View**: Open selected file in a horizontal or vertical split. |
| `Ctrl + l` | FZF | **Quickfix**: Push all selected items from FZF into the Quickfix list. |

### 💻 LSP & IDE Features
| Mapping | Mode | Description |
|---------|------|-------------|
| `<Leader>gd` | Normal | **Definition**: Jump to the definition of the symbol. |
| `<Leader>gr` | Normal | **References**: List all references of the symbol. |
| `<Leader>gn` | Normal | **Rename**: Rename all occurrences of the symbol across the project. |
| `<Leader><Leader>`| Normal | **Hover**: Show type information or documentation in a popup. |
| `<Leader>ga` | Normal | **Code Actions**: Show available LSP actions (e.g., auto-imports). |
| `<Leader>gi` | Normal | **Implementation**: Jump to the interface implementation. |
| `<Leader>g[` / `g]`| Normal | **Diagnostics**: Jump to the previous/next error or warning. |
| `<Leader>pd` | Normal | **Peek Definition**: View definition in a small popup without leaving current line. |

### 🤖 AI Assistance (Vim-AI / Gemini)
| Mapping | Mode | Description |
|---------|------|-------------|
| `<Leader>a` | N/V | **AI Prompt**: Open a prompt to generate code or text. |
| `<Leader>s` | N/V | **AI Edit**: Ask the AI to modify selected text (e.g., "refactor this function"). |
| `<Leader>c` | N/V | **AI Chat**: Open a chat window with the AI. |
| `<Leader>nc` | N/V | **New Tab Chat**: Open AI chat in a full-screen new tab. |

### 📦 Plugin-Specific Commands
| Mapping/Command | Description |
|-----------------|-------------|
| `<Leader>u` | **Undo Tree**: Toggle the undo tree (undotree). |
| `<Leader>ac` | **CSV Arrange**: Align CSV columns (`csv.vim`). |
| `<Leader>uac` | **CSV Unarrange**: Undo CSV column alignment. |
| `<Leader>git` | **Git Graph**: Open the git commit graph (vim-flog). |
| `:Gclean` | **Clean Merged Branches**: Delete local branches merged into HEAD. |
| `:BD` | **Delete Buffers**: FZF multi-select to wipe buffers. |
| `:MarkdownPreview` | **Markdown Preview**: Open live preview in a browser. |
| `:Scratch` | **Scratch Window**: Open a scratch buffer. |
| `:StripWhitespace` | **Strip Whitespace**: Remove trailing whitespace (better-whitespace). |

---

## 🌿 Fugitive (Git) Usage

This configuration uses [vim-fugitive](https://github.com/tpope/vim-fugitive) for seamless Git integration.

### 1. Stage and Commit
- **Open Status**: Type `:G` or `:Git` to open the summary window.
- **Stage/Unstage**: Hover over a file and press `s` to stage or `u` to unstage.
- **Commit**: Press `cc` in the status window to open the commit message buffer. Write your message, save, and close (`:wq`) to finish.
- **Push**: Type `:Git push`.
- Use `:Flog` command to see the git graph

### 2. Open a File at a Specific Commit
To view the current file as it existed in a previous commit:
```vim
:Gedit <commit-hash>:%
" Example: View file from 3 commits ago
:Gedit HEAD~3:%
```
*Tip: `%` represents the current file.*

### 3. Using the Diff Tool
Fugitive integrates with Vim's `diff` mode to compare versions:
- **Compare with Index**: `:Gdiffsplit` (shows your changes vs what is staged).
- **Vertical Diff**: `:Gvdiffsplit`.
- **Resolve Conflicts**: While in a merge, use `:Gdiffsplit!` to see the "target", "merge", and "base" versions simultaneously.

### 4. Compare a File Between Branches/Commits
To compare the current file with its version in another branch:
```vim
:Gdiffsplit <branch-name>
" Example: Compare with main branch
:Gdiffsplit main
```

### 5. Compare All Changes Between Two Commits/Branches
To see all files that changed between two points and iterate through them:
1. **Run Difftool**: `:Git difftool <commit1> <commit2>`
2. **Browse Changes**: This populates the **Quickfix List**.
   - `:copen`: Open the list of changed files.
   - `Ctrl + j`: Move to the next changed file.
   - `Ctrl + k`: Move to the previous changed file.

---

## 🐞 How to Debug

### 1. LSP Logs
If language features are not working, check the LSP log:
```bash
tail -f ~/vim-lsp.log
```
You can also restart/reconnect the LSP server within Vim:
- `<Leader>lr`: Full LSP Restart.
- `<Leader>lc`: Soft Reconnect (refreshes filetype).

### 2. Autocompletion
If completion is stuck, use:
- `:call ResetCompletion()`: Re-initializes `omnifunc` and `asyncomplete`.

### 3. General Health
Check Vim's internal state:
- `:messages`: View recent error or status messages.
- `:scriptnames`: List all loaded scripts/plugins.

---

## 📦 Plugins Reference

| Plugin | Description |
|--------|-------------|
| [Vundle.vim](https://github.com/VundleVim/Vundle.vim) | Plugin manager |
| [indentLine](https://github.com/Yggdroot/indentLine) | Display indentation levels |
| [vim-better-whitespace](https://github.com/ntpeters/vim-better-whitespace) | Highlight and clean trailing whitespace |
| [vim-airline](https://github.com/vim-airline/vim-airline) | Status/tabline (powerline) |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Git wrapper |
| [vim-flog](https://github.com/rbong/vim-flog) | Git graph viewer |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (core + binary) |
| [fzf.vim](https://github.com/junegunn/fzf.vim) | FZF integration (`:Files`, `:Rg`, ...) |
| [undotree](https://github.com/mbbill/undotree) | Visualize the undo tree |
| [csv.vim](https://github.com/chrisbra/csv.vim) | CSV column handling |
| [ale](https://github.com/dense-analysis/ale) | Asynchronous Lint Engine |
| [vim-lsp](https://github.com/prabirshrestha/vim-lsp) | Language Server Protocol client |
| [vim-lsp-settings](https://github.com/mattn/vim-lsp-settings) | Auto-install/config for LSP servers |
| [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim) | Async completion framework |
| [asyncomplete-lsp.vim](https://github.com/prabirshrestha/asyncomplete-lsp.vim) | LSP source for asyncomplete |
| [vim-lsp-ale](https://github.com/rhysd/vim-lsp-ale) | Bridge LSP diagnostics into ALE |
| [vim-ai](https://github.com/madox2/vim-ai) | AI completion and chat |
| [vim-ai-provider-google](https://github.com/madox2/vim-ai-provider-google) | Google/Gemini provider for vim-ai |
| [scratch.vim](https://github.com/mtth/scratch.vim) | Scratch window |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Live Markdown preview |
