" Note: This config requires the following
" - $NVIMCONFIG set in
"    - Windows environment variables as NVIMCONFIG to "C\:Users\_username_\AppData\Local\nvim"
"    - .zshenv (or .bash_profile) to "~/.config/nvim"
"
"      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"      NVIMCONFIG="$HOME/.config/nvim/"
"      export NVIMCONFIG
"      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
" - ripgrep should be installed
"   - https://github.com/BurntSushi/ripgrep
"
" - minpac should be installed
"   - https://github.com/k-takata/minpac
"      git clone https://github.com/k-takata/minpac.git ~/.config/nvim/pack/minpac/opt/minpac
"
" - Python links should be installed (if not already installed, use :checkhealth) with
"   - python3 -m pip install --user --upgrade pynvim

if &compatible
    set nocompatible
endif

command! PackStatus packadd minpac | source $MYVIMRC | call minpac#status()
command! PackUpdate packadd minpac | source $NVIMCONFIG/init.vim | redraw | call minpac#update()
command! PackClean packadd minpac | source $NVIMCONFIG/init.vim | call minpac#clean()
command! Reload source $NVIMCONFIG/init.vim

" ------------ Functions ------------ "

" Detect the current OS (windows/linux/wsl)
function! g:DetectOS()
    if has('win16') || has('win32') || has('win64')
        return 'windows'
    endif
    call system('grep -q Microsoft /proc/version')
    if v:shell_error == 0
        return 'wsl'
    else
        return 'linux'
    endif
endfunction

function! g:AddPackage(info)
    if !has_key(a:info, 'repo')
        echoerr 'missing package repo (trying to add package)'
        return
    endif
    if !has_key(a:info, 'package')
        echoerr 'missing package name (trying to add package)'
        return
    endif
    let repo = a:info.repo
    let package = a:info.package
    let enable = 1
    if has_key(a:info, 'enable')
        let enable = a:info.enable
    endif
    let defaults = {}
    if has_key(a:info, 'config')
        let defaults = extend(defaults, a:info.config)
    endif
    let config = extend(copy(defaults), { 'type': 'opt' })
    if exists('*minpac#init')
        call minpac#add(repo.'/'.package, config)
    endif
    if l:enable
        exec 'packadd! ' . package
    endif
endfunction

function! g:IsLoaded(package)
    return &runtimepath =~ a:package
endfunction

" ------------ Load Plugins ------------ "

packadd minpac
if exists('*minpac#init')
    call minpac#init({ 'verbose': 1 })
endif

call g:AddPackage({ 'repo': 'k-takata', 'package': 'minpac', })
call g:AddPackage({ 'repo': 'tpope', 'package': 'vim-fugitive' })
call g:AddPackage({ 'repo': 'tpope', 'package': 'vim-surround' })
call g:AddPackage({ 'repo': 'tpope', 'package': 'vim-repeat' })
call g:AddPackage({ 'repo': 'tpope', 'package': 'vim-commentary' })
call g:AddPackage({ 'repo': 'tpope', 'package': 'vim-obsession' })
call g:AddPackage({ 'repo': 'raimondi', 'package': 'delimitmate' })
call g:AddPackage({ 'repo': 'editorconfig', 'package': 'editorconfig-vim' })
call g:AddPackage({ 'repo': 'kana', 'package': 'vim-textobj-user' })
call g:AddPackage({ 'repo': 'kana', 'package': 'vim-textobj-indent' })
call g:AddPackage({ 'repo': 'junegunn', 'package': 'fzf', 'config': { 'do': '!./install --bin' } })
call g:AddPackage({ 'repo': 'junegunn', 'package': 'fzf.vim', 'config': { 'do': 'fzf#install()' } })
call g:AddPackage({ 'repo': 'prettier', 'package': 'vim-prettier', 'config': { 'do': '!yarn install' } })
call g:AddPackage({ 'repo': 'dense-analysis', 'package': 'ale' })
call g:AddPackage({ 'repo': 'neoclide', 'package': 'coc.nvim', 'config': { 'do': '!./install.sh' } })
call g:AddPackage({ 'repo': 'sheerun', 'package': 'vim-polyglot' })
call g:AddPackage({ 'repo': 'omnisharp', 'package': 'omnisharp-vim', 'enable': 1 })
call g:AddPackage({ 'repo': 'tpope', 'package': 'vim-vinegar' })
call g:AddPackage({ 'repo': 'vim-airline', 'package': 'vim-airline' })
call g:AddPackage({ 'repo': 'vim-airline', 'package': 'vim-airline-themes' })
call g:AddPackage({ 'repo': 'NLKNguyen', 'package': 'papercolor-theme' })
call g:AddPackage({ 'repo': 'gko', 'package': 'vim-coloresque' })

