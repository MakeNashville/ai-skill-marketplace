---
name: makerspace-signage-cards
description: "Convert equipment manuals, documentation, or informal notes into structured makerspace signage cards (orientation, after-every-use, maintenance, safety, store, feedback, skill-up). Use this skill whenever someone wants to create machine signs, equipment cards, shop signage, maintenance schedules, safety cards, or orientation guides for a makerspace, hackerspace, workshop, or shared fabrication space. Also trigger when the user uploads a PDF manual, spec sheet, or equipment documentation and wants to extract key info into printable card format. Trigger on phrases like 'make a card for', 'create signage for', 'write an orientation card', 'maintenance card', 'safety sign', or references to the MakeNashville card system."
---

# Makerspace Signage Card Creator

Turn equipment manuals, documentation, spec sheets, or informal notes into concise, print-ready signage cards for a shared workshop environment.

## Overview

This skill takes source material about a piece of equipment — manuals, PDFs, spec sheets, web pages, or just a user's knowledge — and produces card copy organized into the standard card types used in makerspace signage systems. The output is concise, action-oriented text formatted for physical cards that will be posted at machine stations.

Before writing any card copy, read `references/card-design-guide.md` for the full card type definitions, color system, layout anatomy, writing style rules, and placeholder templates.

---

## Workflow

### Step 1: Identify the Equipment and Source Material

Determine what machine or area the cards are for. The user may provide:

- An uploaded PDF manual or spec sheet
- A URL to a product page or documentation
- Informal notes, bullet points, or verbal description
- Nothing yet — they may just name the machine

If source material is provided, read it thoroughly. Extract:
- Setup and operating procedures
- Safety warnings and required PPE
- Maintenance schedules (what tasks, at what intervals)
- Consumables and supplies needed
- Common failure modes and troubleshooting
- File formats, software, or connectivity info (for digital fabrication tools)
- Specifications that affect usage (bed size, material compatibility, power requirements)

If the source material is a URL, use `web_fetch` to retrieve it. If it's a product name, use `web_search` to find the manufacturer's documentation and support pages. Prioritize the manufacturer's official manual and support documentation over third-party reviews.

### Step 2: Ask Clarifying Questions

Don't assume — ask. The goal is to produce cards that reflect how *this specific shop* uses the equipment, not generic instructions. Use the `ask_user_input` tool for bounded questions and prose questions for open-ended ones.

**Always ask:**

1. **Which card types do you need?** (Orientation, After Every Use, Weekly/Monthly/Quarterly Maintenance, Safety, Store, Feedback, Skill Up — or all of them)
2. **What's the Slack channel** for this equipment area? (e.g., #3dprint, #laser-maintenance, #woodshop)
3. **Are there any shop-specific rules** that differ from the manufacturer's recommendations? (e.g., "we don't allow ABS on these printers" or "always use the dust collector even though the manual says it's optional")
4. **What QR code URL** should the card point to? (e.g., go.makenashville.org/[shortlink])

**Ask if relevant:**

- What consumables are member-supplied vs. shop-supplied?
- Are there orientation prerequisites? (e.g., "must complete laser orientation before using")
- Are there usage limits? (e.g., max printers per member, time limits)
- Is there specific software members should use? (e.g., OrcaSlicer, LightBurn)
- Any known quirks or gotchas with this specific unit? (e.g., "the bed leveling is finicky on printer #3")
- What PPE is required beyond manufacturer recommendations?
- Who handles repairs — members encouraged to fix, or hands-off and report only?

### Step 3: Draft the Card Copy

Write card copy following the style rules in `references/card-design-guide.md`:

- **One sentence per point.** Lead with an action verb.
- **Emoji prefix** on each line for visual scanning.
- **3–6 points per card.** If you have more, split across cards or prioritize ruthlessly.
- **Declarative and imperative.** "Clean the bed" not "You should make sure to clean the bed."
- **No jargon without context.** If a term is necessary (e.g., "IPA" for isopropyl alcohol), spell it out on first use or parenthetically.
- **Footer notes** in italics for soft guidance, Slack channels, or encouragement.

