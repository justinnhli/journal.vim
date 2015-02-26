if !exists("g:loaded_jrnl_vim")
  finish
endif

" settings {
setlocal noexpandtab
setlocal   fileencoding=utf-8
setlocal   iskeyword+=-
setlocal   tags+=./.tags,.tags
setlocal   wrap
if exists('&breakindent')
    setlocal   breakindent
endif
if has('folding')
    setlocal nofoldenable
    setlocal   foldexpr=journal#JournalFoldExpr(v:lnum)
    setlocal   foldmethod=expr
    setlocal   foldtext=journal#JournalFoldText()
endif
if has('syntax')
    setlocal   spelllang=en_us
    setlocal   spell
    setlocal   synmaxcol=0
endif
" }

" mappings {
nnoremap  <buffer>           <leader>j  q:iJournal -S
vnoremap  <buffer>           <leader>j  "zyq:iJournal -S "<C-r>z"
nnoremap  <buffer> <silent>  <leader>d  :let search=@/<cr>a!<esc>i<cr><esc>Pj^"_d?,<cr>I<c-w><esc>11l"_x:let @/=search<cr>
nnoremap  <buffer>           <leader>D  :r!date '+\%F'<cr>I<c-w><esc>
nnoremap  <buffer> <silent>  <leader>.  :execute "set foldenable foldlevel=".(journal#IndentLevel('.'))<cr>
inoremap  <buffer>           <C-d>      <c-r>=strftime("%Y-%m-%d")<cr>
" }

" commands {
command! -buffer -nargs=+ Journal :call journal#JournalCommand(<q-args>)
" }

" change directory
call journal#SetJournalDir(expand('%:p:h'))
