using System;
using System.Collections.Generic;
using System.Linq;
using YGOSharp.OCGWrapper.Enums;
using WindBot;
using WindBot.Game;
using WindBot.Game.AI;


/*
================================================================================
WindBot design reference — embedded from repo markdown (read alongside code).

Source file: sets/saint_seiya/bots/Saint Seiya - Bronze Only.md

Maintenance: evolve the AI in this .cs; keep this comment in sync when strategy
intent changes so the executor stays the single place for behavior + rationale.

The guide is the full target spec; `Activate*` / `Resolve*` / `Summon*` methods below
implement a practical subset (WindBot defaults cover the rest where registered).

--- embedded guide (markdown as plain text) ---
================================================================================
# Saint Seiya — WindBot Guide
## Deck: **Saint Seiya - Bronze Only**

This document is a **programming guide** for a WindBot executor for the deck:

- Decklist: `deck/Saint Seiya - Bronze Only.ydk`
- Cards DB: `expansions/saint-seiya.cdb`
- Scripts: `script/unofficial/c{ID}.lua`

The deck is **Main-heavy** with a small **Extra Deck** (fusion bosses). Its win plan is:

- **Go first**: build a board with
  - **3+ face-up "Saint" monsters with different names** (turns on `922100082`),
  - **at least 1 "Saint" equipped with a "Cloth" Equip** (turns on `922100103`),
  - backed by **Counter Traps** + protection spells.
- **Go second**: survive the opponent’s push with protection/negates, then stabilize into the same “3 names + 1 equipped” shell and win by battle pressure from Cloths.

---

## Deck contents (by ID)

### Monsters
- `922100000` **Bronze Saint - Seiya of Pegasus**
- `922100001` **Bronze Saint - Shiryu of Dragon**
- `922100002` **Bronze Saint - Hyoga of Cygnus**
- `922100003` **Bronze Saint - Shun of Andromeda**
- `922100004` **Bronze Saint - Ikki of Phoenix**
- `922100005` **Bronze Saint - Jabu of Unicorn**
- `922100006` **Bronze Saint - Ichi of Hydra**
- `922100007` **Bronze Saint - Geki of Bear**
- `922100008` **Bronze Saint - Ban of Lionet**
- `922100009` **Bronze Saint - Nachi of Wolf**
- `922100010` **Mu - The Cloth Repairer**
- `922100011` **Kiki - Messenger of the Cloth Sculptor**

### Extra Deck
- `922100303` **Bronze Saint - Seiya of the Miracle Bonds** (Extra — SS by banishing 1 Seiya + 4 `"Bronze Saint"` from field/GY; no Polymerization; see `c922100303.lua`)

### Bronze Cloth (Equip Spells)
All share a generic GY trigger:
**If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.**
(Triggers from anywhere, not just S/T zone. OPYOT per cloth.)

Each cloth also has unique on-field effects when equipped to its paired Saint.
Andromeda (`922100044`): equipped monster can attack directly; if on Shun in DEF, protects other monsters + restricts SS'd monster effects.

- `922100041` Bronze Cloth - Pegasus
- `922100042` Bronze Cloth - Dragon
- `922100043` Bronze Cloth - Cygnus
- `922100044` Bronze Cloth - Andromeda
- `922100045` Bronze Cloth - Phoenix
- `922100046` Bronze Cloth - Unicorn
- `922100047` Bronze Cloth - Hydra
- `922100048` Bronze Cloth - Bear
- `922100049` Bronze Cloth - Lionet
- `922100050` Bronze Cloth - Wolf

### Spells / Traps
- `922100079` **Athena's Sanctuary** (Field Spell)
 - `922100081` Inherited Cosmos (Normal Spell)
- `922100086` Athena's Shield (Quick-Play)
- `922100088` Athena's Call (Normal Spell)
- `922100092` Bond of Brotherhood (Quick-Play)
- `922100082` Athena's Vanguard (Counter Trap)
- `922100101` Crystal Wall (Counter Trap)
- `922100103` The Pope's Verdict (Counter Trap)

---

## Roles (for decision making)

### Starters (openers / fix hands)
- `922100088` **Athena's Call**: main starter. If you control no monsters it can search `922100011` instead.
- `922100000` **Seiya**: best starter (summon-search + self-SS if you control no monsters).
- Any **Bronze Cloth in hand**: acts as a “starter” because it converts into a Level 4 Saint search.
 - `922100081` **Inherited Cosmos**: fixes hands while setting GY (send 1 Saint from Deck; add a different-name Saint).

### Extenders (increase bodies / unique names)
- `922100005` **Jabu**: hand extender (SS if you control a Saint). On SS: add 1 Cloth from GY, then discard 1.
- `922100004` **Ikki**: GY extender (revive by discarding 1 Saint).
- `922100010` **Mu** (×2 in deck): on summon add up to 2 Cloth Equips from GY; MMZ ignition discards self to search **Athena's Sanctuary**.
- `922100011` **Kiki**:
  - Quick effect from hand: discard → equip 1 Cloth Equip from **Deck or GY** to a Saint you control.
  - Next turn Standby: banish from GY → add up to 2 different-name Cloths from GY.

### Payoffs / “board requirements”
- `922100082` **Athena's Vanguard** turns on at **3+ different-name Saints**.
- `922100103` **The Pope’s Verdict** turns on if you control a **Saint equipped with a Cloth**.

### Stabilizers / protection
- `922100079` **Athena's Sanctuary** (×2 in deck): +300 ATK/DEF to Saints; first battle destruction of a Bronze Saint prevented; once/turn return 1 Cloth in S/T Zone to hand (re-equip via Kiki/ignition).
- `922100086` **Awakening**: 1-turn indestructible + GY destruction replacement.
- `922100092` **Bond**: protects from opponent’s effects (incl. banish); draws if chained to opponent monster effect.

---

## Key interactions (what matters to the bot)

### Live checks (boolean state)
Define these every decision step:

- `HasEquippedSaint`:
  - true if you control a face-up Saint monster whose EquipGroup contains a face-up card in `SET_CLOTH`.
  - Enables `922100103`.

- `SaintDistinctNamesOnField`:
  - count of **unique** Saint card IDs among your face-up Saints.
  - Enables `922100082` if ≥ 3.

- `CanExtendToThreeNamesThisTurn`:
  - true if you can plausibly reach `SaintDistinctNamesOnField >= 3` this turn via:
    - additional Normal Summon lines (see Unicorn Cloth on Jabu),
    - Jabu SS,
    - Cloth discard → search,
    - Seiya search,
    - Athena’s Call search,
    - Raise Your Cosmos (send+add).

### Threat tiers (simple, executor-friendly)
When deciding to spend Counter Traps:

- **Tier S**: board wipes / removal that breaks the “3 names” core, or effects that remove the *equipped Saint*.
- **Tier A**: strong tempo plays (high-impact search/negate engines, wincon setups).
- **Tier B**: value plays (small removal, minor advantage).

Use:
- `Athena's Vanguard (082)` mostly for **Tier S/A**.
- `Pope’s Verdict (103)` for **Tier S/A** if it stops Spell/Trap lines.
- `Crystal Wall (101)` whenever opponent targets your Saints with a negatable activation (usually Tier S/A by definition).

---

## Coinflip policy (choose go-first vs go-second plan)


================================================================================
--- end embedded guide ---
*/

namespace WindBot.Game.AI.Decks
{
    [Deck("SaintSeiyaBronzeOnly", "AI_SaintSeiyaBronzeOnly", "Normal")]
    public class SaintSeiyaBronzeOnlyExecutor : DefaultExecutor
    {
        // Guide coverage notes (embedded MD is the full spec):
        // - Not modeled: full go-second macro loop, Battle-Phase Hyoga trigger, S/A "threat tier" without chain metadata,
        //   Deck runs 2× Mu (922100010) + 2× Athena's Sanctuary (922100079): Mu MMZ ignition searches Sanctuary; backup copy in hand when Field is live.
        // - OnSelectHand stays go-first; counters still lean on engine legality + Util.IsChainTarget where applicable.

        private const int BuildVersion = 63;
        private const string BuildTag = "2026-05-16-v63-ban-on-ss-saint-search";

        /// <summary>Alternate Fusion (c922100303) only when GY has enough Cloth value to justify the summon.</summary>
        private const int MinBronzeClothCardsInGyForMiracleBondsFusion = 2;

        /// <summary>
        /// Bronze Cloth - Hydra (922100047): after damage, battle opponent loses 1000 ATK/DEF until end of turn.
        /// We only credit part of that when Hydra is a realistic equip — avoids over-trusting a delayed debuff.
        /// </summary>
        private const int HydraConservativeOpponentAtkMargin = 900;
        private static bool _buildTagLogged;

        /// <summary>Exact match to texts.str(stringIndex+1) via <see cref="Util.GetStringId"/>.</summary>
        private bool MatchesCardEffectDesc(int desc, int cardId, int stringIndex)
        {
            var sd = (int)Util.GetStringId(cardId, stringIndex);
            if (sd != 0 && desc == sd)
                return true;
            // Custom cards: WindBot may lack str metadata; Ignis still sends id*16+N or filled-str codes.
            return desc == cardId * 16 + stringIndex;
        }

        /// <summary>Optional trigger while this card is in the GY (sent to GY, material, etc.).</summary>
        private bool IsGraveOptionalTriggerDesc(int desc, int cardId, int triggerStringIndex, params int[] excludeOtherEffectIndices)
        {
            if (MatchesCardEffectDesc(desc, cardId, triggerStringIndex))
                return true;
            foreach (var ex in excludeOtherEffectIndices)
            {
                if (MatchesCardEffectDesc(desc, cardId, ex))
                    return false;
            }
            for (var i = 0; i < 8; i++)
            {
                if (i == triggerStringIndex)
                    continue;
                if (MatchesCardEffectDesc(desc, cardId, i))
                    return false;
            }
            if (Card == null || Duel.Player != 0)
                return false;
            return (Card.Location & CardLocation.Grave) != 0;
        }

        /// <summary>Field / Continuous Spell ignition or trigger on Field Zone or Spell Zone.</summary>
        private bool IsFieldSpellOptionalTriggerDesc(int desc, int cardId, int triggerStringIndex, params int[] excludeOtherEffectIndices)
        {
            if (MatchesCardEffectDesc(desc, cardId, triggerStringIndex))
                return true;
            foreach (var ex in excludeOtherEffectIndices)
            {
                if (MatchesCardEffectDesc(desc, cardId, ex))
                    return false;
            }
            for (var i = 0; i < 8; i++)
            {
                if (i == triggerStringIndex)
                    continue;
                if (MatchesCardEffectDesc(desc, cardId, i))
                    return false;
            }
            if (Card == null || Duel.Player != 0)
                return false;
            return (Card.Location & CardLocation.SpellZone) != 0
                || (Card.Location & CardLocation.FieldZone) != 0;
        }

        /// <summary>Stringid index for "sent to GY → add Bronze Saint" on Cloth equips (Phoenix uses 3).</summary>
        private static int BronzeClothGySearchStringIndex(int clothId)
        {
            return clothId == CardId.ClothPhoenix ? 3 : 2;
        }

        /// <summary>Optional trigger on our card (not hand/GY) — EffectYn on summon may predate MMZ sync.</summary>
        private bool IsSummonOptionalTriggerWindow()
        {
            if (Card == null || Duel.Player != 0)
                return false;
            if ((Card.Location & CardLocation.Hand) != 0)
                return false;
            if ((Card.Location & CardLocation.Grave) != 0)
                return false;
            return true;
        }

        /// <summary>On-summon optional effect (Stringid N); EffectYn sends -1/0, id*16+N, or filled texts.str codes.</summary>
        private bool IsOnSummonOptionalTriggerDesc(int desc, int cardId, int summonStringIndex, params int[] excludeOtherEffectIndices)
        {
            if (MatchesCardEffectDesc(desc, cardId, summonStringIndex))
                return true;
            foreach (var ex in excludeOtherEffectIndices)
            {
                if (MatchesCardEffectDesc(desc, cardId, ex))
                    return false;
            }
            for (var i = 0; i < 8; i++)
            {
                if (i == summonStringIndex)
                    continue;
                if (MatchesCardEffectDesc(desc, cardId, i))
                    return false;
            }
            return IsSummonOptionalTriggerWindow();
        }

        public class CardId
        {
            // Monsters
            public const int Seiya = 922100000;
            public const int Shiryu = 922100001;
            public const int Hyoga = 922100002;
            public const int Shun = 922100003;
            public const int Ikki = 922100004;
            public const int Jabu = 922100005;
            public const int Ichi = 922100006;
            public const int Geki = 922100007;
            public const int Ban = 922100008;
            public const int Nachi = 922100009;
            public const int Mu = 922100010;
            public const int Kiki = 922100011;

            /// <summary>Extra — SS proc banishes 1 Seiya + 4 Bronze Saints from MMZ/GY (<c>c922100303.lua</c>, treated as Fusion Summon).</summary>
            public const int SeiyaMiracleBonds = 922100303;

            // Cloth equips (GY trigger: add L4-or-lower Bronze Saint from Deck only — matches script filter)
            public const int ClothPegasus = 922100041;
            public const int ClothDragon = 922100042;
            public const int ClothCygnus = 922100043;
            public const int ClothAndromeda = 922100044;
            public const int ClothPhoenix = 922100045;
            public const int ClothUnicorn = 922100046;
            public const int ClothHydra = 922100047;
            public const int ClothBear = 922100048;
            public const int ClothLionet = 922100049;
            public const int ClothWolf = 922100050;

            // Spells/Traps
            public const int AthenasSanctuary = 922100079;
            public const int RaiseYourCosmos = 922100081;
            public const int AthenaExclamation = 922100082;
            public const int AthenasShield = 922100086;
            public const int AthenasCall = 922100088;
            public const int BondOfBrotherhood = 922100092;
            public const int CrystalWall = 922100101;
            public const int PopesVerdict = 922100103;
        }

        private static readonly int[] Saints =
        {
            CardId.Seiya, CardId.Shiryu, CardId.Hyoga, CardId.Shun, CardId.Ikki,
            CardId.Jabu, CardId.Ichi, CardId.Geki, CardId.Ban, CardId.Nachi,
            CardId.Mu, CardId.Kiki
        };

        private static readonly int[] Lv4Saints =
        {
            CardId.Seiya, CardId.Shiryu, CardId.Hyoga, CardId.Shun, CardId.Ikki,
            CardId.Jabu, CardId.Ichi, CardId.Geki, CardId.Ban, CardId.Nachi
        };

