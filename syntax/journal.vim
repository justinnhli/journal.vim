" syntax highlighting {

	syntax case match

	syntax match datetime '\<[0-9]\{4\}-[0-1][0-9]-[0-3][0-9]\(, \(Sun\|Mon\|Tues\|Wednes\|Thurs\|Fri\|Satur\)day\)\?\>'
	highlight datetime ctermfg=darkgreen guifg=#2AA198

	syntax keyword flag FIXME TODO
	syntax match flag '(FIXME)' " parenthesized FIXME's
	syntax match flag '(FIXME [^()]*)' " parenthesized FIXME's with notes
	syntax match flag ':\@<!([^:()][^()]*$' " unclosed parenthesis
	syntax match flag '^[^(:0-9]*):\@!' " unopened parenthesis
	syntax match flag '\[[^]]*$' " unclosed brackets
	syntax match flag '{[^}]*$' " unclosed braces
	syntax match flag '[^\t -~]' " non-ASCII characters
	syntax match flag '\(^[^|]*\)\@<=[ 	]\+$' " unmarked end-of-line blanks
	syntax match flag '\(^[^|]*\)\@<=  \+' " unmarked multi-space
	syntax match flag '^\(\t*\)[^\t]*\zs\n\1\t\{2,\}' " over-indentation
	syntax match flag '\n\n\t\+' " multiple blank lines
	syntax match flag '[^\t]\t' " non-indentation tabs
	syntax match flag '\t ' " mixed indentation
	syntax match flag '^ ' " space indentation
	highlight flag ctermfg=white ctermbg=darkred guifg=white guibg=#DC322F

	syntax cluster types contains=datetime,flag

	syntax region strong matchgroup=strongMark start='[*[:alnum:]]\@<!\*[* ]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types
	highlight strong cterm=bold gui=bold
	highlight link strongMark strong

	syntax region innerStrong matchgroup=innerStrongMark start='[*[:alnum:]]\@<!\*[* ]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types contained
	highlight innerStrong ctermfg=darkred cterm=bold guifg=red gui=bold
	highlight link innerStrongMark innerStrong

	syntax region outerStrong matchgroup=outerStrongMark start='[*[:alnum:]]\@<!\*[* ]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types contained
	highlight outerStrong ctermfg=darkmagenta cterm=bold guifg=magenta gui=bold
	highlight link outerStrongMark outerStrong

	syntax region innerQuote matchgroup=innerQuote start='[^[(/ \t]\@<!"' end='[[:blank:]([]\@<!"[[:alnum:]]\@!' contains=outerQuote,innerStrong,@types contained
	syntax region outerQuote matchgroup=outerQuote start='[^[(/ \t]\@<!"' end='[[:blank:]([]\@<!"[[:alnum:]]\@!' contains=innerQuote,outerStrong,@types 

	highlight innerQuote ctermfg=darkred guifg=red
	highlight outerQuote ctermfg=darkmagenta guifg=magenta

	syntax match reference '\[[a-zA-Z-]\+\( and [a-zA-Z-]\+\| et al.\)* ([0-9]\{4\})\]' contains=@NoSpell
	syntax match reference '^\s*[a-zA-Z-]\+\(, [a-zA-Z-]\+\( [a-zA-z]\+\)*\)* ([0-9]\{4\})\. .*[.?]$' contains=@NoSpell
	syntax match reference '[[:alnum:]]\@<![a-zA-Z]\+[0-9]\{4\}\([A-Z][a-zA-Z]*\)[[:alnum:]]\@!' contains=@NoSpell
	highlight reference ctermfg=darkyellow guifg=yellow

	syntax match hyperlink 'http[^ ()]*' contains=@NoSpell
	highlight hyperlink cterm=underline gui=underline

	syntax match latex '[[:alnum:]]\@<!\`[^`]\+\`[[:alnum:]]\@!'hs=s+1,he=e-1 contains=@NoSpell
	highlight latex ctermfg=gray cterm=underline guifg=gray gui=underline
" }
