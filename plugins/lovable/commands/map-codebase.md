---
description: Generate a Project Structure Map to help Claude navigate your codebase faster. Can update CLAUDE.md directly.
---

# Map Codebase

Generate a concise codebase map for faster navigation.

## Syntax

```
/lovable:map              # Generate and show map
/lovable:map --update     # Update CLAUDE.md with new map
/lovable:map --verbose    # Show detailed scanning output
```

## Instructions

### Step 1: Parse Flags

Determine mode from user flags:
- `--update`: Write map directly to CLAUDE.md
- `--verbose`: Show detailed scanning progress
- No flags: Generate and display map only

### Step 2: Scan Directory Structure

Use the codebase-map reference (`skills/lovable/references/codebase-map.md`) for scanning patterns.

**Scan in order:**

1. **List `src/` subdirectories**
   ```
   ls -la src/
   ```
   Record: components, pages, hooks, lib, utils, services, contexts, stores, types, integrations, assets

2. **Count items in key directories**
   - Count files in `src/components/` (exclude index files)
   - Count files in `src/pages/`
   - Count files in `src/hooks/`
   - Count functions in `supabase/functions/`
   - Count migrations in `supabase/migrations/`

3. **Detect component organization pattern**
   Check `src/components/` structure:
   - If has `ui/` subfolder → "Feature-based with shadcn/ui"
   - If has subdirectories by feature → "Feature-based"
   - If all .tsx at root level → "Flat"
   - If has atoms/molecules/organisms → "Atomic design"

4. **Identify key files**
   Check existence and content of:
   - `src/App.tsx` or `src/App.jsx` → Main app entry
   - `src/main.tsx` → React DOM mount
   - `src/lib/utils.ts` → Utilities
   - `src/integrations/supabase/client.ts` → Supabase client
   - `src/hooks/use*.ts` → Custom hooks
   - `vite.config.ts` → Vite config
   - `tailwind.config.js` → Tailwind config

5. **Detect state management**
   Search for patterns:
   - `createContext` in `src/contexts/` → React Context
   - `create` from 'zustand' → Zustand
   - `useQuery` / `useMutation` → TanStack Query
   - `configureStore` → Redux

### Step 3: Generate Map

Build the map using this template (~60 lines):

```markdown
## Project Structure Map

> Quick navigation guide - run `/lovable:map --update` to refresh

### Directory Layout
```
src/
├── components/    # [PATTERN] ([COUNT] components)
│   └── ui/        # shadcn/ui primitives
├── pages/         # Route pages ([COUNT] pages)
├── hooks/         # Custom React hooks ([COUNT] hooks)
├── lib/           # Utilities and helpers
├── integrations/  # External integrations
│   └── supabase/  # Supabase client and generated types
[ADDITIONAL_DIRS]

supabase/
├── functions/     # Edge Functions ([COUNT] functions)
└── migrations/    # Database migrations ([COUNT] migrations)
```

### Key Files
| File | Purpose |
|------|---------|
| `src/App.tsx` | Main app entry, routing |
| `src/lib/utils.ts` | Shared utilities (cn, formatters) |
| `src/integrations/supabase/client.ts` | Supabase client configuration |
[ADDITIONAL_KEY_FILES]

### Patterns
- **Components**: [COMPONENT_PATTERN]
- **State**: [STATE_MANAGEMENT] (or "React state + props" if none detected)
- **Data Flow**: Pages → Hooks → Supabase Client → Edge Functions

### Quick Lookup
| Looking for... | Check here |
|----------------|------------|
| UI components | `src/components/ui/` |
| Page routes | `src/pages/` or `src/App.tsx` |
| API calls | `src/hooks/` or `src/integrations/` |
| Types | `src/types/` or `src/integrations/supabase/types.ts` |
| Edge functions | `supabase/functions/[name]/index.ts` |

*Last updated: [CURRENT_TIMESTAMP]*
```

### Step 4: Handle Output

