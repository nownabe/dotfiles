#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Colors (ANSI)
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[32m"
CYAN="\033[36m"
MAGENTA="\033[35m"
YELLOW="\033[33m"
BLUE="\033[34m"
GRAY="\033[90m"
WHITE="\033[97m"

# Extract from Claude Code JSON input
MODEL=$(echo "$input" | jq -r '.model.display_name // empty')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // empty')

# Usage: Get percentage from context window
USAGE_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# Host
USER_NAME=$(whoami)
HOST=$(hostname -s)

# GitHub repo (from git remote)
GITHUB_REPO=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    REMOTE_URL=$(git remote get-url origin 2>/dev/null)
    if [ -n "$REMOTE_URL" ]; then
        GITHUB_REPO=$(echo "$REMOTE_URL" | sed -E 's#.*github\.com[:/](.+/.+?)(\.git)?$#\1#' | sed 's/\.git$//')
    fi
fi

# Worktree (extract wt-XXX from path)
WORKTREE=""
if [[ "$CURRENT_DIR" =~ \.worktrees/(wt-[0-9]+) ]]; then
    WORKTREE="${BASH_REMATCH[1]}"
fi

# Git branch
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_BRANCH=$(git branch --show-current 2>/dev/null)
fi

# Section separator
SEP="${DIM}│${RESET}"

# === Section 1: Host ===
SEC_HOST="${GREEN} ${USER_NAME}@${HOST}${RESET}"

# === Section 2: Git ===
SEC_GIT=""
if [ -n "$GITHUB_REPO" ]; then
    SEC_GIT+="${CYAN} ${GITHUB_REPO}${RESET}"
fi
if [ -n "$WORKTREE" ]; then
    SEC_GIT+=" ${MAGENTA} ${WORKTREE}${RESET}"
fi
if [ -n "$GIT_BRANCH" ]; then
    SEC_GIT+=" ${YELLOW} ${GIT_BRANCH}${RESET}"
fi

# === Section 3: Claude ===
SEC_CLAUDE=""
if [ -n "$MODEL" ]; then
    SEC_CLAUDE+="${BLUE}󰚩 ${MODEL}${RESET}"
fi
SEC_CLAUDE+=" ${GRAY}󰓅 ${USAGE_PCT}%${RESET}"


# Build final status line
STATUS="${SEC_HOST}"
if [ -n "$SEC_GIT" ]; then
    STATUS+=" ${SEP} ${SEC_GIT}"
fi
STATUS+=" ${SEP} ${SEC_CLAUDE}"

printf "%b\n" "$STATUS"
