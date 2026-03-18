# AI Skill Marketplace Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a GitHub repo where Make Nashville members can browse and install reusable Claude Code skills via git clone/submodule and an install script.

**Architecture:** Flat `skills/` directory with self-contained skill directories, an `install.sh` symlink manager, a `manifest.json` catalog, and a README. Two initial skills: `makerspace-signage-cards` (ported from parts-library) and `outline-publisher` (new, distilled from 3dprint-guidelines migration script).

**Tech Stack:** Bash (install script), Markdown (skills), JSON (manifest)

**Spec:** `docs/superpowers/specs/2026-03-17-ai-skill-marketplace-design.md`

---

## Chunk 1: Skill Files

### Task 1: Port makerspace-signage-cards SKILL.md

**Files:**
- Create: `skills/makerspace-signage-cards/SKILL.md`
- Source: `/Users/kevinhuber/src/parts-library/.claude/skills/makerspace-signage-cards/SKILL.md`

- [ ] **Step 1: Copy source SKILL.md**

Copy from `parts-library` source. Then apply these changes:

1. In Step 5 "Output Format" — replace the hardcoded path pattern `src/signage-templates/csv/[machine-slug]-[card-type].csv` with guidance to write CSVs to the current working directory or ask the user for a preferred output path. Change the **File naming** line and examples to remove the `src/signage-templates/csv/` prefix.

Before:
```
**File naming:** `src/signage-templates/csv/[machine-slug]-[card-type].csv`

Examples:
- `src/signage-templates/csv/bambu-lab-p1s-monthly-maintenance.csv`
- `src/signage-templates/csv/bambu-lab-p1s-quarterly-maintenance.csv`
- `src/signage-templates/csv/laser-cutter-orientation.csv`
```

After:
```
**File naming:** `[machine-slug]-[card-type].csv` — write to the current working directory, or ask the user for a preferred output path.

Examples:
- `bambu-lab-p1s-monthly-maintenance.csv`
- `bambu-lab-p1s-quarterly-maintenance.csv`
- `laser-cutter-orientation.csv`
```

No other changes to SKILL.md.

- [ ] **Step 2: Verify the file**

Read the created file and confirm the path change was applied and all other content is intact.

- [ ] **Step 3: Commit**

```bash
git add skills/makerspace-signage-cards/SKILL.md
git commit -m "Add makerspace-signage-cards skill (ported from parts-library)"
```

### Task 2: Port makerspace-signage-cards card-design-guide.md

**Files:**
- Create: `skills/makerspace-signage-cards/references/card-design-guide.md`
- Source: `/Users/kevinhuber/src/parts-library/.claude/skills/makerspace-signage-cards/references/card-design-guide.md`

- [ ] **Step 1: Copy source card-design-guide.md**

Copy from `parts-library` source. Then apply this change:

In the "Canva Bulk Create Field Mapping" section, the line `` Reference SVGs for each template live in `src/signage-templates/`. `` should be changed to:

```
Reference SVGs for each template live in the original `parts-library` repo at `src/signage-templates/`. They are not bundled in the marketplace — refer to that repo if you need the source SVGs.
```

No other changes.

- [ ] **Step 2: Verify the file**

Read the created file and confirm the SVG reference change was applied and all other content is intact.

- [ ] **Step 3: Commit**

```bash
git add skills/makerspace-signage-cards/references/card-design-guide.md
git commit -m "Add card design guide reference for signage cards skill"
```

### Task 3: Create outline-publisher SKILL.md

**Files:**
- Create: `skills/outline-publisher/SKILL.md`

- [ ] **Step 1: Write the SKILL.md**

