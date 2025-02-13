#!/usr/bin/env bash

version_pat='s/^tmux[^0-9]*([.0-9]+).*/\1/p'

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
should_passthru="$CURRENT_DIR/scripts/should_passthru.sh '#{pane_tty}'"

tmux bind-key -n C-h if-shell "$should_passthru" "send-keys C-h" "select-pane -L"
tmux bind-key -n C-j if-shell "$should_passthru" "send-keys C-j" "select-pane -D"
tmux bind-key -n C-k if-shell "$should_passthru" "send-keys C-k" "select-pane -U"
tmux bind-key -n C-l if-shell "$should_passthru" "send-keys C-l" "select-pane -R"
tmux_version="$(tmux -V | sed -En "$version_pat")"
tmux setenv -g tmux_version "$tmux_version"

#echo "{'version' : '${tmux_version}', 'sed_pat' : '${version_pat}' }" > ~/.tmux_version.json

tmux if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$should_passthru\" 'send-keys C-\\'  'select-pane -l'"
tmux if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$should_passthru\" 'send-keys C-\\\\'  'select-pane -l'"

tmux bind-key -T copy-mode-vi C-h select-pane -L
tmux bind-key -T copy-mode-vi C-j select-pane -D
tmux bind-key -T copy-mode-vi C-k select-pane -U
tmux bind-key -T copy-mode-vi C-l select-pane -R
tmux bind-key -T copy-mode-vi C-\\ select-pane -l
