# Yolo Mode: Browser Automation Workflows

Complete reference for browser automation when yolo mode is enabled.

## Overview

This document provides step-by-step instructions for automating Lovable prompt submission using Claude's browser automation capabilities.

## Prerequisites

- Claude in Chrome extension installed
- User logged into Lovable.dev
- `lovable_url` configured in CLAUDE.md
- `yolo_mode: on` in CLAUDE.md

## Trigger Modes

### 1. Auto-Deploy Mode (Recommended)
When `auto_deploy: on`:
- Triggered automatically after `git push origin main`
- Claude detects backend file changes and starts deployment
- No manual command needed

### 2. Command-Triggered Mode
When `auto_deploy: off` or using manual commands:
- Triggered by `/deploy-edge` or `/apply-migration` commands
- User explicitly initiates deployment

## Core Automation Workflow

### Step 1: Navigate to Lovable Project

**Goal:** Open the Lovable project page in the browser.

1. **Read configuration:**
   ```
   - Read CLAUDE.md
   - Extract `lovable_url` field
   - Example: "https://lovable.dev/projects/abc123"
   ```

2. **Open browser:**
   ```
   - Use Claude's browser automation to navigate
   - Target URL: [lovable_url from CLAUDE.md]
   - Wait for: Page load complete
   ```

3. **Check for login:**
   ```
   - If URL redirects to /login or /signin:
     → User not logged in
     → Show message: "Please log in to Lovable"
     → Wait for user to log in
     → Retry navigation

   - If URL stays on project page:
     → User is logged in
     → Proceed to next step
   ```

4. **Verify project page loaded:**
   ```
   - Wait for: Chat interface to appear
   - Timeout: 10 seconds
   - If timeout:
     → Error: "Could not load Lovable project page"
     → Fall back to manual prompt
   ```

**Debug output (if `yolo_debug: on`):**
```
🐛 DEBUG: Step 1 - Navigate to Lovable

URL: https://lovable.dev/projects/abc123
Status: Navigating...
Wait: Page load event
Result: ✅ Loaded (1.2s)
Current URL: https://lovable.dev/projects/abc123
Login status: Authenticated
```

---

### Step 2: Locate Chat Interface

**Goal:** Find and prepare the chat input element for typing.

1. **Find chat input element:**
   ```
   Primary selectors to try (in order):
   1. textarea[data-testid="chat-input"]
   2. textarea[placeholder*="Message"]
   3. input[type="text"][data-testid*="chat"]
   4. textarea[class*="chat"]
   5. div[contenteditable="true"][role="textbox"]

   Wait for: Element exists and is visible
   Timeout: 5 seconds
   ```

2. **Verify element is interactable:**
   ```
   - Check element is not disabled
   - Check element is visible (not hidden)
   - Check element is in viewport
   - Scroll into view if needed
   ```

3. **If element not found:**
   ```
   Error: "Could not locate chat interface"

   Possible reasons:
   - Lovable UI has changed
   - Page still loading
   - Browser viewport too small

   Fallback: Provide manual prompt
   ```

**Debug output (if `yolo_debug: on`):**
```
🐛 DEBUG: Step 2 - Locate Chat Interface

Trying selectors:
  1. textarea[data-testid="chat-input"] → Not found
  2. textarea[placeholder*="Message"] → ✅ Found

Element properties:
  Visible: true
  Enabled: true
  In viewport: true
  Position: x=100, y=500

Result: ✅ Chat input located (0.3s)
```

---

### Step 3: Submit the Prompt

**Goal:** Type the Lovable prompt and submit it.

1. **Click to focus input:**
   ```
   - Click on chat input element
   - Wait for: Element to be focused
   - Verify: Element has focus (active element)
   ```

2. **Type the prompt:**
   ```
   - Clear existing text (if any)
   - Type the full Lovable prompt
   - Example: "Deploy the send-email edge function"
   - Typing speed: Natural (not instant)
   ```

3. **Submit the prompt:**
   ```
   Option A: Press Enter
   - Simulate Enter keypress
   - Wait: 200ms for form submission

   Option B: Click send button (if Enter doesn't work)
   - Find send button near input
   - Selectors: button[type="submit"], button[aria-label*="Send"]
   - Click button
   ```

