# Git abbreviations. Unlike aliases these expand in place, so history and
# `Ctrl-R` show the command that actually ran.
status is-interactive; or exit

abbr -a g git

abbr -a ga git add
abbr -a gaa git add --all
abbr -a gapa git add --patch

abbr -a gb git branch
abbr -a gba git branch -a
abbr -a gbl git blame -b -w
abbr -a gbnm git branch --no-merged
abbr -a gbr git branch --remote
abbr -a gbs git bisect
abbr -a gbsb git bisect bad
abbr -a gbsg git bisect good
abbr -a gbsr git bisect reset
abbr -a gbss git bisect start

abbr -a gc git commit -v
abbr -a 'gc!' git commit -v --amend
abbr -a 'gcn!' git commit -v --no-edit --amend
abbr -a gca git commit -v -a
abbr -a 'gca!' git commit -v -a --amend
abbr -a 'gcan!' git commit -v -a --no-edit --amend
abbr -a gcam git commit -a -m
abbr -a gcb git checkout -b
abbr -a gcf git config --list
abbr -a gcl git clone --recurse-submodules
abbr -a gclean git clean -fd
abbr -a gcmsg git commit -m
abbr -a gco git checkout
abbr -a gsw git switch
abbr -a gswc git switch -c
abbr -a gcount git shortlog -sn
abbr -a gcp git cherry-pick
abbr -a gcs git commit -S

abbr -a gd git diff
abbr -a gdca git diff --cached
abbr -a gdt git diff-tree --no-commit-id --name-only -r
abbr -a gdw git diff --word-diff

abbr -a gf git fetch
abbr -a gfa git fetch --all --prune
abbr -a gfo git fetch origin

abbr -a gignore git update-index --assume-unchanged
abbr -a gignored 'git ls-files -v | grep "^[[:lower:]]"'

abbr -a gl git pull
abbr -a glg git log --stat
abbr -a glgp git log --stat -p
abbr -a glgg git log --graph
abbr -a glgga git log --graph --decorate --all
abbr -a glgm git log --graph --max-count=10
abbr -a glo git log --oneline --decorate
abbr -a glog git log --oneline --decorate --graph
abbr -a gloga git log --oneline --decorate --graph --all

abbr -a gm git merge
abbr -a gmt git mergetool --no-prompt
abbr -a gmtnvim git mergetool --no-prompt --tool=nvimdiff

abbr -a gp git push
abbr -a gpd git push --dry-run
abbr -a gpf git push --force-with-lease
abbr -a gpu git push upstream
abbr -a gpv git push -v

abbr -a gr git remote
abbr -a gra git remote add
abbr -a grb git rebase
abbr -a grba git rebase --abort
abbr -a grbc git rebase --continue
abbr -a grbi git rebase -i
abbr -a grbs git rebase --skip
abbr -a grh git reset HEAD
abbr -a grhh git reset HEAD --hard
abbr -a grmv git remote rename
abbr -a grrm git remote remove
abbr -a grset git remote set-url
abbr -a grup git remote update
abbr -a grv git remote -v

abbr -a gsb git status -sb
abbr -a gst git status
abbr -a gsi git submodule init
abbr -a gsu git submodule update --init --recursive
abbr -a gsps git show --pretty=short --show-signature

abbr -a gsta git stash push
abbr -a gstp git stash pop
abbr -a gstl git stash list
abbr -a gstd git stash drop

abbr -a gwa git worktree add
abbr -a gwl git worktree list
abbr -a gwr git worktree remove

# These resolve the repo's actual main branch (main/master/trunk) at expansion
# time instead of hardcoding "master".
abbr -a gcm --function _git_abbr_checkout_main
abbr -a gmom --function _git_abbr_merge_origin_main
abbr -a grbm --function _git_abbr_rebase_main
