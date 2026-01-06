---
description: Check for Edge Function changes and provide Lovable deployment prompts.
---

# Deploy Edge Functions

Check for Edge Function changes and generate Lovable deployment prompts.

## Instructions

1. **Check for changes** in `supabase/functions/`:
   - List modified files
   - Show which functions have changes

2. **Verify code is pushed**:
   - Check for uncommitted changes
   - Check for unpushed commits to `main`

3. **Detect and validate secrets** (use secret-detection skill):
   - Scan function code for `Deno.env.get("SECRET_NAME")` patterns
   - Read secrets table from CLAUDE.md
   - Cross-reference detected secrets with known status:
     - ✅ In Lovable Cloud → OK
     - ⚠️ Not configured → Warn user
   - Check if any NEW secrets are referenced that aren't in CLAUDE.md
   - Warn about missing secrets before deployment

4. **Generate deployment prompt**:

For specific function:
```
📋 **LOVABLE PROMPT:**
> "Deploy the [function-name] edge function"
```

For multiple functions:
```
📋 **LOVABLE PROMPT:**
> "Deploy all edge functions"
```

5. **If new secrets detected**:
```
⚠️ **New secret required**: `SECRET_NAME`

Before deploying:
1. Go to Cloud → Secrets
2. Add: SECRET_NAME = [your value]
3. Then deploy the edge function
```

6. **Provide verification prompt**:
```
After deploying, verify with:
> "Show logs for [function-name] edge function"
```

## Check for Yolo Mode

After generating the prompt, check if yolo mode is enabled:

1. **Read CLAUDE.md:**
   - Look for `## Yolo Mode Configuration (Beta)` section
   - Check `Status` field
   - Extract `Testing` and `Debug Mode` settings

2. **If `Status: on`:**
   - ✅ Yolo mode is enabled
   - Activate yolo skill (see `/skills/yolo/SKILL.md`)
   - Execute browser automation workflow:
     a. Navigate to Lovable project
     b. Submit deployment prompt
     c. Monitor for successful deployment
     d. Run tests if `Testing: on`
     e. Show deployment summary
   - **Exit** (don't show manual prompt)

3. **If `Status: off` or not found:**
   - ⏸️ Yolo mode is disabled
   - Show manual prompt (as shown in examples below)
   - Suggest enabling yolo mode:
     ```
     💡 **Tip:** Automate deployments with yolo mode!
        Run: /lovable:yolo on
        Benefits: No manual copy-paste, automatic testing
     ```

## Example Output

### Example 1: Yolo Mode Disabled (Manual)

```
## Edge Function Changes

Modified functions:
- `send-email` - Updated email template
- `process-payment` - Added refund handling

✅ All changes committed and pushed to main

## Secret Validation

Secrets used by functions:
- RESEND_API_KEY (send-email)
  Status: ✅ In Lovable Cloud
- STRIPE_SECRET_KEY (process-payment)
  Status: ⚠️ Not configured

⚠️ **Missing secret detected:**
Before deploying, add STRIPE_SECRET_KEY to Cloud → Secrets:
1. Go to Cloud → Secrets in Lovable
2. Click "Add secret"
3. Enter: STRIPE_SECRET_KEY = [your value]
4. Then run the prompt below

📋 **LOVABLE PROMPT:**
> "Deploy all edge functions"

After deployment, verify:
> "Show logs for send-email edge function"
> "Show logs for process-payment edge function"

💡 **Tip:** Automate deployments with yolo mode!
   Run: /lovable:yolo on
   Benefits: No manual copy-paste, automatic testing, auto-run code tests
```

### Example 2: Yolo Mode Enabled (Automated)

```
## Edge Function Changes

Modified functions:
- `send-email` - Updated email template

✅ All changes committed and pushed to main

🤖 Yolo mode: Deploying send-email edge function

⏳ Step 1/8: Navigating to Lovable project...
⏳ Step 2/8: Waiting for GitHub sync...
✅ Step 3/8: Sync verified - Lovable has latest code
✅ Step 4/8: Located chat interface
✅ Step 5/8: Submitted prompt: "Deploy the send-email edge function"
⏳ Step 6/8: Waiting for Lovable response...
✅ Step 7/8: Deployment confirmed
⏳ Step 8/8: Running verification tests...
✅ Step 8/8: All tests passed

## Deployment Summary

**Operation:** Edge Function Deployment
**Function:** send-email
**Status:** ✅ Success
**Duration:** 38 seconds

**Verification Tests:**
1. ✅ Basic verification: Deployment logs show no errors
2. ✅ Console check: No errors in browser console
3. ✅ Functional test: Function endpoint responds (200 OK)

**Production Status:**
- Function is live and responding
- No errors detected
- Ready for use

💡 Yolo mode is enabled. Run `/lovable:yolo off` to disable.
```
