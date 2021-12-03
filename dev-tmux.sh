#!/bin/sh
tmux new-session -d
tmux split-window -h
tmux split-window -h
tmux attach-session -d
