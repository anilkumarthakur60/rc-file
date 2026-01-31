export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/anilthakur/Library/Application Support/Herd/config/php/83/"


# Herd injected NVM configuration
export NVM_DIR="/Users/anilthakur/Library/Application Support/Herd/config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"

# Herd injected PHP binary.
export PATH="/Users/anilthakur/Library/Application Support/Herd/bin/":$PATH


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/anilthakur/Library/Application Support/Herd/config/php/84/"


# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/anilthakur/Library/Application Support/Herd/config/php/82/"
export PATH=$PATH:~/.composer/vendor/bin


# ---------Custom commands---------

function cls() {
  clear
}

function pa() {
  # php artisan + passthrough args
  php artisan "$@"
}

function pao() {
  php artisan optimize "$@"
}

function pam() {
  php artisan migrate "$@"
}

function pas() {
  php artisan serve "$@"
}

function pat() {
  php artisan tinker "$@"
}

function cr() {
  composer require "$@"
}

function cu() {
  composer update "$@"
}

function ci() {
  composer install "$@"
}

function cdu() {
  composer dump-autoload "$@"
}

function gst() {
  git status "$@"
}

function dcopy() {
  local cwd
  cwd="$(pwd)"
  printf '%s' "$cwd" | pbcopy && echo "Copied '$cwd' to clipboard."
}
function horizon() {
  clear
  php artisan horizon "$@"
}


function cicd() {
  # Run static analysis, formatting, and tests
  if [ ! -x ./vendor/bin/phpstan ]; then
    echo "cicd: ./vendor/bin/phpstan not found or not executable."
    return 1
  fi
  if [ ! -x ./vendor/bin/pint ]; then
    echo "cicd: ./vendor/bin/pint not found or not executable."
    return 1
  fi
  if [ ! -x ./vendor/bin/pest ]; then
    echo "cicd: ./vendor/bin/pest not found or not executable."
    return 1
  fi

  ./vendor/bin/phpstan analyse --memory-limit=4G && echo "phpstan run successfully" || { echo "phpstan failed"; return 1; }
  ./vendor/bin/pint && echo "pint run successfully" || { echo "pint failed"; return 1; }
  ./vendor/bin/pest && echo "pest run successfully" || { echo "pest failed"; return 1; }
}

function paoc() {
  php artisan permission:cache-reset && echo "permission cache reset"
  php artisan cache:forget spatie.permission.cache && echo "permission cache forget"
  php artisan optimize:clear && echo "optimize clear"
}

function gp() {
  # git add ., commit with optional message, then push
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "gp: not a git repository."
    return 1
  fi

  if git diff --quiet && git diff --cached --quiet; then
    echo "gp: nothing to commit."
    return 0
  fi

  local msg
  if [ "$#" -gt 0 ]; then
    msg="$*"
  else
    msg="fix: minor changes"
  fi

  git add . || return 1
  git commit -m "$msg" || return 1
  git push origin HEAD
}

function gtp() {
  # git add ., commit with [skip ci], then push
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "gtp: not a git repository."
    return 1
  fi

  if git diff --quiet && git diff --cached --quiet; then
    echo "gtp: nothing to commit."
    return 0
  fi

  local msg
  if [ "$#" -gt 0 ]; then
    msg="$* [skip ci]"
  else
    msg="fix: minor changes [skip ci]"
  fi

  git add . || return 1
  git commit -m "$msg" || return 1
  git push origin HEAD
}

function gitRemove() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "gitRemove: not a git repository."
    return 1
  fi

  git rm -r --cached . || return 1
  git add . || return 1
  git commit -m "Remove all ignored files from tracking" || return 1
  git push origin HEAD
}

function gc() {
  if [ -z "$1" ]; then
    echo "Usage: gc <branch>"
    return 1
  fi

  if git fetch; then
    echo "git fetch successfully"
    if ! git checkout "$1"; then
      echo "Failed to checkout branch $1"
      return 1
    fi
  else
    echo "Failed to fetch from remote repository"
    return 1
  fi
}

function pulls() {
  git fetch --prune --tags || { echo "pulls: fetch failed."; return 1; }

  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [ "$branch" = "HEAD" ]; then
    echo "Detached HEAD. Specify a branch."
    return 2
  fi

  git pull origin "${1:-$branch}"
}