4. **Confirm message sent:**
   ```
   - Wait for: New message to appear in chat
   - Check: Message content matches what we typed
   - Check: Message is from "user" (not assistant)
   - Timeout: 3 seconds
   ```

5. **If submission fails:**
   ```
   - Try alternative submission method
   - If still fails:
     → Error: "Could not submit prompt"
     → Show manual fallback
   ```

**Debug output (if `yolo_debug: on`):**
```
🐛 DEBUG: Step 3 - Submit Prompt

Focus: ✅ Input focused (0.1s)
Typing: "Deploy the send-email edge function"
  Speed: 50ms per character
  Duration: 1.9s
  Result: ✅ Text entered

Submission method: Press Enter
  Key: Enter
  Result: ✅ Submitted (0.1s)

Confirmation: Checking for new message...
  Wait: Message appears in chat
  Result: ✅ Message confirmed (0.4s)
  Content: "Deploy the send-email edge function"
```

---

### Step 4: Monitor Lovable's Response

**Goal:** Wait for Lovable to process the prompt and respond.

1. **Watch for new assistant message:**
   ```
   - Monitor chat for new messages
   - Look for: Message from "assistant" role (not user)
   - Ignore: User messages, system messages
   - Timeout: 180 seconds (3 minutes)
   ```

2. **Track loading indicators:**
   ```
   Common loading indicators:
   - "Thinking..." or "Generating..." text
   - Loading spinner icon
   - Typing indicator animation

   Wait for: All loading indicators to disappear
   ```

3. **Capture response text:**
   ```
   - Read full message content
   - Extract: Text from assistant's response
   - Store: For success/error detection
   ```

4. **If timeout:**
   ```
   After 3 minutes without response:

   Warning: "Lovable hasn't responded after 3 minutes"

   Possible reasons:
   - Complex operation still processing
   - Lovable encountered an error
   - Network issue

   Recommendation: Check Lovable manually
   Prompt submitted: [show prompt]
   ```

**Debug output (if `yolo_debug: on`):**
```
🐛 DEBUG: Step 4 - Monitor Response

Watching for: Assistant message
Elapsed: 0s ... 1s ... 2s ... 3s ... 4s
Loading indicators:
  - Typing animation: Present (3.2s), Gone (4.1s)

Message received:
  Role: assistant
  Timestamp: 4.2s after submission
  Length: 245 characters

Full content:
"I'll deploy the send-email edge function now. This will make the
function available at your Supabase edge function endpoint. The deployment
should complete within 30 seconds. I'll let you know when it's done!"

Result: ✅ Response received (4.2s)
```

---

### Step 5: Detect Success or Failure

**Goal:** Determine if the deployment was successful based on Lovable's response.

**Success Indicators:**

Look for these keywords in the response (case-insensitive):

For edge functions:
- "deploy" or "deployed"
- "function is live"
- "successfully deployed"
- "deployment complete"
- "available at"

For migrations:
- "migration applied"
- "database updated"
- "successfully ran"
- "schema updated"
- "migration complete"

**Error Indicators:**

Look for these keywords in the response:

- "error"
- "failed"
- "could not"
- "unable to"
- "invalid"
- "syntax error"
- "constraint"
- "permission denied"

**Detection Logic:**

```
1. Convert response to lowercase
2. Count success keywords found
3. Count error keywords found

4. If error keywords > 0:
   → Deployment failed
   → Extract error message
   → Show error to user

5. Else if success keywords > 0:
   → Deployment succeeded
   → Proceed to testing (if enabled)

6. Else:
   → Unclear response
   → Show response to user
   → Ask user to verify manually
```

**Examples:**

Success response:
```
"I'll deploy the send-email edge function now..."
→ Found: "deploy", "function"
→ No errors found
→ Status: ✅ Success
```

Error response:
```
"I encountered an error deploying the function. The syntax is invalid..."
→ Found: "error", "invalid"
→ Status: ❌ Failed
→ Error: "syntax is invalid"
```

