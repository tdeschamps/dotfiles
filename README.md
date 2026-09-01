# dotfiles

Personal configuration for **fish**, **Neovim**, **tmux** and **git**.

Everything is symlinked out of this repo into `~/.config`, so editing a file
here changes the live config immediately.

```
config/
  fish/          shell: config.fish, abbreviations, functions, plugin list
  nvim/          Neovim: plain LazyVim + language extras
  tmux/          tmux.conf (XDG location, no Python/powerline dependency)
  git/           git config, global ignore, commit template
  ssh/           ssh client config
  starship.toml  prompt
asdfrc           asdf options (reads .ruby-version, .nvmrc, ...)
Brewfile         every package the config expects
.tool-versions   language runtimes, installed by asdf
.github/         CI: syntax checks and a full LazyVim bootstrap
install.sh       idempotent installer
git_setup.sh     writes your git identity to an untracked local file
```

## Install

```bash
git clone git@github.com:tdeschamps/dotfiles.git ~/code/tdeschamps/dotfiles
cd ~/code/tdeschamps/dotfiles
bash install.sh
bash git_setup.sh
```

`install.sh` installs Homebrew if missing, runs `brew bundle`, links every
config file (including `~/.ssh/config`), installs fisher and tpm, sets fish as
the login shell and syncs the Neovim plugins. `git_setup.sh` then sets your git
identity and, if you have an SSH key, offers to enable commit signing. It backs up anything real that is in the way as
`<file>.backup`, and re-running it is safe.

Then open a new terminal, and inside tmux press `prefix + I` (that is
`Ctrl-Space` then `Shift-i`) to fetch the tmux plugins.

## Languages

