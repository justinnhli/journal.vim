" functions {
function! IndentLevel(lnum)
    return indent(a:lnum) / &tabstop
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

" change directory to ancestor with cache files
function! SetJournalDir(dir)
    let l:parent_dir = a:dir
    let l:child_dir = ''
    let l:found_root = 1
    while l:parent_dir != l:child_dir
	let l:found_root = 1
	for cache_file in ['.cache', '.index', '.metadata', '.tags']
	    let l:found = globpath(l:parent_dir, l:cache_file)
	    if !filereadable(l:found)
		let l:found_root = 0
		break
	    endif
	endfor
	if l:found_root == 1
	    exec 'lcd! ' . l:parent_dir
	    return
	endif
	let l:child_dir = l:parent_dir
	let l:parent_dir = fnamemodify(l:parent_dir, ':h')
    endwhile
endfunction
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

" settings {
setlocal noexpandtab
setlocal   fileencoding=utf-8
setlocal   iskeyword+=-
setlocal   tags+=./.tags,.tags
setlocal   wrap
if has("linebreak") && v:version > 703
    setlocal   breakindent
endif
if has('folding')
    setlocal nofoldenable
    setlocal   foldexpr=JournalFoldExpr(v:lnum)
    setlocal   foldmethod=expr
    setlocal   foldtext=JournalFoldText()
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
nnoremap  <buffer> <silent>  <leader>.  :execute "set foldenable foldlevel=".(IndentLevel('.'))<cr>
inoremap  <buffer>           <C-d>      <C-r>=strftime("%Y-%m-%d")<cr>
" }

call SetJournalDir(expand("%:p:h"))
