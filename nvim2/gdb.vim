
function! BreakLine()
    redir >> breaks.gdb
    let fileline = join([expand("%"), line(".")], ':')
    echo 'break ' . fileline
    redir END
endfunction

function! AddDisplay()
    redir >> disp.gdb
    let varname = expand('<cword>')
    echo 'disp ' . varname
    redir END
endfunction

function! AddWatch()
    redir >> watch.gdb
    let varname = expand('<cword>')
    echo 'watch ' . varname
    redir END
endfunction

function! DebugClear()
    !rm breaks.gdb
    !rm disp.gdb
    !rm watch.gdb
endfunction

nmap <leader>db :call BreakLine()<cr>
nmap <leader>dp :call AddDisplay()<cr>
nmap <leader>dw :call AddWatch()<cr>
nmap <leader>dc :call DebugClear()<cr>
