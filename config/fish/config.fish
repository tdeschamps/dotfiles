# UTF-8 is our default encoding
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

set -x PATH '/usr/local/bin:/usr/local/share:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/local/share/npm/bin:/usr/X11/bin:/usr/texbin:~/bin'
set -x GOPATH $HOME/code/golang
set -x GOROOT /usr/local/opt/go/libexec
set -x PATH $PATH $GOPATH/bin $GOROOT/bin

set -x GOOGLE_APPLICATION_CREDENTIALS "$HOME/.google_cloud/service-account-file.json"


if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

source (pyenv init - | psub)
source (rbenv init - | psub)

test -s "$HOME/.kiex/scripts/kiex.fish"; and source "$HOME/.kiex/scripts/kiex.fish"

# Set the emoji width for iTerm
set -g fish_emoji_width 2# Hide the fish greeting
set fish_greeting ""

set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
# Fix formatting problems
set -x MANROFFOPT "-c"

# True color support for *nix system
set -x TERM xterm-256color

set FISH_KUBECTL_COMPLETION_TIMEOUT 0.5s

# FZF
set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --no-ignore-vcs --glob "!{.git,node_modules,build,dist}"'
set -U FZF_DEFAULT_OPTS "--layout=reverse --info=inline --color bw"
set -U FZF_FIND_FILE_COMMAND "$FZF_DEFAULT_COMMAND"
set -U FZF_PREVIEW_FILE_CMD "bat --style=numbers --color=always"
set -U FZF_TMUX 1
set -U FZF_ENABLE_OPEN_PREVIEW 1

# Fish syntax highlighting
set -g fish_color_autosuggestion '555'  'brblack'
set -g fish_color_cancel -r
set -g fish_color_command --bold
set -g fish_color_comment red
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_end brmagenta
set -g fish_color_error brred
set -g fish_color_escape 'bryellow'  '--bold'
set -g fish_color_history_current --bold
set -g fish_color_host normal
set -g fish_color_match --background=brblue
set -g fish_color_normal normal
set -g fish_color_operator bryellow
set -g fish_color_param cyan
set -g fish_color_quote yellow
set -g fish_color_redirection brblue
set -g fish_color_search_match 'bryellow'  '--background=brblack'
set -g fish_color_selection 'white'  '--bold'  '--background=brblack'
set -g fish_color_user brgreen
set -g fish_color_valid_path --underline

if command -q starship
    starship init fish | source
end
