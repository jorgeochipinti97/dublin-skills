---
name: github-safety
description: Safe Git/GitHub workflow. Triggers on ANY git operation (commit, push, branch, merge, rebase, PR). Prevents destructive operations like force push, history rewriting, and unsafe rebases.
---

# GitHub Safety

## NEVER DO — Absolute Prohibitions

- **`git push --force`** or **`--force-with-lease`** — Create a new commit instead
- **`git rebase`** on any pushed branch — Never rewrite published history
- **`git reset --hard`** — Use `git revert` to undo commits safely
- **`git commit --amend`** on pushed commits — Create a new commit instead
- **`git checkout -- .`** or **`git restore .`** without explicit user confirmation
- **`--no-verify`** — Never skip hooks. If a hook fails, fix the root cause
- **`git clean -f`** — Never without explicit user confirmation
- **Delete remote branches** without explicit user request
- **Push directly to main/master** — Always use feature branches

## ALWAYS DO — Required Practices

- **New commits over rewrites**: Always `git revert`, never `git reset` for published history
- **Check before acting**: Run `git status` + `git log --oneline -5` before any push
- **Feature branches**: All work on branches, PRs to merge
- **Preserve history**: Use `git merge --no-ff` to keep merge context
- **Show commands first**: Display the exact git commands BEFORE executing them
- **Confirm destructive ops**: If ANY operation could lose work, STOP and ask the user
- **Post-op verification**: Show `git status` after every git operation

## PR Workflow

1. Create feature branch from main: `git checkout -b feat/description`
2. Make commits (atomic, descriptive messages)
3. Push branch: `git push -u origin feat/description`
4. Create PR with `gh pr create` — clear title + description
5. Never merge your own PR without user saying so
6. After merge, delete local branch only (remote via PR settings)

## Conflict Resolution

- **Never** use `git checkout --theirs .` or `--ours .` blindly
- Show conflicts to the user, ask how to resolve
- Prefer manual resolution over automated strategies
- After resolving: `git add` conflicted files, then `git commit` (new commit, no amend)

## When Something Goes Wrong

1. **STOP** — Do not attempt more git commands to "fix" the situation
2. **Show status** — `git status`, `git log --oneline -10`, `git stash list`
3. **Explain** — Tell the user what happened clearly
4. **Propose** — Suggest the safest recovery path
5. **Wait** — Get user confirmation before proceeding

## Output Standards

- Be CONCISE in git responses — no verbose explanations
- Show exact commands before running them
- One operation at a time — don't chain destructive commands
- Always end git operations with `git status` to confirm state

## Pairs With

- **`git-workflow`** — constructive counterpart. This skill is DEFENSIVE (what NEVER to do). For team setup (Conventional Commits, PR template, husky hooks, branch protection, CODEOWNERS, CONTRIBUTING.md), invoke `git-workflow` instead. Both can run together.
