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
| str1-str16 | Activation prompt strings. Map to `aux.Stringid(id,0)` through `aux.Stringid(id,15)` |

## SQL Snippets

### Get next ID

```sql
SELECT MAX(id) FROM datas WHERE id >= 922100000;
```

### Insert/Replace

```sql
INSERT OR REPLACE INTO datas VALUES (922100162, 3, 0, 0x1E101D7, 33, 3000, 2500, 8, 1, 32, 0);
INSERT OR REPLACE INTO texts VALUES (922100162, 'Card Name', 'Effect text.', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '');
```

Notes:
- `texts` has 19 columns (id, name, desc, str1-str16)
- Escape apostrophes: `This card''s effect` in SQL, or use Python parameterized queries

## Setcode Packing

Up to 4 archetypes stored as 16-bit segments in a 64-bit integer:

```python
setcode = SET_A | (SET_B << 16) | (SET_C << 32) | (SET_D << 48)
```

`Card.IsSetCard(setcode)` checks each 16-bit segment independently.

### Saint Seiya Setcodes

| Constant | Hex | Description |
|----------|-----|-------------|
| SET_SAINT | 0x1D7 | Base "Saint" archetype |
| SET_BRONZE_SAINT | 0x1D9 | Bronze Saints |
| SET_CLOTH | 0x1DA | Cloth equip cards |
| SET_BLACK_SAINT | 0x1E1 | Black Saints |
| SET_FRAGMENT_OF_SAGITTARIUS | 0x1E2 | Fragment of Sagittarius equips |

See `script/archetype_setcode_constants.lua` for full list.

## Card Type Bitmasks

| Flag | Value | Hex |
|------|-------|-----|
| TYPE_MONSTER | 1 | 0x1 |
| TYPE_SPELL | 2 | 0x2 |
| TYPE_TRAP | 4 | 0x4 |
| TYPE_NORMAL | 16 | 0x10 |
| TYPE_EFFECT | 32 | 0x20 |
| TYPE_FUSION | 64 | 0x40 |
| TYPE_RITUAL | 128 | 0x80 |
| TYPE_TUNER | 4096 | 0x1000 |
| TYPE_SYNCHRO | 8192 | 0x2000 |
| TYPE_XYZ | 8388608 | 0x800000 |
| TYPE_PENDULUM | 16777216 | 0x1000000 |
| TYPE_LINK | 67108864 | 0x4000000 |
| TYPE_QUICKPLAY | 65536 | 0x10000 |
| TYPE_CONTINUOUS | 131072 | 0x20000 |
| TYPE_EQUIP | 262144 | 0x40000 |
| TYPE_FIELD | 524288 | 0x80000 |
| TYPE_COUNTER | 1048576 | 0x100000 |

Common combos: Effect Monster=33, Equip Spell=262146, Counter Trap=1048580, Field Spell=524290

## Attributes

| Value | Attribute |
|-------|-----------|
| 1 | EARTH |
| 2 | WATER |
| 4 | FIRE |
| 8 | WIND |
| 16 | LIGHT |
| 32 | DARK |
| 64 | DIVINE |

## Races

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

## Level Encoding

- **Standard:** Level directly (e.g., 4)
- **Pendulum:** `level + (leftScale << 24) + (rightScale << 16)`
- **Link:** Link Rating in `level`, Link markers in `def`

## Lua Scripting Reference

### Script Skeleton

```lua
--Card Name
local s,id=GetID()
function s.initial_effect(c)
    -- Effects registered here
end
s.listed_names={ID1,ID2}        -- Cards referenced by name
s.listed_series={SET_A,SET_B}   -- Archetypes referenced
```

### Effect Registration Pattern

```lua
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))  -- Maps to str1 in texts
e1:SetCategory(CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_IGNITION)
e1:SetCode(EVENT_or_EFFECT_code)
e1:SetRange(LOCATION_MZONE)
e1:SetCountLimit(1,id)                 -- HOPT
e1:SetCondition(s.con)
e1:SetCost(s.cost)
e1:SetTarget(s.tg)
e1:SetOperation(s.op)
c:RegisterEffect(e1)
```

### HOPT Variants

```lua
e:SetCountLimit(1,id)                           -- HOPT by card name
e:SetCountLimit(1,{id,1})                       -- Second HOPT on same card
e:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)    -- "You can only activate 1 per turn"
e:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)    -- Once per Duel
```

### Effect Types

| Type | Usage |
|------|-------|
| `EFFECT_TYPE_SINGLE` | Affects only this card |
| `EFFECT_TYPE_FIELD` | Affects the field |
| `EFFECT_TYPE_EQUIP` | Equip effect |
| `EFFECT_TYPE_IGNITION` | Manual activation (Main Phase) |
| `EFFECT_TYPE_TRIGGER_O` | Optional trigger |
| `EFFECT_TYPE_TRIGGER_F` | Mandatory trigger |
| `EFFECT_TYPE_QUICK_O` | Quick Effect (optional) |
| `EFFECT_TYPE_QUICK_F` | Quick Effect (mandatory) |
| `EFFECT_TYPE_CONTINUOUS` | Continuous (no chain) |
| `EFFECT_TYPE_ACTIVATE` | Spell/Trap activation |