**Debug output (if `yolo_debug: on`):**
```
🐛 DEBUG: Step 5 - Detect Success/Failure

Response analysis:
  Length: 245 characters
  Lowercase: "i'll deploy the send-email..."

Keyword search:
  Success keywords:
    - "deploy" → ✅ Found (position 6)
    - "deployed" → Not found
    - "function is live" → Not found
    - "successfully" → Not found

  Error keywords:
    - "error" → Not found
    - "failed" → Not found
    - "could not" → Not found

Result:
  Success keywords: 1
  Error keywords: 0
  Status: ✅ SUCCESS
```

---

## Testing Workflows

When `yolo_testing: on`, run these verification tests after successful deployment.

### Level 1: Basic Deployment Verification

**Goal:** Confirm deployment completed via Lovable's own confirmation.

**For Edge Functions:**

1. **Ask Lovable for deployment logs:**
   ```
   Submit follow-up prompt:
   "Show logs for [function-name] edge function"

   Wait for response (60 second timeout)
   ```

2. **Check logs response:**
   ```
   Success indicators in logs:
   - No deployment errors
   - Function shows as "active" or "running"
   - Recent timestamp matches deployment time

   Error indicators:
   - "no logs found"
   - Error messages in logs
   - Function shows as "inactive"
   ```

3. **Report result:**
   ```
   ✅ Basic verification: Deployment logs show no errors
   OR
   ⚠️ Basic verification: Logs show warnings
   OR
   ❌ Basic verification: Deployment errors in logs
   ```

**For Migrations:**

1. **Ask Lovable for schema confirmation:**
   ```
   Submit follow-up prompt:
   "Show me the [table-name] table structure"

   Wait for response (60 second timeout)
   ```

2. **Check schema response:**
   ```
   Success indicators:
   - Table exists
   - Columns match migration
   - No schema errors

   Error indicators:
   - "table does not exist"
   - Missing columns
   - Type mismatches
   ```

3. **Report result:**
   ```
   ✅ Basic verification: Migration applied (schema confirmed)
   OR
   ❌ Basic verification: Schema doesn't match migration
   ```

**Debug output (if `yolo_debug: on`):**
```
🐛 DEBUG: Level 1 - Basic Verification

Follow-up prompt: "Show logs for send-email edge function"
Response time: 2.1s
Response excerpt:
  "Here are the recent logs for send-email:
   [2024-01-15 10:30:00] Function deployed
   [2024-01-15 10:30:01] Function active
   No errors found."

Analysis:
  Deployment timestamp: Recent (< 1 min ago)
  Status: Active
  Errors: None found

Result: ✅ PASS (2.1s)
```

---

### Level 2: Console Error Checking

**Goal:** Monitor the production URL for JavaScript and network errors.

1. **Navigate to production URL:**
   ```
   - Read `production_url` from CLAUDE.md
   - Example: "https://my-app.lovable.app"
   - Navigate to URL in new tab
   - Wait for: Page load complete
   ```

2. **Open browser console:**
   ```
   - Access browser developer tools
   - Navigate to Console tab
   - Clear existing console messages
   ```

3. **Monitor for errors:**
   ```
   Watch for (10-15 seconds):

   JavaScript errors:
   - Uncaught exceptions
   - Reference errors
   - Type errors

   Network errors:
   - Failed API calls (500, 404 status)
   - Edge function call failures
   - CORS errors
   ```

4. **Capture and categorize errors:**
   ```
   For each error found:
   - Source: Which file/line
   - Type: JS error, network error, etc.
   - Message: Full error text
   - Severity: Error vs Warning

   Filter out:
   - Third-party script errors (analytics, etc.)
   - Known warnings that are safe
   ```

5. **Report findings:**
   ```
   If no errors:
   ✅ Console check: No errors detected

   If warnings only:
   ⚠️ Console check: 2 warnings found (non-critical)

   If errors:
   ❌ Console check: 3 errors found
   - Network error: Edge function call to /send-email returned 500
   - JS error: Cannot read property 'data' of undefined (app.js:45)
   ```

