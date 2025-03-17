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

syntax region journalEmph matchgroup=journalEmphMark start='[*[:alnum:]]\@<!\*[ *]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types
syntax region journalEmph matchgroup=journalEmphMark start='[_[:alnum:]]\@<!_[ _]\@!' end='[_]\@<!_[_[:alnum:]]\@!' oneline contains=@types
highlight journalEmph cterm=italic gui=italic
highlight link journalEmphMark journalEmph

syntax region journalStrong matchgroup=journalStrongMark start='[[:alnum:]_]\@<!__[ _]\@!' end='[ _]\@<!__[[:alnum:]_]\@!' oneline contains=@types
highlight journalStrong cterm=bold gui=bold
highlight link journalStrongMark journalStrong

syntax region journalOddQuote matchgroup=journalOddQuote start='[^[:blank:][(/"-]\@<!"\("*\([, ]\|\.[.[:alpha:]]\@!\|$\)\)\@!' end='[[:blank:]([]\@<!"[[:alnum:]]\@!' contains=journalEvenQuote,journalOddEmph,journalOddStrong,@types contained
syntax region journalEvenQuote matchgroup=journalEvenQuote start='[^[:blank:][(/"-]\@<!"\("*\([, ]\|\.[.[:alpha:]]\@!\|$\)\)\@!' end='[[:blank:]([]\@<!"[[:alnum:]]\@!' contains=journalOddQuote,journalEvenEmph,journalEvenStrong,@types contained
syntax region journalOuterQuote matchgroup=journalOuterQuote start='[^[:blank:][(/-]\@<!"\("*\([, ]\|\.[.[:alpha:]]\@!\|$\)\)\@!' end='[[:blank:]([]\@<!"[[:alnum:]]\@!' contains=journalEvenQuote,journalOddEmph,journalOddStrong,@types
highlight link journalOddQuote Constant
highlight link journalEvenQuote String
highlight link journalOuterQuote Constant

syntax region journalEvenEmph matchgroup=journalEvenEmphMark start='[*[:alnum:]]\@<!\*[ *]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types contained
syntax region journalEvenEmph matchgroup=journalEvenEmphMark start='[_[:alnum:]]\@<!_[ _]\@!' end='[_]\@<!_[_[:alnum:]]\@!' oneline contains=@types contained
highlight journalEvenEmph cterm=italic gui=italic
call s:InheritHighlight('journalEvenEmph', 'String')
highlight link journalEvenEmphMark journalEvenEmph

syntax region journalOddEmph matchgroup=journalOddEmphMark start='[*[:alnum:]]\@<!\*[ *]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types contained
syntax region journalOddEmph matchgroup=journalOddEmphMark start='[_[:alnum:]]\@<!_[ _]\@!' end='[_]\@<!_[_[:alnum:]]\@!' oneline contains=@types contained
highlight journalOddEmph cterm=italic gui=italic
call s:InheritHighlight('journalOddEmph', 'Constant')
highlight link journalOddEmphMark journalOddEmph

syntax region journalEvenStrong matchgroup=journalEvenStrongMark start='[[:alnum:]_]\@<!__[ _]\@!' end='[ _]\@<!__[[:alnum:]_]\@!' oneline contains=@types contained
highlight journalEvenStrong cterm=bold gui=bold
call s:InheritHighlight('journalEvenStrong', 'String')
highlight link journalEvenStrongMark journalEvenStrong

syntax region journalOddStrong matchgroup=journalOddStrongMark start='[[:alnum:]_]\@<!__[ _]\@!' end='[ _]\@<!__[[:alnum:]_]\@!' oneline contains=@types contained
highlight journalOddStrong cterm=bold gui=bold
call s:InheritHighlight('journalOddStrong', 'Constant')
highlight link journalOddStrongMark journalOddStrong

syntax match journalReference '\[[[:alpha:]-]\+\( and [[:alpha:]-]\+\| et al.\)* ([0-9]\{4\})\]' contains=@NoSpell
syntax match journalReference '^\s*[[:alpha:]-]\+\(, [[:alpha:]-]\+\( [[:alpha:]]\+\)*\)* ([0-9]\{4\})\. .*[.?]$' contains=@NoSpell
syntax match journalReference '[[:alnum:]]\@<![[:alpha:]]\+[0-9]\{4\}\([A-Z][[:alnum:]]*\)[[:alnum:]]\@!' contains=@NoSpell
highlight link journalReference Statement

syntax match journalSubformat '[.\~]/\([[:alnum:]._-]*/\)*\([[:alnum:]._-]\+\)\?' contains=@NoSpell " filepath
syntax match journalSubformat '[[:alnum:]_.]\+@[[:alnum:]_]\+\(\.[[:alnum:]_]\+\)\+' contains=@NoSpell " email
syntax match journalSubformat 'https\?://[^[:blank:]()]\+' contains=@NoSpell " link
syntax match journalSubformat '[[:alnum:]]\@<!\:[^: ]\+\:[[:alnum:]]\@!' contains=@NoSpell " emoji shortcodes
syntax region journalSubformat start='^[[:blank:]]*```[a-z]*$' end='^[[:blank:]]*```$' contains=@NoSpell " code block
syntax match journalSubformat '[[:alnum:]]\@<!\`[^`]\+\`[[:alnum:]]\@!' contains=@NoSpell " inline code
syntax match journalSubformat '[[:alnum:]]\@<!\$[^$]\+\$[[:alnum:]]\@!' contains=@NoSpell " inline LaTeX
syntax region journalSubformat start='^[[:blank:]]*\$\$$' end='^[[:blank:]]*\$\$$' contains=@NoSpell " LaTeX math block
syntax match journalSubformat '[^[:blank:][(/-]\@<!@[[:alnum:]_]\+\>' contains=@NoSpell " @ handles
syntax match journalSubformat '/[ru]/[[:alnum:]_-]\+' contains=@NoSpell " subreddits/users
highlight link journalSubformat Special

syntax cluster types contains=journalTitle,journalFixme,journalFlag,journalSpaceFlag,journalSubformat
