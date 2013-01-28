" ~/.vimrc
" vim:set ts=2 sts=2 sw=2 expandtab:
" Inspired by https://github.com/garybernhardt/dotfiles/blob/master/.vimrc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PATHOGEN
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
execute pathogen#infect()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BASIC EDITING CONFIGURATION
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
set scrolloff=3
set shiftwidth=2            " Set 2-column shifts
set showcmd
set showmatch
set showtabline=2
set softtabstop=2           
set switchbuf=useopen
set tabstop=2               " Set 2-column indents
set textwidth=0             " Don't wrap words
set wrap                    " Wrap long lines
set wildmenu

filetype plugin indent on

syntax on         " Syntax highlighting for vim

let mapleader=","

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DISABLE ARROW KEYS (FOR TRAINING)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLOR
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256        " 256 colors
set background=dark
color twilight256

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INVISIBLES
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" http://vimcasts.org/episodes/show-invisibles/
" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" AUTOCOMMANDS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" http://vimcasts.org/episodes/whitespace-preferences-and-filetypes/
" Only do this part when compiled with support for autocommands
if has("autocmd")
  augroup vimrcEx
    " Clear all autocmds in the group
    autocmd!

    " enable file type detection
    filetype on
     
    " syntax of these languages is fussy over tabs vs spaces
    autocmd filetype make setlocal ts=8 sts=8 sw=8 noexpandtab
     
    autocmd BufNewFile,BufRead *.god setfiletype ruby
    autocmd BufNewFile,BufRead *.md setfiletype markdown
  augroup END
endif

