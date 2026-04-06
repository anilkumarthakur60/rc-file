# rc-file

A collection of custom zsh functions for Laravel, Git, and frontend development workflows.

## Installation (macOS)

**1. Clone the repo**

```zsh
git clone <repo-url> ~/rc-file
```

**2. Create `~/.zshrc.d` if it doesn't exist**

```zsh
mkdir -p ~/.zshrc.d
```

**3. Symlink `bashrc.zsh` into `~/.zshrc.d`**

```zsh
ln -s ~/rc-file/bashrc.zsh ~/.zshrc.d/rc-file.zsh
```

**4. Make sure `~/.zshrc` loads all files from `~/.zshrc.d`**

Add this to the bottom of `~/.zshrc` if it isn't already there:

```zsh
for file in ~/.zshrc.d/*.zsh; do
  [[ -r "$file" ]] && source "$file"
done
```

**5. Reload your shell**

```zsh
source ~/.zshrc
```

> **Tip:** Using a symlink means you can `git pull` inside `~/rc-file` to get updates — no need to touch `~/.zshrc.d` again.

---

## Functions Reference

### General

| Command | Description |
|---------|-------------|
| `cls` | Clear the terminal |
| `mkcd <dir>` | Create a directory and `cd` into it |
| `killport <port>` | Kill the process listening on a port |
| `mydb` | Connect to MySQL as root |
| `zs` | Re-source `~/.zshrc` |
| `ww` | Quit PhpStorm, WebStorm, and VS Code |
| `dcopy` | Copy the current working directory path to clipboard |

---

### Laravel / PHP Artisan

| Command | Description |
|---------|-------------|
| `pa [args]` | `php artisan` with passthrough args |
| `pao [args]` | `php artisan optimize` |
| `pam [args]` | `php artisan migrate` |
| `pas [args]` | `php artisan serve` |
| `pat [args]` | `php artisan tinker` |
| `rl [args]` | `php artisan r:l` (route list) |
| `horizon [args]` | Clears screen then runs `php artisan horizon` |
| `paoc` | Reset permission cache and run `optimize:clear` |
| `seed [args]` | `php artisan db:seed` |
| `seedclass <Class...>` | Seed specific seeder classes |
| `mf` | Flush Redis, then `migrate:fresh --seed` |
| `mp` | Flush Redis, `migrate:fresh --seed`, then create Passport personal client |
| `refresh` | Run `./refresh.sh` in the current project |

---

### Composer

| Command | Description |
|---------|-------------|
| `cr [args]` | `composer require` |
| `cu [args]` | `composer update` |
| `ci [args]` | `composer install` |
| `cdu [args]` | `composer dump-autoload` |
| `composerUpdate` | Re-require all current dependencies (force-updates them) |

---

### Testing & Code Quality

| Command | Description |
|---------|-------------|
| `pest [args]` | Run Pest with 8GB memory limit |
| `phpunit [args]` | Run PHPUnit |
| `phpstan [args]` | Run PHPStan with 4GB memory limit |
| `pint [args]` | Run Laravel Pint code formatter |
| `cicd` | Run PHPStan + Pint (pre-merge quality check) |
| `coverage` | Run Pest with Xdebug coverage, generate HTML report, and open it |
| `coverage-open` | Open the last generated coverage HTML report |

---

### Git

| Command | Description |
|---------|-------------|
| `gst [args]` | `git status` |
| `gc <branch>` | Fetch then checkout a branch |
| `pull [branch] [remote]` | Smart pull — handles upstream tracking automatically |
| `push [branch]` | `git push` (optionally to a specific branch) |
| `fetch [args]` | `git fetch` |
| `stash [args]` | `git stash` |
| `pop [args]` | `git stash pop` |
| `gp [message]` | Add all, commit, and push (defaults to `"fix: minor changes"`) |
| `gtp [message]` | Same as `gp` but appends `[skip ci]` to the commit message |
| `gitRemove` | Remove all git-ignored files from tracking and push |
| `keep_branch <branch>` | Delete all local branches except the given one, `main`, and `master` |
| `gitlog` | Interactive menu to export git commit logs to a `.txt` file by date range and author |
| `dpush` | Run `./push.sh` in the current project |

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

# Run all migrations fresh with seeds and Passport setup
mp

# Quick git add, commit, push
gp "feat: add user auth"

# Push without triggering CI
gtp "chore: update config"

# Export commits from the last 7 days to a file
gitlog   # then select option 4 and enter 7

# Run tests with coverage and open the report
coverage

# Delete all local branches except feature/my-branch
keep_branch feature/my-branch

# Kill whatever is running on port 8000
killport 8000
```
