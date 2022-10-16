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
Plug 'wellle/context.vim'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/vim-easy-align'

" Plug 'nvim-treesitter/nvim-treesitter'
" Plug 'nvim-treesitter/nvim-treesitter-context'

" Any valid git URL is allowed
" Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Multiple Plug commands can be written in a single line using | separators
" Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" On-demand loading
" Plue 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
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

"----------------------------------------------------------------------
" Basic Options
"----------------------------------------------------------------------
let mapleader=" "
:colo desert
set hidden                " Allow buffer to go background without being saved
set list                  " Show invisible characters
set listchars=tab:>~,nbsp:_,trail:.
":set showmode (obsolete with vim-airline)
:set foldmethod=marker
:set path+=**
:set wildmenu
:set shortmess+=A
" set splitbelow            " Splits show up below by default
" set splitright            " Splits go to the right by default


" netrw
let g:netrw_banner=0
let g:netrw_browse_split=0
let g:netrw_altv=1
let g:netrw_liststyle=0
autocmd FileType netrw setl bufhidden=delete
"au BufNewFile,BufRead,BufReadPost *.sv set syntax=verilog
let NERDTreeShowHidden=1

" Search settings
:set hlsearch
set ignorecase  " Ignore casing of searches
set smartcase           "Be smart about case sensitivity when searching

" Tab settings
:set tabstop=4
:set softtabstop=4
:set shiftwidth=4
:set expandtab
:set autoindent
:set smartindent
:inoremap <S-Tab> <C-V><Tab>

" Tab completion settings
set wildmode=list:longest     " Wildcard matches show a list, matching the longest first
set wildignore+=.git,.hg,.svn " Ignore version control repos
set wildignore+=*.swp         " Ignore vim backups
set wildignore+=*/tmp/*,*.so,*.o,*.zip         " Ignore



" Home path
let g:vim_home_path = "~/nvim"

" Backup settings
execute "set directory=" . g:vim_home_path . "/swap"
execute "set backupdir=" . g:vim_home_path . "/backup"
execute "set undodir=" . g:vim_home_path . "/undo"
set backup
set undofile
set writebackup

" Line numbers
:set number relativenumber

" Always center cursor
:set so=999
"----------------------------------------------------------------------
" Key Mappings
"----------------------------------------------------------------------
" Remap a key sequence in insert mode to kick me out to normal
" mode. This makes it so this key sequence can never be typed
" again in insert mode, so it has to be unique.
inoremap jj <esc>

" Make navigating around splits easier
nnoremap <leader>wj <C-w>j
nnoremap <leader>wk <C-w>k
nnoremap <leader>wh <C-w>h
nnoremap <leader>wl <C-w>l
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
if has('nvim')
  " We have to do this to fix a bug with Neovim on OS X where C-h
  " is sent as backspace for some reason.
  nnoremap <BS> <C-W>h
endif

" Command to write as root if we dont' have permission
cmap w!! %!sudo tee > /dev/null %

:cabbr <expr> %% expand('%:p:h')

" Grep
":command! -nargs=1 GG lgrep! -rnI <f-args> **

" Make Ctags
:command! Tag !ctags -R .

" Let W do write, same as w
:command! W w

" Buffer management
nnoremap <leader>d   :bd<cr>

" Quitting
nnoremap <leader>q :q<cr>

" line number
nnorema <leader>n :set number! relativenumber!<cr>

" Get rid of search highlights
noremap <silent><leader>/ :nohlsearch<cr>

" CtrlP
nnoremap <leader>f :CtrlP <cr>
nnoremap <leader>b :CtrlPBuffer <cr>
nnoremap <leader>l :CtrlPLine<cr>
nnoremap <leader>] :CtrlPTag<cr>

" Copying filename
nmap gy :let @" = expand("%")<cr>

" Tabs
map <C-t> :tabnew<CR>
map <C-c> :tabclose<CR>
map <leader>t :tabnext<CR>

:map <F2> :vsplit<CR>
:map <F3> :lw<CR>
:map <F4> :e %%/ <CR>
":map <F4> :e. <CR>
":map <F5> :execute "noautocmd grep! -rnI " . expand("<cword>") . " **" <BAR> lw <CR>
:map <F5> :execute "noautocmd lgrep " . expand("<cword>") . "" <BAR> lw <CR>
:nnoremap <F6> :cd ..<CR> :pwd<CR>
:nnoremap <F7> :cd %:p:h<CR> :pwd<CR>
:nnoremap <F8> :set invpaste paste?<CR>
:set pastetoggle=<F8>
:map <F9> :bd<CR>


" templates
nnoremap ,class : -1read $HOME/.vim/class.cpp<CR>
nnoremap ,for : -1read $HOME/.vim/for_iter.cpp<CR>
nnoremap ,head : -1read $HOME/.vim/head.cpp<CR>
nnoremap ,right : -1read $HOME/.vim/copyright.cpp<CR>

" Braces
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" vim-easy-align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)


"----------------------------------------------------------------------
" Ripgrep from vim
"----------------------------------------------------------------------
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
nnoremap <leader>g :silent lgrep<Space>
nnoremap <silent> [f :lprevious<CR>
nnoremap <silent> ]f :lnext<CR>
set grepformat=%f:%l:%c:%m,%f:%l:%m

"----------------------------------------------------------------------
" Autocommands
"----------------------------------------------------------------------
" Clear whitespace at the end of lines automatically
autocmd BufWritePre * :%s/\s\+$//e

" Don't fold anything.
autocmd BufWinEnter * set foldlevel=999999

" Disable AutoComments
autocmd VimEnter * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
au BufNew,BufRead * setl fo-=orc

" Automatic toggle with relative line number
":set number relativenumber
" :augroup numbertoggle
" :  autocmd!
" :  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
" :  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
" :augroup END

augroup netrw_mapping
    autocmd!
    autocmd filetype netrw call NetrwMapping()
augroup END

function! NetrwMapping()
    nmap <buffer> h -
    nmap <buffer> <left> -
    nmap <buffer> l <CR>
    nmap <buffer> <right> <CR>
endfunction

"----------------------------------------------------------------------
" Plugin settings
"----------------------------------------------------------------------
" CtrlP
let g:ctrlp_max_files = 10000
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn)$',
    \ 'file': '\v\.(exe|so|dll)$',
    \ 'link': 'some_bad_symbolic_links',
    \ }
" let g:ctrlp_user_command = 'find %s -type f'        " MacOSX/Linux
