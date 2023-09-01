function! ToggleQuickFix()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
        botright copen
    else
        cclose
    endif
endfunction

