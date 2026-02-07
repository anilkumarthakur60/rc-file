Easy 😄 — this is exactly what the `.zshrc.d` setup is for.

I’ll show you the **clean, correct zsh way**, step by step.

---

## 1️⃣ Create a file just for custom functions

Pick a name that’s obvious:

```zsh
mkdir -p ~/.zshrc.d
nano ~/.zshrc.d/functions.zsh
```

(Use `vim` or VS Code if you prefer.)

---

## 2️⃣ Put your custom functions in it

Example:

```zsh
# ~/.zshrc.d/functions.zsh

# Create a directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Kill a process by port
killport() {
  lsof -ti tcp:"$1" | xargs kill -9
}

# Quick MySQL connect
mydb() {
  mysql -u root -p
}
```

---

## 3️⃣ Make sure `.zshrc` loads it

Your `.zshrc` should already have something like this:

```zsh
for file in ~/.zshrc.d/*.zsh; do
  [[ -r "$file" ]] && source "$file"
done
```

If it does — you’re done ✅
If not, add it at the **bottom** of `.zshrc`.

---

## 4️⃣ Reload zsh (no restart needed)

```zsh
source ~/.zshrc
```

Now try:

```zsh
mkcd test
killport 3000
```

---

## Pro tips (worth it)

### 🔹 Avoid name collisions

Before naming a function:

```zsh
type mkcd
```

If it says `not found`, you’re safe.

---

### 🔹 Autoload (optional, nerdy, fast)

If you want **zsh-native autoloading**:

```zsh
mkdir -p ~/.zfunc
```

Put one function per file:

```zsh
~/.zfunc/mkcd
```

```zsh
# ~/.zfunc/mkcd
mkcd() {
  mkdir -p "$1" && cd "$1"
}
```

Then in `.zshrc`:

```zsh
fpath=(~/.zfunc $fpath)
autoload -Uz mkcd
```

This loads functions **only when used** (faster startup).

---

## TL;DR

* ✅ Create `~/.zshrc.d/functions.zsh`
* ✅ Put your functions there
* ✅ Source it from `.zshrc`
* 🔥 Optional: use `autoload` for performance
