set encoding=utf-8
set nocompatible              " be iMproved, required
filetype off                  " required
set backspace=indent,eol,start
set clipboard=unnamedplus

"set verbose=1
"set verbosefile=~/vim_debug.txt

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
"set rtp+=/home/ywchen/.fzf/bin/fzf

call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'majutsushi/tagbar'
Plugin 'Yggdroot/indentLine'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'rbong/vim-flog'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'mbbill/undotree'
Plugin 'rust-lang/rust.vim'
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

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Switch off all auto-indenting
set nocindent
set nosmartindent
set noautoindent
set indentexpr=
filetype indent off
filetype plugin indent off
"
set shiftwidth=2

set hlsearch
hi Search ctermbg=LightYellow
hi Search ctermfg=Red

"set cursorline
"hi CursorLine cterm=none ctermbg=0x444444 ctermfg=none

set cursorcolumn
hi CursorColumn cterm=none ctermbg=0x444444 ctermfg=none

" Enable list mode to show special characters
set list

" Customize listchars to display tabs as a gray block
set listchars=tab:▸\ ,trail:·

" Adjust the color of the 'SpecialKey' highlight group, which affects tab characters
highlight SpecialKey guifg=#FFE4E1
" highlight SpecialKey ctermfg=13 guifg=#FFE4E1

nnoremap <C-K> :call HighlightNearCursor()<CR>
function! HighlightNearCursor()
  if !exists("s:highlightcursor")
    match Todo /\k*\%#\k*/
    let s:highlightcursor=1
  else
    match None
    unlet s:highlightcursor
  endif
endfunction

