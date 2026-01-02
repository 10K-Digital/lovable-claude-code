---
description: Enable/disable yolo mode for automated Lovable deployments with browser automation. Control testing and debug options.
---

# Yolo Mode Toggle

Enable or disable yolo mode for automated Lovable prompt submission via browser automation.

## Syntax

```bash
/yolo [on|off] [--testing|--no-testing] [--debug]
```

## Arguments

- `on` - Enable yolo mode (default: with testing, without debug)
- `off` - Disable yolo mode
- `--testing` - Enable all 3 testing levels after deployment (default when enabling)
- `--no-testing` - Skip testing, only deploy
- `--debug` - Enable verbose logging of browser automation steps
- (no arguments) - Show current yolo mode status

## Instructions

### 1. Parse Command Arguments

Extract the mode (`on`/`off`) and flags from the command:
- If no arguments: proceed to step 7 (show status)
- If `on`: proceed to enable yolo mode
- If `off`: proceed to disable yolo mode
- Parse optional flags: `--testing`, `--no-testing`, `--debug`

### 2. When Enabling Yolo Mode (`/yolo on`)

**a) Show Beta Warning:**

```
⚠️ YOLO MODE (BETA)

This feature uses browser automation to automatically submit Lovable prompts.

Benefits:
✅ No manual copy-paste needed
✅ Automatic deployment verification
✅ Saves time on every deployment

Risks:
⚠️ Beta feature - may have bugs
⚠️ Requires Chrome extension and browser session
⚠️ Lovable UI changes may break automation
⚠️ Always has manual fallback if automation fails

Continue enabling yolo mode? (yes/no)
```

Wait for user confirmation. If no, abort.

**b) Validate Prerequisites:**

1. Check if CLAUDE.md exists:
   ```
   ❌ Cannot enable yolo mode - project not initialized
   Run /init-lovable first to set up the project.
   ```

2. Read CLAUDE.md and check for `lovable_url` field:
   - If missing, ask user:
     ```
     What is your Lovable project URL?
     (e.g., https://lovable.dev/projects/abc123)
     ```
   - Update CLAUDE.md with provided URL

3. Check current Git branch:
   ```bash
   git branch --show-current
   ```
   - If not `main`, warn:
     ```
     ⚠️ You're on branch '[branch-name]'

     Only the main branch syncs with Lovable.
     Yolo mode will work, but deployments won't sync until you merge to main.
     ```

4. Check for Claude in Chrome extension (optional check):
   ```
   💡 Yolo mode requires the Claude in Chrome extension.

   If you don't have it installed:
   - Install: https://chrome.google.com/webstore/detail/claude/...
   - Read docs: https://docs.claude.com/claude/code-intelligence/browser-automation

   ℹ️ You can enable yolo mode now and install the extension later.
   ```

**c) Update CLAUDE.md:**

1. Read current CLAUDE.md content
2. Add or update the yolo mode configuration section:

```markdown
## Yolo Mode Configuration (Beta)

> ⚠️ Beta feature - uses browser automation to auto-submit Lovable prompts

- **Status**: on
- **Testing**: [on if --testing or default, off if --no-testing]
- **Debug Mode**: [on if --debug, off otherwise]
- **Last Updated**: [current timestamp]
- **Operations Covered**:
  - Edge function deployment
  - Migration application

**Configure:** Run `/yolo on/off [--testing|--no-testing] [--debug]`
```

3. If `lovable_url` was added, update the Project Overview section

**d) Confirm Enablement:**

```
✅ Yolo mode ENABLED

Configuration:
- Auto-deployment: ✅ ON
- Testing: [✅ ON / ⏸️ OFF]
- Debug: [✅ ON / OFF]

From now on, when you make changes that need Lovable deployment:
- I'll automatically detect them
- Navigate to your Lovable project
- Submit the prompts for you
[if testing on] - Run 3 levels of verification tests
[if debug on] - Show verbose browser automation details

Operations automated:
✅ Edge function deployment
✅ Migration application

To disable: /yolo off
To change settings: /yolo on --no-testing  or  /yolo on --debug
```

### 3. When Disabling Yolo Mode (`/yolo off`)

**a) Update CLAUDE.md:**

1. Read current CLAUDE.md
2. Update yolo mode configuration:
   - Set `Status: off`
   - Keep other settings for when user re-enables
   - Update `Last Updated` timestamp

**b) Confirm Disablement:**

```
⏸️ Yolo mode DISABLED

I'll still generate Lovable prompts for backend operations,
but you'll need to copy-paste them manually into Lovable.

Your previous settings are saved:
- Testing: [on/off]
- Debug: [on/off]

To re-enable: /yolo on
```

### 4. When No Arguments (`/yolo`)

**Show Current Status:**

1. Read CLAUDE.md
2. Check if yolo mode section exists
3. Display current configuration:

