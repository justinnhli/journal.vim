if !exists("g:loaded_jrnl_vim")
  finish
endif

function! journal#IndentLevel(lnum)
    return indent(a:lnum) / &tabstop
endfunction

function! journal#JournalFoldExpr(lnum)
    if getline(a:lnum) =~? '\v^\s*$'
	return '>' . (journal#IndentLevel(a:lnum-1)+1)
    else
	let cur_indent = journal#IndentLevel(a:lnum)
	let next_indent = journal#IndentLevel(a:lnum+1)
	if next_indent <= cur_indent
	    return cur_indent
	else
	    return '>' . (journal#IndentLevel(a:lnum)+1)
	endif
    endif
endfunction

function! journal#JournalFoldText()
    let indent_level = journal#IndentLevel(v:foldstart)
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
function! journal#SetJournalDir(dir)
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

function! journal#JournalCommand(args)
    tabnew
    let l:command = 'journal.py'
    for ignore_file in g:jrnl_ignore_files
      let l:command = l:command . ' --ignore='.expand(ignore_file)
    endfor
    exe 'r!' . l:command . ' ' . a:args
    0d
    setlocal nobreakindent buftype=nowrite nofoldenable filetype=journal readonly
    0
endfunction
