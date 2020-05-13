function! s:indent_level(lnum)
    return indent(a:lnum) / &tabstop
endfunction

function! journal#JournalFoldExpr(lnum)
    " if a line is all whitespace,
    " use the foldlevel of the first subsequent non-whitespace line
    if getline(a:lnum) =~ '\v^\s*$'
        return s:indent_level(nextnonblank(a:lnum))
    endif
    " otherwise, mark each line as the start of a fold at level indent + 1
    " this is to work with foldtext to hide the folded text completely,
    " and so text at this level is not considered "folded"
    let l:curr_indent = s:indent_level(a:lnum)
    let l:next_indent = s:indent_level(a:lnum + 1)
    if l:next_indent > l:curr_indent
        return '>' . (l:curr_indent + 1)
    else
        return l:curr_indent
    endif
endfunction

function! s:editable_area_width()
    " from https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script/26318602#26318602
    redir => a | execute 'silent sign place buffer=' . bufnr('') | redir end
    let signlist=split(a, '\n')
    return winwidth(0) - ((&number||&relativenumber) ? &numberwidth : 0) - &foldcolumn - (len(signlist) > 2 ? 2 : 0)
endfunction

function! journal#JournalFoldText()
    " calculate the first non-blank line of the fold
    let l:foldtextstart = nextnonblank(v:foldstart)
    " calculate the indent level
    let l:indent_level = s:indent_level(l:foldtextstart)
    " create the indent string (necessary as tabs converted to spaces)
    let l:indent = repeat(' ', l:indent_level * &tabstop)
    " create the text string
    let l:text = strpart(getline(l:foldtextstart), l:indent_level)
    " create a string to indicate the number of lines folded
    let l:fold_info = '+' . (v:foldend - v:foldstart)
    " calculate the maximum amount of showable text
    let l:max_text_length = s:editable_area_width() - len(l:indent) - len(l:fold_info)
    " truncate the text if necessary
    if len(l:text) > l:max_text_length
        let l:text = strpart(l:text, 0, l:max_text_length - 4) . '... '
    endif
    " create a spacer string
    let l:spacer = repeat(' ', l:max_text_length - len(l:text))
    " return the final result
    return l:indent . l:text . l:spacer . l:fold_info
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

function! journal#JournalCommand(args)
    tabnew
    let l:command = 'journal.py --directory="' . journal#GetJournalDir(expand('%:p:h')) . '"'
    for ignore_file in g:jrnl_ignore_files
        let l:command = l:command . ' --ignore='.expand(ignore_file)
    endfor
    execute 'r!' . l:command . ' ' . a:args
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
