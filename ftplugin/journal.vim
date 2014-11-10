" folding {
function! IndentLevel(lnum)
    return indent(a:lnum) / &shiftwidth
endfunction

function! JournalFoldExpr(lnum)
    if getline(a:lnum) =~? '\v^\s*$'
	return '>' . (IndentLevel(a:lnum-1)+1)
    else
	let cur_indent = IndentLevel(a:lnum)
	let next_indent = IndentLevel(a:lnum+1)
	if next_indent <= cur_indent
	    return cur_indent
	else
	    return '>' . (IndentLevel(a:lnum)+1)
	endif
    endif
endfunction

function! JournalFoldText()
    let indent_level = IndentLevel(v:foldstart)
    let number_length = (getwinvar(0, '&number') || getwinvar(0, "&relativenumber")) * max([getwinvar(0, '&numberwidth'), float2nr(ceil(log10(line("$"))))+1])
    let line = repeat(" ", indent_level * &tabstop) . strpart(getline(v:foldstart), indent_level)
    let lines_folded = (v:foldend - v:foldstart)
    if lines_folded
	let fold_info = "+" . lines_folded
    else
	let fold_info = ""
    endif
    let line_space = winwidth(0) - number_length - len(fold_info)
    let view_col = winsaveview()["leftcol"]
    if len(line) > line_space
	let line = strpart(line, view_col, line_space - 4) . "... "
    else
	let line = strpart(line, view_col)
    endif
    let spacing = repeat(" ", max([0, line_space - len(line)]))
    return line . spacing . fold_info
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
	exe "r!journal.py --ignore ~/journal/notes.journal --ignore ponderings.journal " . a:args
	0d
	setlocal nobreakindent buftype=nowrite nofoldenable filetype=journal readonly
	0
    endfunction
endif
command! -buffer -nargs=+ Journal :call s:JournalCommand(<q-args>)
" }

" mappings {
nnoremap  <buffer>           <leader>j  q:iJournal -S
vnoremap  <buffer>           <leader>j  "zyq:iJournal -S "<C-r>z"
nnoremap  <buffer> <silent>  <leader>d  :let search=@/<cr>a!<esc>i<cr><esc>Pj^"_d?,<cr>I<c-w><esc>11l"_x:let @/=search<cr>
nnoremap  <buffer>           <leader>D  :r!date '+\%F'<cr>I<c-w><esc>
nnoremap  <buffer> <silent>  <leader>.  :execute "set foldenable foldlevel=".(IndentLevel('.'))<cr>
inoremap  <buffer>           <C-d>      <C-r>=strftime("%Y-%m-%d")<cr>
" }

" other settings {
setlocal noexpandtab
setlocal   fileencoding=utf-8
setlocal   iskeyword+=-
setlocal   wrap
" }