" ------------ Remaps  ------------ "

" Bind close file buffer to ctrl q
noremap <silent> <C-q> :bd<cr>
noremap <silent> <C-s> :call g:Save()<CR>:w<CR>

" Bind git fugitive manager to ctrl g
nnoremap <silent> <C-g> :tabedit<cr>:Git<cr>
" Bind search to ctrl f
nnoremap <silent> <C-f> /\c

" Bind quick line navigation
nnoremap H ^
nnoremap J 10j
nnoremap K 10k
nnoremap L $
vnoremap H ^
vnoremap J 10j
vnoremap K 10k
vnoremap L $

" Rebind popup navigation and confirmation
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<Up>"


function! g:Save()
    let auto_format_type_list = ['typescript', 'typescriptreact', 'javascript', 'javascriptreact']
    if index(auto_format_type_list, &ft) >= 0
        :CocCommand tsserver.organizeImports
        sleep 500m
        :Prettier
    endif
endfunction

" ------------ Options ------------ "

" Set the cursor hold to 1 second
set updatetime=1000
set signcolumn=yes
set history=400
set lazyredraw
set noerrorbells
set novisualbell
set wildignore=node_modules/**,.git/**,build/**,dist/**,*.temp,obj/**,bin/**
set nobackup
set nowritebackup
set completeopt=menu,noinsert,noselect,preview
set complete=t,.,w,b,u
set number

set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.
set shiftwidth=4    " Indents will have a width of 4
set softtabstop=4   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces

set background=light
set laststatus=2
colorscheme PaperColor

filetype plugin indent on

" ------------ Plugins ------------ "

if g:IsLoaded('fzf')
    nnoremap <C-p> :<C-u>FZF<cr>
    if executable('rg')
        let $FZF_DEFAULT_OPTS='--layout=reverse'
        let $FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git"'

        " Bind search in all files to F
        command! -bang -nargs=* Rg
          \ call fzf#vim#grep(
          \   'rg --column --line-number --no-heading --color=always --smart-case -g "!{node_modules,bin}/*" '.shellescape(<q-args>), 1,
          \   fzf#vim#with_preview(), <bang>0)
        nnoremap <silent> F :Rg<cr>
    endif
endif

if g:IsLoaded('ale')
    " Bind Alt-j, Alt-k to navigate between errors
    nnoremap <silent> <A-j> :ALENext<cr>
    nnoremap <silent> <A-k> :ALEPrevious<cr>

    let g:ale_sign_error = 'x'
    let g:ale_sign_warning = 'w'
    let g:ale_sign_column_always = 1

    " Note: I find that ale prettier works better so let it do it's thing
    " if possible. Otherwise fall back on the prettier plugin when prettier
    " is not installed locally or is not accessible.
    let g:ale_fixers = {
    \   '*': ['trim_whitespace'],
    \   'typescript': ['eslint', 'prettier'],
    \   'typescriptreact': ['eslint', 'prettier'],
    \   'yaml': []
    \}
    let g:ale_linters = {
    \   'cs': ['OmniSharp'],
    \   'typescript': ['eslint', 'prettier'],
    \   'typescriptreact': ['eslint', 'prettier']
    \}

    let g:ale_set_quickfix = 1
    let g:ale_fix_on_save = 1
endif

if g:IsLoaded('vim-airline')
    let g:airline#extensions#ale#enabled = 1
endif

if g:IsLoaded('vim-airline-themes')
    let g:airline_theme = 'papercolor'
endif

" These rules cause another save...
let g:EditorConfig_disable_rules = ['insert_final_newline', 'trim_trailing_whitespace']

if g:IsLoaded('coc.nvim')
    " Bind Crtl-k, Ctrl-j to navigate between errors
    nnoremap <silent> <C-j> :call CocAction('diagnosticNext')<cr>
    nnoremap <silent> <C-k> :call CocAction('diagnosticPrevious')<cr>

    " extensions
    let g:coc_global_extensions = [
    \ 'coc-spell-checker',
    \ 'coc-tsserver',
    \ 'coc-json',
    \ 'coc-snippets',
    \ 'coc-yaml',
    \ ]

    " options
    let g:coc_snippet_next = '<tab>'

    " Highlight symbol under cursor on CursorHold
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Use `:Format` for format current buffer
    command! -nargs=0 Format :call CocAction('format')

    " Use `:Fold` for fold current buffer
    command! -nargs=? Fold :call CocAction('fold', <f-args>)

    augroup cocformat
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        " Fix the color for info from yellow to brown
        autocmd ColorScheme * hi CocInfoSign ctermfg=Blue guifg=#ff922b
        " Fix the color for errors to red when a Reload occurs
        autocmd ColorScheme * hi CocErrorSign ctermfg=Red guifg=#ff0000
    augroup end

    " goto definition
    nmap <silent> gd <Plug>(coc-definition)
    " goto reference
    nmap <silent> gr <Plug>(coc-references)
    " goto implementation
    nmap <silent> <leader>gi <Plug>(coc-implementation)
    " rename current word
    nmap <silent> <leader>rn <Plug>(coc-rename)
    " format
    vmap <silent> <leader>f <Plug>(coc-format-selected)
    nmap <silent> <leader>f <Plug>(coc-format)
    " Fix autofix problem of current line
    nmap <silent> <leader>qf <Plug>(coc-fix-current)
    " Use leader-k for show documentation in preview window
    nnoremap <silent> <leader>k :call <SID>show_documentation()<cr>

    " quick fix menu
    vmap <silent> <leader><space> <Plug>(coc-codeaction-selected)
    nmap <silent> <leader><space> <Plug>(coc-codeaction)
endif

" Show documentation in preview window
function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
endfunction

if g:IsLoaded('omnisharp-vim')
    let g:OmniSharp_server_stdio = 1
    if g:IsLoaded('fzf')
        let g:OmniSharp_selector_ui = 'fzf'
    endif
    let g:OmniSharp_open_quickfix = 1
    let g:OmniSharp_highlight_types = 2
    if g:DetectOS() == 'wsl'
        let g:OmniSharp_translate_cygwin_wsl = 1
        let g:OmniSharp_server_path = '/mnt/c/OmniSharp/omnisharp-win-x64/OmniSharp.exe'
    endif


    " you'd be better of splitting off filetype specific config
    " to filetype files, see :h ftplugin
    au FileType cs nmap <buffer> <silent>
                \ gd
                \ <Plug>(omnisharp_go_to_definition)

    au FileType cs nmap <buffer> <silent>
                \ go
                \ <Plug>(omnisharp_find_members)

    au FileType cs nmap <buffer> <silent>
                \ gs
                \ <Plug>(omnisharp_find_symbols)

    au FileType cs nmap <buffer> <silent>
                \ <leader>rn
                \ <Plug>(omnisharp_rename)

    au FileType cs nmap <buffer> <silent>
                \ <leader>k
                \ <Plug>(omnisharp_documentation)

    au FileType cs nmap <buffer> <silent>
                \ gr
                \ <Plug>(omnisharp_find_usages)

    au FileType cs nmap <buffer> <silent>
                \ <leader>gi
                \ <Plug>(omnisharp_find_implementations)

    au FileType cs nmap <buffer> <silent>
                \ <leader><Space>
                \ <Plug>(omnisharp_code_actions)

    au FileType cs nmap <buffer> <silent>
                \ <leader>qf
                \ <Plug>(omnisharp_fix_usings)

    au FileType cs vnoremap <buffer> <silent>
                \ <leader><Space>
                \ :call OmniSharp#GetCodeActions('visual')<CR>
endif