If yolo mode is ON:
```
## Yolo Mode Configuration

Status: ✅ ENABLED
Testing: ✅ ON (runs 3 verification levels)
Debug: OFF
Last updated: 2024-01-15 10:30:00

Operations automated:
- Edge function deployment
- Migration application

How it works:
- When you run /deploy-edge or /apply-migration
- I'll automatically navigate to Lovable
- Submit the prompts via browser automation
- Verify deployments succeed

To modify:
/yolo off              # Disable
/yolo on --no-testing  # Skip testing
/yolo on --debug       # Enable debug output
```

If yolo mode is OFF or not configured:
```
## Yolo Mode Configuration

Status: ⏸️ DISABLED

Yolo mode automates Lovable prompt submission using browser automation.

Benefits:
✅ No manual copy-paste needed
✅ Automatic deployment verification
✅ Saves time on every deployment

To enable: /yolo on
To learn more: Check README.md or ask "What is yolo mode?"
```

### 5. Handling Flags

**`--testing` flag (default):**
- Set `yolo_testing: on` in CLAUDE.md
- After deployments, run all 3 testing levels:
  - Level 1: Basic verification
  - Level 2: Console error checking
  - Level 3: Functional testing

**`--no-testing` flag:**
- Set `yolo_testing: off` in CLAUDE.md
- After deployments, skip all testing
- Only deploy and confirm basic success

**`--debug` flag:**
- Set `yolo_debug: on` in CLAUDE.md
- During browser automation, output verbose logs:
  - Each navigation step
  - Element selectors used
  - Wait times and conditions
  - Full response text from Lovable

### 6. Error Handling

**CLAUDE.md not found:**
```
❌ Cannot configure yolo mode

CLAUDE.md not found. Initialize the project first:
/init-lovable
```

**Invalid arguments:**
```
❌ Invalid syntax

Usage: /yolo [on|off] [--testing|--no-testing] [--debug]

Examples:
  /yolo              # Show status
  /yolo on           # Enable with testing
  /yolo on --debug   # Enable with debug logs
  /yolo off          # Disable
```

**Conflicting flags:**
```
❌ Cannot use --testing and --no-testing together

Choose one:
  /yolo on --testing     # Enable testing (default)
  /yolo on --no-testing  # Skip testing
```

### 7. Integration Notes

After enabling yolo mode, the following commands will automatically trigger browser automation:
- `/deploy-edge` - Deploys edge functions to Lovable
- `/apply-migration` - Applies database migrations

The automation workflow is defined in `/skills/yolo/SKILL.md` and references.

## Example Outputs

### Example 1: First-time Enable

```
$ /yolo on

⚠️ YOLO MODE (BETA)

This feature uses browser automation to automatically submit Lovable prompts.

Benefits:
✅ No manual copy-paste needed
✅ Automatic deployment verification
✅ Saves time on every deployment

Risks:
⚠️ Beta feature - may have bugs
⚠️ Requires Chrome extension and browser session
⚠️ Lovable UI changes may break automation
⚠️ Always has manual fallback if automation fails

Continue enabling yolo mode? yes

What is your Lovable project URL?
(e.g., https://lovable.dev/projects/abc123)
> https://lovable.dev/projects/my-project

✅ Yolo mode ENABLED

Configuration:
- Auto-deployment: ✅ ON
- Testing: ✅ ON
- Debug: OFF

From now on, when you make changes that need Lovable deployment:
- I'll automatically detect them
- Navigate to your Lovable project
- Submit the prompts for you
- Run 3 levels of verification tests

Operations automated:
✅ Edge function deployment
✅ Migration application

To disable: /yolo off
```

### Example 2: Enable Without Testing

```
$ /yolo on --no-testing

⚠️ YOLO MODE (BETA)
[... beta warning ...]

Continue enabling yolo mode? yes

✅ Yolo mode ENABLED

Configuration:
- Auto-deployment: ✅ ON
- Testing: ⏸️ OFF (deployments only, no verification tests)
- Debug: OFF

Operations automated:
✅ Edge function deployment (no testing)
✅ Migration application (no testing)

To enable testing: /yolo on --testing
```

### Example 3: Enable with Debug

```
$ /yolo on --debug

⚠️ YOLO MODE (BETA)
[... beta warning ...]

Continue enabling yolo mode? yes

✅ Yolo mode ENABLED

Configuration:
- Auto-deployment: ✅ ON
- Testing: ✅ ON
- Debug: ✅ ON (verbose browser automation logs)

You'll see detailed output during deployments:
- Navigation steps
- Element selectors
- Response text
- Timing information

To disable debug: /yolo on
```

### Example 4: Check Status

```
$ /yolo

## Yolo Mode Configuration

Status: ✅ ENABLED
Testing: ✅ ON (runs 3 verification levels)
Debug: ✅ ON
Last updated: 2024-01-15 10:30:00

Operations automated:
- Edge function deployment
- Migration application

To modify:
/yolo off              # Disable
/yolo on --no-testing  # Skip testing
/yolo on               # Disable debug (keeps testing)
```

### Example 5: Disable

```
$ /yolo off

⏸️ Yolo mode DISABLED

I'll still generate Lovable prompts for backend operations,
but you'll need to copy-paste them manually into Lovable.

Your previous settings are saved:
- Testing: on
- Debug: on

To re-enable: /yolo on
```
