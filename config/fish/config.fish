# ~/.config/fish/config.fish

#
# Locale
#
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

#
# Homebrew (Apple Silicon, Intel macOS, Linuxbrew)
#
for brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew
    if test -x $brew_prefix/bin/brew
        $brew_prefix/bin/brew shellenv fish | source
        break
    end
end

#
# PATH
#
fish_add_path -g $HOME/.local/bin
fish_add_path -g $HOME/bin

#
# Editor
#
if command -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx BUNDLER_EDITOR nvim
    set -gx MANPAGER 'nvim +Man!'
else
    set -gx EDITOR vim
    set -gx VISUAL vim
end

#
# Go — the toolchain comes from asdf; this is just where `go install` puts things
#
set -gx GOPATH $HOME/code/golang
fish_add_path -g $GOPATH/bin

#
# Rust — cargo installs binaries here regardless of how rustc was installed
#
fish_add_path -g $HOME/.cargo/bin

#
# Google Cloud
#
set -l gcloud_creds "$HOME/.google_cloud/service-account-file.json"
test -f $gcloud_creds; and set -gx GOOGLE_APPLICATION_CREDENTIALS $gcloud_creds

#
# asdf — every language runtime (see .tool-versions)
#
# asdf 0.16 was rewritten in Go: there is no asdf.fish to source any more, the
# shims directory just goes on PATH. This block is verbatim from the upstream
# fish instructions, including the deliberate avoidance of fish_add_path, which
# can reorder PATH and let a system runtime win over a shim.
if test -z "$ASDF_DATA_DIR"
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

#
# fzf
#
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git --exclude node_modules'
set -gx FZF_DEFAULT_OPTS '--layout=reverse --info=inline --border --height=60%'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_CTRL_T_OPTS '--preview "bat --style=numbers --color=always --line-range :500 {}"'
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git --exclude node_modules'

#
# Interactive-only setup
#
if status is-interactive
    set -g fish_greeting ""
    set -g fish_emoji_width 2

    # bat as the man pager when nvim is not available
    if not command -q nvim; and command -q bat
        set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
        set -gx MANROFFOPT -c
    end

    # zoxide replaces the old `z` / autojump setup
    command -q zoxide; and zoxide init fish | source

    # fzf key bindings (Ctrl-T files, Ctrl-R history, Alt-C cd)
    command -q fzf; and fzf --fish | source

    # Prompt
    command -q starship; and starship init fish | source

    # Syntax highlighting colours
    set -g fish_color_autosuggestion brblack
    set -g fish_color_cancel -r
    set -g fish_color_command --bold
    set -g fish_color_comment brblack
    set -g fish_color_cwd green
    set -g fish_color_cwd_root red
    set -g fish_color_end brmagenta
    set -g fish_color_error brred
    set -g fish_color_escape bryellow --bold
    set -g fish_color_history_current --bold
    set -g fish_color_host normal
    set -g fish_color_host_remote yellow
    set -g fish_color_match --background=brblue
    set -g fish_color_normal normal
    set -g fish_color_operator bryellow
    set -g fish_color_option cyan
    set -g fish_color_param cyan
    set -g fish_color_quote yellow
    set -g fish_color_redirection brblue
    set -g fish_color_search_match bryellow --background=brblack
    set -g fish_color_selection white --bold --background=brblack
    set -g fish_color_status red
    set -g fish_color_user brgreen
    set -g fish_color_valid_path --underline
end
