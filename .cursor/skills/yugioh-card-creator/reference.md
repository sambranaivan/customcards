# Reference: EDOPro Card Scripting

## Database Schema

### Table `datas` (11 columns)

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Unique card ID |
| ot | INTEGER | Format: 1=OCG, 2=TCG, 3=Both, **4=Custom** |
| alias | INTEGER | Alternate card ID (0 if original) |
| setcode | INTEGER | Archetype code (packed 16-bit segments) |
| type | INTEGER | Card type bitmask |
| atk | INTEGER | ATK (-2 for "?") |
| def | INTEGER | DEF (-2 for "?", Link markers for Link) |
| level | INTEGER | Level/Rank/Link Rating |
| race | INTEGER | Monster race bitmask |
| attribute | INTEGER | Attribute bitmask |
| category | INTEGER | Effect category bitmask (usually 0) |

### Table `texts` (19 columns)

| Column | Description |
|--------|-------------|
| id | Same as datas.id |
| name | Card name |
| desc | Full effect/flavor text |
| str1-str16 | Activation prompt strings (shown to player). Map to `aux.Stringid(id,0)` through `aux.Stringid(id,15)` |

## Bitmask Values

### Card Types (`type`)

| Flag | Value | Notes |
|------|-------|-------|
| TYPE_MONSTER | 0x1 (1) | |
| TYPE_SPELL | 0x2 (2) | |
| TYPE_TRAP | 0x4 (4) | |
| TYPE_NORMAL | 0x10 (16) | Normal Monster subtype |
| TYPE_EFFECT | 0x20 (32) | Effect Monster subtype |
| TYPE_FUSION | 0x40 (64) | |
| TYPE_RITUAL | 0x80 (128) | |
| TYPE_SPIRIT | 0x200 (512) | |
| TYPE_UNION | 0x400 (1024) | |
| TYPE_GEMINI | 0x800 (2048) | |
| TYPE_TUNER | 0x1000 (4096) | |
| TYPE_SYNCHRO | 0x2000 (8192) | |
| TYPE_TOKEN | 0x4000 (16384) | |
| TYPE_QUICKPLAY | 0x10000 (65536) | Spell subtype |
| TYPE_CONTINUOUS | 0x20000 (131072) | Spell/Trap subtype |
| TYPE_EQUIP | 0x40000 (262144) | Spell subtype |
| TYPE_FIELD | 0x80000 (524288) | Spell subtype |
| TYPE_COUNTER | 0x100000 (1048576) | Trap subtype |
| TYPE_XYZ | 0x800000 (8388608) | |
| TYPE_PENDULUM | 0x1000000 (16777216) | |
| TYPE_LINK | 0x4000000 (67108864) | |

### Races (`race`)

| Value | Race |
|-------|------|
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
| 8388608 | Wyrm |
| 16777216 | Cyberse |
| 33554432 | Illusion |

### Attributes (`attribute`)

| Value | Attribute |
|-------|-----------|
| 1 | EARTH |
| 2 | WATER |
| 4 | FIRE |
| 8 | WIND |
| 16 | LIGHT |
| 32 | DARK |
| 64 | DIVINE |

### Level Encoding

- **Standard monsters:** Level directly (e.g., Level 4 = `4`)
- **Pendulum:** `level + (leftScale << 24) + (rightScale << 16)`
- **Link:** Link Rating (Link markers stored in `def`)

## Setcode Packing

Up to 4 archetypes stored as 16-bit segments in a 64-bit integer:

```python
setcode = SET_A | (SET_B << 16) | (SET_C << 32) | (SET_D << 48)
```

EDOPro's `Card.IsSetCard(setcode)` checks each 16-bit segment independently.

## Lua Scripting Reference

### Script Skeleton

```lua
--Card Name
local s,id=GetID()
function s.initial_effect(c)
    -- Effects registered here
end
s.listed_names={ID1,ID2}   -- Cards referenced by name
s.listed_series={0x1d0}    -- Archetypes referenced
```

### Effect Registration Pattern