**Debug output (if `yolo_debug: on`):**
```
🐛 DEBUG: Level 2 - Console Error Checking

Navigation:
  URL: https://my-app.lovable.app
  Load time: 1.8s
  Status: 200 OK

Console monitoring (15s):
  Errors: 0
  Warnings: 1
  Info: 5

Warning details:
  [1] DevTools: Third-party cookie warning
    Source: Chrome
    Severity: Low
    Filter: ✅ Ignored (third-party)

Network requests (during monitoring):
  Total: 12
  Success: 12
  Failed: 0

Result: ✅ PASS - No errors (0.1s monitoring)
```

---

### Level 3: Functional Testing

**Goal:** Test that the deployed feature actually works.

**For Edge Functions:**

1. **Determine function endpoint:**
   ```
   Pattern: https://{supabase-ref}.supabase.co/functions/v1/{function-name}

   Get supabase-ref from:
   - CLAUDE.md (if documented)
   - Lovable response (if mentioned)
   - Ask user if not available
   ```

2. **Determine test payload:**
   ```
   Option A: Known test payload
   - If function has documented test data
   - Example: send-email might test with dummy email

   Option B: Ask user
   - "What test data should I send to test [function-name]?"
   - Wait for user input

   Option C: No-payload test
   - For functions that don't require input
   - Just check if endpoint responds
   ```

3. **Make test request:**
   ```
   - HTTP POST to function endpoint
   - Include: Auth headers (if needed), test payload
   - Timeout: 30 seconds
   - Capture: Status code, response body
   ```

4. **Verify response:**
   ```
   Success indicators:
   - Status code: 200-299
   - Response body: Expected structure
   - No error messages in body

   Failure indicators:
   - Status code: 400-599
   - Timeout
   - Error in response body
   ```

5. **Report result:**
   ```
   ✅ Functional test: Function responds correctly (200 OK)
   Response: {"success": true, "message": "Email sent"}

   OR

   ⚠️ Functional test: Function responds with error (500)
   Response: {"error": "SMTP connection failed"}

   OR

   ⏭️ Functional test: Skipped (no test payload available)
   To test manually: [show endpoint and example payload]
   ```

**For Migrations:**

1. **Determine test query:**
   ```
   Based on migration type:

   CREATE TABLE: "SELECT * FROM [table] LIMIT 1"
   ADD COLUMN: "SELECT [column] FROM [table] LIMIT 1"
   CREATE INDEX: "EXPLAIN SELECT * FROM [table] WHERE [indexed-column]"
   ```

2. **Execute test query via Lovable:**
   ```
   Submit prompt to Lovable:
   "Run this query: [test-query]"

   Wait for response (60 second timeout)
   ```

3. **Verify query result:**
   ```
   Success indicators:
   - Query executes without error
   - Returns expected structure
   - No permission errors

   Failure indicators:
   - "relation does not exist"
   - "column does not exist"
   - Permission denied
   ```

4. **Report result:**
   ```
   ✅ Functional test: Test query succeeded
   Query: SELECT * FROM users LIMIT 1
   Result: Table structure confirmed

   OR

   ❌ Functional test: Query failed
   Error: column "new_field" does not exist
   ```

**Debug output (if `yolo_debug: on`):**
```
🐛 DEBUG: Level 3 - Functional Testing

Function: send-email
Endpoint: https://abc123.supabase.co/functions/v1/send-email

Test payload:
  Method: POST
  Headers:
    Authorization: Bearer [token]
    Content-Type: application/json
  Body:
    {
      "to": "test@example.com",
      "subject": "Test",
      "body": "Test message"
    }

Request: Sending...
Response time: 1.2s
Status: 200 OK
Headers:
  Content-Type: application/json
Body:
  {
    "success": true,
    "messageId": "abc-123-def"
  }

Analysis:
  Status code: ✅ 200 (success range)
  Response structure: ✅ Valid JSON
  Error indicators: ❌ None found

Result: ✅ PASS (1.2s)
```

---

## Error Handling Reference

### Error Categories

**1. Browser/Navigation Errors**

```
Could not access browser:
→ Check Chrome extension installed
→ Check browser is running
→ Fallback: Manual prompt

Could not navigate to URL:
→ Check lovable_url is valid
→ Check internet connection
→ Fallback: Manual prompt

Login required:
→ Instruct user to log in
→ Retry automatically
→ Timeout after 2 minutes → manual prompt
```

