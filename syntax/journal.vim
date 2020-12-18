function! s:HighlightGroupAttribute(group, attr)
	return matchstr(execute('highlight ' .. a:group), a:attr .. '=\zs\S*')
endfunction

function! s:InheritHighlight(child, parent)
	" this only works if the parent is not linked to something else
	for s:term in ['cterm', 'gui']
		for s:aspect in ['fg', 'bg']
			let s:attr = s:term .. s:aspect
			let s:value = s:HighlightGroupAttribute(a:parent, s:attr)
			if s:value != ''
				execute('highlight ' .. a:child .. ' ' .. s:attr .. '=' .. s:value)
			endif
		endfor
	endfor
endfunction

syntax case match

syntax match journalTitle '\<[0-9]\{4\}-[0-1][0-9]-[0-3][0-9]\(, \(Sun\|Mon\|Tues\|Wednes\|Thurs\|Fri\|Satur\)day\)\?\>'
syntax match journalTitle '\[\[[^][]\+\]\]'
highlight link journalTitle Identifier

syntax keyword journalFixme FIXME TODO
syntax match journalFixme '(FIXME\>[^()]*)' " parenthesized FIXMEs
syntax match journalFixme '\[FIXME\>[^]]*\]' " bracketed FIXMEs with notes
highlight link journalFixme Todo

syntax match journalFlag ':\@<!([^:()][^()]*$' " unclosed parenthesis
syntax match journalFlag '^[^(:0-9]*):\@!' " unopened parenthesis
syntax match journalFlag '\[[^]]*$' " unclosed brackets
syntax match journalFlag '{[^}]*$' " unclosed braces
syntax match journalFlag '[^\t -~]' " non-ASCII characters
highlight link journalFlag Error

syntax match journalSpaceFlag '^\t*[^|]*[ 	]\+$'ms=e " unmarked end-of-line blanks
syntax match journalSpaceFlag '^\t*[^|]*  \+'ms=e-1 " unmarked multi-space
syntax match journalSpaceFlag '^\(\t*\)[^\t]*\n\1\t\{2,\}' " over-indentation
syntax match journalSpaceFlag '\n\n\t\+' " multiple blank lines
syntax match journalSpaceFlag '[^\t]\t' " non-indentation tabs
syntax match journalSpaceFlag '\t\@<= ' " mixed indentation
syntax match journalSpaceFlag '^ ' " space indentation
highlight journalSpaceFlag cterm=underline ctermfg=203 gui=underline guifg=#e27878 " color from Error guifg in iceberg.vim

syntax region journalEmph matchgroup=journalEmphMark start='[*[:alnum:]]\@<!\*[* ]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types
highlight journalEmph cterm=italic gui=italic
highlight link journalEmphMark journalEmph

syntax region journalStrong matchgroup=journalStrongMark start='[_[:alnum:]]\@<!__[_ ]\@!' end='[_ ]\@<!__[_[:alnum:]]\@!' oneline contains=@types
highlight journalStrong cterm=bold gui=bold
highlight link journalStrongMark journalStrong

syntax region journalInnerQuote matchgroup=journalInnerQuote start='[^[:blank:][(/-]\@<!"[^, ]' end='[[:blank:]([]\@<!"[[:alnum:]]\@!' contains=journalOuterQuote,journalInnerEmph,journalInnerStrong,@types contained
syntax region journalOuterQuote matchgroup=journalOuterQuote start='[^[:blank:][(/-]\@<!"[^, ]' end='[[:blank:]([]\@<!"[[:alnum:]]\@!' contains=journalInnerQuote,journalOuterEmph,journalOuterStrong,@types
highlight link journalInnerQuote String
highlight link journalOuterQuote Constant

syntax region journalInnerEmph matchgroup=journalInnerEmphMark start='[*[:alnum:]]\@<!\*[* ]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types contained
highlight journalInnerEmph cterm=italic gui=italic
call s:InheritHighlight('journalInnerEmph', 'String')
highlight link journalInnerEmphMark journalInnerEmph

syntax region journalOuterEmph matchgroup=journalOuterEmphMark start='[*[:alnum:]]\@<!\*[* ]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types contained
highlight journalOuterEmph cterm=italic gui=italic
call s:InheritHighlight('journalOuterEmph', 'Constant')
highlight link journalOuterEmphMark journalOuterEmph

syntax region journalInnerStrong matchgroup=journalInnerStrongMark start='[_[:alnum:]]\@<!__[_ ]\@!' end='[_ ]\@<!__[_[:alnum:]]\@!' oneline contains=@types contained
highlight journalInnerStrong cterm=bold gui=bold
call s:InheritHighlight('journalInnerStrong', 'String')
highlight link journalInnerStrongMark journalInnerStrong

syntax region journalOuterStrong matchgroup=journalOuterStrongMark start='[_[:alnum:]]\@<!__[_ ]\@!' end='[_ ]\@<!__[_[:alnum:]]\@!' oneline contains=@types contained
highlight journalOuterStrong cterm=bold gui=bold
call s:InheritHighlight('journalOuterStrong', 'Constant')
highlight link journalOuterStrongMark journalOuterStrong

syntax match journalReference '\[[a-zA-Z-]\+\( and [a-zA-Z-]\+\| et al.\)* ([0-9]\{4\})\]' contains=@NoSpell
syntax match journalReference '^\s*[a-zA-Z-]\+\(, [a-zA-Z-]\+\( [a-zA-z]\+\)*\)* ([0-9]\{4\})\. .*[.?]$' contains=@NoSpell
syntax match journalReference '[[:alnum:]]\@<![a-zA-Z]\+[0-9]\{4\}\([A-Z][a-zA-Z]*\)[[:alnum:]]\@!' contains=@NoSpell
highlight link journalReference Statement

syntax match journalSubformat 'http[^[:blank:]()]\+' contains=@NoSpell " link
syntax match journalSubformat '[._0-9A-Za-z]\+@[_0-9A-Za-z]\+\(\.[_0-9A-Za-z]\+\)\+' contains=@NoSpell " email
syntax match journalSubformat '/[ru]/[0-9A-Za-z_-]\+' contains=@NoSpell " subreddits/users
syntax match journalSubformat '[^[:blank:][(/-]\@<!@[0-9A-Za-z_]\+\>' contains=@NoSpell " @ handles
syntax match journalSubformat '[[:alnum:]]\@<!\`[^`]\+\`[[:alnum:]]\@!'hs=s+1,he=e-1 contains=@NoSpell " inline code
syntax match journalSubformat '[[:alnum:]]\@<!\$[^$]\+\$[[:alnum:]]\@!'hs=s+1,he=e-1 contains=@NoSpell " inline LaTeX
syntax region journalSubformat start='[^[:blank:]] ```$'ms=e-3,hs=e+1 end='^[[:blank:]]*```$'he=s-1 contains=@NoSpell " code block
highlight link journalSubformat Special

syntax cluster types contains=journalTitle,journalFlag,journalSpaceFlag,journalSubformat
