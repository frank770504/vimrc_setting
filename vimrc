" =============================================================================
" 1. VIM INITIALIZATION
" =============================================================================
set encoding=utf-8
set nocompatible              " be iMproved, required
filetype off                  " required

" =============================================================================
" 2. PLUGIN MANAGEMENT (Vundle)
" =============================================================================
set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=/home/ywchen/.fzf/bin/fzf

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'Yggdroot/indentLine'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'rbong/vim-flog'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'mbbill/undotree'
Plugin 'chrisbra/csv.vim'
Plugin 'dense-analysis/ale'
Plugin 'prabirshrestha/vim-lsp'
Plugin 'mattn/vim-lsp-settings'
Plugin 'prabirshrestha/asyncomplete.vim'
Plugin 'prabirshrestha/asyncomplete-lsp.vim'
Plugin 'rhysd/vim-lsp-ale'
Plugin 'madox2/vim-ai'
Plugin 'mtth/scratch.vim'
Plugin 'iamcco/markdown-preview.nvim'

call vundle#end()            " required
filetype plugin indent on    " required

" =============================================================================
" 3. GENERAL EDITOR SETTINGS
" =============================================================================
set backspace=indent,eol,start
set clipboard=unnamedplus
set mouse=a
set hlsearch
hi Search ctermbg=LightYellow ctermfg=Red

set number relativenumber
set tags=tags;/
set laststatus=2
set noshowmode
syntax on

" =============================================================================
" 4. INDENTATION & TAB SETTINGS
" =============================================================================
set tabstop=4
set shiftwidth=4
set expandtab
set list
set listchars=tab:▸\ ,trail:·
highlight SpecialKey guifg=#FFE4E1

" =============================================================================
" 5. UI & APPEARANCE
" =============================================================================
set cursorcolumn
hi CursorColumn cterm=none ctermbg=0x444444 ctermfg=none

set colorcolumn=80
hi ColorColumn cterm=none ctermbg=0x444444 ctermfg=LightGray

" =============================================================================
" 6. GENERAL MAPPINGS
" =============================================================================
let mapleader = " "

