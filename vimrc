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
Plugin 'madox2/vim-ai-provider-google'
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
nnoremap <Leader>dp "_dp
xnoremap <Leader>dp "_dp
" Clipboard yank/paste
nnoremap <Leader>o o<Esc>0"_D
nnoremap <Leader>O O<Esc>0"_D
nnoremap <Leader>p "+p
nnoremap <Leader>P "+P
nnoremap <Leader>y "+y
vnoremap <Leader>y "+y
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

" Function to delete local branches already merged into current HEAD
function! CleanMergedBranches()
    " 1. Get the list of merged branches
    " Filters out the current branch (*) and common protected branches
    let l:merged_cmd = "git branch --merged | grep -v '*' | grep -vE '(\\s+)(master|main|develop|dev)$'"
    let l:merged_branches = system(l:merged_cmd)

    " 2. Check if the command returned any branches
    if v:shell_error != 0 || empty(trim(l:merged_branches))
        echo "No merged branches to clean."
        return
    endif

    " 3. Convert the string to a list and trim whitespace
    let l:branch_list = split(l:merged_branches, '\n')
    let l:branch_list = map(l:branch_list, 'trim(v:val)')

    " 4. Execute deletion via Fugitive's :Git wrapper
    for l:branch in l:branch_list
        execute 'Git branch -d ' . l:branch
    endfor

    " 5. Refresh the display and report results
    redraw!
    echo "Deleted branches: " . join(l:branch_list, ", ")
endfunction

" Link the function to a custom command
command! Gclean call CleanMergedBranches()

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
  \ 'ctrl-l': function('s:build_quickfix_list'),
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

function! FindPylsp()
    " Try to locate the best pylsp executable from available environments.
    " Priority: .venv > CONDA_PREFIX > ~/.local > system PATH fallback
    " Returns: path to pylsp or empty string if not found.

    " 1. Project .venv (most specific)
    let l:venv_pylsp = getcwd() . '/.venv/bin/pylsp'
    if executable(l:venv_pylsp)
        return l:venv_pylsp
    endif

    " 2. Active conda environment
    let l:conda_prefix = $CONDA_PREFIX
    if !empty(l:conda_prefix)
        let l:conda_pylsp = l:conda_prefix . '/bin/pylsp'
        if executable(l:conda_pylsp)
            return l:conda_pylsp
        endif
    endif

    " 3. ~/.local/bin (pip install --user)
    if executable(expand('~/.local/bin/pylsp'))
        return expand('~/.local/bin/pylsp')
    endif

    " 4. Whatever is on PATH as a last resort
    if executable('pylsp')
        return 'pylsp'
    endif

    return ''
endfunction

function! HasRuffConfig()
    " Check whether the current project has a ruff config file.
    " Returns: 1 if found, 0 otherwise.
    let l:pyproject = findfile('pyproject.toml', '.;')
    if !empty(l:pyproject)
        " Quick grep for [tool.ruff] section
        let l:lines = readfile(l:pyproject)
        for l:line in l:lines
            if l:line =~ '\[tool\.ruff'
                return 1
            endif
        endfor
    endif
    if !empty(findfile('ruff.toml', '.;'))
        return 1
    endif
    if !empty(findfile('.ruff.toml', '.;'))
        return 1
    endif
    return 0
endfunction

function! SetupPythonLsp()
    let l:pylsp_cmd = FindPylsp()
    if empty(l:pylsp_cmd)
        echo "pylsp not found in any environment. Skipping Python LSP setup."
        return
    endif

    " Base plugins: enable standard linters by default.
    " When a ruff config is detected, we disable the overlapping built-in
    " linters (pycodestyle, pyflakes, mccabe) and let python-lsp-ruff
    " take over — it reads [tool.ruff] from pyproject.toml automatically.
    " When no ruff config is found, keep standard linters so the user
    " still gets basic diagnostics.
    let l:has_ruff = HasRuffConfig()
    let l:plugins = {
        \ 'pycodestyle': {'enabled': v:true},
        \ 'mccabe': {'enabled': v:true},
        \ 'pyflakes': {'enabled': v:true},
        \ 'ruff': {'enabled': l:has_ruff},
        \ }

    if l:has_ruff
        let l:plugins['pycodestyle']['enabled'] = v:false
        let l:plugins['mccabe']['enabled'] = v:false
        let l:plugins['pyflakes']['enabled'] = v:false
    endif

    call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->[l:pylsp_cmd]},
        \ 'allowlist': ['python', 'python3'],
        \ 'workspace_config': {
        \   'pylsp': {
        \     'plugins': l:plugins
        \   }
        \ }
        \ })
