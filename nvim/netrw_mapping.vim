augroup netrw_mapping
    autocmd!
    autocmd filetype netrw call NetrwMapping()
augroup END

function! NetrwMapping()
    nmap <buffer> h -
    nmap <buffer> <left> -
    nmap <buffer> l <CR>
    nmap <buffer> <right> <CR>
endfunction

