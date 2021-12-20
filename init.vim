
set nocompatible              
filetype off                  
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()            " required
Plugin 'VundleVim/Vundle.vim'  " required

" ===================
" my plugins here
" ===================
Plugin 'airblade/vim-gitgutter'
Plugin 'itchyny/lightline.vim'
Plugin 'preservim/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'

" ===================
" end of plugins
" ===================
call vundle#end()               " required
filetype plugin indent on       " required


:set number
:set tabstop=4
:set shiftwidth=4
:set expandtab
:set autoindent
:set smartindent
:inoremap <S-Tab> <C-V><Tab>
:set hlsearch
:map <F2> :NERDTreeToggle %<CR>
:map <F3> :e. <CR>
:cabbr <expr> %% expand('%:p:h')
:map <F4> :e %%/ <CR>
:map <F5> :execute "noautocmd vimgrep /" . expand("<cword>") . "/j **" <BAR> cw <CR> 
:nnoremap <F7> :cd %:h<CR>
:nnoremap <F8> :set invpaste paste?<CR>
:set pastetoggle=<F8>
:set showmode
:map <F9> :bd<CR>
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
