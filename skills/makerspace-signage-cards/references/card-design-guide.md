# MakeNashville Signage Card System — Design Reference

## Card Types and Colors (Print-Optimized CMYK-Safe)

| Card Type | Hex | RGB | Use |
|---|---|---|---|
| Orientation | `#0099CC` | (0, 153, 204) | First-time machine use instructions |
| Maintenance | `#E8891E` | (232, 137, 30) | Weekly, monthly, quarterly upkeep |
| Safety | `#CC2222` | (204, 34, 34) | Non-negotiable rules, solid background |
| Store | `#2D9B3A` | (45, 155, 58) | Purchasing consumables |
| Feedback | `#9B40B0` | (155, 64, 176) | Member input on acquisitions |
| Skill Up | `#2B6CC4` | (43, 108, 196) | Advanced techniques and tips |

### Supporting Neutrals

- Header bar fill: `#FFF8E1`
- Table borders: `#D1D5DB`
- Body text: `#1F2937`
- Background: `#FFFFFF`

---

## Layout Anatomy

Every card follows this structure:

1. **Header bar** — light cream rectangle spanning full width. Bold caps title on the left, MN logo on the right.
2. **Content area** — tables for maintenance cards, emoji-prefixed bullet points for all others.
3. **QR code block** — lower-right, framed in category color. URL text below, "SCAN FOR DETAILS" call-to-action beneath.
4. **Footer note** — italicized, lower-left. Friendly reminder or Slack channel reference.
5. **Border** — rounded rectangle stroke in the category color.

---

## Card Sizes

- **Full card:** 8.5 × 11 in (US Letter)
- **Half card:** 8.5 × 5.5 in (two per page)

---

## Writing Style

- 3–6 points per section maximum
- Declarative, imperative sentences: "Clean the bed" not "You should clean the bed"
- Emoji prefix on each task line for quick visual scanning
- Keep each point to one sentence when possible
- Italic footer for soft reminders or Slack channel callouts
- Bracket placeholders for machine-specific content: `[MACHINE NAME]`, `[slack-channel]`

---

## Placeholder Templates

### Orientation
```
ORIENTATION: [MACHINE NAME]
🔴 Do not use until you have completed an orientation.
💧 [Key setup step]
🎯 [Safety practice]
🧯 [Emergency info]
📄 [Reference to documentation]
🗑️ [Cleanup expectation]
```

### After Every Use
```
AFTER EVERY USE: [MACHINE NAME]
🧹 [Cleanup task]
🗑️ [Waste removal]
🔌 [Shutdown step]
📝 [Logging instruction]
*[Friendly reminder]*
```

### Weekly Maintenance
```
WEEKLY MAINTENANCE: [MACHINE NAME]
[Table: Week | Completed By (slack handle) | Notes]
🧽 [Task 1]
🛢️ [Task 2]
⚙️ [Task 3]
📝 Record your maintenance above.
*[Friendly note]*
```

### Monthly Maintenance
```
MONTHLY MAINTENANCE: [MACHINE NAME]
[Table: Month | Completed By (slack handle) | Issues]
🔍 [Task 1]
🎯 [Task 2]
💧 [Task 3]
💨 [Task 4]
📝 Record your maintenance below.
*Report supply needs in #[slack-channel]*
```

### Quarterly Maintenance
```
QUARTERLY MAINTENANCE: [MACHINE NAME]
[Table: Quarter | Completed By (slack handle) | Issues]
💧 [Task 1]
⚡ [Task 2]
🔧 [Task 3]
🏷️ [Task 4]
📝 Record your maintenance below.
*When in doubt, ask in #[slack-channel]*
```

### Safety
```
REQUIRED SAFETY: [AREA OR MACHINE NAME]
⚠️ [Rule 1]
⚠️ [Rule 2]
⚠️ [Rule 3]
QR → REPORT VIOLATIONS
```

### Store
```
STORE: [ITEM CATEGORY]
[Brief description]
[Pricing tiers if applicable]
How it works:
1. [Step 1]
2. [Step 2]
3. [Step 3]
⚠️ [Important caveat]
```

### Feedback / Acquisition
```
FEEDBACK: [PROMPT QUESTION]
[Large bold equipment name]
[Optional image]
QR → SCAN TO SUBMIT
```

### Skill Up
```
SKILL UP: [TECHNIQUE OR TOPIC]
🔴 Do not use until you have completed an orientation.
💧 [Tip 1]
🎯 [Tip 2]
🧯 [Tip 3]
📄 [Reference]
```

---

## Canva Bulk Create Field Mapping

