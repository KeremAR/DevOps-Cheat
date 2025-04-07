![GIT](/Media/GIT.jpg)

# Git Cheat Sheet

## Setup
Set the name and email that will be attached to your commits and tags
```bash
$ git config --global user.name "Danny Adams"
$ git config --global user.email "my-email@gmail.com"
```

## Start a Project
Create a local repo (omit <directory> to initialise the current directory as a git repo)
```bash
$ git init <directory>
```
Download a remote repo
```bash
$ git clone <url>
```

## Make a Change
Add a file to staging
```bash
$ git add <file>
```
Stage all files
```bash
$ git add .
```
Commit all staged files to git
```bash
$ git commit -m "commit message"
```
Add all changes made to tracked files & commit
```bash
$ git commit -am "commit message"
```

## Basic Concepts
-   **main**: default development branch
-   **origin**: default upstream repo
-   **HEAD**: current branch
-   **HEAD^**: parent of HEAD
-   **HEAD~4**: great-great grandparent of HEAD

## Branches
List all local branches. Add -r flag to show all remote branches. -a flag for all branches.
```bash
$ git branch
```
Create a new branch
```bash
$ git branch <new-branch>
```
Switch to a branch & update the working directory
```bash
$ git checkout <branch>
```
Create a new branch and switch to it
```bash
$ git checkout -b <new-branch>
```
Delete a merged branch
```bash
$ git branch -d <branch>
```
Delete a branch, whether merged or not
```bash
$ git branch -D <branch>
```
Add a tag to current commit (often used for new version releases)
```bash
$ git tag <tag-name>
```

## Merging
Merge branch a into branch b. Add --no-ff option for no-fast-forward merge
```bash
$ git checkout b
$ git merge a
```
Merge & squash all commits into one new commit
```bash
$ git merge --squash a
```

## Rebase
Rebase feature branch onto main (to incorporate new changes made to main). Prevents unnecessary merge commits into feature, keeping history clean.
```bash
$ git checkout feature
$ git rebase main
```
Interactively clean up a branches commits before rebasing onto main
```bash
$ git rebase -i main
```
Interactively rebase the last 3 commits on current branch
```bash
$ git rebase -i HEAD~3
```

## Undoing Things
Move (&/or rename) a file & stage move
```bash
$ git mv <existing_path> <new_path>
```
Remove a file from working directory & staging area, then stage the removal
```bash
$ git rm <file>
```
Remove from staging area only
```bash
$ git rm --cached <file>
```
View a previous commit (READ only)
```bash
$ git checkout <commit_ID>
```
Create a new commit, reverting the changes from a specified commit
```bash
$ git revert <commit_ID>
```
Go back to a previous commit & delete all commits ahead of it (revert is safer). Add --hard flag to also delete workspace changes (BE VERY CAREFUL)
```bash
$ git reset <commit_ID>
$ git reset --hard <commit_ID>
```

## Review your Repo
List new or modified files not yet committed
```bash
$ git status
```
List commit history, with respective IDs
```bash
$ git log --oneline
```
Show changes to unstaged files. For changes to staged files, add --cached option
```bash
$ git diff
```
Show changes between two commits
```bash
$ git diff <commit1_ID> <commit2_ID>
```

