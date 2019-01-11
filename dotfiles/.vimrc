"" =================
""  INIT
"" =================

set encoding=utf-8

" leader (to be set before plugin configs)
let mapleader = "\<Space>"

"" =================
""  PLUGINS
"" =================

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
let s:Include_path = expand('$HOME') . '/.vim/bundle/'
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

" = Git integration =
Plugin 'tpope/vim-fugitive'
ca Gs Gstatus
nnoremap <leader>gs :silent! Gstatus<CR>
nnoremap <leader>gd :silent! Gdiff<CR>
nnoremap <leader>gb :silent! Gblame<CR>
nnoremap <leader>gp :silent! Git push<CR>
nnoremap <leader>gy :silent! Git pull<CR>
nnoremap <leader>gz :silent! Git stash<CR>
nnoremap <leader>gl :silent! Glog! --<CR>:copen<CR>

Plugin 'tpope/vim-git'
Plugin 'gregsexton/gitv'
Plugin 'airblade/vim-gitgutter'
Plugin 'kablamo/vim-git-log'

" = custom statusline =
set laststatus=2

" = CtrlP file, buffer, ... finder =
Plugin 'ctrlpvim/ctrlp.vim'
let g:ctrlp_map = '<leader>p'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_switch_buffer = 'ET'
let g:ctrlp_custom_ignore = {
      \ 'dir': 'node_modules\\',
      \ 'file': '\~$'
      \ }
nnoremap <leader>b :CtrlPBuffer<CR>
nnoremap <leader>m :CtrlPMRU<CR>
nnoremap <leader>l :CtrlPLine<CR>
nnoremap <leader>P :CtrlPMixed<CR>

" = File explorer =
Plugin 'scrooloose/nerdtree'
let g:NERDTreeChDirMode=1
let NERDTreeCascadeOpenSingleChildDir=1
nnoremap <leader>n :NERDTree<CR>

Plugin 'jistr/vim-nerdtree-tabs'
let g:nerdtree_tabs_open_on_gui_startup=0
let g:nerdtree_tabs_open_on_new_tab = 1
nnoremap <silent> ¬ :NERDTreeTabsToggle<CR>

"" ==== MOVEMENT ====
" = Easy and fast movement =
Plugin 'Lokaltog/vim-easymotion'
let g:EasyMotion_leader_key = '<leader>'
map <leader>e <Plug>(easymotion-prefix)
map <leader>ew <Plug>(easymotion-bd-wl)
map <leader>eW <Plug>(easymotion-bd-Wl)
map <leader>ej <Plug>(easymotion-bd-jk)
map <leader>ek <Plug>(easymotion-bd-jk)

" Bi-directional find motion
" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap <leader>es <Plug>(easymotion-s)
nmap <leader>e/ <Plug>(easymotion-sn)

" Turn on case sensitive feature
let g:EasyMotion_smartcase = 1

let g:EasyMotion_keys = 'abcdfghijklmnoprstuvxyzqwe'
let g:EasyMotion_do_shade = 1

" = Change surrounding delimiters =
Plugin 'tpope/vim-surround'

" = Repeat plugin commands with . =
Plugin 'tpope/vim-repeat'

"" ==== LANGUAGE/SYNTAX ====

" = Syntax checking =
Plugin 'vim-syntastic/syntastic'

" = Language syntax =
Plugin 'jelera/vim-javascript-syntax'
Plugin 'othree/javascript-libraries-syntax.vim'
Plugin 'garyburd/go-explorer'
Plugin 'fatih/vim-go'
Plugin 'google/vim-jsonnet'

filetype off

" All of your Plugins must be added before the following line
call vundle#end()            " required

"" =================
""  UI CONFIG
"" =================

" enable mouse
set mouse=a

" remove splash screen
" set shortmess+=Is

" syntax highlighting
syntax on

" display incomplete commands
set showcmd

" split windows to the right
" not using splitbelow
set splitright

