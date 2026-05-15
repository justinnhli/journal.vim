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

" mapping {
function s:CreateOutline()
    " grep lines one indent or less, with between 1-30 characters
    let l:lines = system('grep -Hn "^\t\?[^	]\{1,30\}$" ' .. shellescape(expand('%:p')))
    " split the lines into a list
    let l:lines = split(l:lines, '\n')
    " replace the tab with four spaces
    let l:lines = map(l:lines, {i, ele -> substitute(ele, '	', '    ', '')})
    return l:lines
endfunction
nnoremap  <buffer>  gO  :lexpr <SID>CreateOutline()<cr>
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

" change directory
exec 'lcd! ' .. journal#GetJournalDir(expand('%:p:h'))
