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

" grepprg {
let s:command = 'journal.py --directory=' .. journal#GetJournalDir(expand('%:p:h'))
for ignore_file in g:jrnl_ignore_files
       let s:command = s:command .. ' --ignore=' .. expand(ignore_file)
endfor
let s:command = s:command .. ' --vimgrep'
let s:command = substitute(s:command, ' ', '\\ ', 'g')
execute 'setlocal grepprg=' .. s:command
setlocal grepformat=%f:%l:%c:%m
" }

" autocmds {
autocmd  BufWritePre  <buffer>  call journal#PreWriteAutocmd()
" }

" commands {
command! -buffer -nargs=+  Journal  call journal#JournalCommand(<q-args>)
" }

" change directory
exec 'lcd! ' .. journal#GetJournalDir(expand('%:p:h'))
