---
name: nix-update
description: >
  Update Nix flake inputs (nixpkgs, etc.) and create a PR with the changes.
  Use when the user asks to update packages, update flake inputs, or refresh
  the Nix environment (e.g., "パッケージ更新して", "nix update", "flake update").
---

# Nix Flake Update

Update Nix flake inputs and create a PR with the changes.

## Workflow

### 1. Update flake inputs

Run `nix flake update` in the dotfiles repository root to update `flake.lock`.

### 2. Check for changes

Run `git diff flake.lock` to see what changed. If there are no changes, inform the user that everything is already up to date and stop.

### 3. Verify the build

Run `hms` to apply the updated configuration and verify it builds successfully.

If it fails, investigate the error and attempt to fix it. If you cannot fix it, restore `flake.lock` with `git checkout flake.lock` and report the issue to the user.

### 4. Summarize changes

Parse the `flake.lock` diff to identify which inputs were updated (e.g., nixpkgs revision changed). Include the old and new revisions in the PR description.

### 5. Commit and create PR

Follow the repository's PR rules. Use type `chore` and scope `nix`.

Commit message example: `chore(nix): update flake inputs`

PR title example: `chore(nix): update flake inputs`

Include the input changes summary in the PR body.
