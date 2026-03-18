# AI Skill Marketplace — Design Spec

**Date:** 2026-03-17
**Status:** Draft

## Purpose

A central GitHub repository where Make Nashville members can browse and install reusable Claude Code skills into their own projects. The first two skills are ported from existing repos:

- **makerspace-signage-cards** (from `parts-library`) — converts equipment manuals/docs into print-ready signage cards for Canva Bulk Create
- **outline-publisher** (from `3dprint-guidelines`) — publishes markdown content with images to the Make Nashville Outline wiki

## Audience

Make Nashville members who use Claude Code and want to add makerspace-specific skills to their own projects.

## Repository Structure

```
ai-skill-marketplace/
├── skills/
│   ├── makerspace-signage-cards/
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── card-design-guide.md
│   └── outline-publisher/
│       ├── SKILL.md
│       └── references/
│           └── outline-api-guide.md
├── install.sh
├── manifest.json
└── README.md
```

## Skill: makerspace-signage-cards

Ported from `parts-library/.claude/skills/makerspace-signage-cards/`.

### Changes from Source

- File output paths (e.g., `src/signage-templates/csv/...`) become guidance to write CSVs to the current working directory, or ask the user for a preferred output path.
- SVG template references in card-design-guide.md (`src/signage-templates/`) are informational only — SVGs are not bundled in the marketplace. The guide notes that SVGs live in the original `parts-library` repo for reference.
- All other content carries over as-is: SKILL.md workflow, card-design-guide.md reference, card types, color system, Canva Bulk Create field mappings, and writing style rules.

### Files

- `skills/makerspace-signage-cards/SKILL.md` — the skill definition and workflow (Steps 1-5: identify equipment, ask clarifying questions, draft card copy, iterate, output CSV for Canva)
- `skills/makerspace-signage-cards/references/card-design-guide.md` — design reference with color codes, layout anatomy, placeholder templates, and Canva field mappings

## Skill: outline-publisher

New skill distilled from `3dprint-guidelines/migrate_to_outline.py`. Rather than packaging the Python script, this skill teaches Claude Code how to publish markdown content to Outline via its API directly using `WebFetch`.

### Changes from Source

- `OUTLINE_URL` becomes optional with a hardcoded default of `https://wiki.makenashville.org/`, unlike the source script which requires it as a mandatory env var.
- Implemented as a Claude Code skill using `WebFetch` for API calls rather than a standalone Python script — no Python environment needed.
- Image upload uses a `curl` fallback via Bash for the S3 multipart POST (see Feasibility Notes below), while JSON API calls use `WebFetch`.
- Adds a step to search for existing collections before creating duplicates (source script always creates new).

### SKILL.md Workflow

1. **Identify source content** — markdown file, URL, or inline text
2. **Ask clarifying questions** — target collection name, create new or add to existing collection, publish immediately or as draft
3. **Check environment** — require `OUTLINE_TOKEN` env var (error with setup instructions if missing). Default Outline URL is `https://wiki.makenashville.org/` with optional `OUTLINE_URL` env var override.
4. **Check for existing collection** — search via `collections.list` API before creating a new one. If a matching collection exists, ask the user whether to add to it or create a new one.
5. **Upload images** — for any referenced local images, upload via `attachments.create` API. Step 1 (get pre-signed URL): use `WebFetch` JSON POST. Step 2 (POST file to S3): use `curl` via Bash for multipart binary upload.
6. **Split content** — split by headings into separate documents, or keep as single doc (ask the user)
7. **Create collection + documents** — via Outline API (`collections.create`, `documents.create`) using `WebFetch`
8. **Report back** — provide links to the created documents

### references/outline-api-guide.md

Documents the Outline API surface needed:

- **Authentication:** Bearer token via `Authorization` header
- **`attachments.create`** — request a pre-signed upload URL for images. Request fields: `name`, `contentType`, `size`. Returns `uploadUrl`, `form` (S3 form fields), and `attachment.url`. Second step: POST multipart form data to the `uploadUrl` with the S3 form fields and file (use `curl` for this step).
- **`collections.list`** — search for existing collections. Request fields: `query` (optional search term). Returns array of collections.
- **`collections.create`** — create a wiki collection. Request fields: `name`, `description`, `permission`.
- **`documents.create`** — create a document in a collection. Request fields: `collectionId`, `title`, `text`, `publish`. Documents are created flat at the collection root (no `parentDocumentId` nesting).
- All endpoints accept JSON POST to `{OUTLINE_URL}/api/{endpoint}`

### Design Decisions

- **WebFetch for JSON APIs, curl for binary uploads:** JSON API calls (collections, documents, attachment URL requests) use `WebFetch`. The S3 multipart binary upload for images uses `curl` via Bash, since `WebFetch` may not support constructing multipart/form-data with binary file payloads.
- **Hardcoded default URL:** `https://wiki.makenashville.org/` is the default since this is a Make Nashville tool. `OUTLINE_URL` env var can override.
- **Only `OUTLINE_TOKEN` required:** Minimizes setup friction for members.
- **Collection deduplication:** Search before create to avoid duplicate collections on repeated runs.

## Install Script

`install.sh` — a shell script that symlinks skills into a target project's `.claude/skills/` directory.

### Usage

```bash
# Install all skills
./install.sh /path/to/my-project

# Install a specific skill
./install.sh makerspace-signage-cards /path/to/my-project

# Remove all skills
./install.sh --remove /path/to/my-project

# Remove a specific skill
./install.sh --remove makerspace-signage-cards /path/to/my-project
```

### Behavior

1. Validate the skill exists in `skills/` (if a specific skill is named). The script distinguishes skill names from paths by checking if the argument matches a directory in `skills/`.
2. Create `.claude/skills/` in the target project if it doesn't exist
3. Symlink the skill directory into the target's `.claude/skills/`
4. Print confirmation with skill name and path

When no skill name is passed, iterate over all directories in `skills/` and symlink each one.

`--remove` removes the symlink(s) instead of creating them.

**Edge cases:** If a symlink already exists at the target, replace it. If a non-symlink file or directory exists with the same name, error with a descriptive message rather than overwriting.

No dependency resolution, no version pinning. Just symlink management.

## Manifest

`manifest.json` — machine-readable catalog of available skills. Enables future tooling to list and search skills programmatically (e.g., a CLI browser or integration with other tools). The install script validates skills by checking the filesystem directly, not the manifest.

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

New skills add an entry to the array.

## README

Human-readable catalog with:

- Brief description of the marketplace
- Table of available skills with descriptions
- Installation instructions (clone/submodule + install.sh usage)
- How to add a new skill (directory structure, manifest entry)

## Adding New Skills

To add a skill to the marketplace:

1. Create a directory under `skills/` with a `SKILL.md` and optional `references/` directory
2. Add an entry to `manifest.json`
3. The README skill table updates to match

## Out of Scope

- Version pinning or dependency management
- Automated testing of skills
- Web UI for browsing
- Authentication or access control
- Skill configuration beyond env vars
