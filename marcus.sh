#!/bin/bash
#set -o xtrace
touch marcuslog
clear

if [ -z "$TMUX" ]; then

tmux attach -t marcus
if [[ $? -ne 0 ]]; then
clear
echo "Marcus' Energy Script" | figlet -tcf lean | lolcat -a -F .1 -p 10
file=marcus.txt
while read -r line;
do
echo -e "$line" | lolcat -a -F .1 -p 10 
echo -e "\e[1A\e[$line"
#sleep .1
done<$file
frames="/ | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ - / | \\ -"
for frame in $frames;
do
printf "\r$frame Art By John Fell..."
sleep .1
done
tmux new -d -s marcus 'exec ./marcus-calc.sh $1'
tmux rename-window 'Marcus'
tmux select-window -t marcus:0
tmux split-window -h 'exec /usr/bin/tail -f marcuslog'
tmux select-pane -t 0
tmux -2 attach-session -t marcus
clear
else
sleep 0
fi
else
sleep 0
fi
