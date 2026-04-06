# rc-file

A set of zsh shell functions that shorten everyday commands for Laravel, Git, Composer, and frontend development. Instead of typing `php artisan migrate` you type `pam`. Instead of `git add . && git commit -m "..." && git push` you type `gp "..."`.

---

## Prerequisites

- macOS with zsh (default since macOS Catalina)
- The tools you plan to use installed: `php`, `composer`, `git`, `npm`, `redis-cli` as needed

---

## Installation

### Step 1 — Clone the repo

Pick a permanent home for it (e.g. `~/rc-file`):

```zsh
git clone https://github.com/anilkumarthakur60/rc-file.git ~/rc-file
```

### Step 2 — Create `~/.zshrc.d` if it doesn't exist

```zsh
mkdir -p ~/.zshrc.d
```

### Step 3 — Symlink the functions file into `~/.zshrc.d`

```zsh
ln -sf ~/rc-file/bashrc.zsh ~/.zshrc.d/rc-file.zsh
```

### Step 4 — Make `~/.zshrc` load everything in `~/.zshrc.d`

Open `~/.zshrc` in any editor and add this block at the bottom (skip if it's already there):

```zsh
# Load custom functions from ~/.zshrc.d
for file in ~/.zshrc.d/*.zsh; do
  [[ -r "$file" ]] && source "$file"
done
```

### Step 5 — Reload your shell

```zsh
source ~/.zshrc
```

### Verify it works

```zsh
type gp
# gp is a shell function from /Users/<you>/.zshrc.d/rc-file.zsh
```

---

## Updating

Because the file is symlinked, just pull the latest changes:

```zsh
cd ~/rc-file && git pull
source ~/.zshrc
```

No other steps needed.

---

## Uninstalling

```zsh
rm ~/.zshrc.d/rc-file.zsh
```

Then remove the loader block from `~/.zshrc` if you no longer need it.

---

## Functions Reference

### General

| Command | Description |
|---------|-------------|
| `cls` | Clear the terminal |
| `mkcd <dir>` | Create a directory and `cd` into it |
| `killport <port>` | Kill the process listening on a TCP port |
| `mydb` | Connect to MySQL as root (`mysql -u root -p`) |
| `zs` | Re-source `~/.zshrc` without restarting the terminal |
| `ww` | Gracefully quit PhpStorm, WebStorm, and VS Code |
| `dcopy` | Copy the current working directory path to clipboard |

---

### Laravel / PHP Artisan

| Command | Description |
|---------|-------------|
| `pa [args]` | `php artisan` with any arguments passed through |
| `pao [args]` | `php artisan optimize` |
| `pam [args]` | `php artisan migrate` |
| `pas [args]` | `php artisan serve` |
| `pat [args]` | `php artisan tinker` |
| `rl [args]` | `php artisan r:l` — route list |
| `horizon [args]` | Clears screen then runs `php artisan horizon` |
| `paoc` | Reset Spatie permission cache + `optimize:clear` |
| `seed [args]` | `php artisan db:seed` |
| `seedclass <Class...>` | Seed one or more specific seeder classes by name |
| `mf` | Flush Redis then `migrate:fresh --seed` |
| `mp` | Flush Redis, `migrate:fresh --seed`, then create Passport personal client |
| `refresh` | Run `./refresh.sh` in the current project directory |

---

### Composer

| Command | Description |
|---------|-------------|
| `cr [args]` | `composer require` |
| `cu [args]` | `composer update` |
| `ci [args]` | `composer install` |
| `cdu [args]` | `composer dump-autoload` |
| `composerUpdate` | Re-require all current dependencies to force-update them |

---

### Testing & Code Quality

| Command | Description |
|---------|-------------|
| `pest [args]` | Run Pest with 8 GB memory limit |
| `phpunit [args]` | Run PHPUnit |
| `phpstan [args]` | Run PHPStan with 4 GB memory limit |
| `pint [args]` | Run Laravel Pint code formatter |
| `cicd` | Run PHPStan + Pint in sequence (pre-merge quality check) |
| `coverage` | Run Pest with Xdebug coverage, generate an HTML report, and open it |
| `coverage-open` | Open the last generated coverage HTML report |

> `cicd`, `pest`, `phpunit`, `phpstan`, and `pint` all require the corresponding binary under `./vendor/bin/`.

---

### Git

| Command | Description |
|---------|-------------|
| `gst [args]` | `git status` |
| `gc <branch>` | Fetch from remote then checkout the given branch |
| `pull [branch] [remote]` | Smart pull — auto-detects upstream, fetches with `--prune`, respects rebase config |
| `push [branch]` | `git push` (optionally push a specific branch) |
| `fetch [args]` | `git fetch` |
| `stash [args]` | `git stash` |
| `pop [args]` | `git stash pop` |
| `gp [message]` | `git add .` → commit → push. Defaults to message `"fix: minor changes"` |
| `gtp [message]` | Same as `gp` but appends `[skip ci]` to skip CI pipelines |
| `gitRemove` | Remove all git-ignored files from tracking, commit, and push |
| `keep_branch <branch>` | Delete every local branch except the named one, `main`, and `master` |
| `gitlog` | Interactive menu: export commits to a `.txt` file filtered by date range and author |
| `dpush` | Run `./push.sh` in the current project directory |

---

### Frontend / Node

| Command | Description |
|---------|-------------|
| `dev` | `npm run dev` |
| `build` | `npm run build` |
| `ck` | `npm run check` |
| `fm` | `npm run format` |
| `lint` | `npm run lint` |

---

### Redis

| Command | Description |
|---------|-------------|
| `rclear` | Flush the current Redis database (`FLUSHDB`) |

---

## Examples

```zsh
# Start a Laravel dev server
pas

# Run fresh migrations with seeds and set up Passport
mp

# Quick commit and push
gp "feat: add user auth"

# Push without triggering CI
gtp "chore: update config"

# Run code quality checks before opening a PR
cicd

# Run tests with coverage and open the HTML report
coverage

# Export commits from the last 7 days to a text file
gitlog
# → select option 4, enter 7

# Delete all local branches except the one you're working on
keep_branch feature/my-feature

# Kill whatever is running on port 8000
killport 8000

# Seed only a specific seeder
seedclass UserSeeder RoleSeeder
```