function pull() {
  # Usage: pull [branch] [remote]

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Not a git repository."
    return 1
  }

  git fetch --prune --tags || {
    echo "git fetch failed."
    return 1
  }

  local remote branch upstream has_upstream
  local arg_branch="${1-}" arg_remote="${2-}"

  if upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @"{u}" 2>/dev/null); then
    has_upstream=1
    remote="${upstream%%/*}"
    branch="${upstream#*/}"
  else
    has_upstream=0
    branch="${arg_branch:-$(git rev-parse --abbrev-ref HEAD)}"
    remote="${arg_remote:-origin}"

    if [ "$branch" = "HEAD" ] || [ -z "$branch" ]; then
      echo "Detached HEAD. Specify a branch: pull <branch> [remote]"
      return 2
    fi
  fi

  git remote get-url "$remote" >/dev/null 2>&1 || {
    echo "Remote '$remote' does not exist."
    return 3
  }

  if [ "$has_upstream" = "0" ]; then
    if git ls-remote --exit-code --heads "$remote" "$branch" >/dev/null 2>&1; then
      echo "Setting upstream to $remote/$branch"
      git branch --set-upstream-to="$remote/$branch" "$branch" >/dev/null 2>&1 || true
    fi
  fi

  if git config --bool pull.rebase | grep -q true; then
    git pull --rebase "$remote" "$branch"
  else
    git pull "$remote" "$branch"
  fi
}

function push() {
  if [ -n "$1" ]; then
    git push origin "$1"
  else
    git push
  fi
}

function fetch() {
  git fetch "$@"
}

function pint() {
  if [ -x ./vendor/bin/pint ]; then
    ./vendor/bin/pint "$@"
  else
    echo "pint: ./vendor/bin/pint not found."
    return 1
  fi
}

function phpunit() {
  if [ -x ./vendor/bin/phpunit ]; then
    ./vendor/bin/phpunit "$@"
  else
    echo "phpunit: ./vendor/bin/phpunit not found."
    return 1
  fi
}

function phpstan() {
  clear
  if [ -x ./vendor/bin/phpstan ]; then
    ./vendor/bin/phpstan analyse --memory-limit=4G "$@"
  else
    echo "phpstan: ./vendor/bin/phpstan not found."
    return 1
  fi
}

function pest() {
  if [ -x ./vendor/bin/pest ]; then
    ./vendor/bin/pest -d memory_limit=8G "$@"
  else
    echo "pest: ./vendor/bin/pest not found."
    return 1
  fi
}

function zs() {
  if [ -f "$HOME/.zshrc" ]; then
    # shellcheck disable=SC1090
    source "$HOME/.zshrc"
    echo "zshrc file sourced"
  else
    echo "~/.zshrc not found."
    return 1
  fi
}

function ck() {
  if command -v npm >/dev/null 2>&1; then
    npm run check
  else
    echo "ck: npm not found."
    return 1
  fi
}

function rl() {
  php artisan r:l "$@"
}

function fm() {
  if command -v npm >/dev/null 2>&1; then
    npm run format
  else
    echo "fm: npm not found."
    return 1
  fi
}

function lint() {
  if command -v npm >/dev/null 2>&1; then
    npm run lint
  else
    echo "lint: npm not found."
    return 1
  fi
}

function stash() {
  git stash "$@"
}

function pop() {
  git stash pop "$@"
}

function dev() {
  if command -v npm >/dev/null 2>&1; then
    npm run dev
  else
    echo "dev: npm not found."
    return 1
  fi
}

function build() {
  if command -v npm >/dev/null 2>&1; then
    npm run build
  else
    echo "build: npm not found."
    return 1
  fi
}
function rclear() {
  if command -v redis-cli >/dev/null 2>&1; then
    redis-cli FLUSHDB
    echo "Redis database flushed"
  else
    echo "rclear: redis-cli not found."
    return 1
  fi
}

