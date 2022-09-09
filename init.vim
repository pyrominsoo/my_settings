set nocompatible              
filetype off                  

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'
Plug 'wellle/context.vim'
Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'lukas-reineke/indent-blankline.nvim'
" Plug 'nvim-treesitter/nvim-treesitter'
" Plug 'nvim-treesitter/nvim-treesitter-context'

" Any valid git URL is allowed
" Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Multiple Plug commands can be written in a single line using | separators
" Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" On-demand loading
" Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-default branch
" Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
" Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
" Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Unmanaged plugin (manually installed and updated)
" Plug '~/my-prototype-plugin'

" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting


":colo desert
:set number
:set tabstop=4
:set shiftwidth=4
:set expandtab
:set autoindent
:set smartindent
:inoremap <S-Tab> <C-V><Tab>
:set hlsearch
" :map <F2> :NERDTreeToggle %<CR>
:map <F2> :browse oldfiles <CR>
:map <F3> :NERDTree <CR>
:cabbr <expr> %% expand('%:p:h')
:map <F4> :e %%/ <CR>
":map <F4> :e. <CR>
:map <F5> :execute "noautocmd grep! -rnI " . expand("<cword>") . " **" <BAR> cw <CR> 
:nnoremap <F6> :cd ..<CR> :pwd<CR>
:nnoremap <F7> :cd %:p:h<CR> :pwd<CR>
:nnoremap <F8> :set invpaste paste?<CR>
:set pastetoggle=<F8>
:set showmode
:map <F9> :bd<CR>
:set foldmethod=marker
:set nocompatible
":syntax enable
":filetype plugin on
:set path+=**
:set wildmenu
:command! MakeTags !ctags -R .
:command! -nargs=1 GG grep! -rnI <f-args> **
let g:netrw_banner=0
let g:netrw_browse_split=0
let g:netrw_altv=1
let g:netrw_liststyle=3
" nnoremap ,cpp :-1read $HOME/.vim/.skeleton.cpp<CR>
" nnoremap ,v :-1read $HOME/.vim/.skeleton.v<CR>
" nnoremap ,tb :-1read $HOME/.vim/.skeleton.tb<CR>
" nnoremap ,reg :-1read $HOME/.vim/.reg.v<CR>
" nnoremap ,comb : -1read $HOME/.vim/.comb.v<CR>
" nnoremap ,fsm : -1read $HOME/.vim/.fsm.v<CR>
" nnoremap ,for : -1read $HOME/.vim/.for.v<CR>
" nnoremap ,zim : -1read $HOME/.vim/.skeleton.zim<CR>
nnoremap ,cls : -1read $HOME/.vim/class.cpp<CR>
nnoremap ,for : -1read $HOME/.vim/for_iter.cpp<CR>
nnoremap ,foi : -1read $HOME/.vim/for_i.cpp<CR>
nnoremap ,fnc : -1read $HOME/.vim/func.cpp<CR>
set listchars=tab:>~,nbsp:_,trail:.
autocmd FileType netrw setl bufhidden=delete
"au BufNewFile,BufRead,BufReadPost *.sv set syntax=verilog
let NERDTreeShowHidden=1

inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O
