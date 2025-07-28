![GIT](/Media/GIT.jpg)

# Git Cheat Sheet

Git is a distributed version control system that tracks changes in files and coordinates work among multiple people.

## Key Git Concepts

### Basic Concepts
- **main/master:** Default development branch
- **origin:** Default name for remote repository
- **upstream:** Original repository (when working with forks)
- **HEAD:** Pointer to current branch/commit
- **HEAD^:** Parent of HEAD (previous commit)
- **HEAD~4:** 4 commits before HEAD

### File Status Lifecycle
<img src="/Media/files-lifecycle.png" alt="files-lifecycle" width="500"/>

**Four main states:**
- **Untracked:** File exists but Git doesn't track it
- **Unmodified:** File tracked, no changes since last commit  
- **Modified:** File tracked, has changes since last commit
- **Staged:** File marked to be included in next commit

### Git Object Types
<img src="/Media/object-tree.png" alt="git" width="500"/>

1. **Blob:** Stores file content (no metadata)
2. **Tree:** Represents directory structure
3. **Commit:** Snapshot of entire project with metadata
4. **Tag:** Marks specific commits as important


## SSH Key Setup

SSH keys provide secure authentication without passwords:

1. **Generate SSH key:**
```bash
$ ssh-keygen -t rsa -C "your.email@example.com"
```

2. **Add public key to GitHub/GitLab** (copy content of `~/.ssh/id_rsa.pub`)

**Why SSH keys?** More secure than passwords, no need to enter credentials repeatedly.

## Initial Setup
Set your identity for commits:
```bash
$ git config --global user.name "Your Name"
$ git config --global user.email "your.email@example.com"
```

## Creating Repositories

### Start a New Local Repository
```bash
$ git init <directory>          # Create new repo in directory
$ git init                      # Initialize current directory as repo
```

### Clone an Existing Repository
```bash
$ git clone <url>               # Download remote repo to local machine
```

### Create Local Repo and Push to New Remote
```bash
$ git init                      # Initialize local repo
$ git add .                     # Stage all files
$ git commit -m "Initial commit"   # First commit
$ git branch -M main            # Rename branch to main
$ git remote add origin <url>   # Connect to remote repo
$ git push -u origin main      # Push and set upstream
```
### Fork vs Clone

| Feature         | Clone                                  | Fork                                       |
|-----------------|----------------------------------------|--------------------------------------------|
| **What it does**| Copies a repo to your **local** machine | Copies a repo to **your GitHub account**   |
| **Ownership**   | You don't own the original repo        | You own the copied repo (the fork)         |
| **Connection**  | Directly linked to the original (`origin`) | Linked to the original (`upstream`), but independent |
| **Purpose**     | Get a local working copy               | Contribute to original, start own project  |
| **Location**    | Local machine                          | Server-side (e.g., GitHub)                 |

## Basic Git Workflow



### Adding and Committing Changes
```bash
$ git add <file>                # Stage specific file
$ git add .                     # Stage all files
$ git commit -m "message"       # Commit staged files
$ git commit -am "message"      # Stage tracked files and commit in one step
$ git commit --amend -m "new message"  # Modify last commit message/content
```

## Local Undo Changes

### Unstaging Files (Remove from Staging Area)
```bash
$ git restore --staged <file>   # Unstage file (preferred method)
$ git reset HEAD <file>         # Unstage file (older method)
```

### Discard Working Directory Changes
```bash
$ git restore <file>            # Discard changes to file
$ git checkout -- <file>       # Discard changes (older method)
$ git clean -f                  # Remove untracked files
$ git clean -fd                 # Remove untracked files and directories
```

### Undoing Commits with Reset
```bash
$ git reset --soft HEAD^       # Undo last commit, keep changes staged
$ git reset --mixed HEAD^      # Undo last commit, unstage changes (default)
$ git reset --hard HEAD^       # Undo last commit, discard all changes
$ git reset HEAD~2             # Go back 2 commits
```

**Reset Types:**
- **--soft:** Only removes commit record, keeps changes staged
- **--mixed:** Removes commit and unstages changes, keeps working directory
- **--hard:** Removes commit, staging, and working directory changes completely

