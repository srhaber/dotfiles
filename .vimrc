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
set cmdheight=1
set expandtab               " Convert all tabs to spaces
set hidden                  " Allow unsaved background buffers
set history=10000
set hlsearch                " Highlight search terms
set ignorecase smartcase    " Case-sensitivity when search has uppercase chars
set incsearch               " Jump to matches while typing
set laststatus=2
set number                  " Show line numbers
set numberwidth=4
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

  " syntax of these languages is fussy over tabs vs spaces
  autocmd filetype make setlocal ts=8 sts=8 sw=8 noexpandtab

  autocmd BufNewFile,BufRead *.god set filetype=ruby
  autocmd BufNewFile,BufRead *.md set filetype=markdown

  " Strip trailing whitespace before saving certain files
  autocmd BufWritePre .vimrc,*.rb,*.erb,*.html,*.css,*.scss,*.js,*.coffee,*.conf,*.god,*.py,*.c :call <SID>StripTrailingWhitespaces()

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
nmap <leader>/ \\\

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