## Stashing
Store modified & staged changes. To include untracked files, add -u flag. For untracked & ignored files, add -a flag.
```bash
$ git stash
```
As above, but add a comment.
```bash
$ git stash save "comment"
```
Partial stash. Stash just a single file, a collection of files, or individual changes from within files
```bash
$ git stash -p
```
List all stashes
```bash
$ git stash list
```
Re-apply the stash without deleting it
```bash
$ git stash apply
```
Delete stash at index 1. Omit stash@{#} to delete last stash made
```bash
$ git stash drop stash@{1}
```
Delete all stashes
```bash
$ git stash clear
```
Re-apply the stash at index 2, then delete it from the stash list. Omit stash@{#} to pop the most recent stash.
```bash
$ git stash pop stash@{2}
```
Show the diff summary of stash 1. Pass the -p flag to see the full diff.
```bash
$ git stash show stash@{1}
```

## Synchronizing
Add a remote repo
```bash
$ git remote add <alias> <url>
```
View all remote connections. Add -v flag to view urls.
```bash
$ git remote
```
Remove a connection
```bash
$ git remote remove <alias>
```
Rename a connection
```bash
$ git remote rename <old> <new>
```
Fetch all branches from remote repo (no merge)
```bash
$ git fetch <alias>
```
Fetch a specific branch
```bash
$ git fetch <alias> <branch>
```
Fetch the remote repo's copy of the current branch, then merge
```bash
$ git pull
```
Move (rebase) your local changes onto the top of new changes made to the remote repo (for clean, linear history)
```bash
$ git pull --rebase <alias>
```
Upload local content to remote repo
```bash
$ git push <alias>
```
Upload to a branch (can then pull request)
```bash
$ git push <alias> <branch>
```

<img src="/Media/gitpull.png" alt="GITPULL" width="500"/>

## Key Git Concepts Compared
## Managing Remote Repositories
- **Remote Types**:
  - `origin`: typically refers to your fork
  - `upstream`: typically refers to the original repository

### Fork vs Clone

| Feature         | Clone                                  | Fork                                       |
|-----------------|----------------------------------------|--------------------------------------------|
| **What it does**| Copies a repo to your **local** machine | Copies a repo to **your GitHub account**   |
| **Ownership**   | You don't own the original repo        | You own the copied repo (the fork)         |
| **Connection**  | Directly linked to the original (`origin`) | Linked to the original (`upstream`), but independent |
| **Purpose**     | Get a local working copy               | Contribute to original, start own project  |
| **Location**    | Local machine                          | Server-side (e.g., GitHub)                 |

- **Cloning** directly creates a local copy of an existing remote repository. You usually clone repositories you have write access to, or your own forks.
- **Forking** creates a *server-side* copy of someone else's repository under your own account. This allows you to experiment freely. You typically *clone your fork* locally to make changes, and then propose changes back to the original repository (upstream) via Pull Requests.









### Fetch vs Pull
**Git Fetch:**
- Downloads changes from remote repository but **doesn't integrate** them into your working files
- Safer option as it allows you to review changes before merging
- Updates your remote-tracking branches
```bash
$ git fetch origin

```

**Git Pull:**
- Essentially does a `git fetch` followed by a `git merge`
- Automatically integrates remote changes into your working files
- More convenient but less control
```bash
$ git pull origin master
# Equivalent to:
$ git fetch origin
$ git merge origin/master
```

### Revert vs Reset
<img src="/Media/revertreset.png" alt="GITrevertreset" width="500"/>
**Git Revert:**
- Creates a **new commit** that undoes changes from a previous commit
- Safe for shared branches as it doesn't alter history
- Preserves the project history
```bash
# Creates new commit that undoes commit_id
$ git revert <commit_id>
```

**Git Reset:**
- **Moves** the branch pointer to a previous commit
- **Rewrites** git history by removing commits after the specified point
- Three modes:
  - `--soft`: Keeps changes staged
  - `--mixed` (default): Unstages changes
  - `--hard`: Discards all changes
```bash
# BE CAREFUL with reset, especially --hard
$ git reset --soft <commit_id>   # Keep changes staged
$ git reset <commit_id>          # Keep changes unstaged
$ git reset --hard <commit_id>   # Discard all changes
```

### Merge vs Rebase
**Git Merge:**
- Creates a new "merge commit" that combines changes from both branches
- Preserves complete history and chronological order
- Results in a branch structure that shows parallel development
```bash
$ git checkout main
$ git merge feature
# Creates a merge commit combining main and feature
```

**Git Rebase:**
- Moves the entire feature branch to begin on the tip of the main branch
- Creates linear project history
- Makes it look as if you created your branch from the latest commit
```bash
$ git checkout feature
$ git rebase main
# Replays feature branch commits on top of main
```

**When to Use What:**
1. **Fetch vs Pull:**
   - Use `fetch` when you want to review changes before integrating
   - Use `pull` when you're confident about directly integrating changes

2. **Revert vs Reset:**
   - Use `revert` for shared branches (safer)
   - Use `reset` only for local changes or when you really need to clean history

3. **Merge vs Rebase:**
   - Use `merge` for public/shared branches
   - Use `rebase` for local feature branches to maintain clean history

**Best Practice Tip:** When in doubt, prefer the safer options (`fetch`, `revert`, `merge`) for shared repositories, and use the history-altering options (`reset`, `rebase`) only for local changes.