### Common Effect Codes

| Code | Effect |
|------|--------|
| `EFFECT_UPDATE_ATTACK` | Add to ATK |
| `EFFECT_UPDATE_DEFENSE` | Add to DEF |
| `EFFECT_SET_ATTACK` | Set ATK to value |
| `EFFECT_IMMUNE_EFFECT` | Unaffected by effects (with filter) |
| `EFFECT_INDESTRUCTABLE_BATTLE` | Cannot be destroyed by battle |
| `EFFECT_INDESTRUCTABLE_EFFECT` | Cannot be destroyed by effects |
| `EFFECT_CANNOT_BE_EFFECT_TARGET` | Cannot be targeted |
| `EFFECT_EXTRA_ATTACK` | Extra attacks |
| `EFFECT_EXTRA_ATTACK_MONSTER` | Extra attack on monsters only |
| `EFFECT_DIRECT_ATTACK` | Can attack directly |
| `EFFECT_ATTACK_ALL` | Attack all monsters |
| `EFFECT_SPSUMMON_PROC` | Special Summon procedure |
| `EFFECT_EQUIP_LIMIT` | Equip target restriction |
| `EFFECT_CANNOT_SUMMON` | Cannot be Normal Summoned |
| `EFFECT_CANNOT_MSET` | Cannot be Set |
| `EFFECT_DESTROY_REPLACE` | Destruction substitute |

### Common Events

| Code | Trigger |
|------|---------|
| `EVENT_SUMMON_SUCCESS` | After Normal Summon |
| `EVENT_SPSUMMON_SUCCESS` | After Special Summon |
| `EVENT_TO_GRAVE` | Sent to GY |
| `EVENT_DESTROYED` | Card destroyed |
| `EVENT_ATTACK_ANNOUNCE` | Attack declared |
| `EVENT_CHAINING` | Chain link created |
| `EVENT_BATTLE_DESTROYING` | Destroyed by battle |
| `EVENT_FREE_CHAIN` | Free chain (Spell/Trap activate, Quick Effect) |
| `EVENT_PRE_DAMAGE_CALCULATE` | Before damage calculation |

### Categories

| Code | Category |
|------|----------|
| `CATEGORY_DESTROY` | Destroy |
| `CATEGORY_SPECIAL_SUMMON` | Special Summon |
| `CATEGORY_TOHAND` | Add to hand |
| `CATEGORY_SEARCH` | Search deck |
| `CATEGORY_DRAW` | Draw |
| `CATEGORY_EQUIP` | Equip |
| `CATEGORY_REMOVE` | Banish |
| `CATEGORY_NEGATE` | Negate |
| `CATEGORY_DAMAGE` | Inflict damage |
| `CATEGORY_RECOVER` | Recover LP |
| `CATEGORY_HANDES` | Discard |

### Locations

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

### Reset Constants

| Pattern | Duration |
|---------|----------|
| `RESET_EVENT+RESETS_STANDARD` | Until card leaves field |
| `RESET_PHASE+PHASE_END` | Until End Phase |
| `RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END` | Both (whichever first) |
| `RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2` | Until end of next turn |

### Common Duel Functions

| Function | Purpose |
|----------|---------|
| `Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)` | Special Summon |
| `Duel.Destroy(g,REASON_EFFECT)` | Destroy cards |
| `Duel.SendtoHand(g,nil,REASON_EFFECT)` | Send to hand |
| `Duel.SendtoGrave(g,REASON_COST)` | Send to GY as cost |
| `Duel.Remove(g,POS_FACEUP,REASON_COST)` | Banish |
| `Duel.Equip(tp,equip_card,target)` | Equip card to target |
| `Duel.NegateAttack()` | Negate an attack |
| `Duel.NegateActivation(ev)` | Negate activation |
| `Duel.SSet(tp,c)` | Set a card |
| `Duel.SelectMatchingCard(tp,f,tp,loc1,loc2,min,max,ex)` | Player selects |
| `Duel.GetMatchingGroup(f,tp,loc1,loc2,ex)` | Get matching group |
| `Duel.IsExistingMatchingCard(f,tp,loc1,loc2,ct,ex)` | Check existence |
| `Duel.GetLocationCount(tp,loc)` | Free zones count |
| `Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_*)` | Selection prompt |
| `Duel.SetOperationInfo(0,CATEGORY,g,ct,tp,loc)` | Declare operation |
| `Duel.IsChainNegatable(ev)` | Can negate this chain link |

### Card Methods

