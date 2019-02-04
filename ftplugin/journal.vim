if !exists("g:loaded_jrnl_vim")
    finish
endif

" settings {
setlocal   complete=.,t
setlocal noexpandtab
setlocal   fileencoding=utf-8
setlocal   iskeyword+=-
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

" autocmds {
autocmd BufWritePre <buffer> :call journal#StripTrailingSpace()
" }

" mappings {
nnoremap  <buffer>           <leader>j  q:iJournal -S
vnoremap  <buffer>           <leader>j  "zyq:iJournal -S "<C-r>z"
nnoremap  <buffer> <silent>  <leader>.  :execute "set foldenable foldlevel=".(journal#IndentLevel('.'))<cr>
inoremap  <buffer>           <C-d>      <c-r>=strftime("%Y-%m-%d")<cr>
" }

" commands {
command! -buffer -nargs=+ Journal :call journal#JournalCommand(<q-args>)
" }

" change directory
exec 'lcd! '.journal#SetJournalDir(expand('%:p:h'))
