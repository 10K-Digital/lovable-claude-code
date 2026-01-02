# Yolo Mode: Auto-Detection Logic

Reference for when to trigger browser automation.

## Overview

When yolo mode is enabled (`yolo_mode: on` in CLAUDE.md), automatically detect when Lovable prompts are needed and trigger browser automation.

## Detection Criteria

### 1. Edge Function Deployment Detection

**When to trigger:**
- User runs `/deploy-edge` command
- Files in `supabase/functions/` have been modified
- Changes are committed and pushed to `main` branch

**Detection steps:**

1. **Check yolo mode status:**
   ```
   - Read CLAUDE.md
   - Look for: yolo_mode: on
   - If off or not found → skip automation
   ```

2. **Verify changes are ready:**
   ```
   - Run: git status
   - Check: No uncommitted changes in supabase/functions/
   - Run: git log origin/main..HEAD
   - Check: All commits are pushed to main
   ```

3. **Identify which functions changed:**
   ```
   - Run: git diff origin/main HEAD -- supabase/functions/
   - Parse: Which function directories have changes
   - List: Function names (folder names)
   ```

4. **Trigger automation:**
   ```
   - If single function changed:
     Prompt: "Deploy the [function-name] edge function"

   - If multiple functions changed:
     Prompt: "Deploy all edge functions"

   - Load automation-workflows.md
   - Execute browser automation
   ```

**Example:**
```
Files changed:
  supabase/functions/send-email/index.ts
  supabase/functions/send-email/utils.ts

Detection:
✅ yolo_mode: on
✅ Changes in supabase/functions/
✅ All committed and pushed to main
✅ Function identified: send-email

Action: Trigger automation
Prompt: "Deploy the send-email edge function"
```

---

### 2. Migration Application Detection

**When to trigger:**
- User runs `/apply-migration` command
- New files in `supabase/migrations/` exist
- Changes are committed and pushed to `main` branch

**Detection steps:**

1. **Check yolo mode status:**
   ```
   - Read CLAUDE.md
   - Look for: yolo_mode: on
   - If off → skip automation
   ```

2. **Verify migrations are ready:**
   ```
   - Run: git status
   - Check: No uncommitted migrations
   - Run: git log origin/main..HEAD -- supabase/migrations/
   - Check: Migration files are pushed to main
   ```

3. **List pending migrations:**
   ```
   - List all files in supabase/migrations/
   - Sort by timestamp (filename prefix)
   - Identify: New or modified migrations
   ```

4. **Trigger automation:**
   ```
   - If one migration:
     Prompt: "Apply the [migration-name] migration"

   - If multiple migrations:
     Prompt: "Apply pending Supabase migrations"

   - Load automation-workflows.md
   - Execute browser automation
   ```

**Example:**
```
Files in supabase/migrations/:
  20240115103000_add_user_preferences.sql (new)

Detection:
✅ yolo_mode: on
✅ New migration file exists
✅ Committed and pushed to main

Action: Trigger automation
Prompt: "Apply pending Supabase migrations"
```

---

## Integration with Commands

### /deploy-edge Integration

Add this logic at the end of `/deploy-edge` command:

```markdown
## Check for Yolo Mode

1. Read CLAUDE.md
2. Check if `yolo_mode: on`

3. If yolo mode is ON:
   - Activate yolo skill
   - Execute browser automation (see automation-workflows.md)
   - Run testing based on yolo_testing setting
   - Show deployment summary
   - Exit (don't show manual prompt)

4. If yolo mode is OFF:
   - Show manual prompt (current behavior):
     📋 **LOVABLE PROMPT:**
     > "Deploy the [name] edge function"

   - Suggest enabling yolo mode:
     💡 Tip: Enable yolo mode to automate this!
     Run: /yolo on
```

### /apply-migration Integration

Add this logic at the end of `/apply-migration` command:

```markdown
## Check for Yolo Mode

1. Read CLAUDE.md
2. Check if `yolo_mode: on`

3. If yolo mode is ON:
   - Activate yolo skill
   - Execute browser automation
   - Run testing if enabled
   - Show summary
   - Exit

4. If yolo mode is OFF:
   - Show manual prompt:
     📋 **LOVABLE PROMPT:**
     > "Apply pending Supabase migrations"

   - Suggest yolo mode:
     💡 Automate this with: /yolo on
```

