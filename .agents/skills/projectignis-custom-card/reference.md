# ProjectIgnis custom card reference

## Core file locations

- DB: `expansions/cards-unofficial.cdb`
- Lua scripts: `script/unofficial/c{ID}.lua`
- Artwork: `pics/{ID}.jpg`
- Field visuals (optional): `pics/field/{ID}.png`
- Custom archetype constants: `script/archetype_setcode_constants.lua`
- Placeholder registry: `placeholders.md`

## SQL snippets

### Get next unofficial ID

```sql
SELECT MAX(id) FROM datas WHERE id >= 100000000;
```

### Insert `datas`

```sql
INSERT INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category)
VALUES (100006000, 1, 0, 0, 33, 1800, 1200, 4, 2, 32, 0);
```

### Insert `texts`

```sql
INSERT INTO texts (id, name, desc, str1, str2, str3, str4, str5, str6, str7, str8, str9, str10, str11, str12, str13, str14, str15, str16)
VALUES (100006000, 'My Custom Card', 'Effect text here.', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '');
```

Notes:
- Escape single quotes in SQL by doubling: `This card''s effect`
- Use `str1..str16` only when Lua uses `aux.Stringid(id,n)` prompts.

## Common `type` bitmasks (sum values)

| Value | Type |
|---:|---|
| 1 | Monster |
| 2 | Spell |
| 4 | Trap |
| 16 | Normal (Monster) |
| 32 | Effect |
| 64 | Fusion |
| 128 | Ritual |
| 2048 | Tuner |
| 8192 | Synchro |
| 8388608 | Xyz |
| 16777216 | Pendulum |
| 67108864 | Link |
| 65536 | Quick-Play (Spell) |
| 131072 | Continuous (Spell/Trap) |
| 262144 | Equip (Spell) |
| 1048576 | Field (Spell) |
| 524288 | Counter (Trap) |

Examples:
- Normal Monster: `1 + 16 = 17`
- Effect Monster: `1 + 32 = 33`
- Fusion Effect: `1 + 32 + 64 = 97`
- Link Effect: `1 + 32 + 67108864 = 67108897`
- Quick-Play Spell: `2 + 65536 = 65538`
- Continuous Trap: `4 + 131072 = 131076`

## `attribute` values

| Value | Attribute |
|---:|---|
| 1 | EARTH |
| 2 | WATER |
| 4 | FIRE |
| 8 | WIND |
| 16 | LIGHT |
| 32 | DARK |
| 64 | DIVINE |

## `race` values (monster types)

| Value | Race |
|---:|---|
| 1 | Warrior |
| 2 | Spellcaster |
| 4 | Fairy |
| 8 | Fiend |
| 16 | Zombie |
| 32 | Machine |
| 64 | Aqua |
| 128 | Pyro |
| 256 | Rock |
| 512 | Winged Beast |
| 1024 | Plant |
| 2048 | Insect |
| 4096 | Thunder |
| 8192 | Dragon |
| 16384 | Beast |
| 32768 | Beast-Warrior |
| 65536 | Dinosaur |
| 131072 | Fish |
| 262144 | Sea Serpent |
| 524288 | Reptile |
| 1048576 | Psychic |
| 2097152 | Divine-Beast |
| 4194304 | Creator God |
| 8388608 | Wyrm |
| 16777216 | Cyberse |
| 33554432 | Illusion |

## `level` encoding notes

- Normal monsters: store level directly (e.g. 4)
- Pendulum encoding:
  - `level + (scale_left << 24) + (scale_right << 16)`
  - Example: level 7, scales 1/1 → `7 + (1<<24) + (1<<16) = 16842759`
- Link:
  - `level` = Link Rating
  - Link markers are encoded in `def` (EDOPro convention)

## Lua skeleton

```lua
--Card Name
local s,id=GetID()
function s.initial_effect(c)
  -- register effects here
end
```

## Custom archetype setcodes

Workflow:
1. Open `script/archetype_setcode_constants.lua`
2. Under `--Custom archetypes`, append a new constant with next free hex value
3. Convert hex setcode to decimal and use that number in DB `datas.setcode`

