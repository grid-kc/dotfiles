" ----------------------------
" Other source files
" ----------------------------
set runtimepath+=./vim-scripts

" brackets.vim has the code to auto-bracket things
runtime brackets.vim

" ----------------------------
" PLUGINS
" ----------------------------
"  Plugins are managed by Vundle -- if Vundle isn't installed, then
"  don't bother with setting it up
set nocompatible
if filereadable(expand('~/.vim/bundle/Vundle.vim/README.md'))
  filetype off

  set rtp+=~/.vim/bundle/Vundle.vim
  call vundle#begin()

  Plugin 'VundleVim/Vundle.vim'

  Plugin 'scrooloose/NERDTree'

  Plugin 'tpope/vim-fugitive'

  Plugin 'mtth/scratch.vim'

  " Solarized plugin
"  Plugin 'altercation/vim-colors-solarized'
"  syntax enable
"  set background=dark
"  colorscheme solarized

  call vundle#end()
endif
filetype plugin on
colorscheme desert
" ----------------------------
" Settings
" ----------------------------
" Why is this not a default?
syntax on
" Set reasonable tabbing behavior
set expandtab tabstop=2 shiftwidth=2 shiftround
" Turn on line numbers
set number
" Turn on positioning in bottom right
set ruler
" Turn on search highlighting
set hlsearch
" Make vi search behave like EMACS's I-Search
set incsearch

" Logical, case-insensitive searching
set ignorecase
set smartcase

" Clipboard integration
set clipboard=unnamed

" Splits open where I expect them to
set splitbelow splitright

" Simple smart indentation
set autoindent

" Show number of lines selected in Visual
set showcmd

" ----------------------------
" Useful Key Mappings
" ----------------------------

let mapleader="\<Space>"

" Toggle between relative and absolute numbering
nnoremap <silent> <Leader>n :call ToggleNumbering()<CR>

" Open the NERDTree
nnoremap <silent> <Leader>o :NERDTreeToggle<CR>

" Quicker saves
nnoremap <silent> <Leader>w :w<CR>

" Backwards deletion
nnoremap <C-b> db

" Switch tabs
nnoremap <Leader>h gT
nnoremap <Leader>l gt

" Quit
nnoremap <silent> <Leader>q :q<CR>

" Force quit
nnoremap <silent> <Leader>Q :q!<CR>

" Force reopen
nnoremap <silent> <Leader>E :e!<CR>

" More efficient line jumps
nnoremap <CR> gg
vnoremap <CR> gg

" Highlight everything
nnoremap <C-A> ggVG

" Remove search highlighting
nnoremap <silent> <Leader>k :nohl<CR>

" Right-handed window switching
nnoremap <Leader>j <C-w><C-w>

" Force screen redraw
nnoremap <silent> <Leader>r :redraw!<CR>

" Insert newline
nnoremap <C-n> O<Esc>

" Back to last buffer
nnoremap <silent> <Leader>b :buf #<CR>

" Scroll from the home row (except can't use <C-l>
" because that's for tmux, so leave <C-u> as up
" since that's a comfortable default anyway)
nnoremap <C-j> <C-e>
nnoremap <C-k> <C-y>
nnoremap <C-h> <C-d>

" Insert a single character at cursor
nnoremap <Leader>i i_<Esc>r
"nnoremap <Leader>a a_<Esc>r


" Insert single character at end of line
nnoremap <Leader>$ $a_<Esc>r

" Replace word with yank-register contents
nnoremap <Leader>p viwp