endfunction

" Only trigger if pylsp is available somewhere
if !empty(FindPylsp())
    au User lsp_setup call SetupPythonLsp()
endif

" Disable pylsp-all auto-registration by vim-lsp-settings to avoid
" duplicate diagnostics (our custom pylsp with ruff replaces it).
let g:lsp_settings = get(g:, 'lsp_settings', {})
let g:lsp_settings['pylsp-all'] = get(g:lsp_settings, 'pylsp-all', {})
let g:lsp_settings['pylsp-all']['disabled'] = 1

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
    nnoremap <buffer> <expr><c-j> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-k> lsp#scroll(-4)
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

function! LspRestart() abort
    let l:servers = lsp#get_allowed_servers(bufnr('%'))
    echom "DEBUG: l:servers = " . string(l:servers)

    if empty(l:servers)
        echo "No LSP servers found for this buffer."
        return
    endif

    for l:server in l:servers
        echom "DEBUG: stopping l:server = " . l:server
        call lsp#stop_server(l:server)
    endfor

    call lsp#activate()
    echo "Restarted LSP: " . join(l:servers, ', ')
endfunction

" Map the function to <leader>lr
nnoremap <leader>lr :call LspRestart()<CR>

function! LspDebug() abort
    " Print essential debugging info about the current pylsp setup.
    " Use :messages to see full output after calling.
    echom "===== LSP Debug ====="

    " 1. Which pylsp would be chosen now?
    let l:pylsp_chosen = FindPylsp()
    echom "FindPylsp()     : " . (empty(l:pylsp_chosen) ? 'NOT FOUND' : l:pylsp_chosen)

    " 2. Ruff config detection
    let l:has_ruff = HasRuffConfig()
    if l:has_ruff
        " Show which file matched
        let l:pyproject = findfile('pyproject.toml', '.;')
        if !empty(l:pyproject)
            echom "Ruff config     : " . l:pyproject . " ([tool.ruff] section found)"
        endif
        let l:ruff_toml = findfile('ruff.toml', '.;')
        if !empty(l:ruff_toml)
            echom "Ruff config     : " . l:ruff_toml
        endif
        let l:dot_ruff = findfile('.ruff.toml', '.;')
        if !empty(l:dot_ruff)
            echom "Ruff config     : " . l:dot_ruff
        endif
    else
        echom "Ruff config     : NOT FOUND (using pycodestyle/pyflakes/mccabe)"
    endif

    " 3. Active LSP servers for the current buffer
    let l:servers = lsp#get_allowed_servers(bufnr('%'))
    echom "Active LSP      : " . (empty(l:servers) ? 'NONE' : join(l:servers, ', '))
    for l:srv in l:servers
        " Try to get the server command
        try
            let l:server_info = lsp#get_server_info(l:srv)
            if has_key(l:server_info, 'cmd')
                echom "  " . l:srv . " cmd: " . string(l:server_info['cmd'])
            endif
        catch
        endtry
    endfor

    " 4. Environment info
    echom "CWD             : " . getcwd()
    echom "CONDA_PREFIX    : " . (exists('$CONDA_PREFIX') ? $CONDA_PREFIX : '(not set)')
    echom "VIRTUAL_ENV     : " . (exists('$VIRTUAL_ENV') ? $VIRTUAL_ENV : '(not set)')
    echom "PATH (first 3)  : " . join(split($PATH, ':')[0:2], ':')

    " 5. Workspace config that was registered
    " We can't read it back from pylsp directly here, but we can show
    " what vim-lsp has stored for the buffer
    let l:bufnr = bufnr('%')
    echom "Buffer filetype : " . &filetype
    echom "Buffer omnifunc : " . &omnifunc

    " 6. python-lsp-ruff availability (shell check)
    let l:pylsp_path = empty(l:pylsp_chosen) ? 'pylsp' : l:pylsp_chosen
    let l:has_pylsp_ruff = system('python3 -c "import pylsp_ruff; print(pylsp_ruff.__file__)" 2>/dev/null')
    if l:has_pylsp_ruff =~ 'pylsp_ruff'
        let l:has_pylsp_ruff = substitute(l:has_pylsp_ruff, '\n', '', 'g')
        echom "pylsp_ruff      : " . l:has_pylsp_ruff
    else
        " Try the environment-specific python
        let l:python_cmd = 'python3'
        if !empty(l:pylsp_chosen)
            let l:python_cmd = fnamemodify(l:pylsp_chosen, ':h') . '/python'
        endif
        let l:has_pylsp_ruff = system(l:python_cmd . ' -c "import pylsp_ruff; print(pylsp_ruff.__file__)" 2>&1')
        if l:has_pylsp_ruff =~ 'pylsp_ruff'
            let l:has_pylsp_ruff = substitute(l:has_pylsp_ruff, '\n', '', 'g')
            echom "pylsp_ruff      : " . l:has_pylsp_ruff
        else
            echom "pylsp_ruff      : NOT INSTALLED for " . l:pylsp_chosen
        endif
    endif

    " 7. ALE info (if loaded)
    if exists('g:ale_enabled')
        let l:ale_buf_enabled = getbufvar(bufnr('%'), 'ale_enabled', 1)
        echom "ALE enabled     : global=" . g:ale_enabled . " buffer=" . l:ale_buf_enabled
    else
        echom "ALE enabled     : NOT LOADED (ale.vim plugin not active)"
    endif

    echom "===== End LSP Debug ====="
    echo "See :messages for full debug output"
