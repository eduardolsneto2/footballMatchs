---
name: git-workflow
description: Analyze the current git state and complete the repository's preferred commit workflow. Use when the user asks to commit, push, create a branch, open a pull request, or wants help with the repo git workflow.
---
# Git Workflow

## Use this skill when

- The user asks for a commit, push, branch, or PR
- You need a repeatable workflow for staging and summarizing changes
- You want to preserve the repo's existing history style before writing a commit message

## Workflow

1. Inspect repo state with `git status`, `git diff`, and recent commit history.
2. Stage only the files relevant to the requested task.
3. Never include secrets such as `Config/Secrets.xcconfig`.
4. Write a concise commit message focused on why the change exists.
5. Verify success with a final `git status`.

## Pull requests

When creating a PR:

1. Summarize the user-facing outcome.
2. Call out setup or migration steps.
3. Include a short test plan with build and test commands.
