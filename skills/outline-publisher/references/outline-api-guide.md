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
