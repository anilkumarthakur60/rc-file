

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

function dpush() {
  './push.sh'
}

function composerUpdate(){
  composer require $(composer show -s --format=json | jq '.requires | keys | map(.+" ") | add' -r)
  composer require --dev $(composer show -s --format=json | jq '.devRequires | keys | map(.+" ") | add' -r)
}
