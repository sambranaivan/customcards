---
name: windbot-deck-executor-guide
description: Produces a WindBot executor programming guide for a specific .ydk deck by extracting card effects from ProjectIgnis scripts (script/**/c<ID>.lua) and/or expansions/*.cdb, then writing roles, search/equip priorities, go-first vs go-second (coinflip) macro plan, and a literal pseudocode priority tree. Use when the user says /create-skill for decks, asks to analyze a deck for WindBot, requests combos/strategies for an executor, or asks to save the analysis to a markdown guide under sets/**/bots/.
disable-model-invocation: true
---

# WindBot Deck Executor Guide

## Goal

Given a decklist (`.ydk`) and the ProjectIgnis card sources (`expansions/*.cdb`, `script/**/c<ID>.lua`), write a **single markdown guide** that can be used to implement a WindBot executor:

- deck inventory (by ID)
- roles (starter/extender/payoff/stabilizer)
- search & equip priorities
- go-first vs go-second plan (**choose by coinflip / who started**)
- **literal priority tree** in pseudocode (conditions + subroutines)
- activation policies for key interaction (negates, protection)

## Inputs (ask only if missing)

- **Deck path**: e.g. `deck/My Deck.ydk`
- **CDB path**: e.g. `expansions/saint-seiya.cdb`
- **Scripts root**: usually `script/unofficial/`
- **Output path**: prefer `sets/<set_name>/bots/<Deck Name>.md`

## Workflow

### 1) Parse the `.ydk`

- Extract **Main/Extra/Side** card IDs and counts.
- If Extra/Side are empty, note that in the guide (important for “Extra Deck lock” costs).

### 2) Resolve cards to names/types/effects

Use both sources; **prefer scripts for exact behavior**:

- **Scripts**: read `script/**/c<ID>.lua`
  - Use the header block (the `--[==[ ... ]==]` section) as the authoritative effect summary.
  - Note special constraints that matter for decision-making (once-per-turn, costs, conditions, locks).
- **CDB**: query `expansions/*.cdb` for:
  - `texts.name`
  - `datas.type`, `datas.level`, `datas.atk/def`, etc.
  - Use to fill gaps (if script missing) and to label the guide cleanly.

### 3) Identify “board requirements” (boolean state)

From the effects, define the executor-facing booleans that drive the tree, e.g.:

- `HasEquippedSaint`-style checks (monster equipped with the right set)
- “distinct names on field”
- “can extend to N bodies”
- “need equip online before ending turn”

Write these explicitly in the guide; WindBot logic should compute them frequently.

### 4) Build the macro plan (coinflip)

Implement the policy:

- **Going first** → control/stabilize plan (set interaction, meet conditions to turn on payoffs)
- **Going second** → survive/pressure plan (get a body + equip online early; then extend if safe)

Represent it as a small pseudocode function that chooses between `GO_FIRST_*` and `GO_SECOND_*`.

### 5) Write the literal priority tree (pseudocode)

In the guide, include:

- `MainPhase_GoFirst()` and `MainPhase_GoSecond()`
- subroutines for:
  - each “searcher” (how to choose targets)
  - equip selection
  - when to set traps/spells
- activation policies for interaction cards (event-driven pseudocode)

Keep it **executor-friendly**:

- minimal branching
- stable tie-breakers
- simple “threat tiers” (S/A/B) when spending hard negates

### 6) Output structure (markdown template)

Write the guide using this structure:

```markdown
# <Franchise/Set> — WindBot Guide
## Deck: <deck name>

## Deck contents (by ID)

## Roles (for decision making)

## Key interactions / boolean state

## Coinflip policy (go-first vs go-second)

## Literal priority tree (pseudo-code)

## Subroutines (search/equip/activation policies)

## Notes / implementation tips
```

## Example (expected outcome)

Input:
- `deck/Saint Seiya - Bronze Only.ydk`
- `expansions/saint-seiya.cdb`
- `script/unofficial/c922100000.lua` etc.

Output:
- `sets/saint_seiya/bots/Saint Seiya - Bronze Only.md` containing roles + coinflip plan + literal pseudocode tree.

