#!/bin/bash
# Auto-sync hook for Lovable Claude Code plugin
# Automatically pulls changes from GitHub when:
# 1. User is on main branch
# 2. Local branch is behind remote
# 3. There are no uncommitted changes

set -e

# Exit silently if not in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  exit 0
fi

# Get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Only auto-sync on main branch
if [ "$current_branch" != "main" ]; then
  # Silently exit - don't auto-sync on feature branches
  exit 0
fi

# Check if there are uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  # Has uncommitted changes - don't pull to avoid conflicts
  echo "⚠️  Warning: Skipping auto-sync - uncommitted changes detected. Commit or stash changes first."
  exit 0
fi

# Fetch latest changes from remote (silently)
git fetch origin main --quiet 2>/dev/null || {
  # Fetch failed (network issue, etc) - exit silently
  exit 0
}

# Check if local is behind remote
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")
BASE=$(git merge-base @ @{u} 2>/dev/null || echo "")

# If we can't determine remote state, exit silently
if [ -z "$REMOTE" ] || [ -z "$BASE" ]; then
  exit 0
fi

# Check if local is behind remote
if [ "$LOCAL" = "$REMOTE" ]; then
  # Already up-to-date
  exit 0
elif [ "$LOCAL" = "$BASE" ]; then
  # Local is behind remote - need to pull
  echo "📥 Syncing with GitHub (local branch is behind remote)..."

  # Try to pull with rebase to maintain clean history
  if git pull --rebase origin main 2>&1; then
    echo "✅ Successfully synced with GitHub"
    exit 0
  else
    # Rebase failed (conflicts) - abort and warn user
    git rebase --abort 2>/dev/null || true
    echo "⚠️  Warning: Auto-sync failed due to conflicts. Please manually resolve conflicts:"
    echo "   git pull origin main"
    exit 0
  fi
elif [ "$REMOTE" = "$BASE" ]; then
  # Local is ahead of remote - no need to pull
  exit 0
else
  # Branches have diverged - don't auto-sync
  echo "⚠️  Warning: Branches have diverged. Please manually resolve:"
  echo "   git pull --rebase origin main"
  exit 0
fi
