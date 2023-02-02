
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

function! DebugClear()
    !rm -f breaks.gdb
    !rm -f disp.gdb
endfunction

nmap <leader>db :call BreakLine()<cr>
nmap <leader>dp :call AddDisplay()<cr>
nmap <leader>dc :call DebugClear()<cr>
