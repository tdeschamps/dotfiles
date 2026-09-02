# Install everything with: brew bundle --file=Brewfile
#
# No `tap "homebrew/bundle"`: that tap was merged into Homebrew/brew, so
# `brew bundle` is built in now and tapping it is at best a no-op.
#
# Everything down to the "Personal tools" heading is referenced by a config file
# in this repo — removing one breaks something. Below that line is preference,
# and safe to cut.

# Shell
brew "fish"
brew "starship"      # prompt, initialised in config.fish
brew "tmux"

# Editor
brew "neovim"
brew "tree-sitter-cli"  # required by nvim-treesitter's main branch
brew "lazygit"          # LazyVim binds <leader>gg to it

# Referenced by the fish and git configs
brew "git"
brew "git-delta"     # config/git/config sets delta as the pager — git fails without it
brew "ripgrep"       # LazyVim's picker greps with rg
brew "fd"            # FZF_DEFAULT_COMMAND
brew "fzf"           # config.fish runs `fzf --fish`
brew "bat"           # MANPAGER fallback and the `cat` alias
brew "eza"           # the ls/ll/la/lt aliases
brew "zoxide"

# Version manager. Every language runtime comes from mise — see
# config/mise/config.toml. All of them are mise core tools, so there are no
# plugins to install.
brew "mise"

# Build dependencies for the runtimes mise compiles rather than downloads.
# Ruby needs these; the rest of the pinned runtimes are precompiled downloads.
brew "autoconf"
brew "openssl@3"
brew "readline"
brew "libyaml"
brew "gmp"
brew "libffi"
brew "zlib"

# Personal tools — nothing in this repo depends on them.
brew "btop"          # process viewer
brew "jq"
brew "gh"
brew "shellcheck"    # lets you run CI's shell check before pushing

# Fonts. Casks are macOS-only — Linuxbrew has no cask support, so guard this or
# `brew bundle` fails the whole file. On Linux install the font from
# https://github.com/ryanoasis/nerd-fonts/releases
if OS.mac?
  cask "font-hack-nerd-font"
end
