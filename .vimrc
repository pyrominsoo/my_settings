set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" ===================
" my plugins here
" ===================
Plugin 'airblade/vim-gitgutter'
Plugin 'itchyny/lightline.vim'
Plugin 'preservim/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'

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

:colo desert
:set number
:set tabstop=4
:set shiftwidth=4
:set expandtab
:set autoindent
:inoremap <S-Tab> <C-V><Tab>
:set hlsearch
:set tags+=tags;$HOME
:map <F2> :NERDTreeToggle %<CR>
:map <F3> :e. <CR>
:cabbr <expr> %% expand('%:p:h')
:map <F4> :e %%/ <CR>
:map <F5> :execute "noautocmd vimgrep /" . expand("<cword>") . "/j **" <BAR> cw <CR> 
:nnoremap <F8> :set invpaste paste?<CR>
:set pastetoggle=<F8>
:set showmode
:map <F9> :bd<CR>
:set runtimepath^=~/.vim/bundle/ag
:let g:ag_working_path_mode="r"
:set foldmethod=marker
:set nocompatible
:syntax enable
":filetype plugin on
:set path+=**
:set wildmenu
:command! MakeTags !ctags -R .
let g:netrw_banner=0
let g:netrw_browse_split=0
let g:netrw_altv=1
let g:netrw_liststyle=3
nnoremap ,cpp :-1read $HOME/.vim/.skeleton.cpp<CR>
nnoremap ,v :-1read $HOME/.vim/.skeleton.v<CR>
nnoremap ,tb :-1read $HOME/.vim/.skeleton.tb<CR>
nnoremap ,reg :-1read $HOME/.vim/.reg.v<CR>
nnoremap ,comb : -1read $HOME/.vim/.comb.v<CR>
nnoremap ,fsm : -1read $HOME/.vim/.fsm.v<CR>
nnoremap ,for : -1read $HOME/.vim/.for.v<CR>
nnoremap ,zim : -1read $HOME/.vim/.skeleton.zim<CR>
set listchars=tab:>~,nbsp:_,trail:.
autocmd FileType netrw setl bufhidden=delete
au BufNewFile,BufRead,BufReadPost *.sv set syntax=verilog
let NERDTreeShowHidden=1

inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O
