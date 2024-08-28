set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

Plugin 'ctags.vim'
Plugin 'cscope.vim'
Plugin 'ronakg/quickr-cscope.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'The-NERD-tree'
Plugin 'The-NERD-Commenter'
Plugin 'gnattishness/cscope_maps'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/nerdcommenter'
Plugin 'DoxygenToolkit.vim'
Plugin 'gingerhot/conque-term-vim'
Plugin 'ctrlpvim/ctrlp.vim'               "Ctrl + P for search file
call vundle#end()
filetype plugin indent on


" w
" source %
" :PluginInstall


" Delete all spaces and tabs at eht end of lines
" %s/\s\+$//


set nocompatible " 오리지날 VI와 호환하지 않음
set autoindent  " 자동 들여쓰기
set cindent " C 프로그래밍용 자동 들여쓰기
set smartindent " 스마트한 들여쓰기

set wrap
set nowrapscan " 검색할 때 문서의 끝에서 처음으로 안돌아감
set nobackup " 백업 파일을 안만듬
set visualbell " 키를 잘못눌렀을 때 화면 프레시
set shiftwidth=4 " 자동 들여쓰기 4칸

set laststatus=2 " 화면 하단에 현재 상태 정보 보여줄 것인지 여부 설정"
" 0 - never"
" 1 - only if there are at least two windows (화면분할)"
" 2 - always"

set title "상단에 파일 이름을 표시
set ruler "하단에 현재 커서의 위치(줄, 칸)  표시
set number " 행번호 표시

set fencs=ucs-bom,utf-8,euc-kr.latin1 " 한글 파일은 euc-kr로, 유니코드는 유니코드로
set fileencoding=utf-8 " 파일저장인코딩
set tenc=utf-8      " 터미널 인코딩
set expandtab " 탭대신 스페이스

set incsearch "  키워드 입력시 점진적 검색
set hlsearch " 검색어 강조, set hls 도 가능
set ignorecase " 검색시 대소문자 무시
set wrapscan " 처음부터 다시 검색

set tabstop=4 "  탭을 4칸으로
set lbr
syntax on "  구문강조 사용
filetype indent on "  파일 종류에 따른 구문강조
set background=dark " 하이라이팅 lihgt / dark
colorscheme torte "  vi 색상 테마 설정
set backspace=eol,start,indent "  줄의 끝, 시작, 들여쓰기에서 백스페이스시 이전줄로
set history=1000 "  vi 편집기록 기억갯수 .viminfo에 기록

set clipboard=unnamedplus

" NerdTreeToggle
nmap <F7> :NERDTreeToggle<CR>
" Tagbar
nmap <F8> :TagbarToggle<CR>
"nmap <F6> :N


set cscopequickfix=s-,c-,d-,i-,t-,e-,a-
nmap <F3> :cn<CR>
nmap <F4> :cp<CR>

"Conque
nmap <F5> :ConqueTermSplit bash<CR>

" ctrlp
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
"    <c-f>, <c-b>: 탭 간 이동
"    <c-j>, <c-k> 또는 방향키: 파일 목록 이동
"    <c-t> or <c-v>, <c-x>: 선택된 파일을 탭 또는 분할 화면으로 열기
"    <c-r>: 정규식 검색 모드로 스위칭

"nnoremap <leader>s yiw:cs find s <C-R>=expand("<cword>")<CR><CR>:bd<CR>:cwindow<CR>/<C-R>0<CR>
"
nnoremap <Leader>fs :cscope find s <C-R>=expand("<cword>")<CR><CR>:botright cwindow<CR>
nnoremap <Leader>fg :cscope find g <C-R>=expand("<cword>")<CR><CR>:botright cwindow<CR>
nnoremap <Leader>fc :cscope find c <C-R>=expand("<cword>")<CR><CR>:botright cwindow<CR>
nnoremap <Leader>ft :cscope find t <C-R>=expand("<cword>")<CR><CR>:botright cwindow<CR>
nnoremap <Leader>fe :cscope find e <C-R>=expand("<cword>")<CR><CR>:botright cwindow<CR>
nnoremap <Leader>ff :cscope find f <C-R>=expand("<cfile>")<CR><CR>:botright cwindow<CR>
nnoremap <Leader>fd :cscope find d <C-R>=expand("<cword>")<CR><CR>:botright cwindow<CR>
nnoremap <Leader>fi :cscope find i ^<C-R>=expand("<cfile>")<CR>$<CR>:botright cwindow<CR>

nnoremap <leader>s yiw:cs find s <C-R>=expand("<cword>")<CR><CR>:bd<CR>:cwindow<CR>/<C-R>0<CR>



" NERD Commenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code
" indentation
let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" customize keymapping
map <Leader>cc <plug>NERDComToggleComment
map <Leader>c<space> <plug>NERDComComment

autocmd BufWritePre *.c,*.cpp %s/\s\+$//

"" 라인 공백 제거
"" :%s/\s\+$//