```lua
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))  -- Maps to str1 in texts table
e1:SetCategory(CATEGORY_DESTROY)        -- What the effect does
e1:SetType(EFFECT_TYPE_IGNITION)         -- When/how it activates
e1:SetCode(EVENT_or_EFFECT_code)         -- Trigger event or effect code
e1:SetRange(LOCATION_MZONE)              -- Where the card must be
e1:SetCountLimit(1)                      -- Once per turn
e1:SetCondition(s.con)                   -- Can it activate?
e1:SetCost(s.cost)                       -- Pay cost
e1:SetTarget(s.tg)                       -- Choose targets
e1:SetOperation(s.op)                    -- Resolve effect
c:RegisterEffect(e1)
```

### Effect Types

| Type | Usage |
|------|-------|
| `EFFECT_TYPE_SINGLE` | Affects only this card |
| `EFFECT_TYPE_FIELD` | Affects the field |
| `EFFECT_TYPE_EQUIP` | Equip effect |
| `EFFECT_TYPE_IGNITION` | Manual activation (your Main Phase) |
| `EFFECT_TYPE_TRIGGER_O` | Optional trigger |
| `EFFECT_TYPE_TRIGGER_F` | Mandatory trigger |
| `EFFECT_TYPE_QUICK_O` | Quick Effect (optional) |
| `EFFECT_TYPE_QUICK_F` | Quick Effect (mandatory) |
| `EFFECT_TYPE_CONTINUOUS` | Continuous (no chain) |

### Common Effect Codes

| Code | Effect |
|------|--------|
| `EFFECT_UPDATE_ATTACK` | Add to ATK |
| `EFFECT_SET_ATTACK` | Set ATK to value |
| `EFFECT_UPDATE_DEFENSE` | Add to DEF |
| `EFFECT_IMMUNE_EFFECT` | Unaffected by effects (with filter) |
| `EFFECT_INDESTRUCTABLE_BATTLE` | Cannot be destroyed by battle |
| `EFFECT_INDESTRUCTABLE_EFFECT` | Cannot be destroyed by effects |
| `EFFECT_CANNOT_DIRECT_ATTACK` | Cannot attack directly |
| `EFFECT_DIRECT_ATTACK` | Can attack directly |
| `EFFECT_ATTACK_ALL` | Attack all monsters (value=1) |
| `EFFECT_EXTRA_ATTACK` | Extra attacks (value=N extra) |
| `EFFECT_SPSUMMON_PROC` | Special Summon procedure |
| `EFFECT_EQUIP_LIMIT` | Equip target restriction |

### Common Event Codes

| Code | Trigger |
|------|---------|
| `EVENT_SUMMON_SUCCESS` | After Normal Summon |
| `EVENT_SPSUMMON_SUCCESS` | After Special Summon |
| `EVENT_TO_GRAVE` | Sent to GY |
| `EVENT_DESTROYED` | Card destroyed |
| `EVENT_ATTACK_ANNOUNCE` | Attack declared |
| `EVENT_CHAINING` | Chain link created |
| `EVENT_BATTLE_DESTROYING` | Destroyed monster by battle |
| `EVENT_PHASE+PHASE_END` | End Phase |

### Common Categories

| Code | Category |
|------|----------|
| `CATEGORY_DESTROY` | Destroy |
| `CATEGORY_SPECIAL_SUMMON` | Special Summon |
| `CATEGORY_TOHAND` | Add to hand |
| `CATEGORY_SEARCH` | Search deck (combine with TOHAND) |
| `CATEGORY_DRAW` | Draw |
| `CATEGORY_EQUIP` | Equip |
| `CATEGORY_REMOVE` | Banish |
| `CATEGORY_ATKCHANGE` | Change ATK |

### Location Constants

| Constant | Location |
|----------|----------|
| `LOCATION_HAND` | Hand |
| `LOCATION_MZONE` | Monster Zone |
| `LOCATION_SZONE` | Spell/Trap Zone |
| `LOCATION_GRAVE` | Graveyard |
| `LOCATION_REMOVED` | Banished |
| `LOCATION_DECK` | Deck |
| `LOCATION_EXTRA` | Extra Deck |
| `LOCATION_ONFIELD` | On the field (MZONE+SZONE) |

