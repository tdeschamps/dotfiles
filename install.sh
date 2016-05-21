backup() {
  target=$1
  if [ -e "$target" ]; then           # Does the config file already exist?
    if [ ! -L "$target" ]; then       # as a pure file?
      mv "$target" "$target.backup"   # Then backup it
      echo "-----> Moved your old $target config file to $target.backup"
    fi
  fi
}

# Check if you have brew installed and install vim, tmux, python (for powerline),
# reattach-to-user-namespace (for tmux), z and ag (the_silver_searcher for vim's ctrlp plugin)
if type "brew" > /dev/null
then
  brew update
  brew install vim --override-system-vi tmux python reattach-to-user-namespace z ag
  pip install psutil
  pip install powerline-status
else
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Check that you have robby russell's excellent oh-my-zsh
if [ $(echo $ZSH) != $(echo $HOME/.oh-my-zsh) ]
then
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

#!/bin/zsh
for name in *; do
  if [ ! -d "$name" ]; then
    target="$HOME/.$name"
    if [[ ! "$name" =~ '\.sh$' ]] && [ "$name" != 'README.md' ]; then
      backup $target

      if [ ! -e "$target" ]; then
        echo "-----> Symlinking your new $target"
        ln -s "$PWD/$name" "$target"
      fi
    fi
  fi
done

REGULAR="\\033[0;39m"
YELLOW="\\033[1;33m"
GREEN="\\033[1;32m"

# zsh plugins
CURRENT_DIR=`pwd`
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGINS_DIR" && cd "$ZSH_PLUGINS_DIR"
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  echo "-----> Installing zsh plugin 'zsh-syntax-highlighting'..."
  git clone git://github.com/zsh-users/zsh-syntax-highlighting.git
fi
cd "$CURRENT_DIR"

setopt nocasematch
if [[ ! `uname` =~ "darwin" ]]; then
  git config --global core.editor "subl -n -w $@ >/dev/null 2>&1"
  echo 'export BUNDLER_EDITOR="subl $@ >/dev/null 2>&1"' >> zshrc
else
  git config --global core.editor "'/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl' -n -w"
  bundler_editor="'/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'"
  echo "export BUNDLER_EDITOR=\"${bundler_editor}\"" >> zshrc
fi

# Sublime Text
if [[ ! `uname` =~ "darwin" ]]; then
  SUBL_PATH=~/.config/sublime-text-3
else
  SUBL_PATH=~/Library/Application\ Support/Sublime\ Text\ 3
fi
mkdir -p $SUBL_PATH/Packages/User $SUBL_PATH/Installed\ Packages
backup "$SUBL_PATH/Packages/User/Preferences.sublime-settings"
curl https://sublime.wbond.net/Package%20Control.sublime-package > $SUBL_PATH/Installed\ Packages/Package\ Control.sublime-package
ln -s $PWD/Preferences.sublime-settings $SUBL_PATH/Packages/User/Preferences.sublime-settings
ln -s $PWD/Package\ Control.sublime-settings $SUBL_PATH/Packages/User/Package\ Control.sublime-settings

zsh ~/.zshrc

if [[ `uname` =~ "darwin" ]]; then
  echo "Quit your terminal and restart it (⌘ + Q)."
else
  echo "Quit your terminal and restart it (Alt + F4)."
fi
