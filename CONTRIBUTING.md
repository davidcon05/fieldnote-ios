# Contributing to FieldNote

This is a personal learning project, but this guide documents the Git workflow for working across multiple machines.

---

## Git Workflow

### Daily Workflow

**Before starting work:**
```bash
cd /Users/davidcontreras/AppleXcodeProjects/fieldnote
git pull
```

**After making changes:**
```bash
git add .
git commit -m "Descriptive commit message"
git push
```

---

## SSH Key Setup (Multiple GitHub Accounts)

This project uses a **personal GitHub account** (`davidcon05`) while work projects use a **work account** (`davecon02`). Multiple SSH keys are configured to handle both.

### Current Configuration

| GitHub Account | SSH Key | Projects |
|---------------|---------|----------|
| `davecon02` (work) | `~/.ssh/id_ed25519` | Work projects (GitLab) |
| `davidcon05` (personal) | `~/.ssh/id_ed25519_davidcon05` | FieldNote (GitHub) |

### SSH Config (`~/.ssh/config`)

```bash
# Work GitHub account (davecon02)
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519

# Personal GitHub account (davidcon05)
Host github-davidcon05
  HostName github.com
  User git
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519_davidcon05
```

### Git Remote URL

This project uses the **personal account** via custom SSH host:
```
git@github-davidcon05:davidcon05/fieldnote-ios.git
```

**Note:** `github-davidcon05` is NOT a real host - it's an alias in `~/.ssh/config` that tells SSH to use the davidcon05 key.

---

## Setting Up on a New Machine

### Option 1: Use Existing SSH Key (Easiest)

If you already have the `id_ed25519_davidcon05` key on another Mac:

1. **Copy SSH key from existing Mac:**
   ```bash
   # On existing Mac, copy private key
   cat ~/.ssh/id_ed25519_davidcon05

   # Copy the output, then on new Mac:
   nano ~/.ssh/id_ed25519_davidcon05
   # Paste the key, save (Ctrl+O, Enter, Ctrl+X)

   # Set permissions
   chmod 600 ~/.ssh/id_ed25519_davidcon05
   ```

2. **Add SSH config:**
   ```bash
   # Add to ~/.ssh/config
   cat >> ~/.ssh/config << 'EOF'

   # Personal GitHub account (davidcon05)
   Host github-davidcon05
     HostName github.com
     User git
     AddKeysToAgent yes
     UseKeychain yes
     IdentityFile ~/.ssh/id_ed25519_davidcon05
   EOF
   ```

3. **Clone the repo:**
   ```bash
   cd ~/AppleXcodeProjects
   git clone git@github-davidcon05:davidcon05/fieldnote-ios.git fieldnote
   cd fieldnote
   open fieldnote.xcodeproj
   ```

### Option 2: Generate New SSH Key

If you don't have the key:

1. **Generate new key:**
   ```bash
   ssh-keygen -t ed25519 -C "davidcon05@github.com" -f ~/.ssh/id_ed25519_davidcon05 -N ""
   ```

2. **Add to GitHub:**
   - Copy public key: `cat ~/.ssh/id_ed25519_davidcon05.pub`
   - GitHub.com → Settings → SSH and GPG keys → New SSH key
   - Paste the key, save

3. **Add SSH config** (same as Option 1 step 2)

4. **Clone** (same as Option 1 step 3)

---

## Troubleshooting

### Push Fails: "Permission denied"

**Symptom:**
```
ERROR: Permission to davidcon05/fieldnote-ios.git denied to davecon02.
```

**Cause:** SSH agent is using the wrong key (work key instead of personal)

**Fix:**
```bash
# Clear SSH agent
ssh-add -D

# Add personal key
ssh-add ~/.ssh/id_ed25519_davidcon05

# Verify (should say "Hi davidcon05!")
ssh -T git@github-davidcon05

# Push again
git push
```

### SSH Agent Clears After Reboot

**Symptom:** Push works initially, fails after restarting Mac

**Cause:** SSH agent doesn't persist keys across reboots

**Fix:**
```bash
# Add key to agent
ssh-add ~/.ssh/id_ed25519_davidcon05

# Or make it persist (already configured in ~/.ssh/config):
# AddKeysToAgent yes
# UseKeychain yes
```

### Wrong Remote URL

**Check current remote:**
```bash
git remote -v
```

**Should show:**
```
origin  git@github-davidcon05:davidcon05/fieldnote-ios.git (fetch)
origin  git@github-davidcon05:davidcon05/fieldnote-ios.git (push)
```

**If wrong, fix it:**
```bash
git remote set-url origin git@github-davidcon05:davidcon05/fieldnote-ios.git
```

---

## Commit Message Conventions

### Format

```
<type>: <short description>

<optional detailed explanation>
```

### Types

| Type | When to Use | Example |
|------|------------|---------|
| `feat` | New feature | `feat: Add SwiftData models for Journal and Entry` |
| `fix` | Bug fix | `fix: Correct GPS coordinate rounding` |
| `docs` | Documentation only | `docs: Update architecture diagram` |
| `refactor` | Code refactor (no behavior change) | `refactor: Extract LocationManager to service` |
| `test` | Add or update tests | `test: Add unit tests for WeatherService` |
| `chore` | Build, dependencies, tooling | `chore: Update Xcode project settings` |

### Examples

**Good:**
```
feat: Add Weather struct for API response

- Codable struct for OpenWeatherMap API
- Stored as JSON inside Entry
- Properties: condition, temperature, humidity, windSpeed
```

**Bad:**
```
updates
```
```
wip
```
```
fixed stuff
```

