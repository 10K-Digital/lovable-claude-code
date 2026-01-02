---
description: Generate the correct Lovable prompt for any backend operation. Describe what you need, get the exact prompt.
---

# Generate Lovable Prompt

Generate exact Lovable prompts for backend operations.

## Instructions

1. **Understand the request**: User describes what they need
2. **Select appropriate prompt template** from reference
3. **Output formatted prompt**:

```
📋 **LOVABLE PROMPT:**
> "[exact prompt]"
```

4. **Add warnings if needed**:
   - Destructive operations
   - Required secrets
   - Prerequisites

## Prompt Categories

### Edge Functions
- Deploy: `"Deploy the [name] edge function"`
- Deploy all: `"Deploy all edge functions"`
- Create: `"Create an edge function called [name] that [description]"`
- Debug: `"The [name] edge function returns [error]. Show logs and fix it"`
- Delete: `"Delete the [name] edge function"`

### Database Tables
- Create: `"Create a [name] table with columns: [col1] ([type]), [col2] ([type])"`
- Add column: `"Add a [column] column of type [type] to [table]"`
- Remove column: `"Remove the [column] column from [table]"`
- Drop table: `"Delete the [table] table"` ⚠️

### Migrations
- Apply: `"Apply pending Supabase migrations"`
- Review: `"Review and apply the latest migration"`

### RLS Policies
- Enable: `"Enable RLS on [table]"`
- Auth read: `"Add RLS policy on [table] allowing authenticated users to read all rows"`
- Own rows: `"Add RLS policy on [table] allowing users to only access their own rows"`
- Role-based: `"Add RLS policy on [table] allowing users with role [role] to [action]"`

### Relationships
- Foreign key: `"Add foreign key from [table1].[column] to [table2].id"`
- Cascade: `"Add foreign key from [table1].[column] to [table2].id with cascade delete"`

### Indexes
- Basic: `"Add an index on [table].[column]"`
- Unique: `"Add unique constraint on [table].[column]"`
- Composite: `"Add index on [table] for columns [col1], [col2]"`

### Storage
- Create bucket: `"Create a [public/private] storage bucket called [name]"`
- Set policy: `"Allow authenticated users to upload to [bucket]"`
- Public access: `"Make [bucket] publicly readable"`

### Auth
- Enable provider: `"Enable [Google/GitHub/Apple] authentication"`
- Signup trigger: `"When a user signs up, create a row in [table] with their user_id"`

### Secrets
⚠️ Cannot be set via prompts:
```
Manual steps:
1. Go to Cloud → Secrets
2. Add: [SECRET_NAME] = [value]
3. Run: "Redeploy edge functions"
```

## Example Interactions

**User**: I need to add a description field to the products table

**Output**:
```
📋 **LOVABLE PROMPT:**
> "Add a description column of type text to the products table"
```

---

**User**: Delete all data from the logs table

**Output**:
```
📋 **LOVABLE PROMPT:**
> "Delete all rows from the logs table"

⚠️ **Warning**: This will permanently delete all data in the logs table.
Consider backing up first.
```

---

**User**: My send-email function needs a Resend API key

**Output**:
```
⚠️ **Secrets must be added manually:**

1. Go to **Cloud** → **Secrets**
2. Click **Add secret**
3. Key: `RESEND_API_KEY`
4. Value: [your Resend API key]
5. Save

Then redeploy:

📋 **LOVABLE PROMPT:**
> "Deploy the send-email edge function"
```
