abbr -a brewp 'brew pin'
abbr -a brews 'brew list -1'
abbr -a brewsp 'brew list --pinned'
abbr -a bubo 'brew update && brew outdated'
abbr -a bubc 'brew upgrade && brew cleanup'
abbr -a bubu 'bubo && bubc'
abbr -a bcubo 'brew update && brew cask outdated'
abbr -a bcubc 'brew cask reinstall $(brew cask outdated) && brew cleanup'