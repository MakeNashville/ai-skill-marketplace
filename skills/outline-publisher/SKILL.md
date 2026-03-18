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
