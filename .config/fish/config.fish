if status is-interactive
    fish_config theme choose catppuccin-mocha --color-theme=dark

    # Show every directory name in full while retaining ~ for the home directory.
    set -g fish_prompt_pwd_dir_length 0

    fish_vi_key_bindings
    bind -M insert ctrl-r history-pager
    set -g fish_cursor_default block
    set -g fish_cursor_insert line
    set -g fish_cursor_replace_one underscore
    set -g fish_cursor_visual block
    set -g fish_greeting
end