### Reason Constants

| Constant | Reason |
|----------|--------|
| `REASON_DESTROY` | Destroyed |
| `REASON_BATTLE` | By battle |
| `REASON_EFFECT` | By card effect |
| `REASON_COST` | As cost |
| `REASON_MATERIAL` | Used as material |

### Reset Constants

| Pattern | Duration |
|---------|----------|
| `RESET_EVENT+RESETS_STANDARD` | Until card leaves field |
| `RESET_PHASE+PHASE_END` | Until End Phase |
| `RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END` | Both (whichever first) |

### Fusion Procedures

```lua
-- Exactly 2 specific materials
Fusion.AddProcMix(c,true,true,filter1,filter2)

-- Fixed materials + 1 repeating type (min to max)
Fusion.AddProcMixRep(c,true,true,repeating_filter,min,max,fixed_filter1,...)

-- N copies of same material type
Fusion.AddProcMixN(c,true,true,filter,N)
```

Parameters: `c` = card, `sub` = allow substitutes, `insf` = ignore summoning flag.
Filters: Can be card IDs (numbers) or filter functions `function(c,fc,sumtype,tp)`.

### Common Duel Functions

| Function | Purpose |
|----------|---------|
| `Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)` | Special Summon a card |
| `Duel.Destroy(g,REASON_EFFECT)` | Destroy cards |
| `Duel.SendtoHand(g,nil,REASON_EFFECT)` | Send to hand |
| `Duel.Remove(g,POS_FACEUP,REASON_COST)` | Banish cards |
| `Duel.Release(g,REASON_COST)` | Tribute cards |
| `Duel.Equip(tp,equip_card,target)` | Equip card to target |
| `Duel.SelectMatchingCard(tp,filter,tp,loc1,loc2,min,max,ex)` | Player selects cards |
| `Duel.GetMatchingGroup(filter,tp,loc1,loc2,ex)` | Get matching card group |
| `Duel.IsExistingMatchingCard(filter,tp,loc1,loc2,count,ex)` | Check if cards exist |
| `Duel.GetLP(tp)` | Get player's LP |
| `Duel.GetAttackTarget()` | Get battle target (nil=direct) |
| `Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_*)` | Show selection prompt |
| `Duel.ConfirmCards(1-tp,g)` | Reveal cards to opponent |
| `Duel.SetOperationInfo(0,CATEGORY,g,count,tp,loc)` | Declare operation info |
| `Duel.GetFieldGroupCount(tp,loc1,loc2)` | Count cards in locations |

### Card Methods

| Method | Purpose |
|--------|---------|
| `c:IsCode(id)` | Check card ID |
| `c:IsSetCard(setcode)` | Check archetype |
| `c:IsType(type)` | Check card type |
| `c:IsRace(race)` | Check race |
| `c:IsAttribute(attr)` | Check attribute |
| `c:IsLevelAbove(n)` | Level >= n |
| `c:IsFaceup()` | Is face-up |
| `c:IsLocation(loc)` | Is in location |
| `c:IsPreviousLocation(loc)` | Was in location before moving |
| `c:IsReason(reason)` | Check reason for current state |
| `c:GetAttack()` | Get current ATK |
| `c:GetBaseAttack()` | Get original ATK |
| `c:GetBattleTarget()` | Get battle target |
| `c:GetReasonCard()` | Card that caused this state |
| `c:IsAbleToHand()` | Can be added to hand |
| `c:IsAbleToGraveAsCost()` | Can be sent to GY as cost |
| `c:IsAbleToRemoveAsCost()` | Can be banished as cost |
| `c:IsCanBeSpecialSummoned(e,0,tp,false,false)` | Can be Special Summoned |
| `c:IsRelateToEffect(e)` | Still relates to the triggering effect |
| `c:EnableReviveLimit()` | Must be properly summoned first |
| `c:SetUniqueOnField(1,0,id)` | Only 1 copy on field |
| `c:RegisterEffect(e)` | Register effect to card |

### HOPT (Hard Once Per Turn)

```lua
e:SetCountLimit(1,id)          -- HOPT by card name
e:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)  -- Once per Duel
```
