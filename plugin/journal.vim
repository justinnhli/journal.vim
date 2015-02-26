if exists("g:loaded_jrnl_vim")
    finish
endif
let g:loaded_jrnl_vim = 1

if !exists('g:jrnl_ignore_files')
    let g:jrnl_ignore_files = []
endif