```markdown
---
name: outline-publisher
description: "Publish markdown content with images to the Make Nashville Outline wiki (https://wiki.makenashville.org/). Use this skill when someone wants to publish documentation, guides, instructions, or any markdown content to the Outline wiki. Also trigger when the user wants to migrate a README, create wiki pages, upload documentation, or sync content to Outline. Trigger on phrases like 'publish to Outline', 'add to the wiki', 'create wiki page', 'migrate to Outline', 'publish documentation', or references to wiki.makenashville.org."
---

# Outline Publisher

Publish markdown content — with images — to the Make Nashville Outline wiki at https://wiki.makenashville.org/.

## Overview

This skill takes markdown content (from a file, URL, or inline text) and publishes it to Outline as a collection of documents. It handles image uploads, content splitting, and collection management via the Outline API.

Before making any API calls, read `references/outline-api-guide.md` for the full API surface, authentication details, and request/response formats.

---

## Workflow

### Step 1: Identify the Source Content

Determine what content the user wants to publish. They may provide:

- A markdown file path
- A URL to fetch markdown from
- Inline markdown text in the conversation
- A general topic they want documented

If a file path is given, read it. If a URL, use `WebFetch` to retrieve it. If inline text, work with what's provided.

### Step 2: Ask Clarifying Questions

Don't assume — ask. The goal is to publish content that's organized the way the user expects.

**Always ask:**

1. **What should the collection be called?** (e.g., "3D Print Shop Guidelines", "Laser Cutter Documentation")
2. **Publish immediately or save as draft?**
3. **Split into separate documents by heading, or publish as a single document?**

**Ask if relevant:**

- Should this go into an existing collection or a new one?
- Are there images that need to be uploaded?
- Should any sections be excluded?

### Step 3: Check Environment

Verify the `OUTLINE_TOKEN` environment variable is set. If not, provide setup instructions:

> To use this skill, you need an Outline API token:
>
> 1. Go to https://wiki.makenashville.org/settings/api
> 2. Create a new API token with write permissions
> 3. Set the environment variable: `export OUTLINE_TOKEN=your_token_here`

The Outline URL defaults to `https://wiki.makenashville.org/`. To override, set `OUTLINE_URL`.

### Step 4: Check for Existing Collection

Before creating a new collection, search for existing ones via the `collections.list` API endpoint (see `references/outline-api-guide.md`).

Use `WebFetch` to POST to `{OUTLINE_URL}/api/collections.list` with the collection name as a query.

If a matching collection exists, ask the user whether to:
- Add documents to the existing collection
- Create a new collection anyway

### Step 5: Upload Images

For any local images referenced in the markdown (matching `![alt](path)` patterns):

1. **Get a pre-signed upload URL** — use `WebFetch` to POST to `{OUTLINE_URL}/api/attachments.create` with `name`, `contentType`, and `size` fields.
2. **Upload the file to S3** — use `curl` via Bash to POST the file as multipart form data to the returned `uploadUrl`, including all S3 form fields.
3. **Replace image references** — update the markdown to use the returned `attachment.url` instead of the local path.

See `references/outline-api-guide.md` for the full request/response format and curl example.

### Step 6: Split Content

If the user requested splitting by headings:

- Split the markdown by `## ` headings
- Content before the first `## ` becomes an intro document using the `# ` title (or "Overview")
- Each `## ` section becomes its own document

If the user wants a single document, keep the content as-is.

### Step 7: Create Collection and Documents

1. **Create collection** (if needed) — use `WebFetch` to POST to `{OUTLINE_URL}/api/collections.create` with `name`, `description`, and `permission` fields.
2. **Create documents** — for each section, use `WebFetch` to POST to `{OUTLINE_URL}/api/documents.create` with `collectionId`, `title`, `text`, and `publish` fields. Documents are created flat at the collection root.

### Step 8: Report Back