" tnoremap <Esc> <C-\><C-n>
" the normal keybinding setting
" go to the file explore mode
nnoremap <Space>pv :Ex<CR>
" the F1 for the stupid touchbar
nnoremap <Space>f1 <F1><CR>
" switch bwtween the recent two files
nnoremap <Space>nn :b#<CR>
" clear the search string
nnoremap <Space>sd /a@#$%<CR>
" join several lines together while keeping track of where you started
nnoremap J mzJ`z<CR>
" page up and down and make the cursor in the middle of the screen
nnoremap <C-d> <C-d>zz<CR>
nnoremap <C-k> 20kzz<CR>
nnoremap <C-j> 20jzz<CR>
nnoremap <C-u> <C-u>zz<CR>
" search and stay at the middle (the k is used for shift a line back ... I
" don't know why)
nnoremap n jnkzz<CR>
nnoremap N Nkzz<CR>
" move the sellected line up and down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" able to paste the first yanked itmes again
xnoremap <Leader>dp "_dp<CR>
" yank to the clipboard
" yap is to yank whole paragraph
nnoremap <Leader>o o<Esc>0"_Dk<CR>
nnoremap <Leader>O O<Esc>0"_D<CR>
nnoremap <Leader>p "+p<CR>
nnoremap <Leader>P "+P<CR>
nnoremap <Leader>y "+y<CR>
nnoremap <Leader>yap "+yap<CR>
nnoremap <Leader>Y "+Y<CR>
nnoremap <Leader>% :let @+ = expand('%')<CR>
nnoremap <Leader>%% :let @+ = expand('%:p')<CR>
" delete the line and no affecting yank register
nnoremap <Leader>d "_d<CR>
vnoremap <Leader>d "_d<CR>

nnoremap <C-j> <cmd>cnext<CR>zz
nnoremap <C-k> <cmd>cprev<CR>zz
"nnoremap <C-j> <cmd>cnext<CR>
"nnoremap <C-k> <cmd>cprev<CR>
"nnoremap <Space>k <cmd>lnext<CR>zzk<CR>
"nnoremap <Space>j <cmd>lprev<CR>zzk<CR>


" for fzf
"let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
"let $FZF_DEFAULT_COMMAND = 'rg --files --no-messages'
nnoremap <Space>pf :Files<CR>
nnoremap <Space>pb :Buffers<CR>
nnoremap <Space>pt :Tags<CR>
nnoremap <Space>pm :Maps<CR>
nnoremap <Space>pw :Windows<CR>
nnoremap <Space>pc :History:<CR>
nnoremap <Space>pg :Commits<CR>
function! FuzzyGrepLocal()
  call inputsave()
  let _string = input("Grep < ")
  call inputrestore()
  execute 'Rg ' . _string
endfunction
nnoremap <Space>ps :call FuzzyGrepLocal()<CR>
nnoremap <C-p> :GFiles<CR>

"function! s:build_quickfix_list(lines)
"  call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
"  copen
"  cc
"endfunction
"
"let g:fzf_action = {
"  \ 'ctrl-e': 'wall | bdelete',
"  \ 'ctrl-q': function('s:build_quickfix_list'),
"  \ 'ctrl-t': 'tab split',
"  \ 'ctrl-x': 'split',
"  \ 'ctrl-v': 'vsplit' }

" An action can be a reference to a function that processes selected lines
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


" Path completion with custom source command
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('fd')
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')

" Word completion with custom spec with popup layout option
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

" for undotree
nnoremap <Space>u :UndotreeToggle<CR>

" for csv reader
nnoremap <Leader>ac :%ArrangeColumn<CR>
nnoremap <Leader>uac :%UnArrangeColumn<CR>

" for FLog
nnoremap <Leader>git :Floggit

set number relativenumber

filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
set tags=tags;/
set mouse=a

nmap <Leader>tb :TagbarToggle<CR>      "快捷鍵設定
let g:tagbar_ctags_bin='ctags'          "ctags程式的路徑
let g:tagbar_width=79                  "視窗寬度的設定
let g:tagbar_wrap=1
map <F11> :Tagbar<CR>
"autocmd BufReadPost *.cpp,*.c,*.h,*.hpp,*.cc,*.cxx call tagbar#autoopen() "如果是c語言的程式的話，tagbar自動開啟

let g:airline_powerline_fonts = 1
" enable tabline
let g:airline#extensions#tabline#enabled = 1
" --- Airline Customization ---
let g:airline#extensions#tabline#fnamemod = ':t' " Show only filename in tabs
let g:airline_section_c = '%t'                   " Show only filename in status bar
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" show tab number in tab line
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#vimtex#left = ""
let g:airline#extensions#vimtex#right = ""
"
set laststatus=2 " Show the statusline
set noshowmode " Hide the default mode text
"  airline symbols dictionary
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
if has("gui_running")
  set guifont=MesloLGSDZForPowerline-Regular:h16
endif
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_section_c = '%{airline#util#wrap(airline#parts#file(), 0)}'

function! CleanFugitivePath()
    let l:path = expand('%:p')
    " If it's a fugitive buffer, strip the 'fugitive://...//' part
    if l:path =~ 'fugitive://'
        return 'GIT: ' . expand('%:t')
    endif
    " Otherwise, just show the filename (tail)
    return expand('%:t')
endfunction

" Tell airline to use our custom function for Section C (the middle part)
let g:airline_section_c = '%{CleanFugitivePath()}'


set laststatus=2

set colorcolumn=80
hi ColorColumn cterm=none ctermbg=0x444444 ctermfg=LightGray

" for lsp
if executable('pylsp-all')
    " pip install python-lsp-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp-all',
        \ 'cmd': {server_info->['pylsp-all']},
        \ 'allowlist': ['python', 'python3'],
        \ })
endif

let g:ale_python_pylint_options = '--enable=all --disable=no-member'

let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')


function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> <Space>ga <plug>(lsp-code-action-float)
    nmap <buffer> <Space>gd <plug>(lsp-definition)
    nmap <buffer> <Space>gc <plug>(lsp-declaration)
    nmap <buffer> <Space>pd <plug>(lsp-peek-definition)
    nmap <buffer> <Space>pc <plug>(lsp-peek-declaration)
    nmap <buffer> <Space>gsd <plug>(lsp-document-symbol-search)
    nmap <buffer> <Space>gsw <plug>(lsp-workspace-symbol-search)
    nmap <buffer> <Space>gr <plug>(lsp-references)
    nmap <buffer> <Space>gi <plug>(lsp-implementation)
    nmap <buffer> <Space>gt <plug>(lsp-type-definition)
    nmap <buffer> <Space>gn <plug>(lsp-rename)
    nmap <buffer> <Space>g[ <plug>(lsp-previous-diagnostic)
    nmap <buffer> <Space>g] <plug>(lsp-next-diagnostic)
    nmap <buffer> <Space><Space> <plug>(lsp-hover)
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-ff> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" LSP folding setting
"set foldmethod=expr
"  \ foldexpr=lsp#ui#vim#folding#foldexpr()
"  \ foldtext=lsp#ui#vim#folding#foldtext()
"let g:lsp_fold_enabled = 0

let g:lsp_diagnostics_enabled = 0         " disable diagnostics support
highlight lspReference ctermfg=red guifg=red ctermbg=green guibg=green

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'cpp': ['astyle', 'clangtidy'],
\}

let g:lsp_log_verbose = 0
let g:lsp_log_file = expand('~/vim-lsp.log')

" for asyncomplete.vim log
let g:asyncomplete_log_file = expand('~/asyncomplete.log')

"let g:ale_cpp_clang_options = '-Wall -Wextra -pedantic -std=c++1z'
"let g:ale_cpp_clangd_options = '-Wall -Wextra -pedantic -std=c++1z'
"let g:ale_cpp_cc_options = '-Wall -Wextra -pedantic -std=c++1z'
"let g:ale_linters = {'c': ['clang'], 'cpp': ['clang-tidy', 'g++'], 'hpp': ['clang-tidy', 'g++']}
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

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" allow modifying the completeopt variable, or it will
" be overridden all the time
let g:asyncomplete_auto_completeopt = 0

set completeopt=menuone,noinsert,noselect,preview
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" setup vim-ai
let g:vim_ai_token_file_path = '~/.config/openai.token'
let g:vim_ai_roles_config_file = '~/.config/vim-ai-roles.ini'

" complete text on the current line or in visual selection
nnoremap <leader>a :AI /gemini<CR>
xnoremap <leader>a :AI /gemini<CR>

" edit text with a custom prompt
xnoremap <leader>s :AIEdit /gemini fix grammar and spelling<CR>
nnoremap <leader>s :AIEdit /gemini fix grammar and spelling<CR>

" trigger chat
xnoremap <leader>nc :AIChat /tab /gemini<CR>
nnoremap <leader>nc :AIChat /tab /gemini<CR>

xnoremap <leader>c :AIChat /gemini<CR>
nnoremap <leader>c :AIChat /gemini<CR>

" redo last AI command
nnoremap <leader>r :AIRedo<CR>

" This prompt instructs model to be consise in order to be used inline in editor
let s:initial_complete_prompt =<< trim END
>>> system

You are a general assistant.
Answer shortly, consisely and only what you are asked.
Do not provide any explanantion or comments if not requested.
If you answer in a code, do not wrap it in markdown code block.
END

" :AI
" - engine: chat | complete - see how to configure complete engine in the section below
" - options: openai config (see https://platform.openai.com/docs/api-reference/completions)
" - options.initial_prompt: prompt prepended to every chat request (list of lines or string)
" - options.request_timeout: request timeout in seconds
" - options.enable_auth: enable authorization using openai key
" - options.token_file_path: override global token configuration
" - options.selection_boundary: selection prompt wrapper (eliminates empty responses, see #20)
" - ui.paste_mode: use paste mode (see more info in the Notes below)
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
\  "ui": {
\    "paste_mode": 1,
\  },
\}

" :AIEdit
" - engine: chat | complete - see how to configure complete engine in the section below
" - options: openai config (see https://platform.openai.com/docs/api-reference/completions)
" - options.initial_prompt: prompt prepended to every chat request (list of lines or string)
" - options.request_timeout: request timeout in seconds
" - options.enable_auth: enable authorization using openai key
" - options.token_file_path: override global token configuration
" - options.selection_boundary: selection prompt wrapper (eliminates empty responses, see #20)
" - ui.paste_mode: use paste mode (see more info in the Notes below)
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
\  "ui": {
\    "paste_mode": 1,
\  },
\}

" This prompt instructs model to work with syntax highlighting
let s:initial_chat_prompt =<< trim END
>>> system

You are a general assistant.
If you attach a code block add syntax type after ``` to enable syntax highlighting.
END

