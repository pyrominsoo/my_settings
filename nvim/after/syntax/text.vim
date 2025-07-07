" Highlight groups with desired colors
highlight Eq1 guifg=orange ctermfg=Red
highlight Eq2 guifg=purple ctermfg=Blue
highlight Eq3 guifg=#008000 ctermfg=green
highlight Eq4 guifg=DeepPink ctermfg=Magenta
highlight Eq5 guifg=red ctermfg=Red
highlight MyFileLink guifg=blue ctermfg=Yellow
highlight CancelRegion ctermfg=8 guifg=#888888

" Syntax matches for lines with = decorations
syntax match Eq5 /^===== \zs.\{-}\ze =====$/
syntax match Eq4 /^==== \zs.\{-}\ze ====$/
syntax match Eq3 /^=== \zs.\{-}\ze ===$/
syntax match Eq2 /^== \zs.\{-}\ze ==$/
syntax match Eq1 /^= \zs.\{-}\ze =$/

" Highlight [[FILENAME]]
syntax match MyFileLink /\[\[.\{-}\]\]/

" Highlight {{FILENAME}}
syntax match MyFileLink /{{.\{-}}}/

" Define a syntax region for everything from Cancel{ to the next }
syntax region CancelRegion start=/Cancel{/ end=/}/ contains=NONE keepend
highlight link CancelRegion CancelRegion

