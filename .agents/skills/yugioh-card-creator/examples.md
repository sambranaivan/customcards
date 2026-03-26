# Examples: Complete Card Implementations

## Example 1: Effect Monster with Special Summon + Trigger

**Kid Goku** — Level 3, EARTH, Warrior/Effect, ATK 650 / DEF 250

- Special Summon from hand if opponent controls a monster
- When destroyed: Special Summon a "Goku" from Deck (except "Goku Super Saiyan")

### Insert Script

```python
GOKU_SETCODE = 0x1d0
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000001, 4, 0, GOKU_SETCODE, 33, 650, 250, 3, 1, 1, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000001, 'Kid Goku',
     'If your opponent controls a monster, you can Special Summon this card (from your hand). When this card is destroyed: You can Special Summon 1 "Goku" monster from your Deck, ignoring its Summoning conditions, except "Goku Super Saiyan".',
     'Special Summon a "Goku" monster from the Deck',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))
```

### Lua Script

```lua
--Kid Goku
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end
s.listed_names={900000003}
s.listed_series={0x1d0}

function s.spcon(e,c)
    if c==nil then return true end
    return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
        and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_GOKU) and not c:IsCode(900000003)
        and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
    end
end
```

---

## Example 2: Fusion Monster with Alt Summon + Immunity + Multi-Attack

**Goku Super Saiyan 2** — Level 9, LIGHT, Warrior/Effect/Fusion, ATK 3700 / DEF 3500

- Fusion: 1 "Goku" Normal + 1+ Level 6+ Warriors
- Alt summon: Tribute "Goku Super Saiyan" from field (LP < opponent's)
- Unaffected by monster effects
- Attacks all opponent monsters once each
- If destroyed by battle: search 1 "Goku" card
- Material bonus for "Super Saiyan 3 Goku"

### Key Patterns

**Fusion with variable materials:**
```lua
Fusion.AddProcMixRep(c,true,true,s.matfilter2,1,63,s.matfilter1)
```

**Alt Special Summon from Extra Deck:**
```lua
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_FIELD)
e1:SetCode(EFFECT_SPSUMMON_PROC)
e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
e1:SetRange(LOCATION_EXTRA)
e1:SetCondition(s.spcon)
e1:SetOperation(s.spop)
c:RegisterEffect(e1)

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLP(tp)<Duel.GetLP(1-tp)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Release(g,REASON_COST)
end
```

**Immunity to monster effects:**
```lua
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetCode(EFFECT_IMMUNE_EFFECT)
e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e2:SetRange(LOCATION_MZONE)
e2:SetValue(function(e,te) return te:IsActiveType(TYPE_MONSTER) end)
c:RegisterEffect(e2)
```

**Attack all opponent monsters:**
```lua
local e3=Effect.CreateEffect(c)
e3:SetType(EFFECT_TYPE_SINGLE)
e3:SetCode(EFFECT_ATTACK_ALL)
e3:SetValue(1)
c:RegisterEffect(e3)
```

**Granting effects to another card (material bonus):**
```lua
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    if not rc or rc:IsFacedown() then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DIRECT_ATTACK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    rc:RegisterEffect(e1)
end
```

---

## Example 3: Monster with Conditional ATK + Indestructible + Battle Bonus

**Goku Super Saiyan** — Level 8, LIGHT, Warrior/Effect, ATK 3200 / DEF 3200

- Reactive Special Summon when a monster is destroyed
- Double ATK while "Krillin" is in GY
- Destroy all opponent S/T once per turn
- Indestructible by battle and effects
- ATK boost vs specific monster in battle
- Cannot attack directly

### Key Patterns

**Double ATK conditionally:**
```lua
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetCode(EFFECT_SET_ATTACK)
e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e2:SetRange(LOCATION_MZONE)
e2:SetCondition(s.atkcon)
e2:SetValue(s.atkval)
c:RegisterEffect(e2)

function s.atkcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(s.krillinfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.atkval(e,c)
    return c:GetBaseAttack()*2
end
```

**Indestructible:**
```lua
local e4=Effect.CreateEffect(c)
e4:SetType(EFFECT_TYPE_SINGLE)
e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
e4:SetValue(1)
c:RegisterEffect(e4)

local e5=Effect.CreateEffect(c)
e5:SetType(EFFECT_TYPE_SINGLE)
e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
e5:SetValue(1)
c:RegisterEffect(e5)
```

**ATK boost in battle vs specific monster:**
```lua
function s.frcon(e)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsCode(900000012)
end
function s.frval(e,c)
    local bc=c:GetBattleTarget()
    if bc then return bc:GetAttack()+1000 end
    return 0
end
```

---

## Example 4: Contact Fusion (Banish Materials from Multiple Locations)

**Super Saiyan 3 Goku** — Level 10, LIGHT, Warrior/Effect/Fusion, ATK 4000 / DEF 3700

### Banish from hand/field/GY as Special Summon procedure:

```lua
local BANISH_LOCS=LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE

function s.spfilter1(c)
    return c:IsCode(900000003) and c:IsAbleToRemoveAsCost()
end
function s.spfilter2(c)
    return c:IsCode(900000013) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.spfilter1,tp,BANISH_LOCS,0,1,nil)
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,BANISH_LOCS,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,BANISH_LOCS,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,BANISH_LOCS,0,1,1,nil)
    g1:Merge(g2)
    Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
```

### Respond to another card's activation (EVENT_CHAINING):

```lua
local e3=Effect.CreateEffect(c)
e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
e3:SetCode(EVENT_CHAINING)
e3:SetRange(LOCATION_MZONE)
e3:SetCountLimit(1)
e3:SetCondition(s.dfcon)
e3:SetOperation(s.dfop)
c:RegisterEffect(e3)

function s.dfcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==tp and re:GetHandler():IsCode(900000015)
end
function s.dfop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local atk=c:GetAttack()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_EXTRA_ATTACK)
        e2:SetValue(2)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
    end
end
```

---

## Example 5: Sent from Hand to GY — Search Effect

**Vegeta (Majin Buu Saga)** — Level 7, LIGHT, Warrior/Effect, ATK 2400 / DEF 2100

Multiple archetypes + HOPT hand-to-GY trigger:

### Multiple Archetypes in DB:
```python
COMBINED_SETCODE = 0x1d1 | (0x1d2 << 16) | (0x1d3 << 32)
```

### Lua Pattern:
```lua
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e1:SetCode(EVENT_TO_GRAVE)
e1:SetProperty(EFFECT_FLAG_DELAY)
e1:SetCountLimit(1,id)
e1:SetCondition(s.thcon)
e1:SetTarget(s.thtg)
e1:SetOperation(s.thop)
c:RegisterEffect(e1)

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
```

### Searching 2 Different Cards at Once:
```lua
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local vg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil)
    local pg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil)
    if #vg<1 or #pg<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=vg:Select(tp,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g2=pg:Select(tp,1,1,nil)
    g1:Merge(g2)
    Duel.SendtoHand(g1,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g1)
end
```
