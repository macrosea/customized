
":noremap <tab> <c-w><c-p>
:noremap <s-tab> <c-w><c-w> "switch window

map <silent> <leader><cr> :noh<cr> "Disable highlight

" easymotion {
    map f <Plug>(easymotion-prefix)
    map ff <Plug>(easymotion-s2)
    map fs <Plug>(easymotion-f2)
    map fl <Plug>(easymotion-lineforward)
    map fj <Plug>(easymotion-j2)
    map fk <Plug>(easymotion-k2)
    map fh <Plug>(easymotion-linebackward)
" }
:noremap <F3> *

set pastetoggle=<F10>
:noremap <leader>m :let &mouse=(&mouse == 'a' ? '' : 'a')<CR>:set paste!<CR>:set nu!<CR>

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>M mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" buffer {
    :noremap <F2> :bp<cr>
    :noremap <Leader><F2> :bn<cr>
    " Close the current buffer
    map <leader>bd :Bclose<cr>
    " Close all the buffers
    map <leader>ba :bufdo bd<cr>
" }

map <Leader><F5> :!tagscope<cr><cr>

" folder {
    :nnoremap <space> za
    set nofoldenable
" }
"switch between .h and .c++
nmap <silent> <Leader>sw :FSHere<cr>
" Tagbar {
    nnoremap <F8> :TagbarToggle<CR> 
    let g:tagbar_autoclose=1
    let g:tagbar_width=25
    let g:tagbar_left=1
" }
" NERDTree{
    nmap <F9>  :NERDTreeToggle<CR> 
    let NERDTreeChDirMode = 2
    let NERDTreeWinSize = 25
    let NERDTreeWinPos="right"
" }
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nmap wv     <C-w>v
nmap ws     <C-w>s
nmap wc     <C-w>c




source ~/.vimrcs/cscope_maps.vim
