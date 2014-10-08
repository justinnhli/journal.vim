lcd %:p:h

" folding {
function! IndentLevel(lnum)
    return indent(a:lnum) / &shiftwidth
endfunction
function! JournalFoldExpr(lnum)
    if getline(a:lnum) =~? '\v^\s*$'
	return '-1'
    endif
    let this_indent = IndentLevel(a:lnum)
    let next_indent = IndentLevel(a:lnum+1)
    if next_indent == this_indent
	return this_indent
    elseif next_indent < this_indent
	return this_indent
    elseif next_indent > this_indent
	return '>' . next_indent
    endif
endfunction
function! JournalFoldText()
    let line = getline(v:foldstart)
    let indent_level = IndentLevel(v:foldstart)
    let number_length = getwinvar(0, '&number') * getwinvar(0, '&numberwidth')
    if indent_level
	let prefix_length = (indent_level * (&tabstop - 1))
	let prefix = "-" . repeat(" ", prefix_length - 1)
    else
	let prefix_length = indent_level
	let prefix = ""
    endif
    let line_length = len(line)
    let fold_info = "+" . (v:foldend - v:foldstart) . " "
    let suffix_length = winwidth(0) - number_length - prefix_length - line_length - len(fold_info)
    let suffix = repeat(" ", suffix_length)
    return prefix . line . suffix . fold_info
endfunction
setlocal   foldexpr=JournalFoldExpr(v:lnum)
setlocal   foldmethod=expr
setlocal   foldtext=JournalFoldText()
" }

" spellcheck {
setlocal   spelllang=en_us
setlocal   spell
" }

" syntax highlighting {
setlocal   synmaxcol=0
" }

" commands {
if !exists("*s:JournalCommand")
    function s:JournalCommand(args)
	tabnew
	exe "r!journal.py --ignore ~/journal/notes.journal " . a:args
	0d
	setlocal ft=journal
	setlocal nocursorline
	setlocal buftype=nowrite
	setlocal readonly
	0
    endfunction
endif
command! -buffer -nargs=+ Journal :call s:JournalCommand(<q-args>)
" }

" mappings {
nnoremap  <buffer>  <leader>j  q:iJournal -S
vnoremap  <buffer>  <leader>j  "zyq:iJournal -S "<C-r>z"
" }

" other settings {
setlocal noexpandtab
setlocal   fileencoding=utf-8
setlocal   iskeyword+=-
setlocal   wrap
" }

autocmd BufRead,BufNewFile notes.journal syntax match flag '^.\{2000,\}$'