**Important:** Reset modifies commit history (changes timeline)

<img src="/Media/revertreset.png" alt="revertreset" width="500"/>


## Remote Undo Changes

### Safe Undo for Shared Repositories
```bash
$ git revert <commit_id>        # Create new commit that undoes specified commit
$ git revert HEAD               # Undo last commit safely
```

**Important:** Revert preserves commit history, adds new "undo" commit

## Branches

### Basic Branch Operations
```bash
$ git branch                    # List local branches
$ git branch -r                 # List remote branches  
$ git branch -a                 # List all branches
$ git branch <new-branch>       # Create new branch
$ git checkout <branch>         # Switch to branch
$ git switch <branch>           # Switch to branch (newer command)
$ git checkout -b <new-branch>  # Create and switch to new branch
$ git switch -c <new-branch>    # Create and switch to new branch (newer command)
$ git branch -m <old> <new>     # Rename branch
$ git branch -d <branch>        # Delete merged branch
$ git branch -D <branch>        # Force delete branch
```

## Merging

### Fast-Forward vs Non-Fast-Forward Merge

**Fast-Forward Merge:** When a branch can be directly appended to the tip of the target branch. No merge commit is created.

<table width="100%">
<tr>
<td width="50%"><img src="/Media/fast-forward1.png" alt="Fast-Forward Before" width="100%"/></td>
<td width="50%"><img src="/Media/fast-forward2.png" alt="Fast-Forward After" width="100%"/></td>
</tr>
<tr>
<td align="center"><b>Before Merge</b></td>
<td align="center"><b>After Merge</b></td>
</tr>
</table>

```bash
$ git merge <branch>            # Fast-forward if possible
```

**Non-Fast-Forward Merge:** When both branches have new commits, creates merge commit. Conflicts may occur during merge.

<table width="100%">
<tr>
<td width="50%"><img src="/Media/non-fast-forward1.png" alt="Non-Fast-Forward Before" width="100%"/></td>
<td width="50%"><img src="/Media/non-fast-forward2.png" alt="Non-Fast-Forward After" width="100%"/></td>
</tr>
<tr>
<td align="center"><b>Before Merge</b></td>
<td align="center"><b>After Merge</b></td>
</tr>
</table>

```bash
$ git merge --no-ff <branch>    # Force create merge commit
$ git merge --squash <branch>   # Combine all commits into one
```

**Conflict Resolution:** When merge fails due to conflicts:
1. Open conflicted files
2. Look for conflict markers: `<<<<<<<`, `=======`, `>>>>>>>`
3. Edit to resolve conflicts
4. Stage resolved files: `git add <file>`
5. Complete merge: `git commit`

## Rebase

git rebase means taking a branch and rewriting it on top of another branch's latest commit.

It's like saying "show these changes as if they were made after that point".

<table width="100%">
<tr>
<td width="50%"><img src="/Media/rebase1.png" alt="Rebase Before" width="100%"/></td>
<td width="50%"><img src="/Media/rebase2.png" alt="Rebase After" width="100%"/></td>
</tr>
<tr>
<td align="center"><b>Before Rebase</b></td>
<td align="center"><b>After Rebase</b></td>
</tr>
</table>

**Use rebase when:**
- Cleaning up feature branch history before merging
- Incorporating main branch updates into feature branch
- Making project history linear and easier to follow

```bash
$ git checkout feature          # Switch to feature branch
$ git rebase main              # Replay feature commits on top of main
$ git rebase -i HEAD~3         # Interactive rebase last 3 commits
```

**Rebase vs Merge:**
- **Merge:** Preserves branch history, creates merge commits
- **Rebase:** Creates linear history, rewrites commit history

## Cherry Pick

Cherry pick applies specific commits from one branch to another without merging entire branch:

<table width="100%">
<tr>
<td width="50%"><img src="/Media/cherry-pick1.png" alt="Cherry Pick Before" width="100%"/></td>
<td width="50%"><img src="/Media/cherry-pick2.png" alt="Cherry Pick After" width="100%"/></td>
</tr>
<tr>
<td align="center"><b>Before Cherry Pick</b></td>
<td align="center"><b>After Cherry Pick</b></td>
</tr>
</table>

