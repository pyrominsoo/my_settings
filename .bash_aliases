export EDITOR='nvim'
export LD_LIBRARY_PATH=/usr/local/cuda-11.4/lib64:$LD_LIBRARY_PATH
export PATH=/usr/local/cuda-11.4/bin:/usr/local/cuda-11.3/bin${PATH:+:${PATH}}

alias dfa="df -h /dev/nvme0n1p2 /dev/sda1 /dev/sdb1"
alias gg="grep -rn"

alias rl='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'

alias ll="ls --color -alF"
alias la="ls --color -A"
alias ls="ls --color -CF"

alias tl="tmux ls"
alias ta="tmux attach"
alias tat="tmux attach -t"

alias fehz="feh -zsZF"


alias youdl="yt-dlp"
alias youdlm="yt-dlp --max-filesize 100m"
alias youdlf="yt-dlp -f"
alias youdlfs="yt-dlp -f 137+140"
alias youdlF="yt-dlp -F"
alias youdla="yt-dlp --extract-audio --audio-format mp3 --audio-quality 0"

alias vi="nvim"
alias v="vi ."

alias chrome="google-chrome"

# bash | zsh
alias sd="cd ~ && cd \$(find * -type d | fzf)"
alias vd="cd ~ && cd \$(find * -type d | fzf) && nvim ."

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

