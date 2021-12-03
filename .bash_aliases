export EDITOR='nvim'
export PATH=/usr/local/cuda-11.3/bin${PATH:+:${PATH}}

alias dfa="df -h /dev/nvme0n1p2 /dev/sda1 /dev/sdb1"
alias gg="grep -rn"

alias rl="ranger"

alias tl="tmux ls"
alias ta="tmux attach"
alias tat="tmux attach -t"

alias fehz="feh -zsZF"

alias youdl="youtube-dl"
alias youdla="youtube-dl --extract-audio --audio-format mp3"

alias vi="nvim"

function cd {
    builtin cd "$@" && ls -F
    }

function ranger {
    if [ -z "$RANGER_LEVEL" ]; then
        /usr/bin/ranger "$@"
    else
        exit
    fi
}