        private static readonly int[] Cloths =
        {
            CardId.ClothPegasus, CardId.ClothDragon, CardId.ClothCygnus, CardId.ClothAndromeda,
            CardId.ClothPhoenix, CardId.ClothUnicorn, CardId.ClothHydra, CardId.ClothBear,
            CardId.ClothLionet, CardId.ClothWolf
        };

        public SaintSeiyaBronzeOnlyExecutor(GameAI ai, Duel duel)
            : base(ai, duel)
        {
            if (!_buildTagLogged)
            {
                _buildTagLogged = true;
                try { Logger.WriteLine("[SaintSeiyaBronzeOnlyExecutor] v" + BuildVersion + " build=" + BuildTag); }
                catch { }
            }

            SilenceDefaultDialogs(ai);

            // c922100303: Fusion Summon trigger equips 1-by-1 from GY (multiple MSG_SELECT) — idle order must beat Verdict/Sanctuary/Cloth lines.
            AddExecutor(ExecutorType.Activate, CardId.SeiyaMiracleBonds, ActivateSeiyaMiracleBonds);

            // Counter traps / interaction (reactive)
            AddExecutor(ExecutorType.Activate, CardId.CrystalWall, ActivateCrystalWall);
            AddExecutor(ExecutorType.Activate, CardId.PopesVerdict, ActivatePopesVerdict);
            AddExecutor(ExecutorType.Activate, CardId.AthenaExclamation, ActivateAthenaExclamation);

            // Protection / setup
            AddExecutor(ExecutorType.Activate, CardId.AthenasShield, ActivateAthenasShield);
            AddExecutor(ExecutorType.Activate, CardId.BondOfBrotherhood, ActivateBond);
            AddExecutor(ExecutorType.Activate, CardId.AthenasSanctuary, ActivateSanctuary);

            // Equip online early (guide: Verdict / board shell)
            AddExecutor(ExecutorType.Activate, CardId.Kiki, ResolveKikiActivate);

            // Starters / consistency
            AddExecutor(ExecutorType.Activate, CardId.AthenasCall, ActivateAthenasCall);
            AddExecutor(ExecutorType.Activate, CardId.Seiya, ResolveSeiyaEffect);
            AddExecutor(ExecutorType.Activate, CardId.RaiseYourCosmos, ActivateRaiseYourCosmos);
            foreach (var cloth in Cloths)
                AddExecutor(ExecutorType.Activate, cloth, ResolveClothActivate);

            // Pay-LP equip (Bronze Saints — historically Extra-safe lines)
            AddExecutor(ExecutorType.Activate, CardId.Shiryu, ResolveShiryuActivate);
            AddExecutor(ExecutorType.Activate, CardId.Hyoga, ResolveHyogaActivate);
            AddExecutor(ExecutorType.Activate, CardId.Shun, ResolveShunActivate);

            // Extenders — Jabu: Activate only (ignition SS from hand; trigger after SS — not Normal Summon)
            AddExecutor(ExecutorType.SpSummon, CardId.Jabu, SpSummonJabuFromHandIfBridged);
            AddExecutor(ExecutorType.SpSummon, CardId.SeiyaMiracleBonds, SpSummonSeiyaMiracleBondsFromExtra);
            AddExecutor(ExecutorType.SummonOrSet, CardId.Jabu, SummonOrSetJabuEmergencyOrDefense);
            AddExecutor(ExecutorType.Activate, CardId.Jabu, ResolveJabuActivate);

            // Normal Summon — single prioritized handler for all Saints
            foreach (var id in Lv4Saints)
                AddExecutor(ExecutorType.Summon, id, PrioritizedNormalSummon);
            AddExecutor(ExecutorType.Summon, CardId.Mu, SummonMu);
            AddExecutor(ExecutorType.Activate, CardId.Mu, ResolveMuEffect);
            AddExecutor(ExecutorType.Activate, CardId.Ikki, ResolveIkkiEffect);
            AddExecutor(ExecutorType.Activate, CardId.Ban, ResolveBanActivate);
            AddExecutor(ExecutorType.Activate, CardId.Ichi, ResolveIchiActivate);
            AddExecutor(ExecutorType.Activate, CardId.Geki, ResolveGekiActivate);
            AddExecutor(ExecutorType.Activate, CardId.Nachi, ResolveNachiActivate);

            // Setting traps near end of turn
            AddExecutor(ExecutorType.SpellSet, SpellSetPolicy);

            // Repos last
            AddExecutor(ExecutorType.Repos, DefaultMonsterRepos);
        }

        /// <summary>
        /// Clears all default dialog arrays (summon, activate, attack, etc.) via reflection
        /// so the bot doesn't spam generic WindBot messages every action.
        /// Only the "custom" array remains usable via TrySendCustomChat.
        /// </summary>
        private static void SilenceDefaultDialogs(GameAI ai)
        {
            try
            {
                var dialogsField = ai.GetType().GetField("_dialogs",
                    System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                if (dialogsField == null) return;

                var dialogs = dialogsField.GetValue(ai);
                if (dialogs == null) return;

                var empty = new string[0];
                string[] fieldNames = new string[]
                {
                    "_welcome", "_deckerror", "_duelstart", "_newturn", "_endturn",
                    "_directattack", "_attack", "_ondirectattack",
                    "_activate", "_summon", "_setmonster", "_chaining"
                };

                var dtype = dialogs.GetType();
                foreach (var name in fieldNames)
                {
                    var f = dtype.GetField(name,
                        System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                    if (f != null && f.FieldType == typeof(string[]))
                        f.SetValue(dialogs, empty);
                }
            }
            catch
            {
                // Best-effort; if reflection fails, default messages remain.
            }
        }

        public override bool OnSelectHand()
        {
            return true; // prefer going first
        }

        /// <summary>
        /// Allow Normal Set only in "survive" lines (e.g., empty board into a strong attacker),
        /// otherwise prefer face-up bodies for distinct-name requirements and on-field effects.
        /// </summary>
        public override bool OnSelectMonsterSummonOrSet(ClientCard card)
        {
            if (card == null)
                return false;

            // Default: do not set — we want face-up names/effects.
            // Exception: if we're facing pressure and need to block direct attacks, setting is acceptable.
            if (Duel.Player != 0 || !IsMainPhase())
                return false;

            if (Bot.GetMonsterCount() != 0)
                return false;

            if (Enemy.GetMonsterCount() == 0)
                return false;

            // Prefer Seiya face-up as the best starter; don't set it.
            if (card.IsCode(CardId.Seiya))
                return false;

            int enemyBestAtk = Util.GetBestAttack(Enemy);
            if (enemyBestAtk <= 0)
                return false;

            int combatAtk = card.Attack + ProbableBronzeClothAtkBonusAfterSummon(card.Id);
            int enemyPress = System.Math.Max(0, enemyBestAtk - ConservativeOpponentAtkMarginForHydra(card.Id));

            // If DEF cannot wall but printed ATK + probable Cloth buff can match or beat their line, summon face-up ATK.
            if (enemyPress > card.Defense && enemyPress <= combatAtk)
                return false;

            // If even DEF won't wall, set to at least prevent direct attack lines this turn.
            if (enemyPress > card.Defense)
                return true;

            // Emergency: if we're setting Jabu because we have no better line, allow set even if DEF could wall.
            if (card.IsCode(CardId.Jabu) && FieldIsEmpty() && !Bot.HasInHand(CardId.Seiya))
                return true;

            return false;
        }

        private bool SummonOrSetJabuEmergencyOrDefense()
        {
            if (!IsMainPhase())
                return false;
            if (Duel.Player != 0)
                return false;
            if ((Card.Location & CardLocation.Hand) == 0)
                return false;
            if (!Card.IsCode(CardId.Jabu))
                return false;
            if (Bot.GetMonsterCount() >= 5)
                return false;

            // If we already control a Saint, prefer Jabu's own Special Summon line instead of Normal.
            if (ControlAnySaint())
                return false;

            // Case A (defense): enemy has pressure; setting can prevent direct attacks.
            if (Enemy.GetMonsterCount() > 0)
                return true;

            // Case B (emergency): no Seiya in hand and we need to put something on board.
            if (!Bot.HasInHand(CardId.Seiya) && Bot.GetHandCount() <= 4)
                return true;

            return false;
        }

        private static readonly int[] SaintDiscardPriority =
        {
            // User rule: prioritize Ichi, then Ban, then others.
            CardId.Ichi,
            CardId.Ikki,
            CardId.Ban,
            CardId.Nachi,
            CardId.Geki,
            CardId.Jabu,
            CardId.Shun,
            CardId.Hyoga,
            CardId.Shiryu,       
            CardId.Seiya,
            CardId.Mu,
            CardId.Kiki
        };

        private int? ChooseSaintDiscardFromHand(params int[] excluded)
        {
            var excludedSet = new HashSet<int>(excluded ?? new int[0]);
            foreach (var id in SaintDiscardPriority)
            {
                if (excludedSet.Contains(id))
                    continue;
                if (Bot.HasInHand(id))
                    return id;
            }
            return null;
        }

        private void PreselectDiscardSaintPriority(params int[] excluded)
        {
            // Some executor builds don't expose OnSelectCard overrides to plugins.
            // We can still bias upcoming selection prompts by queuing a selection.
            var pick = ChooseSaintDiscardFromHand(excluded);
            if (pick.HasValue)
                AI.SelectNextCard(pick.Value);
        }

        /// <summary>
        /// WindBot maps the AI to <c>Duel.Fields[0]</c>; turn player index follows <c>Duel.Player</c> (0 = our turn).
        /// Block burning reactive protection Quick-Plays during an open Main Phase on our own turn.
        /// </summary>
        public override bool OnPreActivate(ClientCard card)
        {
            // If an upcoming effect will prompt "discard 1 card", bias the discard selection now.
            // This is necessary because this plugin build can't override OnSelectCard prompts directly.
            if (card != null
                && (card.IsCode(CardId.ClothWolf) || card.IsCode(CardId.ClothLionet))
                && (card.Location & CardLocation.SpellZone) != 0)
            {
                PreselectDiscardSaintPriority();
            }

            // Cygnus (922100043) Stringid 1: negate 1 face-up opponent card (Lua accepts any; executor ranks S/T vs monster).
            // Bias target selection — default AI tends to over-pick monsters.
            if (card != null
                && card.IsCode(CardId.ClothCygnus)
                && (card.Location & CardLocation.SpellZone) != 0
                && IsCygnusNegateIgnitionForCard(card))
            {
                var cygTgt = ChooseCygnusNegateTarget();
                if (cygTgt != null)
                    AI.SelectNextCard(cygTgt);
            }

            // Seiya (922100000) Stringid 0: on N/SS search Cloth or Saint from Deck (EffectYn desc -1).
            if (card != null
                && card.IsCode(CardId.Seiya)
                && IsSeiyaOnSummonSearchPrompt((int)ActivateDescription)
                && SeiyaOnSummonSearchHasDeckTarget())
                PreselectSeiyaDeckSearch();

            // Miracle Bonds (922100303): post-Fusion GY equip — preselect before EffectYn (desc often -1).
            if (card != null
                && card.IsCode(CardId.SeiyaMiracleBonds)
                && IsMiracleBondsGyEquipPrompt((int)ActivateDescription)
                && MiracleBondsGyEquipLegal())
                PreselectMiracleBondsGyClothChain();

            // Athena's Sanctuary (922100079) Stringid 0: return 1 Cloth from S/T Zone to hand.
            if (card != null
                && card.IsCode(CardId.AthenasSanctuary)
                && IsSanctuaryFieldCard(card))
            {
                var tgt = ChooseSanctuaryClothReturnTarget();
                if (tgt != null)
                    AI.SelectNextCard(tgt);
            }

            // Mu Stringid 1: discard to add Athena's Sanctuary from Deck.
            if (card != null
                && card.IsCode(CardId.Mu)
                && (card.Location & CardLocation.Hand) != 0
                && IsMuDiscardSearchSanctuaryDescription((int)ActivateDescription)
                && Bot.GetRemainingCount(CardId.AthenasSanctuary, (int)CardLocation.Deck) > 0)
                AI.SelectCard(CardId.AthenasSanctuary);

            // Jabu (c922100005) Stringid 1: on SS add Cloth from GY, then discard (EffectYn desc -1).
            if (card != null
                && card.IsCode(CardId.Jabu)
                && IsJabuOnSpecialSummonClothPrompt((int)ActivateDescription)
                && JabuSpecialSummonClothRecoveryLegal())
            {
                var cloth = ChooseBestClothFromGraveyard();
                if (cloth != null)
                    AI.SelectCard(cloth);
                PreselectDiscardSaintPriority();
            }

            // Ban (c922100008) Stringid 1: on SS add 1 Saint from GY (any turn; desc often -1/0).
            if (card != null
                && card.IsCode(CardId.Ban)
                && IsBanOnSpecialSummonSaintSearchEffectYn((int)ActivateDescription)
                && BanSpecialSummonSaintRecoveryLegal())
            {
                var saint = ChooseSaintClientCardFromGraveyard();
                if (saint != null)
                    AI.SelectCard(saint);
            }

            if (card != null
                && (card.IsCode(CardId.AthenasShield) || card.IsCode(CardId.BondOfBrotherhood))
                && IsOpenOwnMainPhaseNoChain())
                return false;
            return base.OnPreActivate(card);
        }

        private bool ChainIsEmpty()
        {
            return Duel.CurrentChain == null || Duel.CurrentChain.Count == 0;
        }

        private object TryGetLastChainLink()
        {
            try
            {
                if (Duel == null || Duel.CurrentChain == null || Duel.CurrentChain.Count == 0)
                    return null;
                return Duel.CurrentChain[Duel.CurrentChain.Count - 1];
            }
            catch
            {
                return null;
            }
        }

        private static int? TryReadIntMember(object obj, params string[] names)
        {
            if (obj == null || names == null)
                return null;
            try
            {
                var t = obj.GetType();
                foreach (var n in names)
                {
                    var p = t.GetProperty(n);
                    if (p != null)
                    {
                        var v = p.GetValue(obj, null);
                        if (v is int)
                            return (int)v;
                    }
                    var f = t.GetField(n);
                    if (f != null)
                    {
                        var v = f.GetValue(obj);
                        if (v is int)
                            return (int)v;
                    }
                }
            }
            catch { }
            return null;
        }

        private static string TryReadStringMember(object obj, params string[] names)
        {
            if (obj == null || names == null)
                return null;
            try
            {
                var t = obj.GetType();
                foreach (var n in names)
                {
                    var p = t.GetProperty(n);
                    if (p != null)
                    {
                        var v = p.GetValue(obj, null);
                        if (v is string)
                            return (string)v;
                    }
                    var f = t.GetField(n);
                    if (f != null)
                    {
                        var v = f.GetValue(obj);
                        if (v is string)
                            return (string)v;
                    }
                }
            }
            catch { }
            return null;
        }

        private static object TryReadObjMember(object obj, params string[] names)
        {
            if (obj == null || names == null)
                return null;
            try
            {
                var t = obj.GetType();
                foreach (var n in names)
                {
                    var p = t.GetProperty(n);
                    if (p != null)
                        return p.GetValue(obj, null);
                    var f = t.GetField(n);
                    if (f != null)
                        return f.GetValue(obj);
                }
            }
            catch { }
            return null;
        }

        private int? TryGetLastChainActivatorPlayer()
        {
            var link = TryGetLastChainLink();
            if (link == null)
                return null;

            var p = TryReadIntMember(link, "Player", "Controller", "Activator", "Owner", "ActingPlayer");
            if (p.HasValue)
                return p.Value;

            var handler = TryReadObjMember(link, "Card", "Handler", "Source", "EffectCard", "ActivatingCard");
            p = TryReadIntMember(handler, "Controller", "Player", "Owner");
            if (p.HasValue)
                return p.Value;

            return null;
        }

        private int? TryGetLastChainCardType()
        {
            var link = TryGetLastChainLink();
            if (link == null)
                return null;

            var t = TryReadIntMember(link, "Type", "ActiveType", "CardType");
            if (t.HasValue)
                return t.Value;

            var handler = TryReadObjMember(link, "Card", "Handler", "Source", "EffectCard", "ActivatingCard");
            t = TryReadIntMember(handler, "Type");
            if (t.HasValue)
                return t.Value;

            return null;
        }

        private string TryGetLastChainCardName()
        {
            var link = TryGetLastChainLink();
            if (link == null)
                return null;

            var name = TryReadStringMember(link, "Name", "CardName");
            if (!string.IsNullOrEmpty(name))
                return name;

            var handler = TryReadObjMember(link, "Card", "Handler", "Source", "EffectCard", "ActivatingCard");
            name = TryReadStringMember(handler, "Name", "CardName");
            return name;
        }

        private bool IsOpponentSpellTrapWipeLikeChain()
        {
            if (ChainIsEmpty())
                return false;

            // Must be opponent-driven. If we can't read activator reliably, fall back to "not our turn".
            var activator = TryGetLastChainActivatorPlayer();
            if (activator.HasValue && activator.Value == 0)
                return false;
            if (!activator.HasValue && Duel.Player == 0)
                return false;

            // Must be Spell/Trap when we can read type; otherwise do not assume.
            var type = TryGetLastChainCardType();
            if (!type.HasValue)
                return false;
            if ((type.Value & (int)CardType.Spell) == 0 && (type.Value & (int)CardType.Trap) == 0)
                return false;

            // Non-targeting rule: only consider when chain isn't already targeting our stuff.
            bool anySaintTargeted = Bot.MonsterZone.Any(m => m != null && m.IsFaceup() && Saints.Contains(m.Id) && Util.IsChainTarget(m));
            bool anyClothTargeted = Bot.SpellZone.Any(z => z != null && z.IsFaceup() && Cloths.Contains(z.Id) && Util.IsChainTarget(z));
            if (anySaintTargeted || anyClothTargeted)
                return false;

            // Board-value guard: don't burn on empty/low-value boards.
            int saintsUp = Bot.MonsterZone.Count(m => m != null && m.IsFaceup() && Saints.Contains(m.Id));
            bool haveFaceupCloth = Bot.SpellZone.Any(z => z != null && z.IsFaceup() && Cloths.Contains(z.Id));
            bool haveEquippedShell = HasEquippedSaint();
            if (saintsUp == 0 && !haveFaceupCloth)
                return false;
            if (!(saintsUp >= 2 || haveEquippedShell || haveFaceupCloth))
                return false;

            var name = TryGetLastChainCardName();
            if (string.IsNullOrEmpty(name))
                return false;

            var n = name.ToLowerInvariant();
            // Conservative wipe/removal-ish patterns (English); keep small to avoid false positives.
            // This intentionally misses many cards rather than burning resources.
            var patterns = new[]
            {
                "raigeki",
                "dark hole",
                "lightning storm",
                "feather duster",
                "harpie",
                "evenly matched",
                "torrential tribute",
                "storm",
                "wipe",
                "destroy all"
            };
            return patterns.Any(p => n.Contains(p));
        }

        /// <summary>
        /// Returns true if the last chain link was activated by the opponent.
        /// Returns false if it was ours or if we can't determine the activator on our own turn (conservative).
        /// </summary>
        private bool IsLastChainFromOpponent()
        {
            var activator = TryGetLastChainActivatorPlayer();
            if (activator.HasValue)
                return activator.Value != 0;
            // Fallback: if we can't read the activator, assume opponent only on their turn.
            return Duel.Player != 0;
        }

        /// <summary>Open Main1/Main2 on our turn with no chain — typical "beginner" misuse window for protection QPs.</summary>
        private bool IsOpenOwnMainPhaseNoChain()
        {
            return Duel.Player == 0 && IsMainPhase() && ChainIsEmpty();
        }

        private readonly HashSet<int> _chatSentThisTurn = new HashSet<int>();
        private int _chatLastTurnCount = -1;

        private void TrySendCustomChat(int index, params object[] args)
        {
            try
            {
                // Reset cooldown tracker each new turn.
                int turnCount = Duel.Turn;
                if (turnCount != _chatLastTurnCount)
                {
                    _chatSentThisTurn.Clear();
                    _chatLastTurnCount = turnCount;
                }

                if (_chatSentThisTurn.Contains(index))
                    return;

                if (AI == null)
                    return;
                var method = AI.GetType().GetMethod("SendCustomChat");
                if (method == null)
                    return;
                method.Invoke(AI, new object[] { index, args });
                _chatSentThisTurn.Add(index);
            }
            catch
            {
                // Ignore: dialogs are optional and vary by WindBot build.
            }
        }

        private int DistinctSaintNamesOnField()
        {
            return Bot.MonsterZone
                .Where(c => c != null && c.IsFaceup() && Saints.Contains(c.Id))
                .Select(c => c.Id)
                .Distinct()
                .Count();
        }

        private bool ControlAnySaint()
        {
            return Bot.MonsterZone.Any(c => c != null && c.IsFaceup() && Saints.Contains(c.Id));
        }

        private bool FieldIsEmpty()
        {
            return Bot.GetMonsterCount() == 0;
        }

        private bool HasClothInGraveyard()
        {
            return Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id));
        }

