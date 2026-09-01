status is-interactive; or exit

# eza is the maintained successor to exa; fall back to lsd, then plain ls.
if command -q eza
    alias ls 'eza --group-directories-first'
    alias ll 'eza -l --git --group-directories-first'
    alias la 'eza -la --git --group-directories-first'
    alias lt 'eza --tree --level=2 --group-directories-first'
else if command -q lsd
    alias ls lsd
    alias ll 'lsd -l'
    alias la 'lsd -la'
    alias lt 'lsd --tree --depth 2'
end

command -q bat; and alias cat bat

alias v nvim
alias vi nvim
alias vim nvim
