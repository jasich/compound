# compound

**Your past sessions are goldmines. Mine them.**

A skill for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that extracts learnings from your session history and compounds them into your CLAUDE.md files. Every correction you make teaches future sessions.

## The Problem

You correct Claude: "no, that's not how we do it here." Next session? Same mistake. You explain a codebase quirk. Tomorrow? Explained again. Your hard-won knowledge evaporates with each context window.

## The Solution

compound analyzes your session transcripts for corrections, errors, and learnings — then proposes additions to your CLAUDE.md so Claude remembers forever.

```
/compound              →  Analyze current session
/compound --list       →  Browse recent sessions to pick one
/compound --last 5     →  Analyze last 5 sessions
/compound --session x  →  Analyze specific session
```

## Installation

```bash
git clone https://github.com/jasich/compound.git
cd compound
./install.sh
```

Symlinks to `~/.claude/skills/` — available in every project.

## How It Works

### 1. Detects learning moments

compound scans session JSONL files for:

| Signal | Example |
|--------|---------|
| Explicit corrections | "no, don't use rescue here" |
| Tool rejections | User declined an edit |
| Repeated failures | Same operation retried 3+ times |
| Error → success | Claude learned something |

### 2. Categorizes findings

- **quirk** — Project-specific behavior
- **anti-pattern** — Something to avoid
- **error-solution** — How to fix a specific problem
- **tool-tip** — Better approach to tasks

### 3. Proposes documentation

```
## Learning #1: Avoid rescue blocks

**Confidence**: High
**Category**: anti-pattern
**Target**: ./CLAUDE.md → "Things NOT to do"

### Evidence
> User: "no, don't use rescue here"
> (Session: abc123, 2025-01-30)

### Proposed Addition
- Avoid using `rescue` unless for known, specific error cases

[Approve] [Reject] [Edit] [Skip All]
```

### 4. Writes approved learnings

Approved additions go to the right place:
- Directory-specific → `<dir>/README.md`
- Project-wide → `./CLAUDE.md`
- Universal patterns → `~/.claude/CLAUDE.md`

## The Compound Effect

Session 1: You correct Claude about a naming convention
→ compound adds it to CLAUDE.md

Session 2: Claude gets it right
→ You correct something else

Session 50: Claude knows your entire codebase's quirks
→ You ship faster

Knowledge compounds. Corrections become documentation. Documentation becomes behavior.

## Tips

**Run it at session end** — Before closing a productive session, run `/compound` to capture what Claude learned.

**Review proposals carefully** — compound suggests, you decide. Not every correction deserves permanent documentation.

**Check confidence levels** — High confidence = explicit correction. Low confidence = maybe just a one-off.

## License

MIT
