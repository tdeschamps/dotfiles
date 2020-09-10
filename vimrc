syntax on
filetype plugin indent on
filetype plugin on
set termguicolors
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set rtp+=/usr/local/opt/fzf

let g:fzf_preview_window = 'right:60%'

" keep the current selection when indenting (thanks cbus)
vnoremap < <gv
vnoremap > >gv

" adds a vertical highlight on cursor (useful for indentation based markups)
set cursorcolumn

" you can change buffer without saving
set hidden

" Buffers
noremap <S-tab> :bp!<CR>
noremap <tab> :bn!<CR>

" Tabs
noremap <C-Right> :tabnext<CR>
noremap <C-Left> :tabprevious<CR>

" Remove scrollbars
set guioptions-=r
set guioptions-=L

" shift+R on paragraph resets textwidth on selection
nnoremap R gq}

" Show tabs
set list

" Define characters for 'tabs' and 'end of line'
set listchars=tab:▸\ ,eol:¬

" Yank text to the OS X clipboard
noremap <leader>y "*y
noremap <leader>yy "*Y

" Preserve indentation while pasting text from the OS X clipboard
noremap <leader>p :set paste<CR>:put  *<CR>:set nopaste<CR>

" sachet's vimrc
set nocompatible

" set statusline=%<\ %n:%f\ %m%r%y%=%-35.(line:\ %l\ of\ %L,\ col:\ %c%V\ (%P)%)
" filetype plugin indent on

" syntax on
set number
set hlsearch
set showmatch
set autoindent
set history=1000
set cursorline
if has("unnamedplus")
  set clipboard=unnamedplus
elseif has("clipboard")
  set clipboard=unnamed
endif

set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2

" Nerdtree

" NERDtree toggle
map <C-n> :NERDTreeToggle<CR>

" Don't open if it's a file
function! StartUp()
  if 0 == argc()
    NERDTree
  end
endfunction

autocmd VimEnter * call StartUp()
let NERDTreeShowBookmarks=1
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=0
let NERDTreeMouseMode=2
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.pyc','\~$','\.swo$','\.swp$','\.git','\.hg','\.svn','\.bzr']
let NERDTreeKeepTreeInNewTab=1
let g:nerdtree_tabs_open_on_gui_startup=0

" HTML indentation
let g:html_indent_inctags = "html,body,head,tbody"
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"

" Solarized
set background=dark
colorscheme solarized8
" colorscheme gruvbox
let g:gruvbox_contrast_dark = 'hard'

" powerline
"set rtp+=/Users/thomasdeschamps/.pyenv/versions/3.7.0/lib/python3.7/site-packages/powerline/bindings/vim
"set laststatus=2
set guifont="Hack Nerd"

" creates the swapfiles in /tmp
set dir=/tmp

" Auto-reload modified files (with no local changes)
set autoread

" Rainbow parentheses
let g:rainbow_active = 1

" vim-instant-markdown
let g:instant_markdown_slow = 1
let g:instant_mardown_autostart = 0

" vim-commentary

" set gitcommit commentstring to '#'
autocmd FileType gitcommit set commentstring=#%s

" reset timeout on esc key (ttimeoutlength) but keep timeout on '\' leader key (timeoutlen)
set timeoutlen=1000 ttimeoutlen=0

" Swap iTerm2 cursors in vim insert mode when using tmux
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" use the silver searcher (AG) for ctrlp
set grepprg=rg\ --color=never
let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
let g:ctrlp_use_caching = 0

  " Airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_theme='simple'
let g:airline#extensions#ale#enabled = 1
" git grep inside vim using AG
" set grepprg=ag\ --nogroup
" nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Add preview when searching for files
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview', 'bat --style=numbers --color=always --line-range :500 {}']}, <bang>0)

" nerdcommenter
" " Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
let g:ale_fixers = { '*': ['remove_trailing_lines', 'trim_whitespace'] }
let g:ale_fixers = {
\  '*': ['remove_trailing_lines', 'trim_whitespace'],
\  'javascript': ['prettier', 'eslint'],
\  'json': ['prettier'],
\  'ruby': ['rubocop'],
\  'rust': ['rustfmt'],
\  'typescript': ['prettier', 'eslint'],
\}
let b:ale_linters = {
\  'rust': ['rustfmt'],
\}
let g:ale_completion_enabled = 1
let g:ale_fix_on_save = 1

set wildignore=*/node_modules/*,*/target/*,*/log/*,*/tmp/*,*/.bundle/*
