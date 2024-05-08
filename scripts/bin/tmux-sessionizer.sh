#!/usr/bin/env bash

# Inspired from ThePrimeagen. See:
# * https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer

selected=$(find repos -mindepth 1 -maxdepth 1 -type d | fzf --header='Select directory to start a new session on:' --reverse --header-first)

# echo "You selected $selected"


if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)

# echo "Selected name: $selected_name"

# A starting point to adding worktrees to the workflow.
# Maybe I don't need this
 if [ "$(git -C $selected rev-parse --is-bare-repository)" == true ] ; then
	selected_branch=$(git -C $selected for-each-ref --format='%(refname:short)' refs/heads/ | fzf --header='This is a bare repo. Select a worktree:' --reverse --header-first)
	
	if [[ ! -z $selected_branch ]]; then
		#echo "${selected_name}.${selected_branch}"
		selected_name="${selected_name}-[${selected_branch}]"
		selected="${selected}/${selected_branch}" 
	fi
fi

#echo $selected_name
#echo $selected

tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    # -c start-directory
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

# If no session with that name exists, then create it
if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

# Switch to that session (the created one or the existing one)
tmux switch-client -t $selected_name
