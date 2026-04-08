# Vim Configuration

A comprehensive and efficient Vim setup tailored for development, featuring LSP support, fuzzy finding, Git integration, and AI-powered coding assistance.

## 🛠️ Installation

### 1. Prerequisites
Ensure you have `vim` (with `+python3` and `+clipboard` support recommended) and `git` installed.

For full functionality, the following tools are recommended:
- **[FZF](https://github.com/junegunn/fzf):** Command-line fuzzy finder.
- **[Ripgrep (rg)](https://github.com/BurntSushi/ripgrep):** For fast searching.
- **(Optional) Python LSP Server:** `pip install python-lsp-server` (for Python IDE features).

### 2. Setup
Clone this repository and symlink the `vimrc` file to your home directory:

```bash
git clone https://github.com/your-username/vimrc_setting.git ~/vimrc_setting
ln -s ~/vimrc_setting/vimrc ~/.vimrc
```

### 3. Install Plugin Manager (Vundle)
This configuration uses [Vundle](https://github.com/VundleVim/Vundle.vim) to manage plugins.

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

### 4. Install Plugins
Open Vim and run:
```vim
:PluginInstall
```

---

## 🚀 How to Use

### General Mappings
The `<Leader>` key is set to **Space**.

| Mapping | Action |
|---------|--------|
| `<Leader>pv` | Open File Explorer (Netrw) |
| `<Leader>nn` | Switch to the most recent buffer |
| `<Leader>sd` | Clear search highlights |
| `<Leader>y` | Yank to system clipboard |
| `<Leader>p` | Paste from system clipboard |
| `<Leader>dp` | Paste without overwriting yank register |
| `<Leader>d` | Delete without affecting yank register |
| `Ctrl + d / u` | Scroll down/up and center screen |
| `n / N` | Next/Previous search match and center screen |
| `J / K` (Visual) | Move selected lines up/down |

### Plugins & Features

#### 🔍 Fuzzy Finding (FZF)
| Mapping | Action |
|---------|--------|
| `Ctrl + p` | Find files in Git repo |
| `<Leader>pf` | Find files |
| `<Leader>ps` | Grep search (Rg) |
| `<Leader>pb` | List open buffers |
| `<Leader>pg` | List Git commits |

#### 💻 LSP (Language Server Protocol)
IDE-like features (definitions, references, renaming) via `vim-lsp`.
- `<Leader>gd`: Go to definition.
- `<Leader>gr`: Find references.
- `<Leader>gn`: Rename symbol.
- `<Leader><Leader>`: Hover for documentation.
- `<Leader>ga`: Code actions.

#### 🌿 Git (Fugitive & Flog)
- `<Leader>git`: Open Flog (Git graph).
- Status line shows the current branch and clean Git paths.

#### 🤖 AI Assistance (Vim-AI)
- `<Leader>a`: AI completion/prompt.
- `<Leader>s`: AI Edit (e.g., fix grammar/spelling).
- `<Leader>c`: AI Chat.
- `<Leader>nc`: AI Chat in a new tab.

#### 📝 Others
- **Undotree:** `<Leader>u` to toggle undo history visualizer.
- **CSV:** `<Leader>ac` to arrange CSV columns.
- **Quickfix:** `Ctrl + j / k` to navigate through quickfix list.

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
| [vim-airline](https://github.com/vim-airline/vim-airline) | Lean & mean status/tabline |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | The premier Vim Git wrapper |
| [vim-flog](https://github.com/rbong/vim-flog) | Fast Git graph viewer |
| [fzf.vim](https://github.com/junegunn/fzf.vim) | FZF integration for Vim |
| [undotree](https://github.com/mbbill/undotree) | Visualize the undo tree |
| [csv.vim](https://github.com/chrisbra/csv.vim) | Plugin for handling CSV files |
| [ale](https://github.com/dense-analysis/ale) | Asynchronous Lint Engine |
| [vim-lsp](https://github.com/prabirshrestha/vim-lsp) | Async Language Server Protocol |
| [vim-lsp-settings](https://github.com/mattn/vim-lsp-settings) | Auto-configurations for LSP |
| [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim) | Async completion in Vim |
| [vim-ai](https://github.com/madox2/vim-ai) | AI completion and chat |
| [scratch.vim](https://github.com/mtth/scratch.vim) | Unobtrusive scratch window |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Live preview for Markdown |