" File explorer
nnoremap <Leader>pv :Ex<CR>
" F1 for touchbar
nnoremap <Leader>f1 <F1><CR>
" Switch between recent files
nnoremap <Leader>nn :b#<CR>
" Clear search highlights
nnoremap <Leader>sd :noh<CR>
" Join lines while keeping cursor position
nnoremap J mzJ`z
" Page scroll with centering
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
" Search and center
nnoremap n nzz
nnoremap N Nzz
" Move selected lines
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" Paste without overwriting register
xnoremap <Leader>dp "_dp
" Clipboard yank/paste
nnoremap <Leader>o o<Esc>0"_Dk
nnoremap <Leader>O O<Esc>0"_D
nnoremap <Leader>p "+p
nnoremap <Leader>P "+P
nnoremap <Leader>y "+y
nnoremap <Leader>yap "+yap
nnoremap <Leader>Y "+Y
nnoremap <Leader>% :let @+ = expand('%')<CR>
nnoremap <Leader>%% :let @+ = expand('%:p')<CR>
" Delete without affecting yank register
nnoremap <Leader>d "_d
vnoremap <Leader>d "_d

" Quickfix navigation
nnoremap <C-j> <cmd>cnext<CR>zz
nnoremap <C-k> <cmd>cprev<CR>zz

" Highlight Near Cursor (Moved to <Leader>h to avoid <C-k> conflict)
nnoremap <Leader>h :call HighlightNearCursor()<CR>
function! HighlightNearCursor()
  if !exists("s:highlightcursor")
    match Todo /\k*\%#\k*/
    let s:highlightcursor=1
  else
    match None
    let s:highlightcursor=0
  endif
endfunction

" =============================================================================
" 7. PLUGIN CONFIGURATIONS
" =============================================================================

" --- Airline ---
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

function! CleanFugitivePath()
    let l:path = expand('%:p')
    if l:path =~ 'fugitive://'
        return 'GIT: ' . expand('%:t')
    endif
    return expand('%:t')
endfunction
let g:airline_section_c = '%{CleanFugitivePath()}'

if has("gui_running")
  set guifont=MesloLGSDZForPowerline-Regular:h16
endif

" --- FZF ---
nnoremap <Leader>pf :Files<CR>
nnoremap <Leader>pb :Buffers<CR>
nnoremap <Leader>pt :Tags<CR>
nnoremap <Leader>pm :Maps<CR>
nnoremap <Leader>pw :Windows<CR>
nnoremap <Leader>pc :History:<CR>
nnoremap <Leader>pg :Commits<CR>
nnoremap <C-p> :GFiles<CR>

function! FuzzyGrepLocal()
  call inputsave()
  let _string = input("Grep < ")
  call inputrestore()
  execute 'Rg ' . _string
endfunction
nnoremap <Leader>ps :call FuzzyGrepLocal()<CR>

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines)
  execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

command! BD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines) },
  \ 'options': '--multi --reverse --bind ctrl-t:select-all+accept'
\ }))

inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

" --- UndoTree ---
nnoremap <Leader>u :UndotreeToggle<CR>

" --- CSV Reader ---
nnoremap <Leader>ac :%ArrangeColumn<CR>
nnoremap <Leader>uac :%UnArrangeColumn<CR>

" --- FLog ---
nnoremap <Leader>git :Floggit

" --- LSP (vim-lsp) ---
let g:lsp_log_verbose = 0
let g:lsp_log_file = expand('~/vim-lsp.log')
let g:lsp_diagnostics_enabled = 0
let g:lsp_format_sync_timeout = 1000
highlight lspReference ctermfg=red guifg=red ctermbg=green guibg=green

if executable('pylsp-all')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp-all',
        \ 'cmd': {server_info->['pylsp-all']},
        \ 'allowlist': ['python', 'python3'],
        \ })
endif

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> <Leader>ga <plug>(lsp-code-action-float)
    nmap <buffer> <Leader>gd <plug>(lsp-definition)
    nmap <buffer> <Leader>gc <plug>(lsp-declaration)
    nmap <buffer> <Leader>pd <plug>(lsp-peek-definition)
    nmap <buffer> <Leader>pc <plug>(lsp-peek-declaration)
    nmap <buffer> <Leader>gsd <plug>(lsp-document-symbol-search)
    nmap <buffer> <Leader>gsw <plug>(lsp-workspace-symbol-search)
    nmap <buffer> <Leader>gr <plug>(lsp-references)
    nmap <buffer> <Leader>gi <plug>(lsp-implementation)
    nmap <buffer> <Leader>gt <plug>(lsp-type-definition)
    nmap <buffer> <Leader>gn <plug>(lsp-rename)
    nmap <buffer> <Leader>g[ <plug>(lsp-previous-diagnostic)
    nmap <buffer> <Leader>g] <plug>(lsp-next-diagnostic)
    nmap <buffer> <Leader><Leader> <plug>(lsp-hover)
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-ff> lsp#scroll(-4)
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" --- ALE ---
let g:ale_python_pylint_options = '--enable=all --disable=no-member'
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'cpp': ['astyle', 'clangtidy'],
\}
let g:ale_cpp_cc_executable = exepath("clangd")

function s:apply_cc_options (buffer)
    let [l:root, l:json_file] = ale#c#FindCompileCommands(a:buffer)
    if l:json_file==''
        let g:ale_c_cc_options = '-ansi -pedantic -Wall'
    else
        let g:ale_c_cc_options = ''
    endif
endfunction
autocmd BufReadPost * call s:apply_cc_options(bufnr(''))

" --- Asyncomplete ---
let g:asyncomplete_log_file = expand('~/asyncomplete.log')
let g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert,noselect,preview
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" --- Vim-AI ---
let g:vim_ai_token_file_path = '~/.config/openai.token'
let g:vim_ai_roles_config_file = '~/.config/vim-ai-roles.ini'

nnoremap <leader>a :AI /gemini<CR>
xnoremap <leader>a :AI /gemini<CR>
nnoremap <leader>s :AIEdit /gemini fix grammar and spelling<CR>
xnoremap <leader>s :AIEdit /gemini fix grammar and spelling<CR>
nnoremap <leader>nc :AIChat /tab /gemini<CR>
xnoremap <leader>nc :AIChat /tab /gemini<CR>
nnoremap <leader>c :AIChat /gemini<CR>
xnoremap <leader>c :AIChat /gemini<CR>
nnoremap <leader>r :AIRedo<CR>

let s:initial_complete_prompt =<< trim END
>>> system
You are a general assistant.
Answer shortly, consisely and only what you are asked.
Do not provide any explanantion or comments if not requested.
If you answer in a code, do not wrap it in markdown code block.
END

let g:vim_ai_complete = {
\  "engine": "chat",
\  "options": {
\    "model": "gpt-4o",
\    "endpoint_url": "https://api.openai.com/v1/chat/completions",
\    "max_tokens": 0,
\    "max_completion_tokens": 0,
\    "temperature": 0.1,
\    "request_timeout": 60,
\    "stream": 1,
\    "enable_auth": 1,
\    "token_file_path": "",
\    "selection_boundary": "#####",
\    "initial_prompt": s:initial_complete_prompt,
\  },
\  "ui": { "paste_mode": 1 },
\}

let g:vim_ai_edit = {
\  "engine": "chat",
\  "options": {
\    "model": "gpt-4o",
\    "endpoint_url": "https://api.openai.com/v1/chat/completions",
\    "max_tokens": 0,
\    "max_completion_tokens": 0,
\    "temperature": 0.1,
\    "request_timeout": 60,
\    "stream": 1,
\    "enable_auth": 1,
\    "token_file_path": "",
\    "selection_boundary": "#####",
\    "initial_prompt": s:initial_complete_prompt,
\  },
\  "ui": { "paste_mode": 1 },
\}

let s:initial_chat_prompt =<< trim END
>>> system
You are a general assistant.
If you attach a code block add syntax type after ``` to enable syntax highlighting.
END

let g:vim_ai_chat = {
\  "options": {
\    "model": "gpt-4o",
\    "endpoint_url": "https://api.openai.com/v1/chat/completions",
\    "max_tokens": 0,
\    "max_completion_tokens": 0,
\    "temperature": 1,
\    "request_timeout": 300,
\    "stream": 1,
\    "enable_auth": 1,
\    "token_file_path": "",
\    "selection_boundary": "",
\    "initial_prompt": s:initial_chat_prompt,
\  },
\  "ui": {
\    "code_syntax_enabled": 1,
\    "populate_options": 0,
\    "open_chat_command": "preset_below",
\    "scratch_buffer_keep_open": 0,
\    "paste_mode": 0,
\  },
\}
autocmd FileType aichat setlocal textwidth=85

" --- Markdown ---
let g:markdown_fenced_languages = ['python', 'cpp', 'javascript', 'bash', 'html', 'json']

" --- Diff Highlighting ---
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red