### When to Commit

| ✅ Commit When | ❌ Don't Commit When |
|---------------|---------------------|
| Feature complete and working | Code doesn't compile |
| Tests pass | Breaking existing features |
| Meaningful progress | Just saving work (use stash instead) |
| End of work session | Half-written code |

---

## Coding Standards

### Async/Await Patterns

#### ❌ NEVER: Infinite Loops with AsyncSequence

**Don't do this:**
```swift
// BAD - Infinite loop that freezes UI
Task {
    for await value in publisher.values {
        await doSomething(value)
    }
}
```

**Problem:** The loop never ends, blocks the UI, and creates memory issues.

#### ✅ DO: Use onChange with Proper Cleanup

**Do this instead:**
```swift
// GOOD - Reactive updates with cleanup
@State private var task: Task<Void, Never>?

.onChange(of: someValue) { old, new in
    if let newValue = new {
        handleUpdate(newValue)
    }
}
.onDisappear {
    task?.cancel()
}
```

### API Calls & Network Requests

#### Always Use Timeouts

**Required:** All API calls must timeout after 10 seconds max.

```swift
// GOOD - API call with timeout
private func fetchWeather() {
    weatherTask = Task {
        do {
            let data = try await withTimeout(seconds: 10) {
                try await apiService.fetch()
            }
            // Handle success
        } catch is TimeoutError {
            // Handle timeout
            errorMessage = "Request timed out"
        } catch {
            // Handle other errors
            errorMessage = error.localizedDescription
        }
    }
}

// Reusable timeout helper
private func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError()
        }
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

struct TimeoutError: Error {}
```

#### Never Block View Loading

**UI must load immediately** - data can populate asynchronously.

```swift
// BAD - Blocks UI while waiting for data
.onAppear {
    let data = await fetchData()  // UI frozen!
    displayData(data)
}

// GOOD - UI loads, shows loading state, updates when ready
.onAppear {
    Task {
        isLoading = true
        do {
            let data = try await fetchData()
            self.data = data
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

#### Provide Retry Options

When network requests fail, give users a way to retry:

```swift
// Show retry button on error
if errorMessage != nil {
    Button("Retry") {
        retryFetch()
    }
}
```

### Task Lifecycle Management

**Always clean up async tasks:**

```swift
@State private var fetchTask: Task<Void, Never>?

.onAppear {
    fetchTask = Task {
        await doWork()
    }
}
.onDisappear {
    fetchTask?.cancel()
    fetchTask = nil
}
```

### Loading States

**Every async operation needs three states:**

1. **Loading** - Show spinner/progress
2. **Success** - Display data
3. **Error** - Show error + retry button

```swift
@State private var data: DataType?
@State private var isLoading = false
@State private var errorMessage: String?

// In view
if isLoading {
    ProgressView()
} else if let error = errorMessage {
    VStack {
        Text(error)
        Button("Retry") { retry() }
    }
} else if let data = data {
    DisplayView(data: data)
} else {
    Text("Waiting for data...")
}
```

### Summary

| ✅ Do | ❌ Don't |
|-------|----------|
| Use `onChange` for reactive updates | Use infinite `for await` loops |
| Timeout all API calls (10s max) | Let requests hang indefinitely |
| Load UI immediately | Block UI while fetching data |
| Provide retry buttons on errors | Leave users stuck on errors |
| Cancel tasks in `onDisappear` | Let tasks run forever |
| Show loading/error/success states | Assume network calls succeed |

**Lesson Learned:** These patterns prevent UI freezes, improve UX, and make debugging easier.

---

## Branch Strategy

**Current:** Working directly on `main`

**Why:** Solo project, rapid iteration, learning-focused

**Future:** If project grows, consider:
- `main` = stable, tested code
- `develop` = integration branch
- `feature/*` = new features
- `fix/*` = bug fixes

For now, keep it simple: commit to `main`.

---

## Working Across Multiple Macs

### Scenario: Work on Mac 1, switch to Mac 2

**On Mac 1 (end of session):**
```bash
git add .
git commit -m "Add Dashboard screen layout"
git push
```

**On Mac 2 (start of session):**
```bash
git pull
# Continue work
```

**On Mac 2 (end of session):**
```bash
git add .
git commit -m "Add GPS auto-population logic"
git push
```

**Back on Mac 1:**
```bash
git pull
# Continue work
```

### Avoiding Conflicts

**Always pull before starting work:**
```bash
# Before editing any files
git pull

# If you forgot and made changes:
git stash        # Save your changes
git pull         # Get remote changes
git stash pop    # Reapply your changes
```

---

## Files Never to Commit

Already protected by `.gitignore`:

| File/Folder | Why |
|-------------|-----|
| `**/Config.xcconfig` | Contains API keys |
| `xcuserdata/` | Xcode user preferences |
| `DerivedData/` | Build artifacts |
| `.DS_Store` | macOS junk |

**Check before committing:**
```bash
git status
# Review what's being added
# Make sure no Config.xcconfig or API keys
```

---

## Getting Help

### Git Commands Quick Reference

| Command | Purpose |
|---------|---------|
| `git status` | See what's changed |
| `git log --oneline` | View commit history |
| `git diff` | See unstaged changes |
| `git stash` | Temporarily save changes |
| `git stash pop` | Restore stashed changes |
| `git reset --soft HEAD~1` | Undo last commit (keep changes) |
| `git remote -v` | Check remote URL |

### More Help

- [Git Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [SSH Key Management](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- Ask Claude Code!

---

**Last Updated:** 2026-05-10