" visual autocomplete for command menu
set wildmenu

" Command <Tab> completion, longest common part, then all.
set wildmode=longest:full,full

" don't use preview window for completion
set completeopt-=preview

" don't redraw during macros
set lazyredraw

" show line numbers
set number

" Hide GUI tabline
set go-=e

" if a file is changed outside of vim, automatically reload it without asking
set autoread

" allow backspacing over everything
set backspace=2

" Remove error bells
set noerrorbells visualbell t_vb=
augroup ErrorBells
  au!
  autocmd GUIEnter * set visualbell t_vb=
augroup END

" when scrolling, keep cursor 10 lines away from screen border
set scrolloff=20

" remove | characters in window borders
set fillchars+=vert:\     " whitespace needed

" wrap long lines
set wrap

" switch to existing buffer if file exists
set switchbuf=useopen,usetab

" hide buffers when not shown
set hidden

" open diffs in vertical split, show filler lines
set diffopt=vertical,filler

" jump to last known cursor position when file is opened
augroup FileOpen
  au!
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
augroup END

"" =================
""  WHITESPACE
"" =================

" set indentation
set tabstop=2
set expandtab
set shiftwidth=2
set softtabstop=2
set smartindent
set autoindent

" Show trailing whitespace
set list listchars=tab:»·,trail:·

" function for cleaning trailing whitespace
nnoremap <silent> <F10> :call RemoveWhiteSpace()<CR>

" auto-clean trailing whitespace on write
augroup RemoveWhiteSpace
  au!
  autocmd BufWrite * :call <SID>RemoveWhiteSpace()
augroup END

function! s:RemoveWhiteSpace()
  let save_view = winsaveview()
  if exists(':keeppatterns')
    keeppatterns %s/\s\+$//e
  endif
  call winrestview(save_view)
endfunction


" move cursor to middle of line
nnoremap gm :call cursor(0, strlen(getline('.'))/2)<CR>

"" =================
""  SPLASHSCREEN
"" =================

let g:splash_screen_loaded = 0

let g:splash_screen_file = '~\.vim\vim_ANSI.splash'

augroup splashscreen
  au!
  autocmd VimEnter * call SplashScreen()
augroup END

function! RemoveSplashScreen()
  if g:splash_screen_loaded
    au! splashscreen
    au! removesplashscreen
    au! resizesplashscreen
    silent! Bdelete! 1
  else
    let g:splash_screen_loaded = 1
    nnoremap <silent> <buffer> q :q<CR>
    nnoremap <silent> <buffer> v :e $MYVIMRC<CR>
    nnoremap <silent> <buffer> m :CtrlPMRU<CR>
  endif
endfunction

let g:splash_screen_text =
\ "   ____     _       U  ___ u\n" .
      \ "  |  _\"\\   |\"|       \\/\"_ \\/__        __\n" .
      \ " /| | | |U | | u     | | | |\\\"\\      /\"/\n" .
      \ " U| |_| |\\\\| |/__.-,_| |_| |/\\ \\ /\\ / /\\\n" .
      \ "  |____/ u |_____|\\_)-\\___/U  \\ V  V /  U\n" .
      \ "   |||_    //  \\\\      \\\\  .-,_\\ /\\ /_,-.\n" .
      \ "  (__)_)  (_\")(\"_)    (__)  \\_)-'  '-(_/\n" .
      \ "\n" .
      \ "Vim $VIMVERSION\n".
      \ "\n".
      \ "v to edit .vimrc\n".
      \ "q to quit\n".
      \ "m to fuzzy search for file from this root\n"

