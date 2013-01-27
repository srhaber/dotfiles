" ~/.vimrc
" vim:set ts=2 sts=2 sw=2 expandtab:

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PATHOGEN
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
execute pathogen#infect()
filetype plugin indent on

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BASIC EDITING CONFIGURATION
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set autoindent    " Preserve current indent on new line
set expandtab     " Convert all tabs to spaces
set hlsearch      " Highlight search terms
set ignorecase    " Ignore case while searching
set incsearch     " Jump to matches while typing
set number        " Show line numbers
set ruler         " Show current line,col
set shiftwidth=2  " Set 2-column shifts
set tabstop=2     " Set 2-column indents
set textwidth=0   " Don't wrap words
set wrap          " Wrap long lines

syntax on         " Syntax highlighting for vim

let mapleader=","

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DISABLE ARROW KEYS (FOR TRAINING)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>
