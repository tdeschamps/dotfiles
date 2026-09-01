# Install everything with: brew bundle --file=Brewfile

tap "homebrew/bundle"

# Shell
brew "fish"
brew "starship"      # prompt (replaces powerline)
brew "tmux"

# Editor. LazyVim wants ripgrep, fd, lazygit and a Nerd Font (all below);
# tree-sitter-cli is required by nvim-treesitter's main branch.
brew "neovim"
brew "lazygit"
brew "tree-sitter-cli"

# Core CLI
brew "git"
brew "git-delta"     # replaces diff-so-fancy
brew "ripgrep"       # replaces the_silver_searcher (ag)
brew "fd"            # replaces find for fzf
brew "fzf"
brew "bat"
brew "eza"           # replaces exa / lsd
brew "zoxide"        # replaces z / autojump
brew "jq"
brew "wget"
brew "curl"
brew "tree"
brew "htop"
brew "gh"

# Version manager. Every language runtime comes from asdf — see .tool-versions.
brew "asdf"

# Build dependencies for the asdf plugins that compile from source.
# Ruby and Python need these; Erlang additionally wants wxwidgets, libxslt and
# fop if you care about observer and the docs (see README).
brew "autoconf"
brew "openssl@3"
brew "readline"
brew "libyaml"
brew "gmp"
brew "libffi"
brew "zlib"

# Databases
brew "postgresql@18"
brew "redis"

# Formatters and linters. Neovim gets its own copies through Mason, so these
# are only the ones worth having on PATH outside the editor.
brew "shellcheck"
brew "ruff"

# Fonts (Nerd Fonts are in homebrew/cask-fonts, now part of core casks)
cask "font-hack-nerd-font"