| Method | Purpose |
|--------|---------|
| `c:IsCode(id)` | Check card ID |
| `c:IsSetCard(setcode)` | Check archetype |
| `c:IsType(type)` | Check card type |
| `c:IsLevel(n)` / `c:IsLevelBelow(n)` / `c:IsLevelAbove(n)` | Level checks |
| `c:IsFaceup()` | Is face-up |
| `c:IsLocation(loc)` | Is in location |
| `c:GetEquipTarget()` | Get monster this card equips |
| `c:GetEquipGroup()` | Get cards equipped to this monster |
| `c:GetEquipCount()` | Count equipped cards |
| `c:GetBaseAttack()` | Original ATK |
| `c:GetAttack()` | Current ATK |
| `c:IsAbleToGraveAsCost()` | Can be sent to GY as cost |
| `c:IsCanBeSpecialSummoned(e,0,tp,false,false)` | Can be Special Summoned |
| `c:IsRelateToEffect(e)` | Still relates to effect |
| `c:EnableReviveLimit()` | Must be properly summoned first |
| `c:IsDestructable()` | Can be destroyed |
| `c:IsCanChangePosition()` | Can change position |
| `c:GetControler()` | Controller player |
| `c:GetOriginalCode()` | Original card code |

### Equip Spell Patterns

**Activation + equip limit:**
```lua
local e0=Effect.CreateEffect(c)
e0:SetType(EFFECT_TYPE_ACTIVATE)
e0:SetCode(EVENT_FREE_CHAIN)
c:RegisterEffect(e0)

local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_EQUIP_LIMIT)
e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
e1:SetValue(s.eqlimit)
c:RegisterEffect(e1)
```

**Equip from GY to a monster (e.g., "equip up to 2 from GY"):**
```lua
function s.fraggy(c)
    return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsType(TYPE_EQUIP)
        and c:IsAbleToChangeControler()
end
function s.eqop(e,tp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsFaceup() then return end
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fraggy),tp,
        LOCATION_GRAVE,0,1,math.min(2,ft),nil)
    for tc in aux.Next(g) do
        Duel.Equip(tp,tc,c)
    end
end
```

**Destruction substitute (equipped card dies instead):**
```lua
local e3=Effect.CreateEffect(c)
e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
e3:SetCode(EFFECT_DESTROY_REPLACE)
e3:SetRange(LOCATION_SZONE)
e3:SetTarget(s.reptg)
e3:SetOperation(s.repop)
c:RegisterEffect(e3)

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ec=e:GetHandler():GetEquipTarget()
    if chk==0 then return ec and ec:IsFaceup()
        and ec:IsReason(REASON_BATTLE+REASON_EFFECT) end
    return Duel.SelectYesNo(tp,aux.Stringid(id,1))
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT|REASON_REPLACE)
end
```

### Tiered Protection Pattern (equip count gates)

```lua
-- 1+: Indestructible by battle
local e3=Effect.CreateEffect(c)
e3:SetType(EFFECT_TYPE_SINGLE)
e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
e3:SetCondition(function(e) return e:GetHandler():GetEquipCount()>=1 end)
e3:SetValue(1)
c:RegisterEffect(e3)

-- 2+: Cannot be targeted by opponent Spell/Trap
local e3b=Effect.CreateEffect(c)
e3b:SetType(EFFECT_TYPE_SINGLE)
e3b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
e3b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e3b:SetRange(LOCATION_MZONE)
e3b:SetCondition(function(e) return e:GetHandler():GetEquipCount()>=2 end)
e3b:SetValue(function(e,re,rp)
    return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end)
c:RegisterEffect(e3b)

-- 3+: Immune to opponent monster effects
local e4=Effect.CreateEffect(c)
e4:SetType(EFFECT_TYPE_SINGLE)
e4:SetCode(EFFECT_IMMUNE_EFFECT)
e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e4:SetRange(LOCATION_MZONE)
e4:SetCondition(function(e) return e:GetHandler():GetEquipCount()>=3 end)
e4:SetValue(function(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
        and te:IsActivated() and te:IsActiveType(TYPE_MONSTER)
end)
c:RegisterEffect(e4)
```

### Cannot be Normal Summoned/Set (boss monster)

```lua
c:EnableReviveLimit()
local e0=Effect.CreateEffect(c)
e0:SetType(EFFECT_TYPE_SINGLE)
e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
e0:SetCode(EFFECT_CANNOT_SUMMON)
e0:SetValue(1)
c:RegisterEffect(e0)
local e0b=e0:Clone()
e0b:SetCode(EFFECT_CANNOT_MSET)
c:RegisterEffect(e0b)
```

### Counter Trap Negate Pattern

```lua
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_CHAINING)
e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
e1:SetCondition(s.negcon)
e1:SetCost(s.cost)
e1:SetTarget(s.negtg)
e1:SetOperation(s.negop)
c:RegisterEffect(e1)

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev)~=0 then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end
```

### Counting Distinct Cards by Name in Locations

```lua
function s.ctfrags(tp)
    local g=Duel.GetMatchingGroup(
        function(c) return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) end,
        tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,nil)
    local seen={}
    local ct=0
    for tc in aux.Next(g) do
        local cd=tc:GetCode()
        if not seen[cd] then
            seen[cd]=true
            ct=ct+1
        end
    end
    return ct
end
```

### Fusion Procedures

```lua
Fusion.AddProcMix(c,true,true,filter1,filter2)           -- Exactly 2 materials
Fusion.AddProcMixRep(c,true,true,repFilter,min,max,fix)   -- Fixed + repeating
Fusion.AddProcMixN(c,true,true,filter,N)                  -- N copies of same type
```