---

## Proactive Detection (Future Enhancement)

Not implemented in current version, but could be added:

**After git push to main:**
```
1. Detect files changed in push
2. If supabase/functions/ or supabase/migrations/ modified:
   - Show notification:
     "🤖 Yolo mode detected backend changes.
      Starting automated deployment..."
   - Auto-trigger appropriate automation
```

**Watching for file changes:**
```
1. Monitor supabase/functions/ and supabase/migrations/
2. On file save + commit + push:
   - Auto-detect operation needed
   - Trigger automation immediately
```

---

## Reading CLAUDE.md for Yolo Configuration

**Check if yolo mode is enabled:**

```
1. Read file: CLAUDE.md (in project root)
2. Parse markdown sections
3. Find: "## Yolo Mode Configuration (Beta)"
4. Extract fields:
   - Status: on/off
   - Testing: on/off
   - Debug Mode: on/off
5. Return configuration object
```

**Example CLAUDE.md section:**
```markdown
## Yolo Mode Configuration (Beta)

- **Status**: on
- **Testing**: on
- **Debug Mode**: off
- **Last Updated**: 2024-01-15 10:30:00
```

**Parsed result:**
```javascript
{
  yolo_mode: "on",
  yolo_testing: "on",
  yolo_debug: "off",
  last_updated: "2024-01-15 10:30:00"
}
```

---

## Error Handling in Detection

**CLAUDE.md not found:**
```
- Assume yolo mode is off
- Proceed with manual prompts
- Don't show error (project may not be initialized)
```

**Yolo mode section not in CLAUDE.md:**
```
- Assume yolo mode is off
- Proceed with manual prompts
```

**Invalid yolo mode value:**
```
- Treat as "off"
- Proceed with manual prompts
```

**Git operations fail:**
```
- Show error to user
- Can't determine if changes are pushed
- Proceed with manual prompts
- Suggest: git status, git push
```

---

## Decision Flow

```
User runs /deploy-edge or /apply-migration
    ↓
Read CLAUDE.md
    ↓
Check: yolo_mode field
    ↓
    ├─ yolo_mode: on
    │     ↓
    │  Verify changes committed & pushed
    │     ↓
    │  Identify what changed
    │     ↓
    │  Generate Lovable prompt
    │     ↓
    │  Load automation-workflows.md
    │     ↓
    │  Execute browser automation
    │     ↓
    │  Run tests if yolo_testing: on
    │     ↓
    │  Show deployment summary
    │
    └─ yolo_mode: off
          ↓
       Show manual prompt
          ↓
       Suggest /yolo on
```

---

## Testing Detection Logic

**Test case 1: Yolo mode on, single edge function changed**
```
Setup:
- CLAUDE.md has yolo_mode: on
- Modified: supabase/functions/send-email/index.ts
- Committed and pushed to main

Expected:
✅ Yolo mode detected
✅ Function identified: send-email
✅ Automation triggered
✅ Prompt: "Deploy the send-email edge function"
```

**Test case 2: Yolo mode off**
```
Setup:
- CLAUDE.md has yolo_mode: off
- Modified: supabase/functions/send-email/index.ts

Expected:
✅ Yolo mode not active
✅ Show manual prompt
✅ Suggest /yolo on
```

**Test case 3: Multiple functions changed**
```
Setup:
- CLAUDE.md has yolo_mode: on
- Modified: send-email/, process-payment/

Expected:
✅ Multiple functions detected
✅ Automation triggered
✅ Prompt: "Deploy all edge functions"
```

**Test case 4: Migration detection**
```
Setup:
- CLAUDE.md has yolo_mode: on
- New file: supabase/migrations/20240115_add_field.sql
- Committed and pushed

Expected:
✅ Migration detected
✅ Automation triggered
✅ Prompt: "Apply pending Supabase migrations"
```

---

*This detection logic ensures yolo mode only activates when explicitly enabled and changes are ready to deploy.*
