#!/bin/bash
# Auto-push hook for Lovable Claude Code plugin
# Automatically commits and pushes changes when:
# 1. auto_push: on in CLAUDE.md
# 2. There are uncommitted changes
# 3. User is on main branch

set -e

# Exit silently if CLAUDE.md doesn't exist (not a Lovable project)
if [ ! -f "CLAUDE.md" ]; then
  exit 0
fi

# Check if auto-push is enabled in CLAUDE.md
auto_push_enabled=false
if grep -qE "^Auto-Push to GitHub:\s*(on|enabled)" CLAUDE.md 2>/dev/null; then
  auto_push_enabled=true
fi

# Exit silently if auto-push is not enabled
if [ "$auto_push_enabled" = false ]; then
  exit 0
fi

# Check if there are changes to commit
if git diff --quiet && git diff --cached --quiet; then
  # No changes, nothing to commit
  exit 0
fi

# Get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Only auto-push on main branch
if [ "$current_branch" != "main" ]; then
  # Silently exit - don't auto-push on feature branches
  exit 0
fi

# Generate a descriptive commit message based on changed files
changed_files=$(git diff --name-only)
if [ -z "$changed_files" ]; then
  changed_files=$(git diff --cached --name-only)
fi

# Create commit message
commit_msg="🤖 Auto-commit: Update"
if echo "$changed_files" | grep -q "supabase/functions/"; then
  commit_msg="🤖 Auto-commit: Update edge functions"
elif echo "$changed_files" | grep -q "supabase/migrations/"; then
  commit_msg="🤖 Auto-commit: Update database migrations"
elif echo "$changed_files" | grep -q "src/"; then
  commit_msg="🤖 Auto-commit: Update frontend"
fi

# Add all changes and commit
git add -A
git commit -m "$commit_msg

Generated with Claude Code (https://claude.com/claude-code)
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>" 2>&1

# Push to remote
git push origin main 2>&1

# Output confirmation (visible in Claude's context)
echo "✅ Auto-pushed changes to GitHub (branch: main)"
exit 0