**2. UI Element Errors**

```
Chat interface not found:
→ Try alternative selectors
→ Wait longer (Lovable may be loading)
→ If still not found → Manual prompt
→ Suggest reporting issue

Element not interactable:
→ Scroll into view
→ Wait for animations to complete
→ Remove overlays if present
→ If still blocked → Manual prompt
```

**3. Submission Errors**

```
Could not submit prompt:
→ Try Enter key
→ Try click send button
→ Try paste and submit
→ If all fail → Manual prompt

Message not confirmed:
→ Wait longer (up to 5s)
→ Check if message appeared later
→ If still not confirmed → Warn user, continue
```

**4. Response Errors**

```
Timeout (no response):
→ Warn: "3 minutes without response"
→ Suggest manual check
→ Show what prompt was submitted

Lovable returned error:
→ Parse error message
→ Show to user
→ Suggest fixes based on error type
→ Offer to help debug
```

**5. Testing Errors**

```
Test failed:
→ Show which test failed
→ Show specific error
→ Mark deployment as "⚠️ Deployed but test failed"
→ Suggest manual verification

Could not run test:
→ Skip that test level
→ Continue with remaining tests
→ Note in summary: "Some tests skipped"
```

### Fallback Strategy

For ANY automation failure:

1. **Capture the error**
2. **Show user-friendly message**
3. **Provide manual prompt as fallback:**
   ```
   ❌ [Error description]

   Fallback: Here's the prompt to run manually in Lovable:
   📋 "Deploy the send-email edge function"

   [Context-specific troubleshooting]
   ```
4. **Never block the user** - always provide a way forward

---

## User Notification Templates

### Progress Notifications

**Standard mode (debug off):**
```
🤖 Yolo mode: Deploying send-email edge function

⏳ Step 1/7: Navigating to Lovable project...
✅ Step 2/7: Located chat interface
✅ Step 3/7: Submitted prompt
⏳ Step 4/7: Waiting for Lovable response...
✅ Step 5/7: Deployment confirmed
⏳ Step 6/7: Running verification tests...
  ⏳ Basic verification...
  ⏳ Console error checking...
  ⏳ Functional testing...
✅ Step 7/7: All tests passed

✅ Complete! Edge function deployed and verified.
```

### Summary Notifications

**Success with all tests passed:**
```
## Deployment Summary

**Operation:** Edge Function Deployment
**Function:** send-email
**Status:** ✅ Success
**Duration:** 45 seconds

**Automation Steps:**
1. ✅ Navigated to Lovable project
2. ✅ Submitted deployment prompt
3. ✅ Deployment confirmed by Lovable

**Verification Tests:**
1. ✅ Basic verification: Deployment logs show no errors
2. ✅ Console check: No errors in browser console
3. ✅ Functional test: Function endpoint responds (200 OK)
   Response: {"success": true, "messageId": "abc-123"}

**Production Status:**
- Function is live at endpoint
- No errors detected
- Ready for use

💡 Yolo mode is still enabled. Run `/yolo off` to disable.
```

**Success with test warnings:**
```
## Deployment Summary

**Operation:** Edge Function Deployment
**Function:** send-email
**Status:** ⚠️ Deployed (with warnings)
**Duration:** 52 seconds

**Automation Steps:**
1. ✅ Navigated to Lovable project
2. ✅ Submitted deployment prompt
3. ✅ Deployment confirmed by Lovable

**Verification Tests:**
1. ✅ Basic verification: Deployment logs show no errors
2. ⚠️ Console check: 1 warning found (non-critical)
   - Warning: "Rate limit approaching for Resend API"
3. ✅ Functional test: Function responds (200 OK)

**Recommendation:**
- Function deployed successfully
- Monitor the rate limit warning
- Consider upgrading Resend plan if needed

💡 Yolo mode is still enabled. Run `/yolo off` to disable.
```

