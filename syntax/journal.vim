syntax case match

syntax match datetime '\<[0-9]\{4\}-[0-1][0-9]-[0-3][0-9]\(, \(Sun\|Mon\|Tues\|Wednes\|Thurs\|Fri\|Satur\)day\)\?\>'
highlight link datetime Identifier

syntax keyword fixme FIXME TODO
syntax match fixme '(FIXME)' " parenthesized FIXME's
syntax match fixme '(FIXME [^()]*)' " parenthesized FIXME's with notes
highlight link fixme Todo

syntax match flag ':\@<!([^:()][^()]*$' " unclosed parenthesis
syntax match flag '^[^(:0-9]*):\@!' " unopened parenthesis
syntax match flag '\[[^]]*$' " unclosed brackets
syntax match flag '{[^}]*$' " unclosed braces
syntax match flag '[^\t -~]' " non-ASCII characters
syntax match flag '^\t*[^|]*[ 	]\+$'ms=e " unmarked end-of-line blanks
syntax match flag '^\t*[^|]*  \+'ms=e-1 " unmarked multi-space
syntax match flag '^\(\t*\)[^\t]*\n\1\t\{2,\}' " over-indentation
syntax match flag '\n\n\t\+' " multiple blank lines
syntax match flag '[^\t]\t' " non-indentation tabs
syntax match flag '\t\@<= ' " mixed indentation
syntax match flag '^ ' " space indentation
highlight link flag Error

syntax region strong matchgroup=strongMark start='[*[:alnum:]]\@<!\*[* ]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types
highlight strong cterm=bold gui=bold
highlight link strongMark strong

syntax region innerStrong matchgroup=innerStrongMark start='[*[:alnum:]]\@<!\*[* ]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types contained
highlight innerStrong cterm=bold gui=bold
highlight link innerStrongMark innerStrong

syntax region outerStrong matchgroup=outerStrongMark start='[*[:alnum:]]\@<!\*[* ]\@!' end='[*]\@<!\*[*[:alnum:]]\@!' oneline contains=@types contained
highlight outerStrong cterm=bold gui=bold
highlight link outerStrongMark outerStrong

syntax region innerQuote matchgroup=innerQuote start='[^[(/ \t]\@<!"' end='[[:blank:]([]\@<!"[[:alnum:]]\@!' contains=outerQuote,innerStrong,@types contained
syntax region outerQuote matchgroup=outerQuote start='[^[(/ \t]\@<!"' end='[[:blank:]([]\@<!"[[:alnum:]]\@!' contains=innerQuote,outerStrong,@types 
highlight link innerQuote String
highlight link outerQuote Number

syntax match reference '\[[a-zA-Z-]\+\( and [a-zA-Z-]\+\| et al.\)* ([0-9]\{4\})\]' contains=@NoSpell
syntax match reference '^\s*[a-zA-Z-]\+\(, [a-zA-Z-]\+\( [a-zA-z]\+\)*\)* ([0-9]\{4\})\. .*[.?]$' contains=@NoSpell
syntax match reference '[[:alnum:]]\@<![a-zA-Z]\+[0-9]\{4\}\([A-Z][a-zA-Z]*\)[[:alnum:]]\@!' contains=@NoSpell
highlight link reference Statement

syntax match subformat 'http[^ ()]+' contains=@NoSpell " link
syntax match subformat '[._0-9A-Za-z]\+@[_0-9A-Za-z]\+\(\.[_0-9A-Za-z]\+\)\+' contains=@NoSpell " email
syntax match subformat '/[ru]/[0-9A-Za-z_-]\+' contains=@NoSpell " subreddits/users
syntax match subformat '[^[:blank:]]\@<!@[0-9A-Za-z_]\+\>' contains=@NoSpell " Twitter handles
syntax match subformat '[[:alnum:]]\@<!\`[^`]\+\`[[:alnum:]]\@!'hs=s+1,he=e-1 contains=@NoSpell " inline code
syntax region subformat start='[^[:blank:]] ```$'ms=e-3,hs=e+1 end='^[[:blank:]]*```$'he=s-1 contains=@NoSpell " code block
highlight link subformat Special

syntax cluster types contains=datetime,flag,subformat
