execute pathogen#infect()
execute pathogen#helptags()
filetype plugin indent on

" From /etc/vimrc
if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

set nocompatible	" Use Vim defaults (much better!)
set bs=indent,eol,start		" allow backspacing over everything in insert mode
set viminfo='20,\"50	" read/write a .viminfo file, don't store more
			" than 50 lines of registers
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time

" Only do this part when compiled with support for autocommands
if has("autocmd")
  augroup redhat
  autocmd!
  " In text files, always limit the width of text to 78 characters
  autocmd BufRead *.txt set tw=78
  autocmd BufEnter * execute "chdir ".escape(expand("%:p:h"), ' ')
  " Remove any trailing whitespace that is in the file
  autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
  " don't write swapfile on most commonly used directories for NFS mounts or USB sticks
  autocmd BufNewFile,BufReadPre /media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp
  " start with spec file template
  autocmd BufNewFile *.spec 0r /usr/share/vim/vimfiles/template.spec
  augroup END
endif

if has("cscope") && filereadable("/usr/bin/cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add cscope.out
   " else add database pointed to by environment
   elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
   endif
   set csverb
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

filetype plugin on

if &term=="xterm"
     set t_Co=8
     set t_Sb=%dm
     set t_Sf=%dm
endif

" Custom vimrc
" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"

filetype indent plugin on
filetype on " Automatically detect file types.
syntax enable
set cf " Enable error files & error jumping.
set clipboard+=unnamed " Yanks go on clipboard instead.
set timeoutlen=250 " Time to wait after ESC (default causes an annoying delay)

" Formatting
set ts=2 " Tabs are 2 spaces
set shiftwidth=2 " Tabs under smart indent
set nocp incsearch

set formatoptions=tcqr
set smarttab
set expandtab
set smartindent

" Visual
set showmatch " Show matching brackets.
set mat=5 " Bracket blinking.
" Show $ at end of line and trailing space as ~
set lcs=tab:\ \ ,eol:$,trail:~,extends:>,precedes:<
set noerrorbells " No noise.
set laststatus=2 " Always show status line.
set background=dark

set hidden
set wildmenu
set showcmd
set hlsearch
set ignorecase
set smartcase
set backspace=indent,eol,start
set nostartofline
set confirm
set visualbell
set cmdheight=2
set notimeout ttimeout ttimeoutlen=200
set magic
nnoremap <CR> :noh<CR><CR>
set t_Co=256
set encoding=utf8
set ffs=unix,dos,mac
set nobackup
set nowb
set noswapfile

" Toggle paste mode on/off with F6
set pastetoggle=<F6>
set paste

map <C-l> <C-W>l
map <C-j> <C-W>j
map <C-h> <C-W>h
map <C-k> <C-W>k
map <C-n>  :set invnu<CR>
colorscheme Tomorrow-Night