" :AIChat
" - options: openai config (see https://platform.openai.com/docs/api-reference/chat)
" - options.initial_prompt: prompt prepended to every chat request (list of lines or string)
" - options.request_timeout: request timeout in seconds
" - options.enable_auth: enable authorization using openai key
" - options.token_file_path: override global token configuration
" - options.selection_boundary: selection prompt wrapper (eliminates empty responses, see #20)
" - ui.populate_options: put [chat-options] to the chat header
" - ui.open_chat_command: preset (preset_below, preset_tab, preset_right) or a custom command
" - ui.scratch_buffer_keep_open: re-use scratch buffer within the vim session
" - ui.paste_mode: use paste mode (see more info in the Notes below)
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

" Notes:
" ui.paste_mode
" - if disabled code indentation will work but AI doesn't always respond with a code block
"   therefore it could be messed up
" - find out more in vim's help `:help paste`
" options.max_tokens
" - note that prompt + max_tokens must be less than model's token limit, see #42, #46
" - setting max tokens to 0 will exclude it from the OpenAI API request parameters, it is
"   unclear/undocumented what it exactly does, but it seems to resolve issues when the model
"   hits token limit, which respond with `OpenAI: HTTPError 400`

" markdown
"function OpenMarkdownPreview (url)
"  execute "silent ! /home/ywchen/Documents/waterfox/waterfox-6.6.8/waterfox/waterfox --new-window " . a:url
"endfunction
"let g:mkdp_browserfunc = 'OpenMarkdownPreview'
" function OpenMarkdownPreview (url)
"   execute "silent ! microsoft-edge --new-window " . a:url
" endfunction
" let g:mkdp_browserfunc = 'OpenMarkdownPreview'


syntax on

let g:markdown_fenced_languages = ['python', 'cpp', 'javascript', 'bash', 'html', 'json']

highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red