**If `--verbose` flag:**
Show scanning progress:
```
Scanning src/...
  Found: components/ (23 files), pages/ (8 files), hooks/ (5 files)
  Pattern detected: Feature-based with shadcn/ui
Scanning supabase/...
  Found: 3 edge functions, 12 migrations
Detecting state management...
  Found: React Context (2 contexts), TanStack Query
Building map...
```

**If `--update` flag:**

1. Check if CLAUDE.md exists
   - If not: "No CLAUDE.md found. Run `/lovable:init` first, or use `/lovable:map` without --update to see the map."

2. Check if map section already exists in CLAUDE.md
   - Look for `## Project Structure Map` header

3. Update CLAUDE.md:
   - If section exists: Replace entire section (from `## Project Structure Map` to next `##` header)
   - If not exists: Insert after `## Project Overview` section

4. Confirm:
   ```
   Updated CLAUDE.md with new Project Structure Map.

   Summary:
   - [X] components in [PATTERN] organization
   - [X] pages
   - [X] custom hooks
   - [X] edge functions
   - [X] migrations

   The map will help me navigate your codebase faster.
   ```

**If no flags (display only):**

Show the generated map and prompt:
```
[Generated map content]

---

To add this map to your CLAUDE.md, run:
/lovable:map --update
```

### Step 5: Handle Edge Cases

**Non-Lovable Project (no src/ or supabase/)**
```
This doesn't appear to be a standard Lovable/React project.

Found structure:
[list top-level directories]

Would you like me to generate a basic map anyway? (yes/no)
```

If yes, generate simplified map with whatever structure exists.

**Empty Project**
```
Project appears to be empty or newly initialized.
No structure to map yet.

Run `/lovable:map` again after adding some code.
```

**Large Project (>100 components)**
```
Large project detected ([X] components).
Generating summarized map (grouped by directory)...
```

Group by subdirectory instead of counting total files.

---

## Examples

### Example Output (Standard Lovable Project)

```markdown
## Project Structure Map

> Quick navigation guide - run `/lovable:map --update` to refresh

### Directory Layout
```
src/
├── components/    # Feature-based (34 components)
│   ├── ui/        # shadcn/ui primitives (Button, Card, Dialog...)
│   ├── auth/      # Authentication components
│   ├── dashboard/ # Dashboard widgets
│   └── layout/    # Layout components (Header, Sidebar, Footer)
├── pages/         # Route pages (8 pages)
├── hooks/         # Custom React hooks (6 hooks)
├── lib/           # Utilities and helpers
├── contexts/      # React contexts (2 contexts)
├── integrations/  # External integrations
│   └── supabase/  # Supabase client and generated types
└── types/         # TypeScript definitions

supabase/
├── functions/     # Edge Functions (4 functions)
└── migrations/    # Database migrations (15 migrations)
```

### Key Files
| File | Purpose |
|------|---------|
| `src/App.tsx` | Main app entry, React Router setup |
| `src/main.tsx` | React DOM mount point |
| `src/lib/utils.ts` | cn() helper, date formatters |
| `src/integrations/supabase/client.ts` | Supabase client |
| `src/hooks/useAuth.ts` | Authentication state hook |
| `src/contexts/AuthContext.tsx` | Auth provider context |

### Patterns
- **Components**: Feature-based with shadcn/ui primitives in `ui/`
- **State**: React Context + TanStack Query for server state
- **Data Flow**: Pages → Hooks → Supabase Client → Edge Functions

### Quick Lookup
| Looking for... | Check here |
|----------------|------------|
| UI components | `src/components/ui/` |
| Page routes | `src/pages/` or `src/App.tsx` |
| API calls | `src/hooks/` or `src/integrations/` |
| Types | `src/types/` or `src/integrations/supabase/types.ts` |
| Edge functions | `supabase/functions/[name]/index.ts` |
| Auth logic | `src/contexts/AuthContext.tsx`, `src/hooks/useAuth.ts` |

*Last updated: 2024-01-15 14:30 UTC*
```

---

## Integration Notes

This command can be invoked:
- Standalone: User runs `/lovable:map`
- From `/lovable:init`: As Question 8.5 (optional)
- From `/lovable:sync`: With `--refresh-map` flag

The map generation logic is shared - this command is the primary interface.