        /// <summary>Guide: HasEquippedSaint — Saint with a face-up Cloth equip.</summary>
        private bool HasEquippedSaint()
        {
            return Bot.MonsterZone.Any(m =>
                m != null
                && m.IsFaceup()
                && Saints.Contains(m.Id)
                && m.EquipCards != null
                && m.EquipCards.Any(eq => eq != null && eq.IsFaceup() && Cloths.Contains(eq.Id)));
        }

        /// <summary>Guide: NeedEquipForVerdict — will run Verdict and need an equipped Saint.</summary>
        private bool NeedEquipForVerdict()
        {
            return (Bot.HasInHand(CardId.PopesVerdict) || Bot.HasInSpellZone(CardId.PopesVerdict))
                   && !HasEquippedSaint();
        }

        private bool HasStarterInHandBesidesAthenasCall()
        {
            return Bot.HasInHand(CardId.Seiya)
                   || Bot.Hand.IsExistingMatchingCard(c => Cloths.Contains(c.Id))
                   || Bot.HasInHand(CardId.RaiseYourCosmos);
        }

        /// <summary>Guide: ResolveSeiyaSearch — Cloth access "soon" (hand equip, Kiki, or Seiya+GY equip line).</summary>
        private bool HasBronzeClothAccessSoon()
        {
            if (Bot.Hand.IsExistingMatchingCard(c => Cloths.Contains(c.Id)) && ControlAnySaint() && HasFreeMainSpellZoneForEquip())
                return true;
            if (Bot.HasInHand(CardId.Kiki))
                return true;
            if (HasSeiyaFaceup() && HasClothInGraveyard() && Bot.LifePoints >= 500 && HasFreeMainSpellZoneForEquip())
                return true;
            return false;
        }

        /// <summary>aux.Stringid index for "pay 500 LP; equip Cloth" on each Saint (script-dependent).</summary>
        private static int GetPayEquipStringOption(int monsterId)
        {
            switch (monsterId)
            {
                case CardId.Seiya: return 2;
                case CardId.Shun: return 0;
                case CardId.Shiryu:
                case CardId.Hyoga:
                case CardId.Ikki:
                    return 1;
                default:
                    return -1;
            }
        }

        private bool IsActivateDescriptionPayEquip(int monsterId)
        {
            var opt = GetPayEquipStringOption(monsterId);
            if (opt < 0)
                return false;
            return MatchesCardEffectDesc((int)ActivateDescription, monsterId, opt);
        }

        /// <summary>Kiki equips from Deck or GY — bitmask Deck|Grave.</summary>
        private bool ClothAccessibleFromDeckOrGraveyard(int clothId)
        {
            return Bot.GetRemainingCount(clothId, (int)(CardLocation.Deck | CardLocation.Grave)) > 0;
        }

        /// <summary>Pay-500 equip effects for Saints (922100000..004) now equip Cloths from GY only.</summary>
        private bool ClothAccessibleFromGraveyard(int clothId)
        {
            return Bot.Graveyard.IsExistingMatchingCard(c => c.IsCode(clothId));
        }

        private bool HasFreeMainSpellZoneForEquip()
        {
            for (var i = 0; i < 5; i++)
                if (Bot.SpellZone[i] == null)
                    return true;
            return false;
        }

        /// <summary>Count vacant main S/T zones (0–4) for stacking multiple equips.</summary>
        private int CountVacantMainSpellZonesForEquip()
        {
            int n = 0;
            for (var i = 0; i < 5; i++)
                if (Bot.SpellZone[i] == null)
                    n++;
            return n;
        }

        /// <summary>Passive ATK from equipping a Bronze Cloth (EFFECT_UPDATE_ATTACK on equip; matches scripts c922100041–050).</summary>
        private static int BronzeClothPassiveAtkBuff(int clothId)
        {
            switch (clothId)
            {
                case CardId.ClothPegasus: return 500;
                case CardId.ClothPhoenix: return 1000;
                case CardId.ClothLionet: return 600;
                case CardId.ClothHydra:return 1000;
                case CardId.ClothDragon:
                case CardId.ClothCygnus:
                case CardId.ClothAndromeda:
                case CardId.ClothUnicorn:
                case CardId.ClothBear:
                case CardId.ClothWolf:
                    return 300;
                default:
                    return 0;
            }
        }

        private int MaxBronzeClothAtkBuffInHand()
        {
            int best = 0;
            foreach (var c in Bot.Hand)
            {
                if (c == null || !Cloths.Contains(c.Id))
                    continue;
                int b = BronzeClothPassiveAtkBuff(c.Id);
                if (b > best)
                    best = b;
            }
            return best;
        }

        private int MaxBronzeClothAtkBuffInGraveyard()
        {
            int best = 0;
            foreach (var c in Bot.Graveyard)
            {
                if (c == null || !Cloths.Contains(c.Id))
                    continue;
                int b = BronzeClothPassiveAtkBuff(c.Id);
                if (b > best)
                    best = b;
            }
            return best;
        }

        /// <summary>Best passive ATK still in Main Deck (Seiya on-summon search, Kiki equip-from-Deck, etc.).</summary>
        private int MaxBronzeClothAtkBuffAccessibleFromDeck()
        {
            int best = 0;
            foreach (var clothId in Cloths)
            {
                if (Bot.GetRemainingCount(clothId, (int)CardLocation.Deck) <= 0)
                    continue;
                int b = BronzeClothPassiveAtkBuff(clothId);
                if (b > best)
                    best = b;
            }
            return best;
        }

        /// <summary>
        /// Kiki (hand): discard → equip 1 Cloth from Deck or GY to a Saint (typical post–Normal Summon ATK line).
        /// </summary>
        private int MaxBronzeClothAtkBuffViaKiki(int saintMonsterId)
        {
            if (!Bot.HasInHand(CardId.Kiki))
                return 0;
            if (!HasFreeMainSpellZoneForEquip())
                return 0;

            int best = 0;
            var preferred = ClothMatchingSaint(saintMonsterId);
            if (preferred.HasValue && ClothAccessibleFromDeckOrGraveyard(preferred.Value))
                best = BronzeClothPassiveAtkBuff(preferred.Value);

            foreach (var clothId in Cloths)
            {
                if (!ClothAccessibleFromDeckOrGraveyard(clothId))
                    continue;
                int b = BronzeClothPassiveAtkBuff(clothId);
                if (b > best)
                    best = b;
            }
            return best;
        }

        /// <summary>Seiya NS/SS: add 1 Cloth Equip from Deck (c922100000.lua).</summary>
        private int MaxBronzeClothAtkBuffFromSeiyaOnSummon(int saintMonsterId)
        {
            if (saintMonsterId != CardId.Seiya)
                return 0;
            if (!HasFreeMainSpellZoneForEquip())
                return 0;
            return MaxBronzeClothAtkBuffAccessibleFromDeck();
        }

        /// <summary>Mu NS/SS: add up to 2 Cloth Equips from GY to hand, then equip (c922100010.lua).</summary>
        private int MaxBronzeClothAtkBuffFromMuOnSummon(int saintMonsterId)
        {
            if (saintMonsterId != CardId.Mu)
                return 0;
            if (!HasFreeMainSpellZoneForEquip())
                return 0;
            return MaxBronzeClothAtkBuffInGraveyard();
        }