function ww() {
  # Ask apps to quit immediately (fast + cleaner than -9)
  osascript -e 'tell application "PhpStorm" to quit' 2>/dev/null
  osascript -e 'tell application "WebStorm" to quit' 2>/dev/null
  osascript -e 'tell application "Visual Studio Code" to quit' 2>/dev/null

  # Give them a moment, then kill anything still alive
  sleep 1
  pkill -9 -f "PhpStorm|phpstorm" 2>/dev/null
  pkill -9 -f "WebStorm|webstorm" 2>/dev/null
  pkill -9 -f "Visual Studio Code|com\.microsoft\.VSCode|Code Helper" 2>/dev/null
}



function mp() {
  if command -v redis-cli >/dev/null 2>&1; then
    redis-cli FLUSHDB
    echo "Redis database flushed"
  else
    echo "mp: redis-cli not found."
    return 1
  fi

  php artisan migrate:fresh --seed || return 1
  php artisan passport:client --personal
}

function mf() {
  if command -v redis-cli >/dev/null 2>&1; then
    redis-cli FLUSHDB
    echo "Redis database flushed"
  else
    echo "mf: redis-cli not found."
    return 1
  fi

  php artisan migrate:fresh --seed
}


function seed() {
  php artisan db:seed "$@"
}

function seedclass() {
  if [[ $# -eq 0 ]]; then
    echo 'Usage: seedclass <SeederClassName...> [artisan options...]'
    return 1
  fi

  local -a classes opts
  classes=()
  opts=()

  # Treat tokens that start with "-" as artisan options; everything else as class names
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == -* ]]; then
      opts+=("$1")
    else
      classes+=("$1")
    fi
    shift
  done

  if [[ ${#classes[@]} -eq 0 ]]; then
    echo 'Error: provide at least one seeder class name.'
    return 1
  fi

  local c
  for c in "${classes[@]}"; do
    echo ">> Seeding: $c"
    php artisan db:seed --class="$c" "${opts[@]}" || return $?
  done
}


function coverage-open(){
  open coverage-html/index.html
}

function coverage() {
  # Run Pest with Xdebug coverage enabled and 8GB memory
  XDEBUG_MODE=coverage ./vendor/bin/pest -d memory_limit=8G \
    --coverage --min=0 --coverage-html=coverage-html || return 1

  local report="coverage-html/index.html"

  if [[ ! -f "$report" ]]; then
    echo "Coverage HTML report not found at $report"
    return 1
  fi

  # Open coverage report based on platform
  if command -v open >/dev/null 2>&1; then
    open "$report"          # macOS
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$report"      # Linux
  else
    echo "Your system does not support 'open' or 'xdg-open'."
    echo "Open the report manually: $report"
  fi
}



# delete all git branches except the one passed as argument
function keep_branch() {
  if [ -z "$1" ]; then
    echo "❌ Error: Please provide the branch name you want to keep."
    echo "Usage: keep_branch <branch>"
    return 1
  fi

  local keep="$1"

  echo "🔥 This will delete ALL local branches except: $keep, main, master"
  read "resp?Are you sure? (y/N) "

  if [[ ! "$resp" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    return 0
  fi

  git branch | grep -v "$keep" | grep -v "main" | grep -v "master" | sed 's/* //g' | while read branch
  do
    if [ -n "$branch" ]; then
      echo "Deleting branch: $branch"
      git branch -D "$branch"
    fi
  done

  echo "✅ Done. Only '$keep', 'main', and 'master' remain."
}


function gitlog() {
  emulate -L zsh
  setopt pipefail

  # Colors (using tput for compatibility)
  local RED=$(tput setaf 1 2>/dev/null || echo "")
  local GREEN=$(tput setaf 2 2>/dev/null || echo "")
  local YELLOW=$(tput setaf 3 2>/dev/null || echo "")
  local BLUE=$(tput setaf 4 2>/dev/null || echo "")
  local CYAN=$(tput setaf 6 2>/dev/null || echo "")
  local BOLD=$(tput bold 2>/dev/null || echo "")
  local RESET=$(tput sgr0 2>/dev/null || echo "")

  # Ensure we're in a git repo
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "${RED}❌ Not inside a git repository.${RESET}"
    return 1
  fi

  # Get current branch info
  local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
  echo "${CYAN}${BOLD}📋 Git Commit Log Exporter${RESET}"
  echo "${BLUE}Current branch: ${BOLD}${current_branch}${RESET}\n"

  _gitlog_export() {
    local since="$1"
    local until="$2"
    local label="$3"
    local author="$4"
    local file="commits_${label}.txt"

    # Build git log command properly
    local -a cmd
    cmd=(git log --since="$since" --pretty=format:"%h | %an | %ad | %s" --date=short)
    [[ -n "$until" ]] && cmd+=(--until="$until")
    # Only add author filter if author is non-empty (trim whitespace first)
    author="${author##[[:space:]]*}"  # Remove leading whitespace
    author="${author%%[[:space:]]*}"   # Remove trailing whitespace
    [[ -n "$author" ]] && cmd+=(--author="$author")

    # Get commit count first using proper command execution
    local count
    count=$("${cmd[@]}" --oneline 2>/dev/null | wc -l | tr -d ' ')
    count=${count:-0}

    if (( count == 0 )); then
      echo "${YELLOW}⚠️  No commits found for the selected range.${RESET}"
      echo "   Range: ${CYAN}since='$since'${until:+ until='$until'}${RESET}"
      [[ -n "$author" ]] && echo "   Author: ${CYAN}$author${RESET}"
      read -q "confirm?Create empty file anyway? [y/N]: "
      echo
      if [[ "$confirm" != "y" ]]; then
        echo "${BLUE}Operation cancelled.${RESET}"
        return 0
      fi
      : > "$file"
      echo "${GREEN}✔ Empty file created: ${BOLD}$file${RESET}"
      return 0
    fi

    # Show preview
    echo "\n${CYAN}${BOLD}📊 Preview:${RESET}"
    echo "${BLUE}Found ${BOLD}${count}${RESET}${BLUE} commit(s)${RESET}"
    echo "${BLUE}Range: ${CYAN}since='$since'${until:+ until='$until'}${RESET}"
    [[ -n "$author" ]] && echo "${BLUE}Author filter: ${CYAN}$author${RESET}"
    echo "${BLUE}Output file: ${CYAN}${BOLD}$file${RESET}\n"

    # Show first 5 commits as preview
    local preview
    preview=$("${cmd[@]}" 2>/dev/null | head -5)
    if [[ -n "$preview" ]]; then
      echo "${YELLOW}First 5 commits:${RESET}"
      echo "$preview" | sed "s/^/  /"
      (( count > 5 )) && echo "${BLUE}  ... and $((count - 5)) more${RESET}\n"
    fi

    # Confirm before saving
    read -q "confirm?Save to file? [Y/n]: "
    echo
    if [[ "$confirm" == "n" ]]; then
      echo "${BLUE}Operation cancelled.${RESET}"
      return 0
    fi

    # Run and capture output using proper command execution
    echo "${BLUE}⏳ Exporting commits...${RESET}"
    local out
    out=$("${cmd[@]}" 2>&1)
    local ret=$?

    if (( ret != 0 )); then
      echo "${RED}❌ git log failed:${RESET}"
      echo "$out"
      return $ret
    fi

    # Save to file
    print -r -- "$out" > "$file"
    local file_size
    file_size=$(wc -l < "$file" | tr -d ' ')
    
    echo "${GREEN}✔ Successfully exported ${BOLD}${file_size}${RESET}${GREEN} commit(s) to: ${BOLD}$file${RESET}"
    
    # Option to open file
    if command -v open >/dev/null 2>&1 || command -v xdg-open >/dev/null 2>&1; then
      read -q "open_file?Open file? [y/N]: "
      echo
      if [[ "$open_file" == "y" ]]; then
        if command -v open >/dev/null 2>&1; then
          open "$file" 2>/dev/null || ${EDITOR:-nano} "$file"
        elif command -v xdg-open >/dev/null 2>&1; then
          xdg-open "$file" 2>/dev/null || ${EDITOR:-nano} "$file"
        else
          ${EDITOR:-nano} "$file"
        fi
      fi
    fi
  }

  _get_authors() {
    echo "${CYAN}Available authors:${RESET}"
    git shortlog -sn --all 2>/dev/null | head -10 | sed 's/^/  /'
    echo
  }

  # Main menu
  echo "${BOLD}Select commit log range:${RESET}"
  local options=(
    "Today"
    "Yesterday"
    "Day before yesterday"
    "Last N days"
    "Last N weeks"
    "Last N months"
    "Custom range (since..until)"
    "Default (1 month)"
    "Cancel"
  )

  PS3="${CYAN}Select option [1-${#options[@]}]: ${RESET}"
  select opt in "${options[@]}"; do
    case "$REPLY" in
      1)
        _get_authors
        local author
        read "author?Filter by author (press Enter to skip): "
        # Trim whitespace (leading and trailing)
        author="${author##[[:space:]]*}"
        author="${author%%[[:space:]]*}"
        _gitlog_export "midnight" "" "today" "$author"
        break
        ;;
      2)
        _get_authors
        local author
        read "author?Filter by author (press Enter to skip): "
        author="${author##[[:space:]]*}"
        author="${author%%[[:space:]]*}"
        _gitlog_export "yesterday midnight" "midnight" "yesterday" "$author"
        break
        ;;
      3)
        _get_authors
        local author
        read "author?Filter by author (press Enter to skip): "
        author="${author##[[:space:]]*}"
        author="${author%%[[:space:]]*}"
        _gitlog_export "2 days ago midnight" "yesterday midnight" "day_before_yesterday" "$author"
        break
        ;;
      4)
        local n
        read "n?${CYAN}Enter number of days: ${RESET}"
        [[ "$n" == <-> ]] || { echo "${RED}❌ Please enter a valid number.${RESET}"; continue; }
        _get_authors
        local author
        read "author?Filter by author (press Enter to skip): "
        author="${author##[[:space:]]*}"
        author="${author%%[[:space:]]*}"
        _gitlog_export "$n days ago" "" "last_${n}_days" "$author"
        break
        ;;
      5)
        local n
        read "n?${CYAN}Enter number of weeks: ${RESET}"
        [[ "$n" == <-> ]] || { echo "${RED}❌ Please enter a valid number.${RESET}"; continue; }
        _get_authors
        local author
        read "author?Filter by author (press Enter to skip): "
        author="${author##[[:space:]]*}"
        author="${author%%[[:space:]]*}"
        _gitlog_export "$n weeks ago" "" "last_${n}_weeks" "$author"
        break
        ;;
      6)
        local n
        read "n?${CYAN}Enter number of months: ${RESET}"
        [[ "$n" == <-> ]] || { echo "${RED}❌ Please enter a valid number.${RESET}"; continue; }
        _get_authors
        local author
        read "author?Filter by author (press Enter to skip): "
        author="${author##[[:space:]]*}"
        author="${author%%[[:space:]]*}"
        _gitlog_export "$n months ago" "" "last_${n}_months" "$author"
        break
        ;;
      7)
        local since until label author
        echo "${CYAN}Enter date range:${RESET}"
        read "since?Since (e.g. 2025-11-01 or '2 weeks ago'): "
        read "until?Until (e.g. 2025-12-01 or 'midnight') [optional]: "
        _get_authors
        read "author?Filter by author (press Enter to skip): "
        author="${author##[[:space:]]*}"
        author="${author%%[[:space:]]*}"
        label="custom_${since//[^A-Za-z0-9]/_}"
        [[ -n "$until" ]] && label="${label}_to_${until//[^A-Za-z0-9]/_}"
        _gitlog_export "$since" "$until" "$label" "$author"
        break
        ;;
      8)
        _get_authors
        local author
        read "author?Filter by author (press Enter to skip): "
        author="${author##[[:space:]]*}"
        author="${author%%[[:space:]]*}"
        _gitlog_export "1 month ago" "" "last_1_month" "$author"
        break
        ;;
      9)
        echo "${BLUE}Operation cancelled.${RESET}"
        return 0
        ;;
      *)
        echo "${RED}❌ Invalid option. Please choose 1-${#options[@]}.${RESET}"
        ;;
    esac
  done
}

