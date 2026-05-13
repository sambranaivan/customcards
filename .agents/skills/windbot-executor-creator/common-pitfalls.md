# Common Pitfalls & Proven Fixes

Anti-patterns discovered during real executor development. Check these before writing any new executor logic.

---

## 1. Reactive Cards Burning on Own Effects

**Symptom**: Protection spells (e.g., quick-plays, counter traps) activate when the bot's own equip spells or effects target its own monsters/spells.

**Cause**: Using `Util.IsChainTarget(card)` without verifying **who** activated the chain. Own equips targeting your monsters look identical to enemy removal.

**Fix**: Always check `IsLastChainFromOpponent()` before reacting to chains:

```csharp
// BAD
if (!ChainIsEmpty() && Util.IsChainTarget(myMonster))
    return true; // burns on own equip targeting this monster

// GOOD
if (!ChainIsEmpty() && IsLastChainFromOpponent()
    && Util.IsChainTarget(myMonster))
    return true;
```

**Applies to**: Any card with `ExecutorType.Activate` that reacts to `!ChainIsEmpty()` or `IsChainTarget`.

---

## 2. Chat Message Spam

**Symptom**: Bot floods chat with messages every action, even after duel ends.

**Cause**: Two issues:
1. WindBot's default `Dialogs` system auto-sends messages for every summon, activate, attack, etc.
2. `TrySendCustomChat()` calls placed before condition checks, firing on every evaluation (not just on activation).

**Fix**:
1. Call `SilenceDefaultDialogs(ai)` in the constructor to clear all auto-triggered message arrays.
2. Always place `TrySendCustomChat()` **after** confirming the effect will activate (after all guard clauses).
3. Add per-turn cooldown using a `HashSet<int>` keyed by message index.

```csharp
// BAD — fires on every evaluation
private bool ActivateMyCard()
{
    TrySendCustomChat(0);           // fires even when returning false!
    return SomeCondition();
}

// GOOD — fires only on confirmed activation
private bool ActivateMyCard()
{
    if (!SomeCondition()) return false;
    TrySendCustomChat(0);
    return true;
}
```

---

## 3. C# 5 Language Restrictions

**Symptom**: Compilation errors like `CS1528`, `CS8026`, or `CS1525`.

**Cause**: Plugin mode uses .NET Framework 4.0 with `LangVersion=5`. Many modern C# features are unavailable.

**Forbidden syntax**:

| Feature | C# version | Workaround |
|---------|-----------|------------|
| `$"text {var}"` | C# 6 | `string.Format("text {0}", var)` |
| `int Foo() => expr;` | C# 6 | `int Foo() { return expr; }` |
| `var x = arr?.Length` | C# 6 | `var x = arr != null ? arr.Length : 0` |
| `nameof(X)` | C# 6 | `"X"` (literal string) |
| Local functions | C# 7 | Extract to private method |
| `Array.Empty<T>()` | .NET 4.6 | `new T[0]` |
| `out var x` | C# 7 | Declare variable separately |
| Pattern matching `is T t` | C# 7 | `as T` + null check |

---

## 4. Fixed Normal Summon Order

**Symptom**: Bot always Normal Summons in the same order regardless of hand context. Summons a vanilla body when a combo starter is also in hand.

**Cause**: `AddExecutor(ExecutorType.Summon, ...)` calls are evaluated top-to-bottom; the first `true` wins.

**Fix**: Use a single `PrioritizedNormalSummon()` handler registered for all monsters. Inside, compare `Card.Id` against all other candidates in `Bot.Hand` using a priority function. Only return `true` if `Card.Id` has the highest priority.

---

## 5. Multi-Effect Cards Without ActivateDescription

**Symptom**: Bot activates the wrong effect of a multi-effect card (e.g., uses hand discard effect when it should use on-field ignition).

**Cause**: Same `CardId` registered once for `Activate`, but the card has 2+ effects in different locations or with different descriptions.

**Fix**: Check `Card.Location` and `ActivateDescription` to distinguish:

```csharp
private bool ResolveMyCardActivate()
{
    if ((Card.Location & CardLocation.Hand) != 0)
    {
        if (ActivateDescription != Util.GetStringId(CardId.MyCard, 0)
            && ActivateDescription != -1)
            return false;
        return HandEffectLogic();
    }
    if ((Card.Location & CardLocation.MonsterZone) != 0)
    {
        return FieldEffectLogic();
    }
    if ((Card.Location & CardLocation.Grave) != 0)
    {
        return GraveyardEffectLogic();
    }
    return false;
}
```

Always read the Lua script to find the `Stringid(id, N)` values for each effect.

---

## 6. DLL Locked During Build

**Symptom**: MSBuild error `MSB3027: No se pudo copiar ... utilizado en otro proceso`.

**Cause**: A running `WindBot.exe` process holds the compiled DLL.

**Fix**: Kill all WindBot processes before rebuilding:

```powershell
taskkill /F /IM WindBot.exe 2>$null
# Then rebuild
```

---

## 7. Proactive Activation of Reactive Cards

**Symptom**: Quick-play protection spells or hand traps activate during the bot's open Main Phase with no threat.

**Cause**: No guard against `IsOpenOwnMainPhaseNoChain()`. WindBot evaluates all registered `Activate` handlers every time a priority window opens.

**Fix**: For reactive cards (protection, counter traps), add explicit guards:

```csharp
private bool ActivateProtection()
{
    // Never activate proactively in an open main phase with no threat
    if (Duel.Player == 0 && IsMainPhase() && ChainIsEmpty())
        return false;
    // ... actual reactive logic
}
```

Or use `OnPreActivate` to globally gate reactive cards:

```csharp
public override bool OnPreActivate(ClientCard card)
{
    if (ReactiveCardIds.Contains(card.Id) && IsOpenOwnMainPhaseNoChain())
        return false;
    return base.OnPreActivate(card);
}
```

---

## 8. Ignoring Card Location for GY/Banish Triggers

**Symptom**: A card's GY trigger logic fires when the card is in hand or on field.

**Cause**: A single `AddExecutor(ExecutorType.Activate, CardId.X, handler)` covers all locations. The handler doesn't check `Card.Location`.

**Fix**: Always branch on `Card.Location` first in multi-location handlers:

```csharp
private bool ResolveMyCardActivate()
{
    if ((Card.Location & CardLocation.Hand) != 0)
        return HandleFromHand();
    if ((Card.Location & CardLocation.Grave) != 0)
        return HandleFromGraveyard();
    if ((Card.Location & CardLocation.SpellZone) != 0)
        return HandleOnField();
    return false;
}
```

---

## 9. Forgetting `IsMainPhase()` Guards on Summon/Ignition

**Symptom**: Bot tries to Normal Summon or use ignition effects during Battle Phase or opponent's turn.

**Fix**: Every `Summon` handler and ignition `Activate` handler should start with:

```csharp
if (!IsMainPhase()) return false;
```

---

## 10. Not Reading Lua Before Writing AI Logic

**Symptom**: AI logic doesn't match actual card behavior. Wrong targets, wrong costs, wrong timing.

**Cause**: Writing executor logic based on card descriptions or assumptions instead of the Lua script.

**Fix**: **Always** read `script/unofficial/c{ID}.lua` before writing any handler. Check:
- `SetType`: trigger vs ignition vs quick
- `SetCode`: what event triggers it
- `SetCost` / `SetTarget` / `SetOperation`: what it does
- `Stringid(id, N)`: for `ActivateDescription` matching
- `SetCountLimit`: OPT restrictions
- `SetCondition`: when it can activate