        /// <summary>
        /// After this Normal Summon, a Level 4 Saint will be on the field so Jabu can Special Summon from hand;
        /// on SS, add 1 Cloth from GY to hand then discard (c922100005.lua). Not credited for NS Jabu alone.
        /// </summary>
        private bool SaintBoardEnablesJabuSpecialSummonAfterThisNormalSummon(int saintMonsterId)
        {
            if (Bot.MonsterZone.Any(c => c != null && c.IsFaceup() && Lv4Saints.Contains(c.Id)))
                return true;
            return Bot.GetMonsterCount() == 0
                && Lv4Saints.Contains(saintMonsterId)
                && saintMonsterId != CardId.Jabu;
        }

        /// <summary>Jabu in hand: SS if a Saint is on field → add Cloth from GY (then discard 1).</summary>
        private int MaxBronzeClothAtkBuffFromJabuAfterSaintOnField(int saintMonsterId)
        {
            if (!Bot.HasInHand(CardId.Jabu))
                return 0;
            if (!HasFreeMainSpellZoneForEquip())
                return 0;
            if (!HasClothInGraveyard())
                return 0;
            if (Bot.GetMonsterCount() >= 5)
                return 0;
            if (Bot.GetHandCount() < 2)
                return 0;
            if (!SaintBoardEnablesJabuSpecialSummonAfterThisNormalSummon(saintMonsterId))
                return 0;
            return MaxBronzeClothAtkBuffInGraveyard();
        }

        /// <summary>Main Bronze Saints with pay-500 equip Cloth from GY (922100000–004).</summary>
        private static bool SupportsPayEquipClothFromGraveyard(int saintMonsterId)
        {
            return saintMonsterId == CardId.Seiya
                || saintMonsterId == CardId.Shiryu
                || saintMonsterId == CardId.Hyoga
                || saintMonsterId == CardId.Shun
                || saintMonsterId == CardId.Ikki;
        }

        /// <summary>
        /// Upper bound on extra ATK this turn after the summon resolves: Cloth in hand, pay-equip from GY,
        /// Kiki (Deck/GY equip), Seiya/Mu on-summon Cloth access, Jabu SS → Cloth from GY. Uses vacant S/T zones.
        /// </summary>
        private int ProbableBronzeClothAtkBonusAfterSummon(int saintMonsterId)
        {
            int free = CountVacantMainSpellZonesForEquip();
            if (free <= 0)
                return 0;

            int maxHand = MaxBronzeClothAtkBuffInHand();
            int maxGy = 0;
            if (SupportsPayEquipClothFromGraveyard(saintMonsterId)
                && Bot.LifePoints >= 500
                && HasClothInGraveyard())
                maxGy = MaxBronzeClothAtkBuffInGraveyard();

            int maxKiki = MaxBronzeClothAtkBuffViaKiki(saintMonsterId);
            int maxSeiyaSearch = MaxBronzeClothAtkBuffFromSeiyaOnSummon(saintMonsterId);
            int maxMuRecover = MaxBronzeClothAtkBuffFromMuOnSummon(saintMonsterId);
            int maxJabuLine = MaxBronzeClothAtkBuffFromJabuAfterSaintOnField(saintMonsterId);

            int bestSingle = maxHand;
            if (maxGy > bestSingle)
                bestSingle = maxGy;
            if (maxKiki > bestSingle)
                bestSingle = maxKiki;
            if (maxSeiyaSearch > bestSingle)
                bestSingle = maxSeiyaSearch;
            if (maxMuRecover > bestSingle)
                bestSingle = maxMuRecover;
            if (maxJabuLine > bestSingle)
                bestSingle = maxJabuLine;

            if (free == 1)
                return bestSingle;

            int combined = maxHand;
            int bestOther = maxGy;
            if (maxKiki > bestOther)
                bestOther = maxKiki;
            if (maxSeiyaSearch > bestOther)
                bestOther = maxSeiyaSearch;
            if (maxMuRecover > bestOther)
                bestOther = maxMuRecover;
            if (maxJabuLine > bestOther)
                bestOther = maxJabuLine;
            return combined + bestOther;
        }

        /// <summary>
        /// True if Hydra is among equips we can still place this turn (hand and/or GY pay-equip line).
        /// </summary>
        private bool HydraAmongAccessibleEquips(int saintMonsterId)
        {
            if (!HasFreeMainSpellZoneForEquip())
                return false;
            if (Bot.Hand.Any(c => c != null && c.IsCode(CardId.ClothHydra)))
                return true;
            if (SupportsPayEquipClothFromGraveyard(saintMonsterId)
                && Bot.LifePoints >= 500
                && Bot.Graveyard.Any(c => c != null && c.IsCode(CardId.ClothHydra)))
                return true;
            if (Bot.HasInHand(CardId.Kiki) && ClothAccessibleFromDeckOrGraveyard(CardId.ClothHydra))
                return true;
            if (saintMonsterId == CardId.Seiya
                && Bot.GetRemainingCount(CardId.ClothHydra, (int)CardLocation.Deck) > 0)
                return true;
            if (saintMonsterId == CardId.Mu
                && Bot.Graveyard.Any(c => c != null && c.IsCode(CardId.ClothHydra)))
                return true;
            if (Bot.HasInHand(CardId.Jabu)
                && HasClothInGraveyard()
                && Bot.Graveyard.Any(c => c != null && c.IsCode(CardId.ClothHydra))
                && SaintBoardEnablesJabuSpecialSummonAfterThisNormalSummon(saintMonsterId)
                && Bot.GetHandCount() >= 2
                && Bot.GetMonsterCount() < 5)
                return true;
            return false;
        }

        private int ConservativeOpponentAtkMarginForHydra(int saintMonsterId)
        {
            return HydraAmongAccessibleEquips(saintMonsterId) ? HydraConservativeOpponentAtkMargin : 0;
        }

        private int AdjustedEnemyBestAttackForSizing(int saintMonsterId)
        {
            int raw = Util.GetBestAttack(Enemy);
            int m = ConservativeOpponentAtkMarginForHydra(saintMonsterId);
            return System.Math.Max(0, raw - m);
        }

        private bool AnyEnemyFaceUpBeatsCombatAtkConsideringHydra(int saintMonsterId, int combatAtk)
        {
            int m = ConservativeOpponentAtkMarginForHydra(saintMonsterId);
            foreach (var mon in Enemy.GetMonsters())
            {
                if (mon == null || !mon.IsFaceup())
                    continue;
                int eff = System.Math.Max(0, mon.Attack - m);
                if (eff > combatAtk)
                    return true;
            }
            return false;
        }

        /// <summary>Bronze Saint → matching Cloth for synergy (Mu/Kiki have no pairing).</summary>
        private static int? ClothMatchingSaint(int saintMonsterId)
        {
            switch (saintMonsterId)
            {
                case CardId.Seiya: return CardId.ClothPegasus;
                case CardId.Shiryu: return CardId.ClothDragon;
                case CardId.Hyoga: return CardId.ClothCygnus;
                case CardId.Shun: return CardId.ClothAndromeda;
                case CardId.Ikki: return CardId.ClothPhoenix;
                case CardId.Jabu: return CardId.ClothUnicorn;
                case CardId.Ichi: return CardId.ClothHydra;
                case CardId.Geki: return CardId.ClothBear;
                case CardId.Ban: return CardId.ClothLionet;
                case CardId.Nachi: return CardId.ClothWolf;
                default: return null;
            }
        }

        /// <summary>Bronze Cloth → owning Bronze Saint (inverse of <see cref="ClothMatchingSaint"/>).</summary>
        private static int? SaintMatchingCloth(int clothId)
        {
            switch (clothId)
            {
                case CardId.ClothPegasus: return CardId.Seiya;
                case CardId.ClothDragon: return CardId.Shiryu;
                case CardId.ClothCygnus: return CardId.Hyoga;
                case CardId.ClothAndromeda: return CardId.Shun;
                case CardId.ClothPhoenix: return CardId.Ikki;
                case CardId.ClothUnicorn: return CardId.Jabu;
                case CardId.ClothHydra: return CardId.Ichi;
                case CardId.ClothBear: return CardId.Geki;
                case CardId.ClothLionet: return CardId.Ban;
                case CardId.ClothWolf: return CardId.Nachi;
                default: return null;
            }
        }

        private ClientCard GetFaceupBronzeSaintOnField(int saintId)
        {
            foreach (var c in Bot.MonsterZone)
            {
                if (c != null && c.IsFaceup() && c.IsCode(saintId) && IsBronzeSaintWarriorId(c.Id))
                    return c;
            }
            return null;
        }

        private bool IsClothOnMatchingBronzeSaint(ClientCard cloth)
        {
            if (cloth == null)
                return false;
            var saintId = SaintMatchingCloth(cloth.Id);
            if (!saintId.HasValue)
                return false;
            var host = cloth.EquipTarget;
            return host != null && host.IsFaceup() && host.IsCode(saintId.Value);
        }

        private bool MatchingSaintAlreadyHasClothEquipped(int saintId, int clothId, ClientCard exceptCloth)
        {
            foreach (var z in Bot.SpellZone)
            {
                if (z == null || z == exceptCloth || !z.IsFaceup() || !Cloths.Contains(z.Id))
                    continue;
                var host = z.EquipTarget;
                if (host != null && host.IsFaceup() && host.IsCode(saintId) && z.IsCode(clothId))
                    return true;
            }
            return false;
        }

        /// <summary>Return Cloth only when its paired Bronze Saint is on field and this equip is on the wrong host.</summary>
        private bool SanctuaryClothEligibleForRePair(ClientCard cloth)
        {
            if (cloth == null || !cloth.IsFaceup() || !Cloths.Contains(cloth.Id))
                return false;
            var saintId = SaintMatchingCloth(cloth.Id);
            if (!saintId.HasValue)
                return false;
            if (GetFaceupBronzeSaintOnField(saintId.Value) == null)
                return false;
            if (IsClothOnMatchingBronzeSaint(cloth))
                return false;
            if (MatchingSaintAlreadyHasClothEquipped(saintId.Value, cloth.Id, cloth))
                return false;
            return true;
        }

        private int[] BuildKikiClothPriorityForTarget(ClientCard saintTarget)
        {
            var preferred = saintTarget != null ? ClothMatchingSaint(saintTarget.Id) : null;
            var fallback = new[]
            {
                CardId.ClothCygnus,
                CardId.ClothDragon,
                CardId.ClothAndromeda,
                CardId.ClothPhoenix,
                CardId.ClothPegasus,
                CardId.ClothUnicorn,
                CardId.ClothHydra,
                CardId.ClothBear,
                CardId.ClothLionet,
                CardId.ClothWolf
            };
            var ordered = new List<int>();
            if (preferred.HasValue && ClothAccessibleFromDeckOrGraveyard(preferred.Value))
                ordered.Add(preferred.Value);
            foreach (var id in fallback)
                if (!ordered.Contains(id))
                    ordered.Add(id);
            return ordered.ToArray();
        }

        private bool HasSeiyaFaceup()
        {
            return Bot.MonsterZone.Any(c => c != null && c.IsFaceup() && c.IsCode(CardId.Seiya));
        }

        private bool IsMainPhase()
        {
            return Duel.Phase == DuelPhase.Main1 || Duel.Phase == DuelPhase.Main2;
        }

        private static bool IsBattlePhase(DuelPhase phase)
        {
            switch (phase)
            {
                case DuelPhase.BattleStart:
                case DuelPhase.BattleStep:
                case DuelPhase.Damage:
                case DuelPhase.DamageCal:
                case DuelPhase.Battle:
                    return true;
                default:
                    return false;
            }
        }

        /// <summary>Post-Fusion equip trigger (c922100303) can SEG in Main or Battle on our turn.</summary>
        private bool IsOurPhaseForMiracleBondsGyEquip()
        {
            return Duel.Player == 0 && (IsMainPhase() || IsBattlePhase(Duel.Phase));
        }

        private bool MiracleBondsGyEquipLegal()
        {
            return HasFreeMainSpellZoneForEquip() && HasClothInGraveyard();
        }

        private int CountBronzeClothCardsInGraveyard()
        {
            var n = 0;
            foreach (var c in Bot.Graveyard)
            {
                if (c != null && Cloths.Contains(c.Id))
                    n++;
            }
            return n;
        }

        /// <summary>GY banish Fusion not worth it with a single Cloth to equip afterward.</summary>
        private bool MiracleBondsFusionSummonWorthwhile()
        {
            return CountBronzeClothCardsInGraveyard() >= MinBronzeClothCardsInGyForMiracleBondsFusion
                && MiracleBondsGyEquipLegal();
        }

        private bool IsMiracleBondsBanishMaterial(ClientCard c)
        {
            return c != null && IsBronzeSaintWarriorId(c.Id);
        }

        private bool HasMiracleBondsSeiyaMaterialAccessible()
        {
            if (Bot.Graveyard.IsExistingMatchingCard(c => c != null && c.IsCode(CardId.Seiya)))
                return true;
            return Bot.MonsterZone.IsExistingMatchingCard(m =>
                m != null && m.IsFaceup() && m.IsCode(CardId.Seiya));
        }

        /// <summary>Distinct Bronze Saint bodies legal for <c>s.matfilter</c> (MMZ face-up + GY).</summary>
        private int CountMiracleBondsBanishMaterialCards()
        {
            var seen = new HashSet<ClientCard>();
            foreach (var c in Bot.Graveyard)
            {
                if (IsMiracleBondsBanishMaterial(c))
                    seen.Add(c);
            }
            foreach (var m in Bot.MonsterZone)
            {
                if (m != null && m.IsFaceup() && IsMiracleBondsBanishMaterial(m))
                    seen.Add(m);
            }
            return seen.Count;
        }

        private static int MiracleBondsBanishMaterialPriority(ClientCard c)
        {
            if (c == null)
                return int.MaxValue;
            var slot = SaintDiscardPriority.Length;
            for (var i = 0; i < SaintDiscardPriority.Length; i++)
            {
                if (SaintDiscardPriority[i] == c.Id)
                {
                    slot = i;
                    break;
                }
            }
            var fromGy = (c.Location & CardLocation.Grave) != 0;
            return (fromGy ? 0 : 1000) + slot;
        }

