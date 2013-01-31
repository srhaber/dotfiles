" ~/.vimrc
" vim:set ts=2 sts=2 sw=2 expandtab:
" Inspired by https://github.com/garybernhardt/dotfiles/blob/master/.vimrc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PATHOGEN
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
execute pathogen#infect()
execute pathogen#helptags()
filetype plugin indent on

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BASIC EDITING CONFIGURATION
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
set autoindent              " Preserve current indent on new line
set backspace=indent,eol,start
set cmdheight=2
set cursorline
set expandtab               " Convert all tabs to spaces
set hidden                  " Allow unsaved background buffers
set history=10000
set hlsearch                " Highlight search terms
set ignorecase smartcase    " Case-sensitivity when search has uppercase chars
set incsearch               " Jump to matches while typing
set laststatus=2
set number                  " Show line numbers
set numberwidth=4
set pastetoggle=<leader>p
set ruler                   " Show current line,col
set scrolloff=3             " Prevent cursor from reaching screen edges
set shell=bash              " Vim doesn't work well with ZSH, it seems
set shiftwidth=2            " Set 2-column shifts
set showcmd
set showmatch
set showtabline=2
set softtabstop=2
set switchbuf=useopen
set tabstop=2               " Set 2-column indents
set textwidth=0             " Don't wrap words
set wrap                    " Wrap long lines
set wildmode=longest,list
set wildmenu                " Bash-style tab completion

" Synax highlighting
syntax on

let mapleader=","

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DISABLE ARROW KEYS (FOR TRAINING)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLOR
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256        " 256 colors
set background=dark
color twilight256

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" HIGHLIGHTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi CursorLine guifg=NONE guibg=#121212 gui=NONE ctermfg=NONE ctermbg=234 cterm=NONE

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INVISIBLES
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" http://vimcasts.org/episodes/show-invisibles/
" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" AUTOCOMMANDS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" http://vimcasts.org/episodes/whitespace-preferences-and-filetypes/
" Only do this part when compiled with support for autocommands
augroup vimrcEx
  " Clear all autocmds in the group
  autocmd!

  " enable file type detection
  filetype on

  " Jump to last cursor position unless it's invalid or in an event handler
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " syntax of these languages is fussy over tabs vs spaces
  autocmd filetype make setlocal ts=8 sts=8 sw=8 noexpandtab

  autocmd BufNewFile,BufRead Gemfile,*.god,*.rake set filetype=ruby
  autocmd BufNewFile,BufRead *.md set filetype=markdown

  " Strip trailing whitespace before saving certain files
  autocmd BufWritePre .vimrc,Gemfile,*.rb,*.erb,*.html,*.css,*.scss,*.js,*.coffee,*.conf,*.god,*.rake,*.py,*.c :call <SID>StripTrailingWhitespaces()

  " TODO Prevent cursor from jumping to top after save
  " Auto-source .vimrc after saving
  " autocmd BufWritePost .vimrc source $MYVIMRC
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STRIP TRAILING WHITESPACE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" http://vimcasts.org/episodes/tidying-whitespace/
function! <SID>StripTrailingWhitespaces()
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  %s/\s\+$//e
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

nnoremap <leader>s :call StripTrailingWhitespaces()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MISC KEY MAPS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Easy toggling of splits
nnoremap <leader>w <c-w>w

" Clear the search buffer when hitting return
function! MapCR()
  nnoremap <cr> :nohlsearch<cr>
endfunction
call MapCR()

" Easy switching to alternate file
nnoremap <leader><leader> <c-^>

" Easy editing of .vimrc
nmap <leader>c :tabedit $MYVIMRC<cr>

" Easy commenting (relies on vim-commentary plugin)
map <leader>/ \\\

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OPEN FILES IN DIRECTORY OF CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COMMAND-T
" Always reload file list to avoid getting stale
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>f :CommandTFlush<cr>\|:CommandT<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING CODE AND TESTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>r :call RunCode()<cr>
map <leader>t :call RunTests()<cr>

function! RunCode()
  let filename = expand("%")

  if match(filename, '\.rb$') >= 0
    let cmd = "ruby -I./lib " . filename
  else
    return
  end

  call RunCommand(cmd)
endfunction

function! RunTests()
  let in_test_file = match(expand("%"), '\(_spec.rb\|_test.rb\)$') >= 0

  if in_test_file
    " Save test file in tabpage variable
    let t:filename = @%
  elseif !exists("t:filename")
    return
  end

  if match(t:filename, '_spec.rb$') >= 0
    let cmd = "rspec -I./spec --color " . t:filename
  elseif match(t:filename, '_test.rb$') >= 0
    let cmd = "ruby -I./test " . t:filename
  else
    return
  end

  call RunCommand(cmd)
endfunction

function! RunCommand(cmd)
  :w
  :silent !clear
  exec ":!echo $ " . a:cmd . " && " . a:cmd
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RENAME CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>