# Push current repo to a temporary "dev-origin" remote, then optionally remove it.
# Usage:
#   devpush git@github.com:techdevnepal/scraper.git
#   devpush --keep git@github.com:techdevnepal/scraper.git
#   devpush --remote mytmp git@github.com:techdevnepal/scraper.git
#   devpush --yes git@github.com:techdevnepal/scraper.git   # skip prompts, delete remote (default)
#
# Notes:
# - Pushes all local branches and tags.
# - Also pushes current branch and sets upstream on dev-origin.

function 
devpush() {
  emulate -L zsh
  setopt pipefail

  local keep=0
  local assume_yes=0
  local remote_name="dev-origin"

  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -k|--keep) keep=1; shift ;;
      -y|--yes) assume_yes=1; shift ;;
      -r|--remote)
        remote_name="$2"
        if [[ -z "$remote_name" ]]; then
          print -u2 "Error: --remote requires a name"
          return 2
        fi
        shift 2
        ;;
      -h|--help)
        print "Usage: devpush [--keep] [--yes] [--remote NAME] <git-ssh-url>"
        return 0
        ;;
      *)
        break
        ;;
    esac
  done

  local url="$1"
  if [[ -z "$url" ]]; then
    print -u2 "Error: Missing git SSH URL."
    print -u2 "Example: devpush git@github.com:techdevnepal/scraper.git"
    return 2
  fi

  # Must be inside a git repo
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print -u2 "Error: Not inside a git repository."
    return 2
  fi

  # Require at least one commit
  if ! git rev-parse HEAD >/dev/null 2>&1; then
    print -u2 "Error: This repo has no commits yet. Commit first, then run devpush."
    return 2
  fi

  local current_branch
  current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

  print "Remote name : $remote_name"
  print "Remote URL  : $url"
  print "Branch      : $current_branch"
  print ""

  # If remote exists, prompt to overwrite
  if git remote get-url "$remote_name" >/dev/null 2>&1; then
    local existing
    existing="$(git remote get-url "$remote_name" 2>/dev/null)"

    if [[ "$assume_yes" -eq 0 ]]; then
      print -n "Remote '$remote_name' already exists ($existing). Overwrite? [y/N]: "
      local ans
      read -r ans
      if [[ ! "$ans" == [yY]* ]]; then
        print "Aborted."
        return 1
      fi
    fi

    git remote remove "$remote_name" || {
      print -u2 "Error: Failed to remove existing remote '$remote_name'."
      return 1
    }
  fi

  # Add the temp remote
  git remote add "$remote_name" "$url" || {
    print -u2 "Error: Failed to add remote '$remote_name' -> $url"
    return 1
  }

  # Push all branches
  print "\nPushing ALL branches to $remote_name ..."
  git push "$remote_name" --all
  if [[ $? -ne 0 ]]; then
    print -u2 "\n❌ Push of branches failed."
    print -u2 "Remote '$remote_name' kept so you can inspect/fix."
    return 1
  fi

  # Push tags
  print "\nPushing tags to $remote_name ..."
  git push "$remote_name" --tags
  if [[ $? -ne 0 ]]; then
    print -u2 "\n❌ Push of tags failed."
    print -u2 "Remote '$remote_name' kept so you can inspect/fix."
    return 1
  fi

  # Set upstream for current branch (if not detached)
  if [[ -n "$current_branch" && "$current_branch" != "HEAD" ]]; then
    print "\nSetting upstream for '$current_branch' on $remote_name ..."
    git push -u "$remote_name" "$current_branch"
    if [[ $? -ne 0 ]]; then
      print -u2 "\n❌ Setting upstream failed."
      print -u2 "Remote '$remote_name' kept so you can inspect/fix."
      return 1
    fi
  fi

  print "\n✅ Done pushing."

  # Keep remote?
  if [[ "$keep" -eq 1 ]]; then
    print "Keeping remote '$remote_name' (per --keep)."
    return 0
  fi

  # Ask to delete unless --yes
  if [[ "$assume_yes" -eq 0 ]]; then
    print -n "Delete remote '$remote_name' now? [Y/n]: "
    local del
    read -r del
    if [[ "$del" == [nN]* ]]; then
      print "Keeping remote '$remote_name'."
      return 0
    fi
  fi

  git remote remove "$remote_name" || {
    print -u2 "Warning: Could not remove remote '$remote_name'. Remove manually: git remote remove $remote_name"
    return 1
  }

  print "Removed remote '$remote_name'."
}

