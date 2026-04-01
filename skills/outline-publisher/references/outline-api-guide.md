# Outline API Reference — Image Uploads

The Make Nashville Wiki MCP server handles collections and documents. Image uploads are the one operation that still requires the raw Outline API.

## Authentication

Image upload requests require a Bearer token in the `Authorization` header:

```
Authorization: Bearer {OUTLINE_TOKEN}
Content-Type: application/json
```

The `OUTLINE_TOKEN` environment variable must be set. Generate one at https://wiki.makenashville.org/settings/api.

---

## `attachments.create`

Request a pre-signed upload URL for an image or file.

**Step 1: Get the upload URL**

Use `WebFetch` to POST to `https://wiki.makenashville.org/api/attachments.create`:

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

Replace the local image path in markdown with the full attachment URL:

Before: `![Photo](images/photo.jpg)`
After: `![Photo](https://wiki.makenashville.org/api/attachments.redirect?id=attachment-uuid)`