function! SplashScreen()
  if !argc()
    setl
          \ nonumber
          \ nocursorline
          \ nocursorcolumn
          \ buftype=nofile
          \ bufhidden=wipe
          \ nobuflisted
          \ nolist
          \ nowrap
    let status_line_command = 'setl statusline=' . escape($VIMRUNTIME, ' \/')
    exe status_line_command
    if exists('g:splash_screen_file') && filereadable(expand(g:splash_screen_file))
      let g:splash_screen_file_text = join(readfile(expand(g:splash_screen_file)), "\n")
      put =g:splash_screen_file_text
    elseif exists('g:splash_screen_text')
      put =g:splash_screen_text
    else
      put =g:splash_screen_default
    endif
    silent! call RemoveWhiteSpace()
    let maxcol = 0
    let lnum = 1
    while lnum <= line("$")
      call cursor(lnum, 0)
      let countcol = Countcol(lnum)
      if countcol > maxcol
        let maxcol = countcol
      endif
      let lnum += 1
    endwhile
    let patch_no = GetPatchNo()
    let version_no = version[0] . '.' . substitute(version[1:-1], '0\+', '', '') . (patch_no ? '.' . patch_no : '')
    exe 'silent file Vim\' version_no
    silent! /\$VIMVERSION/
    call histdel('/', -1)
    exe 's/\$VIMVERSION/'version_no'/e'
    call histdel('/', -1)
    let align_spaces = repeat(' ', (maxcol - col('$'))/2)
    exe 'normal! I' align_spaces
    let old_a = @a
    silent exe 'normal! gg"ayG'
    let g:splash_screen_contents = @a
    let @a = old_a
    augroup resizesplashscreen
      autocmd VimResized <buffer> call JustifyContents()
    augroup END
    call JustifyContents()
    " AnsiEsc
  endif
  au! splashscreen
endfunction

function! Countcol(line)
  let line = getline(a:line)
  let line = substitute(line, '\[\(\d\|;\)\{-}m', '', 'g')
  return strdisplaywidth(line)
endfunction

function! AuRemoveSplashScreen()
  augroup removesplashscreen
    autocmd TextChanged,TabLeave,WinEnter,CursorMoved,InsertEnter * call RemoveSplashScreen()
  augroup END
endfunction

function! GetPatchNo()
  let major_version = v:version/100
  let minor_version = v:version - major_version*100
  let patch_no = 999
  while patch_no > 0
    if has("patch" . patch_no)
      break
    endif
    let patch_no -= 1
  endwhile
  return patch_no
endfunction

function! JustifyContents()
  silent! au! removesplashscreen
  let save_view = winsaveview()
  exe 'normal! gg"_dG'
  put =g:splash_screen_contents
  let maxcol = 0
  let lnum = 1
  while lnum <= line("$")
    call cursor(lnum, 0)
    let countcol = Countcol(lnum)
    if countcol > maxcol
      let maxcol = countcol
    endif
    let lnum += 1
  endwhile
  let lnum = 1
  let old_search = @/
  exe '%s/^/'(repeat(' ', (winwidth(0) - maxcol)/2))'/'
  let @/ = old_search
  call cursor(1, 0)
  let lines_to_add = max([0, winheight(0) - line('$')])/2
  exe ('normal! ' . lines_to_add . 'O')
  call cursor(line('$'), 1)
  exe ('normal! ' . (winheight(0) - line('$')) . 'o')
  silent! call RemoveWhiteSpace()
  call winrestview(save_view)
  call AuRemoveSplashScreen()
endfunction

"" =================
""  OTHERS
"" =================
filetype plugin on
set nolist

" easy vimrc handling
nnoremap <leader>v :e $MYVIMRC<cr>
nnoremap <leader>s :source $MYVIMRC<cr>

"" =================
""  relative number
"" =================
set relativenumber
function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
  else
    set relativenumber
  endif
endfunc

nnoremap <F2> :call NumberToggle()<cr>
nnoremap <F9> :setl noai nocin nosi inde=<CR>

" Useful for copying things from vim to windows clipboard in WSL
map <Leader>b :call system("/mnt/c/Windows/System32/clip.exe", @0)<CR>
vmap <Leader>y y<Leader>b

" Use for when using linux instead
" vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
