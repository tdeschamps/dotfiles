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
  mise/          language runtimes and mise settings
  starship.toml  prompt
Brewfile         every package the config expects
.github/         CI: syntax checks and a full LazyVim bootstrap
install.sh       idempotent installer
git_setup.sh     writes your git identity to an untracked local file
```

## Setting up a new machine

Written for macOS, which is what most of this config assumes. Linux works too —
the ssh, tmux and Homebrew bits branch on the platform — but the notes below
call out where it differs.

**1. Command Line Tools.** Nothing else works without them: git on a fresh Mac
is a stub that only prompts for this, and Homebrew needs a compiler.

```bash
xcode-select --install
```

Wait for it to finish. `install.sh` refuses to run without it rather than
failing later with something cryptic.

**2. Clone over HTTPS.** Not SSH — you have no key yet, and the key you will
make is configured by a file inside this repo.

```bash
git clone https://github.com/tdeschamps/dotfiles.git ~/code/tdeschamps/dotfiles
cd ~/code/tdeschamps/dotfiles
```

**3. Install.** Takes a while, mostly Homebrew.

```bash
bash install.sh
```

It installs Homebrew if missing, runs `brew bundle`, links every config file
(including `~/.ssh/config`), installs fisher and tpm, sets fish as your login
shell, and bootstraps LazyVim. Anything real that is in the way is moved to
`<file>.backup` — or `.backup.1`, `.backup.2` and so on, so an earlier backup
is never overwritten. Re-running it is safe.

**4. Git identity and SSH key.**

```bash
bash git_setup.sh
```

Asks for your name and email, then offers to generate an ed25519 key if you
have none and prints the public half. Add it to GitHub **twice** — under
[SSH keys](https://github.com/settings/ssh/new) authentication and signing are
separate entries and you want both. It then turns on commit signing.

Check it worked:

```bash
ssh -T git@github.com
```

**5. Switch this repo to SSH** now that the key exists, so future pushes use it:

```bash
git remote set-url origin git@github.com:tdeschamps/dotfiles.git
```

**6. Language runtimes.** Separate from `install.sh` because Ruby compiles from
source and takes a while.

```bash
mise install
mise doctor
```

**7. Open a new terminal.** fish is your shell now.

**8. Set the terminal font** to *Hack Nerd Font* — the Brewfile installs it, but
nothing can select it for you, and without it the prompt and status line render
icons as empty boxes. In Terminal.app that is Settings → Profiles → Text; iTerm2
and Ghostty have their own font settings.

**9. tmux plugins.** Start tmux and press `Ctrl-Space` then `Shift-i`.

**10. Check Neovim** with `:LazyHealth`.

### Re-running later

On a machine that is already set up, `bash install.sh` is the only step you
need; everything in it is idempotent.

## Languages

Everything is managed by [mise](https://mise.jdx.dev) and pinned in
[`config/mise/config.toml`](config/mise/config.toml), which is linked to
`~/.config/mise/config.toml`. Versions are the latest stable releases as of
**2026-09-01**.

| Language | Version |
| -------- | ------- |
| Ruby     | 4.0.6   |
| Node.js  | 26.8.1  |
| Python   | 3.14.7  |
| Go       | 1.27.0  |
| Rust     | 1.98.0  |

All five are mise **core** tools — built into the binary, so there are no
plugins to install.

```bash
mise install              # everything pinned above
mise use -g ruby@4.0.7    # change one, recorded back into the config
mise outdated             # what has moved on
mise doctor               # check the setup
```

Node 26 is the current release line; it becomes Active LTS on 2026-10-28. Use
`24.20.0` instead if you want LTS today.

The config also sets `idiomatic_version_file_enable_tools` for Ruby, Node and
Python, so mise honours a project's own `.ruby-version` or `.nvmrc` and not just
`mise.toml`. mise disables these by default and makes them opt-in per tool,
unlike asdf's blanket `legacy_version_file`.

Because this is the *global* config, per-project files still win: mise merges
configuration walking up from the current directory.

Ruby compiles from source; the Brewfile covers its build dependencies. The rest
are precompiled downloads.

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
toggle a module. Fourteen are on:

- **Languages** — ruby, go, rust, typescript, python, json, yaml, sql,
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

## Prompt

[starship](https://starship.rs) renders the prompt, configured in
`config/starship.toml` and linked to `~/.config/starship.toml`. `config.fish`
initialises it only if the binary is present, so the shell still works without
it.

The prompt shows directory, git branch and status, the version of whichever
runtime the project uses, Docker context, Kubernetes context, and command
duration over two seconds — then `â¯` on its own line, green normally and red after
a failed command. Kubernetes contexts matching `.*prod.*` render bold red.

Verified with starship 1.26.0: `starship explain` accepts the file, and the
language modules resolve versions from whatever the active runtime is, which is
what mise puts on `PATH`.

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
  `fast-nvm-fish`. Everything is mise now, pinned in one global config file.
  mise hooks the shell and manages `PATH` directly instead of using shims, so
  `which ruby` reports the real binary.
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