```bash
$ git cherry-pick <commit_id>   # Apply specific commit to current branch
$ git cherry-pick <commit1>..<commit2>  # Apply range of commits
```


## Stashing

Temporarily save changes without committing:
```bash
$ git stash                     # Stash current changes
$ git stash save "message"      # Stash with custom message
$ git stash list                # List all stashes
$ git stash apply               # Apply most recent stash (stash@{0})
$ git stash apply stash@{1}     # Apply specific stash
$ git stash pop                 # Apply and delete most recent stash
$ git stash drop stash@{1}      # Delete specific stash
$ git stash clear               # Delete all stashes
```

## Tags

Tags mark important points in history (like releases):
```bash
$ git tag                       # List all tags
$ git tag <tag-name>           # Create lightweight tag
$ git tag -a <tag-name> -m "message"  # Create annotated tag
$ git push origin <tag-name>    # Push specific tag
$ git push origin --tags       # Push all tags
$ git tag -d <tag-name>        # Delete local tag
$ git push origin --delete <tag-name>  # Delete remote tag
```

## Remote Operations

### Remote Repository Management
```bash
$ git remote                    # List remote connections
$ git remote -v                 # List with URLs
$ git remote add <alias> <url>  # Add remote repository
$ git remote set-url origin <new-url>  # Change remote URL
$ git remote remove <alias>     # Remove remote connection
$ git remote rename <old> <new> # Rename remote connection
```

### Fetching and Pulling
```bash
$ git fetch <remote>            # Download changes without merging
$ git fetch origin <branch>     # Fetch specific branch
$ git pull                      # Fetch and merge remote changes
$ git pull --rebase origin main # Fetch and rebase instead of merge
```

**Fetch vs Pull:**
- **Fetch:** Downloads changes but doesn't integrate them (safer)
- **Pull:** Downloads and automatically merges changes (convenient)

<img src="/Media/gitpull.png" alt="GITPULL" width="500"/>

### Pushing Changes
```bash
$ git push origin <branch>      # Push specific branch
$ git push -u origin <branch>   # Push and set upstream tracking
$ git push --all origin         # Push all branches
$ git push origin --delete <branch>  # Delete remote branch
$ git push --force             # Force push (dangerous, overwrites remote)
```

## Detached HEAD

**What is Detached HEAD?** When you checkout a specific commit or tag instead of a branch.

```bash
$ git checkout <commit_id>      # Enter detached HEAD state
$ git checkout <tag_name>       # Also creates detached HEAD
```

**Why is Detached HEAD needed?** Detached HEAD is used when you want to temporarily view, test, or start a new branch from a past commit's content.

**Saving Changes in Detached HEAD:**
```bash
$ git checkout -b <new-branch>  # Create new branch from current state
$ git branch <new-branch>       # Create branch, then checkout
$ git checkout <existing-branch>
```

## Review and Inspection

### Checking Status and History
```bash
$ git status                    # Show working directory status
$ git log --oneline            # Show commit history
$ git log --graph --oneline    # Show history with branch visualization
$ git diff                     # Show unstaged changes
$ git diff --staged            # Show staged changes
$ git diff <commit1> <commit2>  # Compare two commits
$ git ls-files -s              # List staged files with details
```

## Best Practices

### Safe Operations for Shared Repositories
- Use `revert` instead of `reset` for published commits
- Use `fetch` before `pull` to review changes
- Create feature branches for new development
- Use `--no-ff` merges to preserve branch context

### When to Use What

**Revert vs Reset:**
- **Revert:** Safe for shared branches, creates new commit, preserves commit history
- **Reset:** Only for local changes, rewrites history, modifies commit timeline

**Merge vs Rebase:**
- **Merge:** Preserves true history, good for feature integration
- **Rebase:** Creates linear history, good for cleaning up branches

**Stash vs Commit:**
- **Stash:** Temporary save for incomplete work
- **Commit:** Permanent save for complete features