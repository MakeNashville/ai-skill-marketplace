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