**Deployment succeeded but testing failed:**
```
## Deployment Summary

**Operation:** Edge Function Deployment
**Function:** send-email
**Status:** ⚠️ Deployed (test failures)
**Duration:** 48 seconds

**Automation Steps:**
1. ✅ Navigated to Lovable project
2. ✅ Submitted deployment prompt
3. ✅ Deployment confirmed by Lovable

**Verification Tests:**
1. ✅ Basic verification: Passed
2. ✅ Console check: Passed
3. ❌ Functional test: Failed
   Status: 500 Internal Server Error
   Error: "RESEND_API_KEY not found"

**Issue Found:**
The function deployed but isn't working because the RESEND_API_KEY
secret is missing.

**Next Steps:**
1. Go to Cloud → Secrets in Lovable
2. Add: RESEND_API_KEY = [your key]
3. Test the function again

Would you like me to help you find your Resend API key?
```

---

## Configuration Options

### Testing Control

**Enable all tests (default):**
```
yolo_testing: on
```
Runs all 3 testing levels after each deployment.

**Disable all tests:**
```
yolo_testing: off
```
Only deploys, no verification. Faster but less safe.

### Debug Control

**Enable debug output:**
```
yolo_debug: on
```
Shows verbose logs with timing, selectors, full responses.

**Disable debug output (default):**
```
yolo_debug: off
```
Shows minimal progress indicators only.

---

## Performance Notes

**Typical timing:**
- Navigation: 1-2s
- Element location: 0.2-0.5s
- Prompt submission: 0.1-0.3s
- Lovable response: 3-10s
- Basic verification: 2-5s
- Console checking: 10-15s
- Functional testing: 1-5s

**Total automation time:**
- Without testing: ~5-15s
- With testing: ~20-40s

**Timeout limits:**
- Page load: 10s
- Element finding: 5s
- Lovable response: 180s (3 min)
- Test requests: 30-60s

---

## Graceful Fallback Strategy

**CRITICAL:** Browser automation MUST always fall back gracefully to manual instructions. Never leave the user stuck.

### Fallback Principles

1. **Always provide manual prompt** - Every failure message includes the Lovable prompt to copy-paste
2. **Clear error explanation** - Tell user why automation failed
3. **Actionable next steps** - Provide troubleshooting or workaround
4. **Never block progress** - User can always complete task manually

### Auto-Deploy Fallback Flow

```
git push origin main
    ↓
Detect backend changes
    ↓
Attempt automation
    ↓
┌─ Success → Show deployment summary
│
└─ Failure → Graceful fallback:
      1. Show clear error message
      2. Explain what went wrong
      3. Provide manual Lovable prompt
      4. Suggest troubleshooting steps
      5. Offer to disable auto-deploy if needed
```

### Fallback Message Templates

**For auto-deploy failures:**
```
❌ Auto-deploy failed: [specific error]

Backend changes were pushed successfully to GitHub.
Lovable will sync the code, but deployment requires a prompt.

**Complete manually in Lovable:**

📋 **LOVABLE PROMPT:**
> "Deploy the [function-name] edge function"

**Troubleshooting:**
[Context-specific suggestions]

💡 To disable auto-deploy: /lovable:yolo --no-auto-deploy
```

**For command-triggered failures:**
```
❌ Browser automation failed: [specific error]

**Fallback - run this prompt in Lovable:**

📋 **LOVABLE PROMPT:**
> "[the prompt that was going to be submitted]"

**What happened:**
[Brief explanation]

**Suggestions:**
[How to fix or work around]
```

### Error-Specific Fallbacks

| Error | Fallback Message |
|-------|------------------|
| Extension not installed | Prompt + link to install Chrome extension |
| Not logged in | Prompt + "Please log in to Lovable" |
| UI element not found | Prompt + "Lovable UI may have changed" + report link |
| Timeout | Prompt + "Check Lovable manually, may still be processing" |
| Deployment error | Prompt + error details + suggested fixes |
| Network error | Prompt + "Check internet connection" |

### Recovery Options

After any failure, offer these options:

1. **Manual completion** - Provide exact prompt to copy-paste
2. **Retry** - User can try automation again
3. **Change mode** - Suggest switching to manual mode if errors persist
4. **Report issue** - Link to GitHub issues for persistent problems

---

*This reference should be consulted for all browser automation operations in yolo mode.*
