---
name: worktree
description: >
  Switch to an isolated git worktree before starting work. Use when the user
  invokes /worktree or asks to work in a worktree (e.g., "worktree で作業して",
  "work in a worktree").
---

# Worktree

Move the session into an isolated git worktree so that subsequent work does not
touch the main working directory.

Call the `EnterWorktree` tool. It is a deferred tool, so load its schema first
with `ToolSearch("select:EnterWorktree")` if it is not already available.

If arguments are provided, use them as the worktree name. After entering the
worktree, continue with whatever task the user gives next.