endfunction

" Map to <leader>ld
nnoremap <leader>ld :call LspDebug()<CR>

function! LspReconnect() abort
    " 1. Save the current filetype
    let l:ft = &filetype

    " 2. Re-set the filetype to itself.
    " This triggers the 'FileType' autocommand which vim-lsp listens to.
    execute 'set filetype=' . l:ft

    " 3. Explicitly call activate for the current buffer
    call lsp#activate()

    echo "Soft reconnected LSP for " . l:ft . " (Buffer " . bufnr('%') . ")"
endfunction

" Mapping for Soft Reconnect
nnoremap <leader>lc :call LspReconnect()<CR>

function! ResetCompletion() abort
    " 1. Force set the omnifunc again (the most likely culprit)
    setlocal omnifunc=lsp#complete

    " 2. Tell asyncomplete to refresh its source cache for this buffer
    if exists('*asyncomplete#force_refresh')
        call asyncomplete#force_refresh()
    endif

    echo "Completion re-initialized"
endfunction

function! LspAsyncompleteDeepReset() abort
    " 1. Unregister the LSP source to clear any stale IDs
    " This name must match exactly what you saw in asyncomplete#get_source_names()
    silent! call asyncomplete#unregister_source('asyncomplete_lsp_clangd')

    " 2. Re-trigger the 'LspSetup' event.
    " asyncomplete-lsp listens for this to register itself.
    doautocmd User lsp_setup

    " 3. Force a refresh
    call asyncomplete#force_refresh()

    echo "Asyncomplete-LSP source re-registered"
endfunction
" --- ALE ---
let g:ale_python_executable = getcwd() . '/.venv/bin/python'

" Ensure ALE uses the venv for pylint and other tools
let g:ale_python_pylint_executable = 'uv'
let g:ale_python_pylint_use_global = 0
let g:ale_python_pylint_options = '--enable=all --disable=no-member,bad-indentation,W0311'
let g:ale_python_flake8_options = '--max-line-length=90'
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'cpp': ['astyle', 'clangtidy'],
\}
let g:ale_cpp_cc_executable = exepath("clangd")
"let g:ale_exclude_highlights = ['line too long', 'E501', 'C0301']

"let g:ale_python_auto_virtualenv = 1
"" Specify directory names ALE should look for
"let g:ale_virtualenv_dir_names = ['venv', '.venv', 'env']
"let g:ale_python_pylint_auto_pipenv = 1

"let g:ale_lint_on_enter = 1
"let g:ale_lint_on_save = 1

function s:apply_cc_options (buffer)
    let [l:root, l:json_file] = ale#c#FindCompileCommands(a:buffer)
    if l:json_file==''
        let g:ale_c_cc_options = '-ansi -pedantic -Wall'
    else
        let g:ale_c_cc_options = ''
    endif
endfunction
autocmd BufReadPost * call s:apply_cc_options(bufnr(''))

" Tell ALE to find the python binary inside the uv-created .venv
let g:ale_python_auto_uv = 1
let g:ale_python_executable = getcwd() . '/.venv/bin/python'

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
\    "request_timeout": 100,
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
