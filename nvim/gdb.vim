
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
    redir >> ref.gdb
    let varname = expand('<cword>')
    echo 'watch ' . varname
    redir END
endfunction

function! AddPrint()
    redir >> ref.gdb
    let varname = expand('<cword>')
    echo 'p ' . varname
    redir END
endfunction

function! DebugClear()
    !rm -f breaks.gdb
    !rm -f disp.gdb
    !rm -f ref.gdb
endfunction

nmap <leader>db :call BreakLine()<cr>
nmap <leader>dw :call AddWatch()<cr>
nmap <leader>dc :call DebugClear()<cr>
nmap <leader>dp :call AddPrint()<cr>
nmap <leader>dd :call AddDisplay()<cr>