" Bracket word
nnoremap <Leader>b( ea)<Esc>Bi(<Esc>i
nnoremap <Leader>b) ea)<Esc>Bi(<Esc>i
nnoremap <Leader>b[ ea]<Esc>Bi[<Esc>i
nnoremap <Leader>b] ea]<Esc>Bi[<Esc>i

" Quote stuff
nnoremap <Leader>b" ea"<Esc>Bi"<Esc>
nnoremap <Leader>b' ea'<Esc>Bi'<Esc>

" Get quotes and type in them
nnoremap <Leader>" i""<Space><Esc>hi
nnoremap <Leader>' i''<Space><Esc>hi

" Make backspace key work on Linux
set backspace=2

" Make arrow keys into scroll keys
noremap <Up> <C-y>
noremap <Down> <C-e>
noremap <Left> <C-u>
noremap <Right> <C-d>

" Add a way to comment a selection of lines
nnoremap <silent> <Leader>/ :call CommentLine(getline('.'))<CR>
vnoremap <silent> <Leader>/ :call CommentLine(getline('.'))<CR>

" Convenient way to copy to and paste from the clipboard register
nnoremap <Leader>c "+
vnoremap <Leader>c "+
nnoremap <Leader>v "+p
vnoremap <Leader>v "+p

" Append a line to the clipboard
nnoremap <silent> <Leader>C :let @+=@+.getline('.')<CR>

" Prepend to selection
nnoremap <silent> <Leader>I :call PrependToLines()<CR>
vnoremap <silent> <Leader>I :'<,'>call PrependToLines()<CR>
" ----------------------------
" Align Things
" ----------------------------
command! -nargs=1 Align call ExtendCharTo(<f-args>, GetCharAtCursor())
nnoremap <Leader>a dd"=:Align<space>P


" ----------------------------
" Utility Functions
" ----------------------------
function! FixMarkdownNumbering()
  let numbering_start = line('.')
  let numbering_end   = line('.')
  let numbering_pat   = '^[0-9]\+\.'
  while match(getline(numbering_start), numbering_pat) != -1
    let numbering_start = numbering_start - 1
  endwhile
  let numbering_start = numbering_start + 1

  while match(getline(numbering_end), numbering_pat) != -1
    let numbering_end = numbering_end + 1
  endwhile
  let numbering_end = numbering_end - 1

  let awk_cmd = "awk -F'.' '{ $1=NR \".\" ; print $0 }'"
  let range   = string(numbering_start) . "," . string(numbering_end)
	execute range . "!" . awk_cmd
endfunction

function! ToggleNumbering()
  if(&relativenumber == 1)
    set norelativenumber
  else
    set relativenumber
  endif
endfunction

function! CommentLine(line)
  let a:chars = split(a:line, '\zs')
  if(&ft == 'groovy' || &ft == 'java')
    if(a:chars[0] ==? "\/" && a:chars[1] ==? "\/")
      s/\/\///
    else
      s/^/\/\//
    endif
  elseif(&ft == 'vim')
    if(a:chars[0] ==? "\"")
      s/"//
    else
      s/^/"/
    endif
  else
    if(a:chars[0] ==? "#")
      s/\#//
    else
      s/^/#/
    endif
  endif
endfunction

function! GetCurWord()
  return expand("<cword">)
endfunction

function! PrependToLines() range
  let str = escape(input("Prepend: "), '\/.*$^~[]')
	execute a:firstline . "," . a:lastline . 'substitute/^/' . str .'/'
endfunction

function! GetCharAtCursor()
  return getline('.')[col('.')-1]
endfunction

function! ExtendCharTo(mark, char)
  " Get index of mark in a line. Column numbering starts at 1 instead of 0,
  " hence the subtraction
  let myIdx = getpos('.')[2] - 1
  let toIdx = getpos("'" . a:mark)[2]
  let myLine = getline('.')
  let leftSide = myLine[0:myIdx-1]
  let rightSide = myLine[myIdx+1:-1]
  let newLine = leftSide . repeat(a:char, toIdx - myIdx - 1) . rightSide
  return newLine
endfunction
" ----------------------------
" Filetypes
" ----------------------------

" Highlight gradle files correctly
autocmd BufRead,BufNewFile *.gradle set filetype=groovy

" Wordwrap in markdown files
autocmd BufRead,BufNewFile *.md set textwidth=80

" Highlight messages files
autocmd BufRead,BufNewFile messages* set filetype=messages


" ----------------------------
" Helpers
" ----------------------------
" Strip trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e