Present the user with:
- The collection URL
- A list of created documents with their titles and URLs
- Any warnings (e.g., images that couldn't be uploaded)

---

## Key Principles

**Respect existing content.** Always check for existing collections before creating new ones. Don't overwrite without asking.

**Handle images gracefully.** If image upload fails, warn the user and continue — don't block the entire publish on a single image failure.

**Keep it simple.** This skill publishes content. It doesn't manage Outline users, permissions, or complex document hierarchies.

---

## Common Pitfalls

- **Missing API token.** Always check for `OUTLINE_TOKEN` before making any API calls.
- **Forgetting to replace image paths.** After uploading images, the markdown must be updated with the new URLs before creating documents.
- **Creating duplicate collections.** Always search first.
- **Large documents.** If a single document is very long, suggest splitting by headings even if the user didn't ask.
```

- [ ] **Step 2: Verify the file**

Read the created file and confirm the workflow matches the spec (8 steps, correct API endpoints, curl for image uploads, WebFetch for JSON APIs).

- [ ] **Step 3: Commit**

```bash
git add skills/outline-publisher/SKILL.md
git commit -m "Add outline-publisher skill for Outline wiki publishing"
```

### Task 4: Create outline-publisher outline-api-guide.md

**Files:**
- Create: `skills/outline-publisher/references/outline-api-guide.md`

- [ ] **Step 1: Write the API guide**

```markdown
# Outline API Reference — Publisher Skill

API reference for the endpoints used by the outline-publisher skill. All endpoints accept JSON POST requests to `{OUTLINE_URL}/api/{endpoint}`.

## Authentication

All requests require a Bearer token in the `Authorization` header:

```
Authorization: Bearer {OUTLINE_TOKEN}
Content-Type: application/json
```

Default `OUTLINE_URL`: `https://wiki.makenashville.org/`
Override with the `OUTLINE_URL` environment variable.

---

## Endpoints

### `collections.list`

Search for existing collections.

**Request:**
```json
{
  "query": "3D Print Shop Guidelines"
}
```

The `query` field is optional. Omit it to list all collections.

**Response:**
```json
{
  "data": [
    {
      "id": "collection-uuid",
      "name": "3D Print Shop Guidelines",
      "description": "...",
      "url": "/collection/3d-print-shop-guidelines-abc123"
    }
  ]
}
```

---

### `collections.create`

Create a new wiki collection.

**Request:**
```json
{
  "name": "3D Print Shop Guidelines",
  "description": "Guidelines for the Make Nashville 3D print shop.",
  "permission": "read"
}
```

- `permission`: `"read"` makes the collection visible to all workspace members.

**Response:**
```json
{
  "data": {
    "id": "collection-uuid",
    "name": "3D Print Shop Guidelines",
    "url": "/collection/3d-print-shop-guidelines-abc123"
  }
}
```

---

### `documents.create`

Create a document within a collection.

**Request:**
```json
{
  "collectionId": "collection-uuid",
  "title": "How to Print (Quick Start)",
  "text": "Markdown content here...",
  "publish": true
}
```

- `publish`: `true` to publish immediately, `false` to save as draft.
- Documents are created flat at the collection root (no `parentDocumentId` nesting).

**Response:**
```json
{
  "data": {
    "id": "document-uuid",
    "title": "How to Print (Quick Start)",
    "url": "/doc/how-to-print-quick-start-abc123"
  }
}
```

---

### `attachments.create`

Request a pre-signed upload URL for an image or file.

**Step 1: Get the upload URL**

Use `WebFetch` to POST:

```json
{
  "name": "photo.jpg",
  "contentType": "image/jpeg",
  "size": 102400
}
```

**Response:**
```json
{
  "data": {
    "uploadUrl": "https://s3.amazonaws.com/bucket/...",
    "form": {
      "key": "uploads/...",
      "Content-Type": "image/jpeg",
      "policy": "...",
      "x-amz-credential": "...",
      "x-amz-algorithm": "AWS4-HMAC-SHA256",
      "x-amz-date": "...",
      "x-amz-signature": "..."
    },
    "attachment": {
      "url": "/api/attachments.redirect?id=attachment-uuid"
    }
  }
}
```

**Step 2: Upload the file to S3**

Use `curl` via Bash. Build the command from the `form` fields returned above. The file field **must be last** in the multipart form:

```bash
curl -X POST "{uploadUrl}" \
  -F "key={form.key}" \
  -F "Content-Type={form.Content-Type}" \
  -F "policy={form.policy}" \
  -F "x-amz-credential={form.x-amz-credential}" \
  -F "x-amz-algorithm={form.x-amz-algorithm}" \
  -F "x-amz-date={form.x-amz-date}" \
  -F "x-amz-signature={form.x-amz-signature}" \
  -F "file=@/path/to/photo.jpg;type=image/jpeg"
```

A `204 No Content` response means success.

**Step 3: Use the attachment URL**

Replace the local image path in markdown with `{OUTLINE_URL}{attachment.url}`:

Before: `![Photo](images/photo.jpg)`
After: `![Photo](https://wiki.makenashville.org/api/attachments.redirect?id=attachment-uuid)`
```

- [ ] **Step 2: Verify the file**

Read the created file and confirm all four endpoints are documented with request/response examples.

- [ ] **Step 3: Commit**

```bash
git add skills/outline-publisher/references/outline-api-guide.md
git commit -m "Add Outline API reference guide for publisher skill"
```

---

## Chunk 2: Install Script, Manifest, and README

### Task 5: Write install.sh with tests

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Write install.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

usage() {
    cat <<'USAGE'
Usage:
  ./install.sh [skill-name] <project-path>       Install skill(s)
  ./install.sh --remove [skill-name] <project-path>  Remove skill(s)

Examples:
  ./install.sh /path/to/my-project                    Install all skills
  ./install.sh makerspace-signage-cards /path/to/proj  Install one skill
  ./install.sh --remove /path/to/my-project            Remove all skills
  ./install.sh --remove outline-publisher /path/to/proj Remove one skill
USAGE
    exit 1
}

install_skill() {
    local skill_name="$1"
    local target_dir="$2"
    local skill_source="$SKILLS_DIR/$skill_name"
    local skill_target="$target_dir/.claude/skills/$skill_name"

    if [[ -e "$skill_target" && ! -L "$skill_target" ]]; then
        echo "Error: $skill_target exists and is not a symlink. Remove it manually to proceed." >&2
        return 1
    fi

    mkdir -p "$target_dir/.claude/skills"
    ln -sfn "$skill_source" "$skill_target"
    echo "Installed $skill_name -> $skill_target"
}

remove_skill() {
    local skill_name="$1"
    local target_dir="$2"
    local skill_target="$target_dir/.claude/skills/$skill_name"

    if [[ -L "$skill_target" ]]; then
        rm "$skill_target"
        echo "Removed $skill_name from $target_dir/.claude/skills/"
    elif [[ -e "$skill_target" ]]; then
        echo "Error: $skill_target is not a symlink. Remove it manually." >&2
        return 1
    else
        echo "Skipping $skill_name (not installed in $target_dir)"
    fi
}

# Parse arguments
REMOVE=false
if [[ "${1:-}" == "--remove" ]]; then
    REMOVE=true
    shift
fi

if [[ $# -eq 0 ]]; then
    usage
fi

# Determine if first arg is a skill name or a project path
SKILL_NAME=""
PROJECT_PATH=""

if [[ $# -eq 1 ]]; then
    # Only one arg: must be project path, operate on all skills
    PROJECT_PATH="$1"
elif [[ $# -eq 2 ]]; then
    # Two args: first is skill name, second is project path
    if [[ -d "$SKILLS_DIR/$1" ]]; then
        SKILL_NAME="$1"
        PROJECT_PATH="$2"
    else
        echo "Error: Unknown skill '$1'. Available skills:" >&2
        ls -1 "$SKILLS_DIR" >&2
        exit 1
    fi
else
    usage
fi

# Validate project path
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "Error: Project directory '$PROJECT_PATH' does not exist." >&2
    exit 1
fi

# Execute
if [[ -n "$SKILL_NAME" ]]; then
    if $REMOVE; then
        remove_skill "$SKILL_NAME" "$PROJECT_PATH"
    else
        install_skill "$SKILL_NAME" "$PROJECT_PATH"
    fi
else
    for skill_dir in "$SKILLS_DIR"/*/; do
        skill="$(basename "$skill_dir")"
        if $REMOVE; then
            remove_skill "$skill" "$PROJECT_PATH"
        else
            install_skill "$skill" "$PROJECT_PATH"
        fi
    done
fi
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x install.sh
```

- [ ] **Step 3: Test install.sh**

Run all tests in a single shell session (variables must persist across commands):

```bash
# Test: install all skills
tmp=$(mktemp -d)
./install.sh "$tmp"
ls -la "$tmp/.claude/skills/"
# Expected: symlinks for both makerspace-signage-cards and outline-publisher

# Test: install single skill
tmp2=$(mktemp -d)
./install.sh makerspace-signage-cards "$tmp2"
ls "$tmp2/.claude/skills/"
# Expected: only makerspace-signage-cards

# Test: remove single skill
./install.sh --remove makerspace-signage-cards "$tmp"
ls "$tmp/.claude/skills/"
# Expected: only outline-publisher remains

# Test: remove all skills
./install.sh --remove "$tmp"
ls "$tmp/.claude/skills/" 2>&1
# Expected: empty or no such directory

# Test: error on non-symlink conflict
tmp3=$(mktemp -d)
mkdir -p "$tmp3/.claude/skills/makerspace-signage-cards"
./install.sh makerspace-signage-cards "$tmp3" 2>&1 || true
# Expected: error about non-symlink, exit code 1

# Test: error on unknown skill
tmp4=$(mktemp -d)
./install.sh nonexistent-skill "$tmp4" 2>&1 || true
# Expected: error listing available skills, exit code 1

# Cleanup
rm -rf "$tmp" "$tmp2" "$tmp3" "$tmp4"
```

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "Add install script for symlinking skills into projects"
```

### Task 6: Create manifest.json

**Files:**
- Create: `manifest.json`

- [ ] **Step 1: Write manifest.json**

```json
{
  "version": "1.0.0",
  "skills": [
    {
      "name": "makerspace-signage-cards",
      "description": "Convert equipment manuals and docs into print-ready makerspace signage cards for Canva Bulk Create",
      "tags": ["signage", "canva", "makerspace", "printing"],
      "path": "skills/makerspace-signage-cards"
    },
    {
      "name": "outline-publisher",
      "description": "Publish markdown content with images to the Make Nashville Outline wiki",
      "tags": ["outline", "wiki", "documentation", "publishing"],
      "path": "skills/outline-publisher"
    }
  ]
}
```

- [ ] **Step 2: Validate JSON**

```bash
python3 -c "import json; json.load(open('manifest.json'))"
```

Expected: no output (valid JSON).

- [ ] **Step 3: Commit**

```bash
git add manifest.json
git commit -m "Add skill manifest with metadata for both skills"
```

### Task 7: Create README.md

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README.md**

```markdown
# AI Skill Marketplace

Reusable Claude Code skills for Make Nashville members. Browse available skills, then install them into your projects with the included install script.

## Available Skills

| Skill | Description |
|-------|-------------|
| [makerspace-signage-cards](skills/makerspace-signage-cards/) | Convert equipment manuals and docs into print-ready makerspace signage cards for Canva Bulk Create |
| [outline-publisher](skills/outline-publisher/) | Publish markdown content with images to the Make Nashville Outline wiki |

## Installation

### Add to your project

Clone this repo (or add it as a git submodule):

```bash
git clone https://github.com/MakeNashville/ai-skill-marketplace.git
```

Or as a submodule:

```bash
git submodule add https://github.com/MakeNashville/ai-skill-marketplace.git
```

### Install skills

Install all skills into your project:

```bash
./ai-skill-marketplace/install.sh /path/to/your-project
```

Install a specific skill:

```bash
./ai-skill-marketplace/install.sh makerspace-signage-cards /path/to/your-project
```

This creates symlinks in your project's `.claude/skills/` directory.

### Remove skills

```bash
# Remove all
./ai-skill-marketplace/install.sh --remove /path/to/your-project

# Remove one
./ai-skill-marketplace/install.sh --remove outline-publisher /path/to/your-project
```

## Adding a New Skill

1. Create a directory under `skills/` with a `SKILL.md` and optional `references/` subdirectory
2. Add an entry to `manifest.json`
3. Update the skills table in this README
```

Note: The GitHub org URL in the README is a placeholder — update it to the correct org/user before publishing.

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "Add README with skill catalog and installation instructions"
```