        /// <summary>1 Seiya + 4 other Bronze Saints for <c>s.spop</c> (prefer GY, then expendable field bodies).</summary>
        private List<ClientCard> BuildMiracleBondsBanishGroup()
        {
            var result = new List<ClientCard>();
            var used = new HashSet<ClientCard>();

            ClientCard seiya = null;
            foreach (var c in Bot.Graveyard)
            {
                if (c != null && c.IsCode(CardId.Seiya) && used.Add(c))
                {
                    seiya = c;
                    break;
                }
            }
            if (seiya == null)
            {
                foreach (var m in Bot.MonsterZone)
                {
                    if (m != null && m.IsFaceup() && m.IsCode(CardId.Seiya) && used.Add(m))
                    {
                        seiya = m;
                        break;
                    }
                }
            }
            if (seiya == null)
                return result;

            result.Add(seiya);

            var pool = new List<ClientCard>();
            foreach (var c in Bot.Graveyard)
            {
                if (c != null && IsMiracleBondsBanishMaterial(c) && !used.Contains(c))
                    pool.Add(c);
            }
            foreach (var m in Bot.MonsterZone)
            {
                if (m != null && m.IsFaceup() && IsMiracleBondsBanishMaterial(m) && !used.Contains(m))
                    pool.Add(m);
            }
            pool.Sort((a, b) => MiracleBondsBanishMaterialPriority(a).CompareTo(MiracleBondsBanishMaterialPriority(b)));
            foreach (var c in pool)
            {
                if (result.Count >= 5)
                    break;
                used.Add(c);
                result.Add(c);
            }
            return result;
        }

        private bool MiracleBondsSpSummonMaterialsLegal()
        {
            return BuildMiracleBondsBanishGroup().Count >= 5;
        }

        /// <summary>Two MSG_SELECT_CARD: 1 Seiya then 4 others (LIFO selector stack).</summary>
        private void PreselectMiracleBondsBanishMaterials()
        {
            var group = BuildMiracleBondsBanishGroup();
            if (group.Count < 5)
                return;
            var rest = new List<ClientCard>();
            for (var i = 1; i < group.Count; i++)
                rest.Add(group[i]);
            AI.SelectCard(group[0]);
            AI.SelectNextCard(rest);
        }

        /// <summary>Passive ATK from Cloths <c>c922100303</c> will equip from GY on summon (zones + GY order).</summary>
        private int MiracleBondsGyClothAtkBonusIfSummoned()
        {
            var total = 0;
            foreach (var c in ChooseMiracleBondsGyClothClientChain(CountVacantMainSpellZonesForEquip()))
            {
                if (c != null)
                    total += BronzeClothPassiveAtkBuff(c.Id);
            }
            return total;
        }

        /// <summary>Queue one <see cref="CardSelector"/> per Lua <c>eqop</c> Select(1,1) (LIFO stack).</summary>
        private void PreselectMiracleBondsGyClothChain()
        {
            var maxEq = System.Math.Min(CountVacantMainSpellZonesForEquip(), 12);
            var picks = ChooseMiracleBondsGyClothClientChain(maxEq);
            if (picks.Count == 1)
                AI.SelectCard(picks[0]);
            else if (picks.Count > 1)
            {
                AI.SelectCard(picks[0]);
                for (var i = 1; i < picks.Count; i++)
                    AI.SelectNextCard(picks[i]);
            }
        }

        /// <summary>
        /// Distinct GY <see cref="Cloths"/> ClientCards in <see cref="BuildPayEquipClothOrder"/> priority, capped by free S/T zones (c922100303 while-loop).
        /// </summary>
        private List<ClientCard> ChooseMiracleBondsGyClothClientChain(int maxEquips)
        {
            var result = new List<ClientCard>();
            if (maxEquips <= 0 || Bot.Graveyard == null)
                return result;
            var used = new HashSet<ClientCard>();
            var order = BuildPayEquipClothOrder(CardId.Seiya);
            foreach (var clothId in order)
            {
                if (result.Count >= maxEquips)
                    break;
                foreach (var c in Bot.Graveyard)
                {
                    if (c == null || used.Contains(c) || !c.IsCode(clothId) || !Cloths.Contains(c.Id))
                        continue;
                    used.Add(c);
                    result.Add(c);
                    break;
                }
            }
            return result;
        }

        private int ChooseSaintToMaximizeDistinct()
        {
            var onField = new HashSet<int>(Bot.MonsterZone.Where(c => c != null && c.IsFaceup()).Select(c => c.Id));
            foreach (var id in Lv4Saints)
                if (!onField.Contains(id) && Bot.GetRemainingCount(id, 3) > 0)
                    return id;
            return CardId.Seiya;
        }

        /// <summary>
        /// Deck → hand L4 Saint picks (Cloth discard, Seiya, Athena's Call, Raise Your Cosmos).
        /// With a Saint already out, Jabu is a free Special Summon + Cloth from GY — grab him first if still in Deck.
        /// </summary>
        private int ChooseLv4SaintForDeckSearch()
        {
            var onField = new HashSet<int>(Bot.MonsterZone.Where(c => c != null && c.IsFaceup()).Select(c => c.Id));

            // User strategy: when searching a Saint, prefer Ban for SS lines.
            if (!onField.Contains(CardId.Ban)
                && !Bot.HasInHand(CardId.Ban)
                && Bot.GetRemainingCount(CardId.Ban, 3) > 0)
                return CardId.Ban;

            if (ControlAnySaint()
                && Bot.GetMonsterCount() < 5
                && !onField.Contains(CardId.Jabu)
                && !Bot.HasInHand(CardId.Jabu)
                && Bot.GetRemainingCount(CardId.Jabu, 3) > 0)
                return CardId.Jabu;
            return ChooseSaintToMaximizeDistinct();
        }

        private static bool IsSanctuaryFieldCard(ClientCard card)
        {
            if (card == null || !card.IsCode(CardId.AthenasSanctuary))
                return false;
            return (card.Location & CardLocation.FieldZone) != 0
                || (card.Location & CardLocation.SpellZone) != 0;
        }

        private bool IsAthenasSanctuaryOnField()
        {
            if (Bot.SpellZone == null)
                return false;
            foreach (var z in Bot.SpellZone)
            {
                if (z != null && z.IsCode(CardId.AthenasSanctuary))
                    return true;
            }
            return false;
        }

        /// <summary>c922100079 ignition: return Cloth only to re-equip on its paired Bronze Saint on field.</summary>
        private ClientCard ChooseSanctuaryClothReturnTarget()
        {
            ClientCard best = null;
            var bestScore = int.MinValue;
            foreach (var z in Bot.SpellZone)
            {
                if (z == null || z.IsCode(CardId.AthenasSanctuary) || !z.IsFaceup() || !Cloths.Contains(z.Id))
                    continue;
                var score = SanctuaryClothRePairScore(z);
                if (score > bestScore)
                {
                    bestScore = score;
                    best = z;
                }
            }
            return best;
        }

        private int SanctuaryClothRePairScore(ClientCard cloth)
        {
            if (!SanctuaryClothEligibleForRePair(cloth))
                return int.MinValue;
            var saintId = SaintMatchingCloth(cloth.Id).Value;
            var saint = GetFaceupBronzeSaintOnField(saintId);
            var host = cloth.EquipTarget;
            int score = 4000 + BronzeClothPassiveAtkBuff(cloth.Id);
            if (host != null && host.IsFaceup() && IsBronzeSaintWarriorId(host.Id) && host.Id != saintId)
                score += 2000;
            else if (host != null && host.IsFaceup() && !IsBronzeSaintWarriorId(host.Id))
                score += 1000;
            if (saint != null && saint.Attack < Util.GetBestAttack(Enemy))
                score += 500;
            return score;
        }

        private bool SanctuaryFieldClothReturnWorthActivating()
        {
            return ChooseSanctuaryClothReturnTarget() != null;
        }

        private bool IsMuDiscardSearchSanctuaryDescription(int d)
        {
            return MatchesCardEffectDesc(d, CardId.Mu, 1);
        }

        /// <summary>Mu ignition: search Sanctuary from Deck (first copy to Field, second as hand backup).</summary>
        private bool MuSanctuarySearchFromDeckWorthActivating()
        {
            if (Bot.GetRemainingCount(CardId.AthenasSanctuary, (int)CardLocation.Deck) <= 0)
                return false;
            if (!IsAthenasSanctuaryOnField())
                return true;
            return !Bot.Hand.IsExistingMatchingCard(c => c != null && c.IsCode(CardId.AthenasSanctuary));
        }

        /// <summary>c922100079: activate from hand, or Stringid 0 ignition to return Cloth to hand.</summary>
        private bool ActivateSanctuary()
        {
            if (!IsMainPhase() || Duel.Player != 0)
                return false;
            if (Card == null || !Card.IsCode(CardId.AthenasSanctuary))
                return false;

            if (IsSanctuaryFieldCard(Card))
            {
                if (!IsFieldSpellOptionalTriggerDesc((int)ActivateDescription, CardId.AthenasSanctuary, 0))
                    return false;
                return SanctuaryFieldClothReturnWorthActivating();
            }

            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (IsAthenasSanctuaryOnField())
                    return false;
                return true;
            }

            return false;
        }

        private bool ResolveSeiyaEquipLegality()
        {
            return Bot.LifePoints >= 500 && HasFreeMainSpellZoneForEquip() && HasClothInGraveyard();
        }

        private int[] BuildPayEquipClothOrder(int saintMonsterId)
        {
            var list = new List<int>();
            var pref = ClothMatchingSaint(saintMonsterId);
            if (pref.HasValue)
                list.Add(pref.Value);
            foreach (var id in Cloths)
                if (!list.Contains(id))
                    list.Add(id);
            return list.ToArray();
        }

        private bool ResolveSeiyaEquipFromGy()
        {
            if (!ResolveSeiyaEquipLegality())
                return false;
            var order = BuildPayEquipClothOrder(CardId.Seiya);
            var gyOnly = order.Where(id => Bot.Graveyard.IsExistingMatchingCard(c => c.IsCode(id))).ToArray();
            if (gyOnly.Length == 0)
                return false;
            AI.SelectCard(gyOnly);
            return true;
        }

        /// <summary>c922100000 Stringid 0 / str1 — on N/SS Deck search (EffectYn).</summary>
        private bool IsSeiyaOnSummonSearchPrompt(int desc)
        {
            if (MatchesCardEffectDesc(desc, CardId.Seiya, 1)
                || MatchesCardEffectDesc(desc, CardId.Seiya, 2)
                || MatchesCardEffectDesc(desc, CardId.Seiya, 3))
                return false;
            return IsOnSummonOptionalTriggerDesc(desc, CardId.Seiya, 0, 1, 2, 3);
        }

        private bool SeiyaOnSummonSearchHasDeckTarget()
        {
            foreach (var clothId in Cloths)
            {
                if (Bot.GetRemainingCount(clothId, (int)CardLocation.Deck) > 0)
                    return true;
            }
            foreach (var sid in Saints)
            {
                if (Bot.GetRemainingCount(sid, (int)CardLocation.Deck) > 0)
                    return true;
            }
            return false;
        }

        private void PreselectSeiyaDeckSearch()
        {
            if (!HasBronzeClothAccessSoon())
            {
                AI.SelectCard(new[]
                {
                    CardId.ClothCygnus,
                    CardId.ClothDragon,
                    CardId.ClothAndromeda,
                    CardId.ClothPhoenix,
                    CardId.ClothPegasus
                });
                return;
            }
            AI.SelectCard(ChooseLv4SaintForDeckSearch());
        }

        private bool ResolveSeiyaDeckSearch()
        {
            if (!SeiyaOnSummonSearchHasDeckTarget())
                return false;
            PreselectSeiyaDeckSearch();
            return true;
        }

        private bool ResolvePayEquipSaint(int saintMonsterId)
        {
            if (!IsMainPhase())
                return false;
            if (Bot.LifePoints < 500)
                return false;
            if (!HasFreeMainSpellZoneForEquip())
                return false;
            var order = BuildPayEquipClothOrder(saintMonsterId);
            var filtered = order.Where(ClothAccessibleFromGraveyard).ToArray();
            if (filtered.Length == 0)
                return false;
            AI.SelectCard(filtered);
            return true;
        }

        private bool ActivateAthenasCall()
        {
            if (!IsMainPhase())
                return false;

            // Guide: empty field → Kiki if NeedEquipForVerdict or no other starter in hand.
            if (FieldIsEmpty() && Bot.GetRemainingCount(CardId.Kiki, 3) > 0)
            {
                if (NeedEquipForVerdict() || !HasStarterInHandBesidesAthenasCall())
                {
                    TrySendCustomChat(0);
                    AI.SelectCard(CardId.Kiki);
                    return true;
                }
            }

            // Prefer Seiya as the best starter if available.
            if (!Bot.HasInHand(CardId.Seiya) && Bot.GetRemainingCount(CardId.Seiya, 3) > 0)
            {
                TrySendCustomChat(1);
                AI.SelectCard(CardId.Seiya);
                return true;
            }

            TrySendCustomChat(0);
            AI.SelectCard(ChooseLv4SaintForDeckSearch());
            return true;
        }

        /// <summary>Saints with on-Normal-Summon triggers (EVENT_SUMMON_SUCCESS).</summary>
        private static readonly HashSet<int> SaintsWithNSTrigger = new HashSet<int>
        {
            CardId.Seiya, // NS/SS → search Cloth/Spell from Deck
            CardId.Geki,  // NS/SS → pump ATK of all Saints
            CardId.Mu     // NS/SS → target equip Cloth from GY
        };

        /// <summary>Saints with useful on-field ignition effects (not NS trigger, but still valuable).</summary>
        private static readonly HashSet<int> SaintsWithIgnitionEffect = new HashSet<int>
        {
            CardId.Shiryu, // pay LP → equip from GY
            CardId.Hyoga,  // pay LP → equip from GY
            CardId.Ikki    // send Cloth to GY for advantage
        };