Each Canva template has named data fields that map to CSV column headers. When generating CSV output, use these exact field names. Emoji prefixes are included in text values. Optional fields can be left blank in the CSV.

Reference SVGs for each template live in the original `parts-library` repo at `src/signage-templates/`. They are not bundled in the marketplace — refer to that repo if you need the source SVGs.

### Monthly Maintenance (`monthly-maintenance.svg`)

| Field | Description |
|---|---|
| `title` | Header text, e.g., "MONTHLY MAINTENANCE: BAMBU LAB P1S" |
| `task_1` | First task with emoji prefix |
| `task_2` | Second task |
| `task_3` | Third task |
| `task_4` | Fourth task |
| `task_5` | Fifth task |
| `task_6` | Sixth task (optional) |
| `footer_note` | Italic footer text |
| `qr_url` | URL displayed below QR code |

**Static elements (not in CSV):** Month table rows (January–December), column headers, "Record your maintenance below" line.

### Quarterly Maintenance (`quarterly-maintenance.svg`)

| Field | Description |
|---|---|
| `title` | Header text, e.g., "QUARTERLY MAINTENANCE: BAMBU LAB P1S" |
| `task_1` | First task with emoji prefix |
| `task_2` | Second task |
| `task_3` | Third task |
| `task_4` | Fourth task |
| `task_5` | Fifth task (optional) |
| `footer_note` | Italic footer text |
| `qr_url` | URL displayed below QR code |

**Static elements:** Quarter table rows, column headers, "Record your maintenance below" line.

### Weekly Maintenance (`weekly-maintenance.svg`)

| Field | Description |
|---|---|
| `title` | Header text, e.g., "WEEKLY MAINTENANCE: BAMBU LAB P1S" |
| `task_1` | First task with emoji prefix |
| `task_2` | Second task |
| `task_3` | Third task |
| `friendly_note` | Footer note |
| `qr_url` | URL displayed below QR code |

**Static elements:** Week range rows, column headers, "Record your maintenance above" line.

### Orientation + After Every Use (`orientation-after-every-use.svg`)

| Field | Description |
|---|---|
| `title` | Header text, e.g., "ORIENTATION: BAMBU LAB P1S" |
| `orientation_line_1` | First point (bold orientation gate) |
| `orientation_line_2` | Second point |
| `orientation_line_3` | Third point |
| `orientation_line_4` | Fourth point |
| `orientation_line_5` | Fifth point |
| `orientation_line_6` | Sixth point (optional) |
| `after_use_line_1` | First after-use task |
| `after_use_line_2` | Second task |
| `after_use_line_3` | Third task |
| `after_use_line_4` | Fourth task |
| `footer_note` | Italic footer text |
| `qr_url` | URL displayed below QR code |

**Static elements:** "AFTER EVERY USE" section heading, "SCAN FOR DETAILS" text.

### Safety (`safety.svg`)

| Field | Description |
|---|---|
| `title` | Header text, e.g., "REQUIRED SAFETY: WOODSHOP" |
| `rule_1` | First rule (large text) |
| `rule_2` | Second rule |
| `rule_3` | Third rule |
| `qr_url` | URL displayed below QR code |

**Static elements:** "REPORT VIOLATIONS" text, red background.

### Store (`store.svg`)

| Field | Description |
|---|---|
| `title` | Header text, e.g., "STORE: FILAMENT" |
| `body` | Full description block (pricing, instructions, warnings) |
| `qr_url` | URL displayed below QR code |

**Static elements:** "SCAN FOR DETAILS" text.

### Feedback (`feedback.svg`)

| Field | Description |
|---|---|
| `title` | Header text, e.g., "FEEDBACK: WHAT SHOULD WE ACQUIRE?" |
| `equipment_name` | Large bold featured text |
| `qr_url` | URL displayed below QR code |

**Static elements:** "SCAN TO SUBMIT" text, optional image placeholder.

### Orientation + Skill Up Half (`orientation-skill-up-half.svg`)

| Field | Description |
|---|---|
| `orientation_title` | Top card header |
| `orientation_line_1` | Bold orientation gate |
| `orientation_line_2` | Second point |
| `orientation_line_3` | Third point |
| `orientation_line_4` | Fourth point |
| `orientation_line_5` | Fifth point |
| `orientation_qr_url` | Top card QR URL |
| `skillup_title` | Bottom card header |
| `skillup_line_1` | Bold orientation gate |
| `skillup_line_2` | First tip |
| `skillup_line_3` | Second tip |
| `skillup_line_4` | Third tip |
| `skillup_qr_url` | Bottom card QR URL |

**Static elements:** "SCAN FOR DETAILS" / "SCAN FOR MORE" text.
