window_root "$(pwd)"
new_window "Hack"
run_cmd "nvim"
new_window "Terminals"
run_cmd "pnpm i && pnpm dev"
split_h 50
run_cmd "pnpm test"
new_window "Master"
run_cmd "tmux kill-window -t 1"
run_cmd "clear"
select_window "Hack"