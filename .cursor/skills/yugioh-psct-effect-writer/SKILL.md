---
name: yugioh-psct-effect-writer
description: >
  Converts a plain-language effect description into English Yu-Gi-Oh! effect text that follows PSCT (Problem-Solving Card Text).
  Use when the user asks to write/translate/clean up card effects, oracle text, templated wording, or mentions PSCT, EDOPro wording,
  or "write this effect like a real Yu-Gi-Oh! card".
---

# Skill: Yu-Gi-Oh! PSCT Effect Writer (English)

## Non-negotiables

- Always output **English** PSCT-style text.
- Prefer **TCG/EDOPro** conventions and common official wording.
- Be explicit about **activation timing**, **conditions**, **costs**, **targets**, and **resolution**.
- Use PSCT punctuation and structure: **conditions** → **costs** → **targets** → **effect**, with semicolons separating cost/target from effect.
- If the input is ambiguous, make the **most conservative, rules-consistent** assumptions and produce text that still functions.

Reference: Problem-Solving Card Text (PSCT). Use it as the governing style guide.
Primary reference: `https://yugioh.fandom.com/es/wiki/Problem-Solving_Card_Text`

## What to ask for (only if missing)

Only ask follow-ups if the description cannot be made rules-consistent without inventing key mechanics.

- **Card type**: Monster / Spell / Trap (and if Monster: Normal/Effect/Ritual/Fusion/Synchro/Xyz/Link; if Spell/Trap: Normal/Continuous/Quick-Play/Equip/Field/Counter).
- **Timing**: ignition / Trigger / Quick Effect; and if Trigger: optional vs mandatory.
- **Targeting**: does it target? how many? what zone?
- **Cost vs effect**: what is paid (discard, LP, banish, tributes) vs what happens on resolution.
- **Once-per-turn**: HOPT (“You can only use this effect of ‘Name’ once per turn.”) vs SOPT (“Once per turn:”).

If the user did not specify, default to:
- Monster: **Ignition** effect unless it clearly triggers or is reactive.
- Spell/Trap: standard activation with targeting only if clearly intended.
- Once-per-turn: **SOPT** if the effect is moderate; **HOPT** if it searches, negates, summons from Deck, or loops resources.

## PSCT assembly algorithm (strict)

### Step 0 — Normalize the intent

Rewrite the user description into these fields (internally):
- **Activation requirement** (if any): “If…”, “When…”, “During…”, “At the start of…”.
- **Cost** (if any): “You can…;”.
- **Target** (if any): “target …;”.
- **Effect** (resolution): the actual outcome.
- **Duration** (if any): “until the end of this turn”, “while…”, “for the rest of this turn”.
- **Restrictions** (if any): “also you cannot…”, “you can only Special Summon…”.

### Step 1 — Decide if it targets

Use “target” only if the effect selects cards at activation.
- If it targets: “**target** 1 …;”
- If it does not target: avoid “target”, use “choose”, “apply”, or zone-wide text.

### Step 2 — Place semicolons correctly

- Put a semicolon after **cost** and/or **targeting** (the activation procedure).
- Do not place a semicolon between chained resolution actions unless you are separating activation procedure from resolution.

### Step 3 — Use standard verbs and objects

Prefer official wording:
- Add to hand: “add it to your hand” (not “search”).
- Special Summon: “Special Summon it” / “Special Summon 1 … from your GY”.
- Send: “send it to the GY”.
- Banish: “banish it”.
- Destroy: “destroy it”.
- Return: “return it to the hand” / “shuffle it into the Deck”.
- Negate: “negate the activation” (Spell/Trap) / “negate that effect” (monster effect) / “negate its effects” (continuous negation).

### Step 4 — Clarify duration and scope

Use “until the end of this turn” vs “until the end of the next turn” precisely.
If an effect applies to “all monsters”, specify controller if needed: “all monsters your opponent controls”.

### Step 5 — Add usage limits

Use one of:
- **SOPT label**: “Once per turn: You can …”
- **HOPT line**: “You can only use this effect of ‘CARDNAME’ once per turn.”
- **Hard once per Duel**: “You can only use this effect of ‘CARDNAME’ once per Duel.”

### Step 6 — Add summoning restrictions when needed

If the description implies preventing abuse, add:
- “Also, for the rest of this turn, you cannot Special Summon monsters, except …”
Keep it minimal and consistent with the described intent.

## Canonical templates (copy/paste)

### Monster — Ignition (no target)

Use:

```text
Once per turn: You can [COST, if any]; [EFFECT].
```

### Monster — Ignition (targets)

```text
Once per turn: You can [COST, if any]; target [TARGET]; [EFFECT].
```

### Monster — Trigger (optional)

```text
If/When [EVENT]: You can [optional cost/target]; [EFFECT].
```

### Monster — Quick Effect

```text
(Quick Effect): You can [COST, if any]; target [TARGET, if any]; [EFFECT].
```

### Spell/Trap — activation (targets)

```text
Target [TARGET]; [EFFECT].
```

### Spell/Trap — activation (no target)

```text
[EFFECT].
```

### Continuous effects

Use:

```text
While this card is face-up on the field, [CONTINUOUS EFFECT].
```

### Replacement / prevention

Use:

```text
If [THING] would be destroyed, you can [COST/CONDITION]; destroy this card instead.
```

### Negation (quick)

Use:

```text
When your opponent activates [CARD TYPE/EFFECT] (Quick Effect): You can [COST, if any]; negate the activation, and if you do, destroy it.
```

## PSCT wording micro-rules (high impact)

- “**and if you do**” means the second action happens only if the first succeeded.
- “**then**” means the second action happens after the first, but does not necessarily depend on success unless implied.
- “**also**” means both actions happen, order is not essential.
- Avoid “up to” unless the player may choose 0; if 0 is not intended, specify 1+.
- Use “**that target**” only if the effect targeted at activation.
- Do not say “select” (use “target” or “choose”).
- Be consistent with zones: “hand”, “Deck”, “Extra Deck”, “GY”, “banishment”.

## Output format

When the user provides a description, respond with:

1) **Final PSCT text** (as plain text, ready to paste).
2) **Assumptions** (only if you had to infer anything important, 1–5 bullets max).

Do not include analysis, explanation of PSCT, or alternative wordings unless explicitly asked.

## Examples

### Example 1 — simple SOPT targeting removal

Input (user): “Once per turn you can discard 1 card to destroy a monster on the field.”

Output:

```text
Once per turn: You can discard 1 card; target 1 monster on the field; destroy it.
```

### Example 2 — trigger on summon, adds from Deck (HOPT)

Input (user): “If this card is Normal Summoned: add 1 ‘Ignis’ Spell from your Deck to your hand. Only once per turn.”

Output:

```text
If this card is Normal Summoned: You can add 1 "Ignis" Spell from your Deck to your hand.
You can only use this effect of "CARDNAME" once per turn.
```

Assumptions:
- “Only once per turn” intended as HOPT.

### Example 3 — Quick Effect negate activation

Input (user): “During either turn, pay 800 LP to negate a Trap Card and destroy it.”

Output:

```text
When your opponent activates a Trap Card (Quick Effect): You can pay 800 LP; negate the activation, and if you do, destroy it.
```

Assumptions:
- Reaction window is “when activated”, not “when resolves”.

