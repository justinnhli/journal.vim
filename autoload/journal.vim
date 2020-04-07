if !exists("g:loaded_jrnl_vim")
    finish
endif

function! journal#IndentLevel(lnum)
    return indent(a:lnum) / &tabstop
endfunction

function! journal#JournalFoldExpr(lnum)
    " if a line is all whitespace,
    " use the foldlevel of the first subsequent non-whitespace line
    if getline(a:lnum) =~ '\v^\s*$'
        let l:lnum = a:lnum
        while l:lnum < line('$') && getline(l:lnum) =~ '\v^\s*$'
            let l:lnum += 1
        endwhile
        return journal#IndentLevel(l:lnum)
    endif
    " otherwise, mark each line as the start of a fold at level indent + 1
    " this is to work with foldtext to hide the folded text completely,
    " and so text at this level is not considered "folded"
    let l:curr_indent = journal#IndentLevel(a:lnum)
    let l:next_indent = journal#IndentLevel(a:lnum + 1)
    if l:next_indent > l:curr_indent
        return '>' . (l:curr_indent + 1)
    else
        return l:curr_indent
    endif
endfunction

function! journal#JournalFoldText()
    let l:lines_folded = (v:foldend - v:foldstart)
    if l:lines_folded
        let l:fold_info = "+" . l:lines_folded
    else
        let l:fold_info = ""
    endif
    let l:number_width = 0
    if getwinvar(0, '&number') || getwinvar(0, "&relativenumber")
        let l:number_width = max([getwinvar(0, '&numberwidth'), float2nr(ceil(log10(line("$")))) + 1])
    endif
    let l:line_width = winwidth(0) - l:number_width - len(l:fold_info)
    let l:indent_level = journal#IndentLevel(v:foldstart)
    let l:text = strpart(repeat(" ", l:indent_level * &tabstop) . strpart(getline(v:foldstart), l:indent_level), winsaveview()["leftcol"])
    if len(l:text) > l:line_width
        let l:text = strpart(l:text, 0, l:line_width - 4) . "... "
    endif
    let l:spacing = repeat(" ", l:line_width - len(l:text))
    return l:text . l:spacing . l:fold_info
endfunction

" change directory to ancestor with cache files
function! journal#GetJournalDir(dir)
    let l:parent_dir = a:dir
    let l:child_dir = ''
    let l:found_root = 1
    while l:parent_dir != l:child_dir
        let l:found_root = 1
        for cache_file in ['.cache', '.tags']
            let l:found = globpath(l:parent_dir, l:cache_file)
            if !filereadable(l:found)
                let l:found_root = 0
                break
            endif
        endfor
        if l:found_root == 1
            return l:parent_dir
        endif
        let l:child_dir = l:parent_dir
        let l:parent_dir = fnamemodify(l:parent_dir, ':h')
    endwhile
    return a:dir
endfunction
" }

function! journal#JournalCommand(args)
    tabnew
    let l:command = 'journal.py'
    let l:command = l:command . ' --directory="'.journal#GetJournalDir(expand('%:p:h')).'"'
    for ignore_file in g:jrnl_ignore_files
        let l:command = l:command . ' --ignore='.expand(ignore_file)
    endfor
    exe 'r!' . l:command . ' ' . a:args
    0d
    setlocal nobreakindent buftype=nowrite nofoldenable filetype=journal readonly nomodifiable
    0
endfunction

function! journal#PreWriteAutocmd()
    let l:winview = winsaveview()
    %s#\s\+$##e
    %retab
    call winrestview(l:winview)
endfunction