Everything is managed by [asdf](https://asdf-vm.com) and pinned in
[`.tool-versions`](.tool-versions). Versions are the latest stable releases as
of **2026-09-01**.

| Language | Version |
| -------- | ------- |
| Ruby     | 4.0.6   |
| Node.js  | 26.8.1  |
| Python   | 3.14.7  |
| Go       | 1.27.0  |
| Rust     | 1.98.0  |
| Erlang   | 29.0.6  |
| Elixir   | 1.20.4  |

`install.sh` adds the asdf plugins for you. Building the runtimes is a separate,
slower step:

```bash
asdf install          # everything in .tool-versions
asdf set ruby 4.0.7   # change one, then asdf install
```

Node 26 is the current release line; it becomes Active LTS on 2026-10-28. Use
`24.20.0` instead if you want LTS today.

`asdfrc` sets `legacy_version_file = yes`, so asdf also honours the
`.ruby-version`, `.nvmrc` and `.python-version` files that most repos still
ship, not just `.tool-versions`.

Erlang compiles from source. The Brewfile covers the common build dependencies;
if you want `observer` and the docs, add `wxwidgets`, `libxslt` and `fop`. For
Elixir, asdf also accepts OTP-tagged versions like `1.20.4-otp-29` when you need
a build matched to a specific Erlang.

PostgreSQL and Redis stay on Homebrew — they are services, not runtimes:

```bash
brew services start postgresql@18
```

### Ruby gems

```bash
gem install bundler rspec rubocop pry pry-byebug debug
```

Never use `sudo gem install`, whatever Stack Overflow says.

## fish

The shell config lives in `config/fish`.

- `config.fish` — locale, Homebrew, `PATH`, editor, version managers, fzf,
  prompt and colours. Interactive-only settings are behind
  `status is-interactive` so scripts start fast.
- `conf.d/abbr.fish` — Homebrew, Docker Compose and bundler abbreviations.
- `conf.d/git.abbr.fish` — the git shorthands. These are **abbreviations**, not
  aliases: they expand in place as you type, so `Ctrl-R` history shows the real
  command. `gcm`, `gmom` and `grbm` resolve the repo's actual default branch at
  expansion time instead of assuming `master`.
- `conf.d/aliases.fish`, `functions/` — `ls`/`ll` via eza, `serve`, `myip`,
  `localips`, and `stt` (which now opens Neovim).

Plugins are managed by [fisher](https://github.com/jorgebucaran/fisher) and
listed in `fish_plugins`. Add one with `fisher install owner/repo`, then commit
the updated `fish_plugins`.

## Neovim

`config/nvim` is a plain [LazyVim](https://www.lazyvim.org) install — the
upstream starter, unmodified. There is no hand-written plugin configuration to
maintain: LazyVim owns the defaults, and `:Lazy update` picks up upstream fixes
when a plugin changes its API.

Leader is `<Space>`. Press it and wait for which-key to show what is available,
or `<leader>sk` to search every keymap.

Three commands worth knowing:

| Command | What it does |
| --- | --- |
| `:LazyExtras` | Browse and toggle language/tooling modules |
| `:Lazy` | Plugin manager — update, profile, debug |
| `:LazyHealth` | Check that everything LazyVim needs is present |

### Enabled extras

Recorded in `config/nvim/lazyvim.json`, which `:LazyExtras` rewrites when you
toggle a module. Fifteen are on:

- **Languages** — ruby, elixir, go, rust, typescript, python, json, yaml, sql,
  docker, markdown, git
- **Tooling** — prettier (formatting), eslint (linting)
- **Editing** — mini-surround, because the old vimrc used vim-surround

Everything else is LazyVim's default: snacks.nvim for the picker, explorer and
dashboard, blink.cmp for completion, tokyonight for colours, conform.nvim and
nvim-lint wired up per language, mason.nvim for the servers.

Adding a language is `:LazyExtras`, toggle, restart — then commit the changed
`lazyvim.json` and `lazy-lock.json`.

### Local changes

`lua/plugins/overrides.lua` is where your own specs go; it is merged on top of
LazyVim's. `lua/config/{options,keymaps,autocmds}.lua` are loaded automatically
and are intentionally empty. Nothing from the old vim setup was carried over —
LazyVim's own keymaps replace it.

Some servers and formatters Mason installs (`ts_ls`, `jsonls`, `eslint`,
`prettier`, `markdownlint`) need Node on `PATH`, so install a Node version
before first launch.

## git

`config/git/config` is the tracked global config. Your name and email are
**not** in it — `git_setup.sh` writes them to `~/.config/git/config.local`,
which the tracked config `[include]`s and `.gitignore` excludes.

Notable settings: `init.defaultBranch = main`, `push.autoSetupRemote`,
`fetch.prune`, `rebase.autoStash`, `rerere.enabled`, `merge.conflictstyle =
zdiff3`, and [delta](https://github.com/dandavison/delta) as the pager.

If `~/.gitconfig` exists it silently overrides all of this — remove it.

### Commit signing

`git_setup.sh` also offers to turn on SSH commit signing, using the first key it
finds in `~/.ssh`. It writes `user.signingkey` and `commit.gpgsign` to
`config.local` and adds your key to `~/.config/git/allowed_signers` so
`git log --show-signature` can verify your own commits.

Only `gpg.format = ssh` is tracked, so a machine with no signing key still
commits normally. After enabling it, add the same key to GitHub as a **signing**
key — that is a separate entry from the authentication key.

## ssh

`config/ssh/config` becomes `~/.ssh/config`. It enables `AddKeysToAgent`,
`UseKeychain` on macOS (guarded by `IgnoreUnknown`, so the same file parses on
Linux), keepalives, and connection multiplexing.

`IdentitiesOnly` is scoped to `github.com` rather than `Host *`, so other hosts
can still authenticate from the agent.

Machine-specific and work hosts go in `~/.ssh/config.local`, which is included
first — ssh takes the first value it sees for each option, so anything there
wins. That file is not tracked.

Generate a key on a new machine with:

```bash
ssh-keygen -t ed25519 -C "your@email"
```

## CI

`.github/workflows/ci.yml` runs on every push and weekly on a schedule, because
upstream moves even when this repo does not.

- **shell** — shellcheck, `fish --no-execute` on every fish file, then a real
  fish load asserting the abbreviations and functions register; tmux, ssh and
  git configs are parsed by their own tools; JSON and TOML are validated; and
  the installer's linking is checked for correctness and idempotency.
- **neovim** — bootstraps LazyVim from an empty config, asserts a clean second
  start, and checks that every declared extra loaded and every plugin installed.

The weekly run is the point: it catches a plugin breaking its API before the
next time you install these dotfiles somewhere.

## What changed in the 2026 refresh

This repo started as a fork of `lewagon/dotfiles` and had not been touched
since 2020. The rewrite:

- **Shell** — dropped zsh and oh-my-zsh; fish is the only shell. Fixed the
  `PATH` handling (it was one colon-joined string), added `brew shellenv` so
  Apple Silicon works, and removed the `set -x TERM xterm-256color` override
  that was breaking true colour.
- **Editor** — replaced Sublime Text and the 28 vim submodules with a plain
  LazyVim install. `stt` opens Neovim; the TextMate `tm_properties` file is
  gone.
- **fisher** — the vendored copy was v3.3.1 and installed itself from
  `git.io`, which GitHub shut down in 2022. `fishfile` is now `fish_plugins`.
- **Version managers** — dropped the vendored 2013 rbenv fish shims and
  `fast-nvm-fish`. Everything is asdf now, via `.tool-versions`. asdf 0.16 was
  rewritten in Go, so there is no `asdf.fish` to source any more — the shims
  directory just goes on `PATH`.
- **Docker** — `docker-compose` v1 reached end of life in July 2023; the
  abbreviations and completions now use `docker compose`.
- **tmux** — the config pointed at a powerline install inside a hardcoded
  `pyenv 3.8.2` path. Status line is now plain tmux formatting with no Python
  dependency, `default-terminal` is `tmux-256color`, and
  `reattach-to-user-namespace` is gone (unnecessary since macOS 10.12).
- **install.sh** — installed Homebrew with `/usr/bin/ruby` (removed from macOS
  in Monterey), used `brew install vim --override-system-vi` (flag long gone),
  cloned over the `git://` protocol (disabled by GitHub in 2021), appended to
  its own tracked `zshrc` on every run, and never linked `config/` at all — so
  the fish config was never actually installed. All fixed.
- **git** — `commit.template` referenced a `gitmessage` file that did not exist
  in the repo. It does now. `diff-so-fancy` became delta, gitignore.io links
  point at their current home, and the hardcoded identity moved out of the
  tracked file.
- **Tools** — `ag` to ripgrep, `z`/autojump to zoxide, `lsd` to eza, powerline
  to starship.
