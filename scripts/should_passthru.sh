#!/usr/bin/env bash
# see https://github.com/christoomey/vim-tmux-navigator/issues/295#issuecomment-922092511
# Usage: should_passthru.sh <tty>
#   tty: Specify tty to check if the current process should receive input combo directly
tty=$1

# Construct process tree.
children=()
while read -r pid ppid; do
  [[ -n $pid && pid -ne ppid ]] && children[ppid]+=" $pid"
done <<<"$(ps -e -o pid= -o ppid=)"

# Get all descendant pids of processes in $tty with BFS
idx=0
IFS=$'\n' read -r -d '' -a pids < <(ps -o pid= -t $tty && printf '\0')
while ((${#pids[@]} > idx)); do
  pid=${pids[idx++]}
  pids+=(${children[pid]-})
done

# Check child processes
ps -o state= -o comm= -p "${pids[@]}" | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?|fzf)(diff)?$'
exit $?