        private int NormalSummonPriority(int id)
        {
            // Seiya is always top: the deck's primary combo starter.
            if (id == CardId.Seiya) return 100;

            // NS/SS trigger Saints are next best.
            if (SaintsWithNSTrigger.Contains(id))
            {
                if (id == CardId.Mu && Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id)))
                {
                    if (!IsAthenasSanctuaryOnField() && Bot.GetRemainingCount(CardId.AthenasSanctuary, (int)CardLocation.Deck) > 0)
                        return 92;
                    return 90;
                }
                if (id == CardId.Geki)
                    return 85; // Geki pumps ATK on summon
                return 80;
            }

            // Saints with on-field ignition effects.
            if (SaintsWithIgnitionEffect.Contains(id))
            {
                if (id == CardId.Ikki) return 70;
                // Shiryu/Hyoga: ignition equip from GY — valuable if GY has Cloths.
                if (Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id)))
                    return 65;
                return 50;
            }

            // Vanilla bodies (Shun, Jabu, Ban, Ichi, Nachi) — value comes from distinct name count.
            bool isDistinctNameOnField = Bot.MonsterZone.IsExistingMatchingCard(c => c != null && c.IsFaceup() && c.IsCode(id));
            if (!isDistinctNameOnField) return 40;

            return 10; // duplicate name already on field
        }

        /// <summary>
        /// Unified Normal Summon handler. Only summons the current Card if it is the best
        /// candidate in hand according to NormalSummonPriority.
        /// </summary>
        private bool PrioritizedNormalSummon()
        {
            if (!IsMainPhase())
                return false;

            if (Bot.GetMonsterCount() >= 5)
                return false;

            int myPriority = NormalSummonPriority(Card.Id);

            // Check if any other Lv4 Saint in hand has strictly higher priority — if so, wait for that one.
            foreach (var c in Bot.Hand)
            {
                if (c == null) continue;
                if (c.Id == Card.Id) continue;
                if (!Lv4Saints.Contains(c.Id)) continue;
                if (NormalSummonPriority(c.Id) > myPriority)
                    return false;
            }

            // Board-development conditions (same logic as before).
            if (DistinctSaintNamesOnField() < 3)
                return true;

            int lv4InHand = Bot.Hand.Count(c => Lv4Saints.Contains(c.Id));
            if (lv4InHand >= 2 && Bot.GetMonsterCount() <= 3)
                return true;

            if (NeedEquipForVerdict() && Bot.GetMonsterCount() < 5)
                return true;

            if (!HasEquippedSaint()
                && Bot.Hand.IsExistingMatchingCard(c => Cloths.Contains(c.Id))
                && Bot.GetMonsterCount() < 4)
                return true;

            if (Bot.GetHandCount() >= 5)
                return true;

            if (Bot.Hand.IsExistingMatchingCard(c => c.IsCode(CardId.AthenaExclamation) || c.IsCode(CardId.PopesVerdict)))
                return true;

            return false;
        }

        /// <summary>
        /// Prefer FaceUpDefence when their strongest line threatens ATK mode but DEF mode walls better.
        /// <paramref name="combatAtk"/> = printed ATK + probable Bronze Cloth equip buff (hand and/or pay-from-GY).
        /// When Hydra (922100047) is an accessible equip, enemy ATK is discounted by a conservative margin (post-battle debuff).
        /// </summary>
        private bool PreferFaceUpDefenceSummon(int monsterId, int combatAtk, int defStat, IList<CardPosition> positions)
        {
            if (positions == null || !positions.Contains(CardPosition.FaceUpDefence))
                return false;

            int enemyBestAtk = AdjustedEnemyBestAttackForSizing(monsterId);

            // Classic wall: loses as attacker (combat ATK) but survives battle when defending (DEF vs their best ATK).
            if (enemyBestAtk > combatAtk && enemyBestAtk <= defStat)
                return true;

            // Solo body (no other monsters yet): do not leave ATK into their best attacker if DEF is legal.
            if (Bot.GetMonsterCount() == 0 && enemyBestAtk >= combatAtk)
                return true;

            // Multi-monster: any visible attacker beats our combat ATK — DEF avoids an unfavourable crash when attacked.
            if (AnyEnemyFaceUpBeatsCombatAtkConsideringHydra(monsterId, combatAtk))
                return true;

            return false;
        }

        public override CardPosition OnSelectPosition(int cardId, IList<CardPosition> positions)
        {
            var named = YGOSharp.OCGWrapper.NamedCard.Get(cardId);
            if (named != null && named.Attack == 0 && positions != null && positions.Contains(CardPosition.FaceUpDefence))
                return CardPosition.FaceUpDefence;

            int atkStat = Card != null ? Card.Attack : (named != null ? named.Attack : 0);
            int defStat = Card != null ? Card.Defense : (named != null ? named.Defense : 0);

            // Seiya Miracle Bonds (922100303): always Special Summon in face-up ATK.
            if (cardId == CardId.SeiyaMiracleBonds
                && positions != null
                && positions.Contains(CardPosition.FaceUpAttack))
                return CardPosition.FaceUpAttack;

            int clothBonus = ProbableBronzeClothAtkBonusAfterSummon(cardId);
            int combatAtkSaint = atkStat + clothBonus;

            // Shun + Andromeda Cloth (922100044): DEF unlocks the "protect other monsters / freeze SS'd monsters" line;
            // ATK enables declaring attacks including direct attack while equipped.
            if (cardId == CardId.Shun && positions != null)
            {
                bool andromedaSoon = Bot.Hand.IsExistingMatchingCard(c => c.IsCode(CardId.ClothAndromeda))
                    || Bot.SpellZone.Any(z => z != null && z.IsCode(CardId.ClothAndromeda));
                if (andromedaSoon)
                {
                    if (Bot.GetMonsterCount() >= 1 && positions.Contains(CardPosition.FaceUpDefence))
                        return CardPosition.FaceUpDefence;

                    if (Bot.GetMonsterCount() == 0 && positions.Contains(CardPosition.FaceUpAttack))
                    {
                        int enemyBest = AdjustedEnemyBestAttackForSizing(CardId.Shun);
                        if (enemyBest <= combatAtkSaint || Enemy.LifePoints <= 2500)
                            return CardPosition.FaceUpAttack;
                    }
                }
            }

            if (PreferFaceUpDefenceSummon(cardId, combatAtkSaint, defStat, positions))
                return CardPosition.FaceUpDefence;

            return base.OnSelectPosition(cardId, positions);
        }

        private bool ResolveSeiyaEffect()
        {
            if (Card == null || !Card.IsCode(CardId.Seiya))
                return false;

            var d = (int)ActivateDescription;

            // Hand — Stringid 1 / str2: SS if you control no monsters.
            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (!IsMainPhase())
                    return false;
                if (!MatchesCardEffectDesc(d, CardId.Seiya, 1))
                    return false;
                return FieldIsEmpty() && Bot.GetMonsterCount() < 5;
            }

            // On N/SS search — EffectYn (not Main-Phase-only; MMZ may lag during trigger).
            if (IsSeiyaOnSummonSearchPrompt(d))
                return ResolveSeiyaDeckSearch();

            // Field ignition — Stringid 2 / str3: pay 500; equip Cloth from GY.
            if ((Card.Location & CardLocation.MonsterZone) != 0
                && MatchesCardEffectDesc(d, CardId.Seiya, 2))
            {
                if (!IsMainPhase())
                    return false;
                return ResolveSeiyaEquipFromGy();
            }

            return false;
        }

        private bool IsCygnusNegateIgnitionForCard(ClientCard clothCard)
        {
            if (clothCard == null || !clothCard.IsCode(CardId.ClothCygnus))
                return false;
            if ((clothCard.Location & CardLocation.SpellZone) == 0)
                return false;
            return MatchesCardEffectDesc((int)ActivateDescription, CardId.ClothCygnus, 1);
        }

        /// <summary>Opponent MMZ — any face-up monster (Lua allows any face-up card; executor ranks threats).</summary>
        private static bool CygnusNegateValidOpponentMonster(ClientCard c)
        {
            if (c == null || !c.IsFaceup())
                return false;
            return (c.Location & CardLocation.MonsterZone) != 0;
        }

        /// <summary>Opponent S/T zones — any face-up Spell/Trap (matches permissive c922100043.lua negfilter).</summary>
        private static bool CygnusNegateValidOpponentSpellTrap(ClientCard c)
        {
            if (c == null || !c.IsFaceup())
                return false;
            if ((c.Location & CardLocation.MonsterZone) != 0)
                return false;
            if ((c.Location & CardLocation.SpellZone) == 0 && (c.Location & CardLocation.FieldZone) == 0)
                return false;
            return c.HasType(CardType.Spell) || c.HasType(CardType.Trap);
        }

        private static int CygnusSpellTrapNegatePriority(ClientCard c)
        {
            int p = 0;
            if (c.HasType(CardType.Field)) p += 480;
            if (c.HasType(CardType.Continuous)) p += 360;
            if (c.HasType(CardType.Pendulum)) p += 260;
            if (c.HasType(CardType.Equip)) p += 140;
            if (c.HasType(CardType.QuickPlay)) p += 90;
            if (p == 0 && (c.HasType(CardType.Spell) || c.HasType(CardType.Trap))) p += 50;
            return p;
        }

        private static int CygnusMonsterNegatePriority(ClientCard m, ClientCard preferredProblem)
        {
            int a = m.Attack;
            if (a < 0)
                a = 0;
            int bonus = (preferredProblem != null && ReferenceEquals(m, preferredProblem)) ? 450 : 0;
            if (m.HasType(CardType.Effect))
                bonus += 120;
            return a + bonus;
        }

        /// <summary>Negate target for Bronze Cloth - Cygnus (executor picks best face-up S/T vs monster).</summary>
        private ClientCard ChooseCygnusNegateTarget()
        {
            ClientCard bestSt = null;
            int bestStP = -1;
            var sz = Enemy.SpellZone;
            if (sz != null)
            {
                for (var z = 0; z < sz.Length; z++)
                {
                    var c = sz[z];
                    if (!CygnusNegateValidOpponentSpellTrap(c))
                        continue;
                    int p = CygnusSpellTrapNegatePriority(c);
                    try
                    {
                        var probS = Util.GetProblematicEnemySpell();
                        if (probS != null && ReferenceEquals(c, probS))
                            p += 520;
                    }
                    catch
                    {
                    }
                    if (p > bestStP)
                    {
                        bestStP = p;
                        bestSt = c;
                    }
                }
            }

            ClientCard bestM = null;
            int bestMP = -1;
            ClientCard preferredMon = null;
            try
            {
                preferredMon = Util.GetProblematicEnemyMonster();
            }
            catch
            {
            }
            foreach (var m in Enemy.MonsterZone)
            {
                if (!CygnusNegateValidOpponentMonster(m))
                    continue;
                int p = CygnusMonsterNegatePriority(m, preferredMon);
                if (p > bestMP)
                {
                    bestMP = p;
                    bestM = m;
                }
            }

            if (bestSt == null)
                return bestM;
            if (bestM == null)
                return bestSt;
            if (bestStP < 220 && bestMP >= 2100)
                return bestM;
            if (bestMP >= bestStP + 900)
                return bestM;
            return bestSt;
        }

        /// <summary>
        /// Bronze Cloth effects (updated):
        /// - Hand: activate to equip to a face-up Saint (Stringid 0).
        /// - S/T zone: Cygnus negate (Stringid 1) biases target in OnPreActivate; other on-field cloth effects — engine handles.
        /// - GY trigger: add 1 Level 4 or lower "Bronze Saint" from Deck to hand (Deck only; Lua gythfilter).
        ///   Triggers from anywhere (not just S/T zone). OPYOT applies per cloth.
        /// </summary>
        private bool ResolveClothActivate()
        {
            if (!Cloths.Contains(Card.Id))
                return false;

            // Hand → activate as Equip Spell (equip to a Saint you control).
            if ((Card.Location & CardLocation.Hand) != 0)
                return ActivateBronzeClothEquipFromHand();

            // GY → "sent to the GY" trigger: search a L4-or-lower Bronze Saint from Deck only.
            if ((Card.Location & CardLocation.Grave) != 0)
            {
                var gyIdx = BronzeClothGySearchStringIndex(Card.Id);
                if (Card.Id == CardId.ClothPhoenix)
                {
                    if (!IsGraveOptionalTriggerDesc((int)ActivateDescription, Card.Id, gyIdx, 0, 1, 2))
                        return false;
                }
                else if (!IsGraveOptionalTriggerDesc((int)ActivateDescription, Card.Id, gyIdx, 0, 1))
                    return false;
                return ResolveClothGySentSearch();
            }

            // S/T zone: Cygnus negate needs a legal target; others (Wolf, etc.) — engine handles.
            if ((Card.Location & CardLocation.SpellZone) != 0)
            {
                if (IsCygnusNegateIgnitionForCard(Card) && ChooseCygnusNegateTarget() == null)
                    return false;
                return true;
            }

            return false;
        }

        private bool ActivateBronzeClothEquipFromHand()
        {
            if (!IsMainPhase())
                return false;
            if (!ControlAnySaint())
                return false;
            if (!HasFreeMainSpellZoneForEquip())
                return false;

            // Prefer equipping the paired Saint for maximum synergy.
            ClientCard target = null;
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || !m.IsFaceup())
                    continue;
                var paired = ClothMatchingSaint(m.Id);
                if (paired.HasValue && paired.Value == Card.Id)
                {
                    target = m;
                    break;
                }
            }

            if (target == null)
                target = Bot.MonsterZone.FirstOrDefault(c => c != null && c.IsFaceup() && Saints.Contains(c.Id));

            if (target == null)
                return false;

            AI.SelectCard(target);
            return true;
        }

        /// <summary>
        /// Bronze Cloth GY trigger: add 1 Level 4 or lower "Bronze Saint" from Deck (Deck only; see c922100041.lua gythfilter).
        /// Fires when sent from anywhere, so always accept and pick the best target still in Deck.
        /// </summary>
        private bool ResolveClothGySentSearch()
        {
            AI.SelectCard(ChooseLv4BronzeSaintForClothDeckSearch());
            return true;
        }

        /// <summary>True if a copy of this Bronze Saint can still be added from the Deck (Cloth GY search is Deck-only).</summary>
        private bool BronzeSaintAvailableInDeckForClothSearch(int id)
        {
            return Bot.GetRemainingCount(id, 3) > 0;
        }

        /// <summary>
        /// Picks the best L4-or-lower Bronze Saint to add from the Deck (Cloth GY trigger).
        /// Same priority heuristics as before, but only cards still in Deck are valid.
        /// </summary>
        private int ChooseLv4BronzeSaintForClothDeckSearch()
        {
            var onField = new HashSet<int>(Bot.MonsterZone.Where(c => c != null && c.IsFaceup()).Select(c => c.Id));
            var inHand = new HashSet<int>(Bot.Hand.Where(c => c != null).Select(c => c.Id));

            // Empty field: Seiya is the best combo starter (summon-search + self-SS).
            if (FieldIsEmpty()
                && !inHand.Contains(CardId.Seiya) && BronzeSaintAvailableInDeckForClothSearch(CardId.Seiya))
                return CardId.Seiya;

            // Ban priority for SS lines.
            if (!onField.Contains(CardId.Ban) && !inHand.Contains(CardId.Ban) && BronzeSaintAvailableInDeckForClothSearch(CardId.Ban))
                return CardId.Ban;

            // Jabu for free SS when we already control a Saint.
            if (ControlAnySaint()
                && Bot.GetMonsterCount() < 5
                && !onField.Contains(CardId.Jabu) && !inHand.Contains(CardId.Jabu) && BronzeSaintAvailableInDeckForClothSearch(CardId.Jabu))
                return CardId.Jabu;

            // Distinct name we don't yet control.
            foreach (var id in Lv4Saints)
                if (!onField.Contains(id) && !inHand.Contains(id) && BronzeSaintAvailableInDeckForClothSearch(id))
                    return id;

            return ChooseSaintToMaximizeDistinct();
        }

        private bool ActivateRaiseYourCosmos()
        {
            if (!IsMainPhase())
                return false;

            if (DistinctSaintNamesOnField() >= 3)
                return false;

            // Send Ikki by default for revival lines.
            AI.SelectCard(CardId.Ikki);
            // Add a different-name Saint to hand.
            AI.SelectNextCard(ChooseLv4SaintForDeckSearch());
            return true;
        }

        private bool ResolveKikiActivate()
        {
            if ((Card.Location & CardLocation.Hand) != 0)
                return ActivateKikiEquip();
            if ((Card.Location & CardLocation.Grave) != 0 && Duel.Phase == DuelPhase.Standby)
                return Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id));
            return false;
        }

        private bool ActivateKikiEquip()
        {
            // Kiki (hand): discard -> equip a Cloth from Deck/GY to a Saint you control.
            // Guide: key line to turn on Verdict (NeedEquipForVerdict).
            if (!IsMainPhase())
                return false;

            if (!ControlAnySaint())
                return false;

            // Pick equip target: Shun (sticky) > Seiya (pressure) > Shiryu (defensive)
            var target = Bot.MonsterZone.FirstOrDefault(c => c != null && c.IsFaceup() && c.IsCode(CardId.Shun))
                         ?? Bot.MonsterZone.FirstOrDefault(c => c != null && c.IsFaceup() && c.IsCode(CardId.Seiya))
                         ?? Bot.MonsterZone.FirstOrDefault(c => c != null && c.IsFaceup() && c.IsCode(CardId.Shiryu))
                         ?? Bot.MonsterZone.FirstOrDefault(c => c != null && c.IsFaceup() && Saints.Contains(c.Id));

            if (target == null)
                return false;

            TrySendCustomChat(2, target.Name);
            AI.SelectCard(target);

            AI.SelectNextCard(BuildKikiClothPriorityForTarget(target));

            return true;
        }

        private bool ResolveShiryuActivate()
        {
            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (!MatchesCardEffectDesc((int)ActivateDescription, CardId.Shiryu, 0))
                    return false;
                if (Duel.Player == 0)
                    return false;
                // Updated script: discard from hand gives our "Cloth" cards indestructible by card effects this turn.
                // Do NOT burn this from hand unless a chain is actually threatening a face-up Cloth we control.
                if (ChainIsEmpty())
                    return false;
                // Only react to opponent's effects — ignore our own equips/spells targeting Cloths.
                if (!IsLastChainFromOpponent())
                    return false;
                if (Bot.SpellZone.Any(z =>
                    z != null && z.IsFaceup() && Cloths.Contains(z.Id) && Util.IsChainTarget(z)))
                    return true;
                // Soft rule: only against opponent Spell/Trap that looks like a wipe/removal; requires readable chain type+name.
                return IsOpponentSpellTrapWipeLikeChain()
                       && Bot.SpellZone.Any(z => z != null && z.IsFaceup() && Cloths.Contains(z.Id));
            }
            if (!IsMainPhase())
                return false;
            if ((Card.Location & CardLocation.MonsterZone) == 0)
                return false;
            if (MatchesCardEffectDesc((int)ActivateDescription, CardId.Shiryu, 1))
                return ResolvePayEquipSaint(CardId.Shiryu);
            return false;
        }

        private bool ResolveHyogaActivate()
        {
            if (!IsMainPhase())
                return false;
            if ((Card.Location & CardLocation.MonsterZone) == 0)
                return false;
            if (MatchesCardEffectDesc((int)ActivateDescription, CardId.Hyoga, 1))
                return ResolvePayEquipSaint(CardId.Hyoga);
            return false;
        }

        private bool ResolveShunActivate()
        {
            if (!IsMainPhase())
                return false;
            if ((Card.Location & CardLocation.MonsterZone) == 0)
                return false;
            if (MatchesCardEffectDesc((int)ActivateDescription, CardId.Shun, 0))
                return ResolvePayEquipSaint(CardId.Shun);
            return false;
        }

        private bool SummonMu()
        {
            if (!IsMainPhase())
                return false;
            if (Bot.GetMonsterCount() >= 5)
                return false;
            if (!ControlAnySaint())
                return false;
            if (!Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id)))
                return false;
            // With 2× Mu in deck: allow NS even when hand is thin if another Mu remains in hand.
            if (Bot.GetRemainingCount(CardId.Mu, (int)CardLocation.Hand) >= 2)
                return true;
            return Bot.GetHandCount() > 1;
        }

        private bool ResolveMuEffect()
        {
            var d = (int)ActivateDescription;

            // Stringid 1: discard Mu from MMZ; add "Athena's Sanctuary" (922100079) from Deck (c922100010.lua).
            if ((Card.Location & CardLocation.MonsterZone) != 0
                && IsMuDiscardSearchSanctuaryDescription(d))
            {
                if (!IsMainPhase())
                    return false;
                return MuSanctuarySearchFromDeckWorthActivating();
            }

            // Stringid 0 / str1: on N/SS — add Cloths from GY (EffectYn; not Main-Phase-only).
            if (IsOnSummonOptionalTriggerDesc(d, CardId.Mu, 0, 1)
                && Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id)))
            {
                AI.SelectCard(Cloths);
                return true;
            }

            return false;
        }

        /// <summary>c922100303 Stringid 1 — after Fusion Summon equip Cloths from GY (EffectYn).</summary>
        private bool IsMiracleBondsGyEquipPrompt(int desc)
        {
            if (MatchesCardEffectDesc(desc, CardId.SeiyaMiracleBonds, 0))
                return false;
            return IsOnSummonOptionalTriggerDesc(desc, CardId.SeiyaMiracleBonds, 1, 0);
        }

        /// <summary>
        /// <c>c922100303.lua</c> Stringid 1: optional equip all legal <see cref="Cloths"/> from GY after Fusion Summon.
        /// Routed via <c>OnSelectEffectYn</c> (desc often -1) — do not gate on MMZ sync or Main Phase only.
        /// </summary>
        private bool ActivateSeiyaMiracleBonds()
        {
            if (Card == null || !Card.IsCode(CardId.SeiyaMiracleBonds))
                return false;

            // Stringid 0: alternate Fusion from Extra (banish 5) — only <see cref="SpSummonSeiyaMiracleBondsFromExtra"/>.
            if ((Card.Location & CardLocation.Extra) != 0)
                return false;

            if (Duel.Player != 0)
                return false;

            if ((Card.Location & CardLocation.Hand) != 0
                || (Card.Location & CardLocation.Grave) != 0)
                return false;

            if (IsMiracleBondsGyEquipPrompt((int)ActivateDescription))
                return MiracleBondsGyEquipLegal();

            return false;
        }

        /// <summary>Some WindBot builds route hand ignition SS through SpSummon.</summary>
        private bool SpSummonJabuFromHandIfBridged()
        {
            if (!IsMainPhase())
                return false;
            if ((Card.Location & CardLocation.Hand) == 0)
                return false;
            return ControlAnySaint() && Bot.GetMonsterCount() < 5;
        }

        /// <summary>
        /// <c>c922100303.lua</c> Stringid 0: SS from Extra by banishing 1 Seiya + 4 Bronze Saints from MMZ/GY (Fusion Summon type).
        /// </summary>
        private bool SpSummonSeiyaMiracleBondsFromExtra()
        {
            if (Card == null || !Card.IsCode(CardId.SeiyaMiracleBonds))
                return false;
            if ((Card.Location & CardLocation.Extra) == 0)
                return false;
            if (!IsMainPhase() || Duel.Player != 0)
                return false;
            if (Bot.GetMonsterCount() >= 5)
                return false;
            if (!HasMiracleBondsSeiyaMaterialAccessible())
                return false;
            if (CountMiracleBondsBanishMaterialCards() < 5)
                return false;
            if (!MiracleBondsSpSummonMaterialsLegal())
                return false;
            if (!MiracleBondsFusionSummonWorthwhile())
                return false;
            PreselectMiracleBondsBanishMaterials();
            return true;
        }

        private static bool IsBronzeSaintWarriorId(int id)
        {
            for (var i = 0; i < Lv4Saints.Length; i++)
            {
                if (Lv4Saints[i] == id)
                    return true;
            }
            return false;
        }

        /// <summary>c922100005 Stringid 1 — after Special Summon (EffectYn; not Main-Phase-only).</summary>
        private bool IsJabuOnSpecialSummonClothPrompt(int desc)
        {
            if (MatchesCardEffectDesc(desc, CardId.Jabu, 0) || MatchesCardEffectDesc(desc, CardId.Jabu, 2))
                return false;
            return IsOnSummonOptionalTriggerDesc(desc, CardId.Jabu, 1, 0, 2);
        }

        private bool JabuSpecialSummonClothRecoveryLegal()
        {
            if (!HasClothInGraveyard())
                return false;
            return Bot.Hand != null && Bot.Hand.Count > 0;
        }

        private ClientCard ChooseBestClothFromGraveyard()
        {
            var order = BuildPayEquipClothOrder(CardId.Jabu);
            foreach (var clothId in order)
            {
                var c = Bot.Graveyard.FirstOrDefault(x => x != null && x.IsCode(clothId));
                if (c != null)
                    return c;
            }
            return Bot.Graveyard.FirstOrDefault(c => c != null && Cloths.Contains(c.Id));
        }

        private bool JabuMaterialClothEffectLegal()
        {
            if (Bot.SpellZone != null)
            {
                foreach (var z in Bot.SpellZone)
                {
                    if (z != null && z.IsFaceup() && Cloths.Contains(z.Id))
                        return true;
                }
            }
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || m.EquipCards == null)
                    continue;
                foreach (var eq in m.EquipCards)
                {
                    if (eq != null && eq.IsFaceup() && Cloths.Contains(eq.Id))
                        return true;
                }
            }
            return false;
        }

        private bool ResolveJabuActivate()
        {
            var d = (int)ActivateDescription;

            // Hand — Stringid 0 / str1: ignition SS if you control a Saint.
            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (!IsMainPhase())
                    return false;
                if (!MatchesCardEffectDesc(d, CardId.Jabu, 0))
                    return false;
                return ControlAnySaint() && Bot.GetMonsterCount() < 5;
            }

            // GY — Stringid 2 / str3: sent as Saint material → equip/attach face-up Cloth you control.
            if ((Card.Location & CardLocation.Grave) != 0)
            {
                if (!IsGraveOptionalTriggerDesc(d, CardId.Jabu, 2, 0, 1))
                    return false;
                return JabuMaterialClothEffectLegal();
            }

            // On SS — Stringid 1 / str2: add Cloth from GY, then discard (routes via OnSelectEffectYn).
            if (IsJabuOnSpecialSummonClothPrompt(d))
            {
                if (!JabuSpecialSummonClothRecoveryLegal())
                    return false;
                var cloth = ChooseBestClothFromGraveyard();
                if (cloth == null)
                    return false;
                AI.SelectCard(cloth);
                PreselectDiscardSaintPriority();
                return true;
            }

            return false;
        }

        private bool ResolveIkkiEffect()
        {
            if (!IsMainPhase())
                return false;

            var d = (int)ActivateDescription;

            // Field: pay 500 LP; equip 1 "Cloth" from GY (Stringid 1 / str2).
            if ((Card.Location & CardLocation.MonsterZone) != 0)
            {
                if (!MatchesCardEffectDesc(d, CardId.Ikki, 1))
                    return false;
                return ResolvePayEquipSaint(CardId.Ikki);
            }

            // GY: discard 1 "Saint" → Special Summon (Stringid 0 / str1).
            if ((Card.Location & CardLocation.Grave) == 0)
                return false;
            if (!MatchesCardEffectDesc(d, CardId.Ikki, 0))
                return false;

            if (DistinctSaintNamesOnField() >= 3)
                return false;

            if (!Bot.Hand.IsExistingMatchingCard(c => Saints.Contains(c.Id) && c.Id != CardId.Ikki))
                return false;

            // Ikki revive cost = discard 1 "Saint": prioritize Ichi, then Ban, then others.
            var discard = ChooseSaintDiscardFromHand(CardId.Ikki);
            if (discard.HasValue)
                AI.SelectCard(discard.Value);
            else
                AI.SelectCard(ChooseSaintToMaximizeDistinct());
            return true;
        }

        private int? ChooseSaintToAddFromGraveyard()
        {
            var gySaints = Bot.Graveyard.Where(c => c != null && Saints.Contains(c.Id)).ToList();
            if (gySaints.Count == 0)
                return null;

            // Prefer cards we don't already have in hand.
            int[] priority =
            {
                CardId.Seiya,
                CardId.Ichi,
                CardId.Ikki,
                CardId.Ban,
                CardId.Jabu,
                CardId.Shun,
                CardId.Hyoga,
                CardId.Shiryu,
                CardId.Nachi,
                CardId.Geki,
                CardId.Mu,
                CardId.Kiki
            };

            foreach (var id in priority)
                if (!Bot.HasInHand(id) && gySaints.Any(c => c.IsCode(id)))
                    return id;

            return gySaints[0].Id;
        }

        private ClientCard ChooseSaintClientCardFromGraveyard()
        {
            var id = ChooseSaintToAddFromGraveyard();
            if (!id.HasValue)
                return null;
            return Bot.Graveyard.FirstOrDefault(c => c != null && c.IsCode(id.Value));
        }

        /// <summary>c922100008 Stringid 1 — on SS add Saint from GY (texts.str2); any turn/phase; not hand/GY prompts.</summary>
        private bool IsBanOnSpecialSummonSaintSearchEffectYn(int desc)
        {
            if (MatchesCardEffectDesc(desc, CardId.Ban, 0) || MatchesCardEffectDesc(desc, CardId.Ban, 2))
                return false;
            if (MatchesCardEffectDesc(desc, CardId.Ban, 1))
                return true;
            for (var i = 0; i < 8; i++)
            {
                if (i == 1)
                    continue;
                if (MatchesCardEffectDesc(desc, CardId.Ban, i))
                    return false;
            }
            if (Card == null)
                return false;
            if ((Card.Location & CardLocation.Hand) != 0 || (Card.Location & CardLocation.Grave) != 0)
                return false;
            return true;
        }

        private bool BanSpecialSummonSaintRecoveryLegal()
        {
            return ChooseSaintClientCardFromGraveyard() != null;
        }

        private bool ResolveBanActivate()
        {
            var d = (int)ActivateDescription;

            // On SS — Stringid 1: add Saint from GY (before hand path; EffectYn may predate MMZ sync).
            if (IsBanOnSpecialSummonSaintSearchEffectYn(d))
            {
                if (!BanSpecialSummonSaintRecoveryLegal())
                    return false;
                var saint = ChooseSaintClientCardFromGraveyard();
                if (saint == null)
                    return false;
                AI.SelectCard(saint);
                return true;
            }

            // Hand: EVENT_BATTLE_DESTROYED → SS self (Stringid 0 / str1).
            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (MatchesCardEffectDesc(d, CardId.Ban, 1) || MatchesCardEffectDesc(d, CardId.Ban, 2))
                    return false;
                return true;
            }

            if ((Card.Location & CardLocation.Grave) != 0)
                return false;

            return false;
        }

        /// <summary>Cloth value tier for discard/shuffle ordering (still used by Ichi/Nachi/etc.).</summary>
        private static int ClothValueTier(int clothId)
        {
            switch (clothId)
            {
                case CardId.ClothWolf:
                case CardId.ClothLionet:
                case CardId.ClothBear:
                case CardId.ClothHydra:
                    return 0;
                case CardId.ClothPegasus:
                case CardId.ClothUnicorn:
                case CardId.ClothPhoenix:
                    return 1;
                case CardId.ClothAndromeda:
                case CardId.ClothDragon:
                case CardId.ClothCygnus:
                    return 2;
                default:
                    return 1;
            }
        }

        private int? ChooseClothFromHandToDiscard()
        {
            var inHand = Bot.Hand.Where(c => c != null && Cloths.Contains(c.Id)).ToList();
            if (inHand.Count == 0)
                return null;
            // Discard the least valuable Cloth first (highest tier number).
            var best = inHand
                .OrderByDescending(c => ClothValueTier(c.Id))
                .First();
            return best.Id;
        }

        private int? ChooseClothFromDeckToSendToGraveyard()
        {
            // Prefer sending the matching Cloth for a face-up Bronze Saint we control, if that Cloth isn't in GY yet.
            foreach (var m in Bot.MonsterZone.Where(c => c != null && c.IsFaceup() && Lv4Saints.Contains(c.Id)))
            {
                var match = ClothMatchingSaint(m.Id);
                if (match.HasValue
                    && Bot.GetRemainingCount(match.Value, 3) > 0
                    && !Bot.Graveyard.IsExistingMatchingCard(g => g.IsCode(match.Value)))
                    return match.Value;
            }

            // Otherwise seed Phoenix (commonly useful) if available.
            if (Bot.GetRemainingCount(CardId.ClothPhoenix, 3) > 0)
                return CardId.ClothPhoenix;

            // Fallback to any Cloth remaining in deck.
            foreach (var id in Cloths)
                if (Bot.GetRemainingCount(id, 3) > 0)
                    return id;

            return null;
        }

        private int? ChooseClothFromGraveyardToHand()
        {
            // Prefer matching Cloth for any face-up Saint we control.
            foreach (var m in Bot.MonsterZone.Where(c => c != null && c.IsFaceup() && Saints.Contains(c.Id)))
            {
                var match = ClothMatchingSaint(m.Id);
                if (match.HasValue && Bot.Graveyard.IsExistingMatchingCard(g => g.IsCode(match.Value)))
                    return match.Value;
            }

            // Otherwise take highest tier Cloth (more flexible utility) first.
            var gy = Bot.Graveyard.Where(c => c != null && Cloths.Contains(c.Id)).ToList();
            if (gy.Count == 0)
                return null;
            return gy.OrderByDescending(c => ClothValueTier(c.Id)).First().Id;
        }

        private int? ChooseClothFromGraveyardToShuffle()
        {
            // Prefer shuffling back low-value Cloths (highest tier).
            var gy = Bot.Graveyard.Where(c => c != null && Cloths.Contains(c.Id)).ToList();
            if (gy.Count == 0)
                return null;
            return gy.OrderByDescending(c => ClothValueTier(c.Id)).First().Id;
        }

        private bool ResolveIchiActivate()
        {
            var d = (int)ActivateDescription;

            // Field ignition: discard 1 Cloth -> burn 800 (Stringid 0 / str1).
            if ((Card.Location & CardLocation.MonsterZone) != 0)
            {
                if (!IsMainPhase())
                    return false;
                if (!MatchesCardEffectDesc(d, CardId.Ichi, 0))
                    return false;

                var discardCloth = ChooseClothFromHandToDiscard();
                if (!discardCloth.HasValue)
                    return false;

                // Heuristic: use burn when we have spare Cloths or it meaningfully closes the game.
                bool lethalish = Enemy.LifePoints <= 2000;
                bool spare = Bot.Hand.Count(c => c != null && Cloths.Contains(c.Id)) >= 2;
                if (!lethalish && !spare)
                    return false;

                AI.SelectCard(discardCloth.Value);
                return true;
            }

            // Trigger in GY: send 1 Cloth from Deck to GY (Stringid 1).
            if ((Card.Location & CardLocation.Grave) != 0)
            {
                // Custom builds sometimes report ActivateDescription inconsistently for delayed triggers.
                // Hard block the "material" trigger (Stringid 2) to avoid selecting from the wrong location.
                if (MatchesCardEffectDesc(d, CardId.Ichi, 2))
                    return false;
                if (!IsGraveOptionalTriggerDesc(d, CardId.Ichi, 1, 0, 2))
                    return false;
                var send = ChooseClothFromDeckToSendToGraveyard();
                if (!send.HasValue)
                    return false;
                AI.SelectCard(send.Value);
                return true;
            }

            return false;
        }

        private bool ResolveGekiActivate()
        {
            var d = (int)ActivateDescription;

            // On-summon search (Stringid 0 / str1): no Level 5+ Saints in this build — skip.
            if (IsOnSummonOptionalTriggerDesc(d, CardId.Geki, 0, 1))
                return false;

            // GY ignition (Stringid 1 / str2): add 1 Cloth from GY, then banish self.
            if ((Card.Location & CardLocation.Grave) != 0)
            {
                if (!IsMainPhase())
                    return false;
                if (!MatchesCardEffectDesc(d, CardId.Geki, 1))
                    return false;
                var pick = ChooseClothFromGraveyardToHand();
                if (!pick.HasValue)
                    return false;
                AI.SelectCard(pick.Value);
                return true;
            }

            return false;
        }

        private bool ResolveNachiActivate()
        {
            var d = (int)ActivateDescription;

            // GY — Stringid 0 / str1: sent as Link Material or Tributed -> draw 1, discard 1.
            if ((Card.Location & CardLocation.Grave) != 0)
            {
                if (MatchesCardEffectDesc(d, CardId.Nachi, 2))
                    return false;
                if (!IsGraveOptionalTriggerDesc(d, CardId.Nachi, 0, 1, 2))
                    return false;
                return Bot.GetHandCount() > 0;
            }

            // Ignition on field (Stringid 1 / str2): shuffle 1 Cloth from GY; draw 1.
            if ((Card.Location & CardLocation.MonsterZone) != 0)
            {
                if (!IsMainPhase())
                    return false;
                if (!MatchesCardEffectDesc(d, CardId.Nachi, 1))
                    return false;
                var pick = ChooseClothFromGraveyardToShuffle();
                if (!pick.HasValue)
                    return false;
                AI.SelectCard(pick.Value);
                return true;
            }

            return false;
        }

        private ClientCard ChooseSaintToProtect()
        {
            // Prefer protecting the equipped Saint (keeps Pope's Verdict live) then the highest ATK Saint.
            var equipped = Bot.MonsterZone.FirstOrDefault(m =>
                m != null && m.IsFaceup() && Saints.Contains(m.Id)
                && m.EquipCards != null
                && m.EquipCards.Any(eq => eq != null && eq.IsFaceup() && Cloths.Contains(eq.Id)));
            if (equipped != null)
                return equipped;

            ClientCard best = null;
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || !m.IsFaceup() || !Saints.Contains(m.Id))
                    continue;
                if (best == null || m.Attack > best.Attack)
                    best = m;
            }
            return best;
        }

        private ClientCard TryGetAttackedMonster()
        {
            // Some WindBot builds expose battle context on Duel (AttackTarget/GetAttackTarget).
            // Use reflection to stay compatible across ExecutorBase.dll variants.
            try
            {
                if (Duel == null)
                    return null;

                var t = Duel.GetType();
                var prop = t.GetProperty("AttackTarget");
                if (prop != null)
                {
                    var v = prop.GetValue(Duel, null) as ClientCard;
                    if (v != null)
                        return v;
                }

                var mGet = t.GetMethod("GetAttackTarget");
                if (mGet != null)
                {
                    var v = mGet.Invoke(Duel, null) as ClientCard;
                    if (v != null)
                        return v;
                }
            }
            catch
            {
                // ignore
            }
            return null;
        }

        private bool ActivateAthenasShield()
        {
            // 922100086 updated: quick-play that targets 1 Saint you control; it can't be destroyed this turn.
            // Also has a GY destroy-replacement that the engine handles (no executor action needed).
            //
            // User intent: activate in two cases:
            // - Our turn: in response to an effect that would destroy a Saint (chain window).
            // - Opponent turn: when they declare an attack on our monster (battle window).
            //
            // This plugin API doesn't expose attacker/attack target, so we approximate by phase + chain targets.

            if (!ControlAnySaint())
                return false;

            // Case 1: An opponent's chain currently targets one of our Saints (likely destruction/removal).
            if (!ChainIsEmpty())
            {
                // Only react to opponent's effects — ignore our own equips/spells targeting Saints.
                if (!IsLastChainFromOpponent())
                    return false;

                var target = Bot.MonsterZone.FirstOrDefault(m =>
                    m != null && m.IsFaceup() && Saints.Contains(m.Id) && Util.IsChainTarget(m));
                if (target == null)
                    target = ChooseSaintToProtect();
                if (target == null)
                    return false;
                AI.SelectCard(target);
                return true;
            }

            // Case 2: Opponent battle phase windows: protect a key Saint before damage.
            if (Duel.Player != 0)
            {
                switch (Duel.Phase)
                {
                    case DuelPhase.BattleStart:
                    case DuelPhase.BattleStep:
                    case DuelPhase.Damage:
                    case DuelPhase.DamageCal:
                    case DuelPhase.Battle:
                        // Prefer the actual attack target if the build exposes it.
                        var attacked = TryGetAttackedMonster();
                        if (attacked != null
                            && attacked.IsFaceup()
                            && Saints.Contains(attacked.Id)
                            && attacked.Controller == 0)
                        {
                            AI.SelectCard(attacked);
                            return true;
                        }
                        var protect = ChooseSaintToProtect();
                        if (protect == null)
                            return false;
                        AI.SelectCard(protect);
                        return true;
                }
            }

            // Don't waste it proactively on open Main.
            return false;
        }

        private bool ActivateBond()
        {
            // 922100092: protects a targeted Saint from opponent's effects (destruction/banish) this turn.
            // Avoid burning it pro-actively: only use when a chain targets one of our Saints.
            if (ChainIsEmpty())
                return false;

            // Only react to opponent's effects — ignore our own equips/spells targeting Saints.
            if (!IsLastChainFromOpponent())
                return false;

            var target = Bot.MonsterZone.FirstOrDefault(m =>
                m != null && m.IsFaceup() && Saints.Contains(m.Id) && Util.IsChainTarget(m));
            if (target == null)
            {
                // Soft rule: only against opponent Spell/Trap that looks like a wipe/removal; requires readable chain type+name.
                if (!IsOpponentSpellTrapWipeLikeChain())
                    return false;
                target = ChooseSaintToProtect();
                if (target == null)
                    return false;
            }

            AI.SelectCard(target);
            return true;
        }

        private bool ActivateCrystalWall()
        {
            // 922100101 updated: triggers on EVENT_ATTACK_ANNOUNCE (negate attack; bonus destroy if Mu is controlled).
            // Engine legality enforces: opponent's monster declares an attack AND the attack target is a "Saint".
            // We keep this lightweight so the AI doesn't miss the window (attack context is not exposed in this plugin API).
            if (Duel.Player == 0)
                return false;
            if (!ControlAnySaint())
                return false;
            // Avoid activating outside of battle windows (reduces pointless attempts).
            switch (Duel.Phase)
            {
                case DuelPhase.BattleStart:
                case DuelPhase.BattleStep:
                case DuelPhase.Damage:
                case DuelPhase.DamageCal:
                case DuelPhase.Battle:
                    return true;
                default:
                    return false;
            }
        }

        private bool ActivatePopesVerdict()
        {
            // 922100103 updated: only negates opponent Spell/Trap activations while an equipped Saint is controlled.
            if (Duel.Player == 0 || !HasEquippedSaint())
                return false;
            TrySendCustomChat(4);
            return true;
        }

        private bool ActivateAthenaExclamation()
        {
            // Guide: 082 when ≥3 distinct names and meaningful interaction (engine also gates legality).
            if (Duel.Player == 0 || DistinctSaintNamesOnField() < 3)
                return false;
            TrySendCustomChat(3);
            return true;
        }

        private bool SpellSetPolicy()
        {
            // Set counter traps at end of main phase if possible.
            if (!IsMainPhase())
                return false;

            // Cloths are now equips — prefer keeping them in hand for equipping, not setting face-down.
            if (Cloths.Contains(Card.Id))
                return false;

            if (Card.IsCode(CardId.PopesVerdict))
                return ControlAnySaint() || HasEquippedSaint();

            if (Card.IsCode(CardId.AthenaExclamation))
                return DistinctSaintNamesOnField() >= 3 || Bot.GetHandCount() >= 6;

            return DefaultSpellSet();
        }
    }
}

