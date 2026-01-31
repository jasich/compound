---
name: compound
description: Extract learnings from past sessions to improve future Claude interactions
argument-hint: "[--last <n> | --session <id>]"
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, AskUserQuestion
---

# Compound: Session Learning Extractor

Analyze past Claude Code sessions to identify learnings from user corrections and errors, then propose additions to CLAUDE.md/README files.

## Usage

```bash
/compound                    # Analyze current session (default)
/compound --last 5           # Analyze last 5 sessions
/compound --session abc123   # Analyze specific session by ID
```

## Instructions

### Step 1: Parse Arguments

Parse the provided arguments:
- No args → analyze the **current session** (the JSONL file for this conversation)
- `--last <n>` → analyze last N sessions by modification time
- `--session <uuid>` → analyze specific session by UUID

**Finding the current session:**
The current session ID is provided in system context. Look for a path like:
`~/.claude/projects/<encoded-path>/<session-id>.jsonl`

### Step 2: Locate Session Files

1. Get the current working directory
2. Encode the path by replacing `/` with `-` (e.g., `/Users/jason/code/work/admin` → `-Users-jason-code-work-admin`)
3. Session files are located at: `~/.claude/projects/<encoded-path>/*.jsonl`
4. List sessions sorted by modification time: `ls -t ~/.claude/projects/<encoded-path>/*.jsonl | head -<n>`

### Step 3: Analyze Sessions for Patterns

For each session JSONL file, read and analyze for these patterns:

| Pattern | Signal | What to Look For |
|---------|--------|------------------|
| Tool rejection | `"is_error":true` with rejection message | User rejected an edit or action |
| Explicit correction | User message starting with correction words | "no,", "wrong", "actually", "instead", "don't", "stop" |
| Multiple attempts | Same tool repeated 3+ times on same target | Retrying failed operations |
| Error resolution | Error followed by success on same task | Learning from mistakes |

**Detection regex for user corrections:**
```
/^(no[,.\s]|wrong|actually|instead|don't|stop|not that|not what|wait)/i
```

**JSONL structure notes:**
- Each line is independent JSON
- Key fields: `type`, `message.content`, `is_error`, `toolUseResult`, `timestamp`
- User messages have `type: "user"`
- Assistant messages have `type: "assistant"`

### Step 4: Extract Learnings

For each detected pattern, categorize and extract:

**Categories:**
- `quirk` - Project-specific behavior or convention
- `anti-pattern` - Something to avoid doing
- `error-solution` - How to fix a specific error
- `tool-tip` - Better way to use tools or approach tasks

**For each learning, capture:**
- Category (from above)
- Summary (brief description)
- Evidence (relevant session excerpt - user message + context)
- Recommendation (proposed text to add)
- Target file (where it should go)
- Confidence: `high` (explicit correction) | `medium` (pattern detected) | `low` (ambiguous)

### Step 5: Determine Target File

Priority order for where to add the learning:

1. **Directory-specific** → `<dir>/README.md` if it exists and learning relates to that directory
2. **Project-wide** → `./CLAUDE.md` in current project root
3. **Cross-project** → `~/.claude/CLAUDE.md` for universal patterns

**Match to existing CLAUDE.md sections:**
- Quirks → "Important Notes" > "Known issues or quirks"
- Anti-patterns → "Important Notes" > "Things NOT to do"
- Tool tips → "Working with This Codebase"
- Error solutions → "Guidelines" or relevant subsection

### Step 6: Present Learnings for Approval

Use AskUserQuestion to present each learning for approval. Format:

```
## Learning #N: <Title>

**Confidence**: High | Medium | Low
**Category**: <category>
**Target**: <file path> → "<section name>"

### Evidence
> User: "<the correction or feedback>"
> (Session: <filename>, <date>)

### Proposed Addition
<the text to add to the file>
```

Offer options:
- **Approve** - Write this learning to the target file
- **Reject** - Skip this learning
- **Edit** - Let user modify the proposed text
- **Skip All** - Stop processing remaining learnings

### Step 7: Write Approved Changes

For each approved learning:

1. Read the target file
2. Find the appropriate section using Grep
3. If section exists, append the learning to that section
4. If section doesn't exist, create it in a logical location
5. Use Edit tool to make the change
6. Confirm the write was successful

### Edge Cases to Handle

- **No sessions found** → Display friendly message: "No session files found for this project."
- **Large sessions** → Focus on user messages and tool errors, skip long assistant responses
- **Already documented** → Before proposing, check if similar text already exists in target file
- **Ambiguous patterns** → Mark as low confidence but still present for user decision
- **Empty results** → "No learnings detected in the analyzed sessions."

## Output Format

After analysis, summarize:

```
📊 Compound Analysis Complete

Session: <current | N sessions analyzed>
Patterns detected: N
Learnings extracted: N

[Then present each learning for approval]
```

After all approvals processed:

```
✅ Compound Complete

- N learnings approved and written
- N learnings rejected
- Files modified: <list>
```
