# Abbreviations expand inline as you type, so you always see the real command.
status is-interactive; or exit

#
# Homebrew
#
abbr -a brewp brew pin
abbr -a brews brew list -1
abbr -a brewsp brew list --pinned
abbr -a bubo 'brew update && brew outdated'
abbr -a bubc 'brew upgrade && brew cleanup'
abbr -a bubu 'bubo && bubc'
# `brew cask` was removed in Homebrew 2.6 — casks are first-class now.
abbr -a bcubo 'brew update && brew outdated --cask --greedy'
abbr -a bcubc 'brew upgrade --cask --greedy && brew cleanup'

#
# Docker Compose (v2 is a docker subcommand; the standalone `docker-compose` is EOL)
#
abbr -a dcb docker compose build
abbr -a dce docker compose exec
abbr -a dcps docker compose ps
abbr -a dcrestart docker compose restart
abbr -a dcrm docker compose rm
abbr -a dcr docker compose run
abbr -a dcstop docker compose stop
abbr -a dcstart docker compose start
abbr -a dcup docker compose up
abbr -a dcupd docker compose up -d
abbr -a dcdn docker compose down
abbr -a dcl docker compose logs
abbr -a dclf docker compose logs -f
abbr -a dcpull docker compose pull
abbr -a dck docker compose kill

#
# Bundler
#
abbr -a b bundle
abbr -a be bundle exec
abbr -a bi bundle install
abbr -a bl bundle list
abbr -a bu bundle update