# Push local main -> dev/main (force) after adding remote "dev" from a URL.
# Usage:
#   devpush git@github.com:user/repo.git
#   devpush https://github.com/user/repo.git
#   devpush git@github.com:user/repo.git --delete-remote
#   devpush git@github.com:user/repo.git --remote myremote
#   devpush git@github.com:user/repo.git --hard   # uses --force instead of --force-with-lease
#
function pushdev () {
  emulate -L zsh
  set -euo pipefail

  if (( $# < 1 )); then
    echo "Usage: devpush <repo-url> [--delete-remote] [--remote <name>] [--hard]"
    return 2
  fi

  local repo_url="$1"
  shift

  local remote_name="dev"
  local delete_remote=0
  local hard_force=0

  while (( $# > 0 )); do
    case "$1" in
      --delete-remote|-d)
        delete_remote=1
        shift
        ;;
      --remote|-r)
        shift
        if (( $# == 0 )); then
          echo "Error: --remote requires a name"
          return 2
        fi
        remote_name="$1"
        shift
        ;;
      --hard)
        hard_force=1
        shift
        ;;
      -h|--help)
        echo "Usage: devpush <repo-url> [--delete-remote] [--remote <name>] [--hard]"
        return 0
        ;;
      *)
        echo "Unknown option: $1"
        echo "Usage: devpush <repo-url> [--delete-remote] [--remote <name>] [--hard]"
        return 2
        ;;
    esac
  done

  # Must be inside a git repo
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: not inside a git repository."
    return 1
  fi

  # Ensure local main exists and we're on it (since you asked push main)
  if ! git show-ref --verify --quiet refs/heads/main; then
    echo "Error: local branch 'main' does not exist."
    return 1
  fi

  local current_branch
  current_branch="$(git branch --show-current)"
  if [[ "$current_branch" != "main" ]]; then
    echo "Switching to 'main' (currently on '$current_branch')..."
    git switch main
  fi

  # Add or update remote
  if git remote get-url "$remote_name" >/dev/null 2>&1; then
    echo "Remote '$remote_name' exists. Setting URL to: $repo_url"
    git remote set-url "$remote_name" "$repo_url"
  else
    echo "Adding remote '$remote_name' -> $repo_url"
    git remote add "$remote_name" "$repo_url"
  fi

  # Force push local main -> remote main
  if (( hard_force )); then
    echo "Pushing (HARD FORCE): main -> $remote_name/main"
    git push "$remote_name" main:main --force
  else
    echo "Pushing (safer force): main -> $remote_name/main"
    git push "$remote_name" main:main --force-with-lease
  fi

  # Optionally delete remote
  if (( delete_remote )); then
    echo "Deleting remote '$remote_name'"
    git remote remove "$remote_name"
  fi

  echo "Done."
}

function gpp() {
  if [ -z "$1" ]; then
    echo "gpp: missing git repository URL"
    echo "usage: gpp git@github.com:user/repo.git"
    return 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "gpp: git not found."
    return 1
  fi

  local branch
  branch="$(git branch --show-current 2>/dev/null)"

  if [ -z "$branch" ]; then
    echo "gpp: not on a branch (detached HEAD)"
    return 1
  fi

  git remote add dev "$1" || return 1

  # push current branch -> same branch on dev
  git push dev "$branch" || {
    git remote remove dev
    return 1
  }

  git remote remove dev
  echo "Pushed dev $branch"
}

function dpush() {
  './push.sh'
}

function composerUpdate(){
  composer require $(composer show -s --format=json | jq '.requires | keys | map(.+" ") | add' -r)
  composer require --dev $(composer show -s --format=json | jq '.devRequires | keys | map(.+" ") | add' -r)
}


# ---------end of custom commands---------
export JAVA_HOME="$(brew --prefix openjdk)/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH"

# Created by `pipx` on 2025-05-12 09:08:08
export PATH="$PATH:/Users/anilthakur/.local/bin"

# Global bin directory for custom scripts
export PATH="$HOME/bin:$PATH"

# Conventional Commit Configuration
export USE_EMOJI=1
export WRAP_COL=72
export EDITOR_CMD="code -w"

# Git helpers alias
alias cc="$HOME/bin/cc"

# Added by Antigravity
export PATH="/Users/anilthakur/.antigravity/antigravity/bin:$PATH"


# Herd injected PHP 8.5 configuration.
export HERD_PHP_85_INI_SCAN_DIR="/Users/anilthakur/Library/Application Support/Herd/config/php/85/"