For maintenance cards, determine the right cadence by looking at the manufacturer's recommended intervals. Map tasks to weekly, monthly, or quarterly as appropriate. Not every machine needs all three — a simple tool might only need a weekly card.

For safety cards, lead with the most critical rule. Use the red card format with large bold text. These should be readable from several feet away.

### Step 4: Present and Iterate

Present all drafted cards in a single response, clearly separated by card type. After each card, note your reasoning — why you included certain tasks, what you pulled from the manual vs. inferred, and anything you're unsure about.

Ask the user to review and flag:
- Anything missing from their shop experience
- Anything too detailed or unnecessary for a card (remember: the card is a summary, the QR code links to full documentation)
- Ordering — the most important point should come first on each card
- Tone — should match the space's culture (friendly but clear)

Iterate until the user is satisfied. Each revision should tighten copy, not expand it. If a card is getting long, suggest splitting it or moving detail to the linked documentation.

### Step 5: Output Format

The final deliverable has two parts: human-readable card copy and a machine-readable CSV for Canva Bulk Create.

#### Part A: Card Copy (for review)

Present clean, copy-pasteable text organized by card type:

```
## [CARD TYPE]: [MACHINE NAME]

[Border color: #hex]

- 🔴 Do not use until you have completed an orientation.
- 💧 First task here.
- 🎯 Second task here.
- 📄 Third task here.

*Footer note in italics.*

QR: [url]
```

#### Part B: CSV for Canva Bulk Create

After the user approves the card copy, generate a CSV file for each card type requested. Use the field names defined in `references/card-design-guide.md` under "Canva Bulk Create Field Mapping" as column headers.

**File naming:** `[machine-slug]-[card-type].csv` — write to the current working directory, or ask the user for a preferred output path.

Examples:
- `bambu-lab-p1s-monthly-maintenance.csv`
- `bambu-lab-p1s-quarterly-maintenance.csv`
- `laser-cutter-orientation.csv`

**CSV rules:**
- One header row with field names, one data row per card
- Emoji prefixes are included in text values (e.g., "🧹 Clean the bed")
- Optional fields left blank if unused
- Values containing commas must be quoted
- Multiple machines can be batched as multiple rows in one CSV

**After generating the CSV, instruct the user:**

1. Open the matching Canva template
2. Click **Bulk Create** in the left sidebar
3. Click **Upload data** and select the CSV
4. Connect each column to the corresponding text element in the template
5. Click **Generate designs**

Note: The first time using a template with Bulk Create, the user must manually connect CSV columns to Canva text elements. After that, Canva remembers the mapping for future uploads.

---

## Key Principles

**Cards are not manuals.** A card is a quick reference at the point of use. It answers "what do I do right now?" not "how does this machine work?" The QR code bridges to deeper documentation.

**Write for the person standing at the machine.** They're holding material, wearing safety glasses, maybe a little impatient. Every word must earn its place.

**Safety is non-negotiable, everything else is guidance.** Safety cards use bold, large text, red backgrounds, and imperative language. Other card types can be friendlier in tone.

**Maintenance tasks should be completable by any oriented member.** If a task requires specialized knowledge, note that on the card ("Ask a shop lead for help with this step") or move it to a quarterly/annual schedule handled by leads.

**When in doubt, ask.** It's better to ask one more clarifying question than to produce a card with wrong information that gets laminated and posted for six months.

---

## Common Pitfalls

- **Too many points.** If an orientation card has 12 bullet points, nobody reads it. Cut to 6 or split into Orientation + After Every Use.
- **Passive voice.** "The bed should be cleaned" → "Clean the bed."
- **Assuming knowledge.** Not everyone knows what "tramming" means. Use plain language or add a brief parenthetical.
- **Forgetting the footer.** The Slack channel callout and friendly reminder are part of the system — they create a feedback loop.
- **Generic safety.** "Be careful" is useless. "Wear safety glasses — flying debris risk" is actionable.
