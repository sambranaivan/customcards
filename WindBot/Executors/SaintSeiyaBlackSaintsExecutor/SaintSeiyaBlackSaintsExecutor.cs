using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using YGOSharp.OCGWrapper.Enums;
using WindBot;
using WindBot.Game;
using WindBot.Game.AI;

/*
================================================================================
WindBot — Saint Seiya Black Saints (custom deck)
Deck file: deck/Saint Seiya - Black Saints.ydk  ->  WindBot/Decks/AI_SaintSeiyaBlackSaints.ydk
Strategy reference: sets/saint_seiya/black_saints_effects.md + script/unofficial/c922100*.lua

Goals:
- Go first: establish Death Queen Island, mill/send Fragments, Normal Summon Jango or extenders,
  equip Fragments to Black Saints, set or activate The Heist / Oath of the Shadow (Continuous Spell), end with Ikki + Fragment lines when possible.
- Spend The Heist on meaningful opponent activations while a Black Saint wears a Fragment.
- Use Oath / Guilty / Esmeralda for recursion; Esmeralda (c922100168) also defends with Maiden-like Ikki SS when targeted (1 card effect/turn shared with her Deck search). Dark Andromeda for draw when Fragments move by effects.
- Boss (922100162): Fusion Summon from Extra (`SpSummon` + `CardLocation.Extra`) when **exactly 7 distinct Fragment names** on field/GY (c922100162.lua); **Activate** for post-SS GY equip is registered **first** so DQI/Stolen Gold/etc. do not win `ActivatableCards` first (`GameAI.OnSelectIdleCmd` executor order).
- While Boss remains in the Extra Deck and distinct Fragment count is under 7, mill/setup (Jango, Death Queen Island, Stolen Gold Cloth, Oath, Dark Dragon equip) bias missing Fragment names from Deck.
- Fragment / Jango GY search: `ChooseBlackSaintForDeckSearch()` — Boss when **exactly 7 distinct** on field/GY; Ikki when 3+ BS and still building Boss; then scores.

Maintenance: bump BuildVersion / BuildTag when behavior changes.
================================================================================
*/

namespace WindBot.Game.AI.Decks
{
    [Deck("SaintSeiyaBlackSaints", "AI_SaintSeiyaBlackSaints", "Normal")]
    public class SaintSeiyaBlackSaintsExecutor : DefaultExecutor
    {
        private const int BuildVersion = 31;
        private const string BuildTag = "2026-05-16-v31-boss-exactly-7-distinct-fragments";

        /// <summary>Distinct Fragment names on field/GY required to Fusion Summon Boss from Extra (c922100162.lua; must be exactly this count).</summary>
        private const int BossFragmentDistinctRequired = 7;

        /// <summary>Enemy face-up ATK at or above this → Main Phase Quick is allowed (with other gates).</summary>
        private const int FragmentQuickThreatAtkFloor = 1900;
        /// <summary>Skirt: opponent loses 500 ATK during damage calc only — conservative ATK margin vs their printed ATK.</summary>
        private const int FragmentSkirtBattleMarginAtk = 500;
        private static bool _buildTagLogged;

        public class CardId
        {
            public const int Ikki = 922100148;
            public const int Jango = 922100149;
            public const int DarkPegasus = 922100150;
            public const int DarkDragon = 922100151;
            public const int DarkCygnus = 922100152;
            public const int DarkAndromeda = 922100153;
            public const int DarkPhoenix = 922100154;

            public const int FragmentHelmet = 922100155;
            public const int FragmentChestplate = 922100156;
            public const int FragmentSkirt = 922100157;
            public const int FragmentLeftArm = 922100158;
            public const int FragmentRightArm = 922100159;
            public const int FragmentRightLeg = 922100160;
            public const int FragmentLeftLeg = 922100161;

            public const int BossReassembled = 922100162;
            public const int DeathQueenIsland = 922100163;
            public const int StolenGoldCloth = 922100164;
            public const int Heist = 922100165;
            public const int OathOfShadow = 922100166;
            public const int Esmeralda = 922100168;
            public const int Guilty = 922100169;
            public const int EsmeraldasLastWill = 922100170;
            public const int GuiltysCruelTrial = 922100171;
        }

        private static readonly int[] FragmentIds =
        {
            CardId.FragmentHelmet, CardId.FragmentChestplate, CardId.FragmentSkirt,
            CardId.FragmentLeftArm, CardId.FragmentRightArm, CardId.FragmentRightLeg,
            CardId.FragmentLeftLeg
        };

        private static readonly int[] BlackSaintMonsterIds =
        {
            CardId.Ikki, CardId.Jango, CardId.DarkPegasus, CardId.DarkDragon,
            CardId.DarkCygnus, CardId.DarkAndromeda, CardId.DarkPhoenix,
            CardId.Esmeralda, CardId.Guilty, CardId.BossReassembled
        };

        private static readonly int[] NormalSummonPriorityIds =
        {
            CardId.Jango, CardId.DarkPegasus, CardId.DarkDragon,
            CardId.DarkCygnus, CardId.DarkAndromeda, CardId.DarkPhoenix
        };

        public SaintSeiyaBlackSaintsExecutor(GameAI ai, Duel duel)
            : base(ai, duel)
        {
            if (!_buildTagLogged)
            {
                _buildTagLogged = true;
                try
                {
                    Logger.WriteLine(string.Format("[SaintSeiyaBlackSaintsExecutor] v{0} build={1}", BuildVersion, BuildTag));
                }
                catch { }
            }

            SilenceDefaultDialogs(ai);

            // Boss post-Fusion equip must win idle Main1 before field starters (DQI hand, Stolen Gold, etc.) — GameAI tries executors in order.
            AddExecutor(ExecutorType.Activate, CardId.BossReassembled, ActivateBossOnField);
            AddExecutor(ExecutorType.SpSummon, CardId.BossReassembled, SpSummonBossReassembled);

            AddExecutor(ExecutorType.Activate, CardId.Heist, ActivateHeist);
            // Esmeralda defenses must win SelectEffectYn / SelectChain before generic spell handlers.
            AddExecutor(ExecutorType.Activate, CardId.Esmeralda, ActivateEsmeralda);
            AddExecutor(ExecutorType.Activate, CardId.DeathQueenIsland, ActivateDeathQueenIsland);
            AddExecutor(ExecutorType.Activate, CardId.StolenGoldCloth, ActivateStolenGoldCloth);
            AddExecutor(ExecutorType.Activate, CardId.EsmeraldasLastWill, ActivateEsmeraldasLastWill);
            AddExecutor(ExecutorType.Activate, CardId.GuiltysCruelTrial, ActivateGuiltysCruelTrial);
            AddExecutor(ExecutorType.Activate, CardId.OathOfShadow, ActivateOathOfShadow);

            AddExecutor(ExecutorType.SpSummon, CardId.DarkPegasus, SpSummonDarkPegasusFromHand);
            // Main Phase SS from hand is IGNITION (Activatable), not always SpecialSummonable — keep Activate early.
            AddExecutor(ExecutorType.Activate, CardId.DarkPegasus, ActivateDarkPegasus);

            AddExecutor(ExecutorType.SpSummon, CardId.DarkPhoenix, SpSummonDarkPhoenixFromHand);
            AddExecutor(ExecutorType.SpSummon, CardId.Guilty, SpSummonGuiltyFromHand);
            AddExecutor(ExecutorType.SpSummon, CardId.Ikki, SpSummonIkkiFromHand);

            AddExecutor(ExecutorType.Summon, CardId.Esmeralda, PrioritizeEsmeraldaNormalSummon);

            AddExecutor(ExecutorType.Activate, CardId.Guilty, ActivateGuilty);
            AddExecutor(ExecutorType.Activate, CardId.Ikki, ActivateIkki);
            AddExecutor(ExecutorType.Activate, CardId.Jango, ActivateJango);
            AddExecutor(ExecutorType.Activate, CardId.DarkDragon, ActivateDarkDragon);
            AddExecutor(ExecutorType.Activate, CardId.DarkCygnus, ActivateDarkCygnus);
            AddExecutor(ExecutorType.Activate, CardId.DarkAndromeda, ActivateDarkAndromeda);
            AddExecutor(ExecutorType.Activate, CardId.DarkPhoenix, ActivateDarkPhoenix);

            foreach (var fid in FragmentIds)
                AddExecutor(ExecutorType.Activate, fid, ActivateAnyFragment);

            foreach (var mid in NormalSummonPriorityIds)
                AddExecutor(ExecutorType.Summon, mid, PrioritizedNormalSummon);

            AddExecutor(ExecutorType.SpellSet, SpellSetPolicy);
            AddExecutor(ExecutorType.Repos, DefaultMonsterRepos);
        }

        private static void SilenceDefaultDialogs(GameAI ai)
        {
            try
            {
                var dialogsField = ai.GetType().GetField("_dialogs",
                    BindingFlags.NonPublic | BindingFlags.Instance);
                if (dialogsField == null)
                    return;

                var dialogs = dialogsField.GetValue(ai);
                if (dialogs == null)
                    return;

                var empty = new string[0];
                var fieldNames = new[]
                {
                    "_welcome", "_deckerror", "_duelstart", "_newturn", "_endturn",
                    "_directattack", "_attack", "_ondirectattack",
                    "_activate", "_summon", "_setmonster", "_chaining"
                };

                var dtype = dialogs.GetType();
                foreach (var name in fieldNames)
                {
                    var f = dtype.GetField(name,
                        BindingFlags.NonPublic | BindingFlags.Instance);
                    if (f != null && f.FieldType == typeof(string[]))
                        f.SetValue(dialogs, empty);
                }
            }
            catch { }
        }

        public override bool OnSelectHand()
        {
            return true;
        }

        /// <summary>Target/no selections before activate; veto Esmeralda's Last Will outside Battle Phase.</summary>
        public override bool OnPreActivate(ClientCard card)
        {
            if (card != null
                && card.IsCode(CardId.EsmeraldasLastWill)
                && !IsBattlePhase())
                return false;

            if (card != null && card.IsCode(CardId.Esmeralda))
            {
                var d = (int)ActivateDescription;
                // Stringid 0: on-summon add Death Queen Island from Deck.
                if (IsEsmeraldaSummonSearchDescription(d))
                {
                    var searchId = ChooseEsmeraldaDeckSearchCardId();
                    if (searchId != 0)
                        AI.SelectCard(searchId);
                }
                // Ikki bias: opponent-turn defend + Quick (Stringid 1).
                else if ((card.Location & CardLocation.MonsterZone) != 0
                    && (IsOpponentTurn()
                        || IsEsmeraldaQuickIkkiActivateDescription()
                        || IsEsmeraldaBattleActivateDescription(d)))
                {
                    var ikki = ChooseEsmeraldaIkkiClientCardForSelectNext();
                    if (ikki != null)
                        AI.SelectNextCard(ikki);
                }
            }

            // Dark Dragon (c922100151) Stringid 0: on-summon equip Fragment from Deck.
            if (card != null
                && card.IsCode(CardId.DarkDragon)
                && (card.Location & CardLocation.MonsterZone) != 0)
            {
                var dDd = (int)ActivateDescription;
                var ddSummonEq = (int)Util.GetStringId(CardId.DarkDragon, 0);
                if (ddSummonEq == dDd || ((dDd == -1 || dDd == 0) && !DarkDragonHasEquipToSendAsCost()))
                {
                    var fragId = ChooseFragmentIdForDeckMill();
                    if (fragId != 0)
                        AI.SelectCard(fragId);
                }
            }

            // Death Queen Island (c922100163) Stringid 1: on-field ignition equip Fragment from GY to BS.
            if (card != null
                && card.IsCode(CardId.DeathQueenIsland)
                && (card.Location & CardLocation.Hand) == 0
                && ((card.Location & CardLocation.SpellZone) != 0
                    || (card.Location & CardLocation.FieldZone) != 0))
            {
                var dDqi = (int)ActivateDescription;
                var dqiEq = (int)Util.GetStringId(CardId.DeathQueenIsland, 1);
                if (dqiEq == dDqi || dDqi == -1 || dDqi == 0)
                {
                    var tgt = BestBlackSaintForEquip();
                    if (tgt != null)
                        AI.SelectCard(tgt);
                    var gyFrag = ChooseBestGraveFragmentCardForEquip(null);
                    if (gyFrag != null)
                        AI.SelectNextCard(gyFrag);
                }
            }

            // Boss (c922100162) Stringid 1: after Special Summon, equip up to 2 Fragments from GY.
            if (card != null
                && card.IsCode(CardId.BossReassembled)
                && (card.Location & CardLocation.MonsterZone) != 0)
            {
                var dBoss = (int)ActivateDescription;
                var bossEq = (int)Util.GetStringId(CardId.BossReassembled, 1);
                // texts.str* often empty for custom cards — GetStringId is 0 while engine sends a real id.
                if (bossEq == dBoss || dBoss == -1 || dBoss == 0 || bossEq == 0)
                {
                    // One MSG_SELECT_CARD with min=1 max=2: CardSelector(Card) only returns one pick; use IList to send both.
                    var maxPick = System.Math.Min(2, CountFreeSpellZones());
                    var picks = ChooseOrderedGraveFragmentsForBossEquip(maxPick);
                    if (picks.Count == 1)
                        AI.SelectCard(picks[0]);
                    else if (picks.Count > 1)
                        AI.SelectCard(picks);
                }
            }

            // Jango (c922100149) Stringid 0: send 1 Fragment from Deck to GY on summon.
            if (card != null
                && card.IsCode(CardId.Jango)
                && ActivateDescription == Util.GetStringId(CardId.Jango, 0))
            {
                var fragId = ChooseFragmentIdForDeckMill();
                if (fragId != 0)
                    AI.SelectCard(fragId);
            }

            // Ikki (c922100148) Stringid 2: on N/SS add 1 Fragment from Deck (e.g. after Esmeralda Quick/battle SS).
            if (card != null
                && card.IsCode(CardId.Ikki)
                && (card.Location & CardLocation.MonsterZone) != 0
                && IsIkkiMonsterZoneOnSummonSearchDescription((int)ActivateDescription))
            {
                var fragId = ChooseFragmentIdForDeckMill();
                if (fragId != 0)
                    AI.SelectCard(fragId);
            }

            // Death Queen Island / Stolen Gold Cloth: Deck→GY Fragment when activating those spells from **hand** (mill/setup).
            if (card != null && PursuingBossCombo())
            {
                if (card.IsCode(CardId.StolenGoldCloth))
                {
                    var fragId = ChooseMissingFragmentIdFromDeck();
                    if (fragId != 0)
                        AI.SelectCard(fragId);
                }
                if (card.IsCode(CardId.DeathQueenIsland) && (card.Location & CardLocation.Hand) != 0)
                {
                    var fragId = ChooseMissingFragmentIdFromDeck();
                    if (fragId != 0)
                        AI.SelectCard(fragId);
                }
            }

            return base.OnPreActivate(card);
        }

        /// <summary>
        /// Allow Normal Set only in "survive" lines; keep Jango face-up as the primary starter.
        /// </summary>
        public override bool OnSelectMonsterSummonOrSet(ClientCard card)
        {
            if (card == null)
                return false;

            if (Duel.Player != 0 || !IsMainPhase())
                return false;

            if (Bot.GetMonsterCount() != 0)
                return false;

            if (Enemy.GetMonsterCount() == 0)
                return false;

            if (card.IsCode(CardId.Jango))
                return false;

            int enemyBestAtk = Util.GetBestAttack(Enemy);
            if (enemyBestAtk <= 0)
                return false;

            if (enemyBestAtk > card.Defense)
                return true;

            // Esmeralda: never Set — Normal Summon face-up ATK for c922100168 protection lines.
            if (card.IsCode(CardId.Esmeralda))
                return false;

            return false;
        }

        /// <summary>
        /// Esmeralda (c922100168): Normal Summon face-up ATK (negate attack / Ikki when targeted).
        /// Jango still opens on empty field when available.
        /// </summary>
        private bool PrioritizeEsmeraldaNormalSummon()
        {
            if (!IsMainPhase() || Duel.Player != 0)
                return false;
            if (!Card.IsCode(CardId.Esmeralda))
                return false;
            if ((Card.Location & CardLocation.Hand) == 0)
                return false;
            if (Bot.GetMonsterCount() >= 5)
                return false;

            if (Bot.HasInHand(CardId.Jango) && Bot.GetMonsterCount() == 0 && !ControlAnyBlackSaintFaceUp())
                return false;

            if (PursuingBossCombo() && Bot.HasInHand(CardId.Jango))
                return false;

            return true;
        }

        /// <summary>
        /// Prefer FaceUpDefence when their strongest line threatens ATK mode but DEF walls better (or solo lines).
        /// For Black Saints, projects equip ATK/DEF from Fragments in hand + free S/T zones (see card Lua EFFECT_UPDATE_ATTACK).
        /// If Skirt is among the greedy top-<c>k</c> equips from hand, adds <see cref="FragmentSkirtBattleMarginAtk"/> for battle ATK comparisons (Skirt damage-step −500 to opponent).
        /// </summary>
        private bool PreferFaceUpDefenceSummon(int atkStat, int defStat, IList<CardPosition> positions, int monsterCardId)
        {
            if (positions == null || !positions.Contains(CardPosition.FaceUpDefence))
                return false;

            // Esmeralda wants ATK to draw attacks/effects (Maiden-like protection).
            if (monsterCardId == CardId.Esmeralda)
                return false;

            int projAtk = atkStat;
            int projDef = defStat;
            var skirtAmongK = false;
            if (IsBlackSaintMonsterId(monsterCardId))
            {
                int k = Math.Min(CountFreeSpellZones(), CountFragmentsInHand());
                projAtk = atkStat + SumBestFragmentAtkBuffsFromHand(k);
                skirtAmongK = HasSkirtAmongBestKFragmentHandPicks(k);
                int chest = CountFragmentChestplateInHand();
                projDef = defStat + 500 * Math.Min(k, chest);
            }

            int projAtkBattle = projAtk + (skirtAmongK ? FragmentSkirtBattleMarginAtk : 0);

            int enemyBestAtk = Util.GetBestAttack(Enemy);

            if (enemyBestAtk > projAtkBattle && enemyBestAtk <= projDef)
                return true;

            if (Bot.GetMonsterCount() == 0 && enemyBestAtk >= projAtkBattle)
                return true;

            if (Enemy.GetMonsters().Any(m => m != null && m.IsFaceup() && m.Attack > projAtkBattle))
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
            int monsterId = Card != null ? Card.Id : cardId;

            if (monsterId == CardId.Esmeralda && positions != null && positions.Contains(CardPosition.FaceUpAttack))
                return CardPosition.FaceUpAttack;

            if (PreferFaceUpDefenceSummon(atkStat, defStat, positions, monsterId))
                return CardPosition.FaceUpDefence;

            return base.OnSelectPosition(cardId, positions);
        }

        private bool IsMainPhase()
        {
            return Duel.Phase == DuelPhase.Main1 || Duel.Phase == DuelPhase.Main2;
        }

        /// <summary>WindBot turn player index: 0 = us, 1 = opponent (see GameAI / Duel.Player).</summary>
        private bool IsOpponentTurn()
        {
            return Duel.Player != 0;
        }

        private bool IsBattlePhase()
        {
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

        private bool IsLastChainFromOpponent()
        {
            var activator = TryGetLastChainActivatorPlayer();
            if (activator.HasValue)
                return activator.Value != 0;
            return Duel.Player != 0;
        }

        private static bool IsFragmentId(int id)
        {
            for (var i = 0; i < FragmentIds.Length; i++)
                if (FragmentIds[i] == id)
                    return true;
            return false;
        }

        private static bool IsBlackSaintMonsterId(int id)
        {
            for (var i = 0; i < BlackSaintMonsterIds.Length; i++)
                if (BlackSaintMonsterIds[i] == id)
                    return true;
            return false;
        }

        private bool HasFreeSpellZone()
        {
            for (var i = 0; i < 5; i++)
                if (Bot.SpellZone[i] == null)
                    return true;
            return false;
        }

        /// <summary>How many S/T zones we can still place an equip in (Fragment activates from hand).</summary>
        private int CountFreeSpellZones()
        {
            var n = 0;
            for (var i = 0; i < 5; i++)
            {
                if (Bot.SpellZone[i] == null)
                    n++;
            }
            return n;
        }

        /// <summary>Static ATK bonus from Fragment equip (matches script/unofficial c922100155–161.lua).</summary>
        private static int FragmentStaticEquipAtkBonus(int id)
        {
            switch (id)
            {
                case CardId.FragmentRightArm:
                    return 600;
                case CardId.FragmentLeftArm:
                    return 400;
                case CardId.FragmentHelmet:
                case CardId.FragmentChestplate:
                case CardId.FragmentSkirt:
                case CardId.FragmentRightLeg:
                case CardId.FragmentLeftLeg:
                    return 300;
                default:
                    return 0;
            }
        }

        private int CountFragmentsInHand()
        {
            var n = 0;
            foreach (var c in Bot.Hand)
            {
                if (c != null && IsFragmentId(c.Id))
                    n++;
            }
            return n;
        }

        private int CountFragmentChestplateInHand()
        {
            var n = 0;
            foreach (var c in Bot.Hand)
            {
                if (c != null && c.IsCode(CardId.FragmentChestplate))
                    n++;
            }
            return n;
        }

        /// <summary>Best-case total ATK from equipping up to <paramref name="maxEquips"/> Fragments from hand (greedy by bonus).</summary>
        private int SumBestFragmentAtkBuffsFromHand(int maxEquips)
        {
            if (maxEquips <= 0)
                return 0;
            var bonuses = new List<int>();
            foreach (var c in Bot.Hand)
            {
                if (c == null)
                    continue;
                var b = FragmentStaticEquipAtkBonus(c.Id);
                if (b > 0)
                    bonuses.Add(b);
            }
            bonuses.Sort((a, b) => b.CompareTo(a));
            var s = 0;
            for (var i = 0; i < bonuses.Count && i < maxEquips; i++)
                s += bonuses[i];
            return s;
        }

        /// <summary>
        /// True if <c>Fragment of Sagittarius - Skirt</c> is one of the top-<paramref name="maxEquips"/> Fragment picks from hand
        /// (same greedy order as <see cref="SumBestFragmentAtkBuffsFromHand"/>: ATK bonus desc, Skirt before other +300 ties).
        /// </summary>
        private bool HasSkirtAmongBestKFragmentHandPicks(int maxEquips)
        {
            if (maxEquips <= 0)
                return false;
            var ids = new List<int>();
            foreach (var c in Bot.Hand)
            {
                if (c == null)
                    continue;
                if (!IsFragmentId(c.Id))
                    continue;
                if (FragmentStaticEquipAtkBonus(c.Id) <= 0)
                    continue;
                ids.Add(c.Id);
            }
            if (ids.Count == 0)
                return false;
            ids.Sort((a, b) =>
            {
                int ba = FragmentStaticEquipAtkBonus(a);
                int bb = FragmentStaticEquipAtkBonus(b);
                int cmp = bb.CompareTo(ba);
                if (cmp != 0)
                    return cmp;
                bool sa = a == CardId.FragmentSkirt;
                bool sb = b == CardId.FragmentSkirt;
                if (sa && !sb)
                    return -1;
                if (!sa && sb)
                    return 1;
                return a.CompareTo(b);
            });
            for (var i = 0; i < maxEquips && i < ids.Count; i++)
            {
                if (ids[i] == CardId.FragmentSkirt)
                    return true;
            }
            return false;
        }

        private bool ControlAnyBlackSaintFaceUp()
        {
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || !m.IsFaceup())
                    continue;
                if (IsBlackSaintMonsterId(m.Id))
                    return true;
            }
            return false;
        }

        private int CountBlackSaintMonstersFaceUp()
        {
            var n = 0;
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || !m.IsFaceup())
                    continue;
                if (IsBlackSaintMonsterId(m.Id))
                    n++;
            }
            return n;
        }

        private bool MonsterHasFaceUpFragmentEquip(ClientCard m)
        {
            if (m == null || !m.IsFaceup() || m.EquipCards == null)
                return false;
            foreach (var eq in m.EquipCards)
            {
                if (eq == null || !eq.IsFaceup())
                    continue;
                if (IsFragmentId(eq.Id))
                    return true;
            }
            return false;
        }

        private bool HasBlackSaintEquippedWithFragment()
        {
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || !m.IsFaceup())
                    continue;
                if (!IsBlackSaintMonsterId(m.Id))
                    continue;
                if (MonsterHasFaceUpFragmentEquip(m))
                    return true;
            }
            return false;
        }

        private void CollectDistinctFragmentCodesOnFieldAndGrave(HashSet<int> set)
        {
            if (set == null)
                return;
            foreach (var z in Bot.SpellZone)
            {
                if (z == null || !z.IsFaceup())
                    continue;
                if (IsFragmentId(z.Id))
                    set.Add(z.Id);
            }
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || m.EquipCards == null)
                    continue;
                foreach (var eq in m.EquipCards)
                {
                    if (eq == null || !eq.IsFaceup())
                        continue;
                    if (IsFragmentId(eq.Id))
                        set.Add(eq.Id);
                }
            }
            foreach (var c in Bot.Graveyard)
            {
                if (c != null && IsFragmentId(c.Id))
                    set.Add(c.Id);
            }
        }

        private int CountDistinctFragmentNamesOnFieldAndGrave()
        {
            var set = new HashSet<int>();
            CollectDistinctFragmentCodesOnFieldAndGrave(set);
            return set.Count;
        }

        private int CountMissingDistinctFragmentNames()
        {
            var have = CountDistinctFragmentNamesOnFieldAndGrave();
            if (have == BossFragmentDistinctRequired)
                return 0;
            return BossFragmentDistinctRequired - have;
        }

        private bool BossDistinctFragmentGateReady()
        {
            return CountDistinctFragmentNamesOnFieldAndGrave() == BossFragmentDistinctRequired;
        }

        private bool BossAccessible()
        {
            return Bot.GetRemainingCount(CardId.BossReassembled, (int)CardLocation.Extra) > 0;
        }

        /// <summary>Building toward Boss SS: Boss still reachable and fewer than 7 distinct Fragment names on field/GY.</summary>
        private bool PursuingBossCombo()
        {
            return BossAccessible()
                && CountDistinctFragmentNamesOnFieldAndGrave() < BossFragmentDistinctRequired;
        }

        private bool BossAlreadyOnField()
        {
            return Bot.MonsterZone.IsExistingMatchingCard(
                m => m != null && m.IsFaceup() && m.IsCode(CardId.BossReassembled));
        }

        private bool BossSummonReady()
        {
            if (!IsMainPhase())
                return false;
            if (Bot.GetMonsterCount() >= 5)
                return false;
            if (BossAlreadyOnField())
                return false;
            return BossDistinctFragmentGateReady();
        }

        private ClientCard BestBlackSaintForEquip()
        {
            ClientCard best = null;
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || !m.IsFaceup())
                    continue;
                if (!IsBlackSaintMonsterId(m.Id))
                    continue;
                if (m.IsCode(CardId.Ikki))
                    return m;
                if (best == null || m.Attack > best.Attack)
                    best = m;
            }
            return best;
        }

        /// <summary>Fragment cards (any name) in our GY only.</summary>
        private int CountFragmentCardsInGraveyard()
        {
            var n = 0;
            foreach (var c in Bot.Graveyard)
            {
                if (c != null && IsFragmentId(c.Id))
                    n++;
            }
            return n;
        }

        /// <summary>
        /// Distinct Fragment cards we control in GY, hand, spell zones, and equipped (same physical card deduped).
        /// Used for the “5+ Fragments” Boss deck-search rule (GY + field + hand).
        /// </summary>
        private int CountFragmentCardsInGraveFieldAndHand()
        {
            var seen = new HashSet<ClientCard>();
            foreach (var c in Bot.Graveyard)
            {
                if (c != null && IsFragmentId(c.Id))
                    seen.Add(c);
            }
            foreach (var c in Bot.Hand)
            {
                if (c != null && IsFragmentId(c.Id))
                    seen.Add(c);
            }
            if (Bot.SpellZone != null)
            {
                foreach (var z in Bot.SpellZone)
                {
                    if (z != null && IsFragmentId(z.Id))
                        seen.Add(z);
                }
            }
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || m.EquipCards == null)
                    continue;
                foreach (var eq in m.EquipCards)
                {
                    if (eq != null && IsFragmentId(eq.Id))
                        seen.Add(eq);
                }
            }
            return seen.Count;
        }

        private int CountBlackSaintCardsInOurGraveyard()
        {
            var n = 0;
            foreach (var c in Bot.Graveyard)
            {
                if (c != null && IsBlackSaintMonsterId(c.Id))
                    n++;
            }
            return n;
        }

        private int EnemyMaxFaceUpMonsterAtk()
        {
            var best = 0;
            foreach (var m in Enemy.MonsterZone)
            {
                if (m == null || !m.IsFaceup())
                    continue;
                if (m.Attack > best)
                    best = m.Attack;
            }
            return best;
        }

        private bool BlackSaintInMainDeck(int id)
        {
            return Bot.GetRemainingCount(id, (int)CardLocation.Deck) > 0;
        }

        private bool BotControlsFaceUpBlackSaint(int id)
        {
            foreach (var m in Bot.MonsterZone)
            {
                if (m != null && m.IsFaceup() && m.IsCode(id))
                    return true;
            }
            return false;
        }

        /// <summary>
        /// Per-card priority when several Black Saints are still in the Deck (Fragment GY trigger, Jango, etc.).
        /// Higher score = more likely to be selected.
        /// </summary>
        private int BlackSaintDeckSearchScore(int id)
        {
            var frGy = CountFragmentCardsInGraveyard();
            var frSeen = CountFragmentCardsInGraveFieldAndHand();
            var distFr = CountDistinctFragmentNamesOnFieldAndGrave();
            var bs = CountBlackSaintMonstersFaceUp();
            var enemyMax = EnemyMaxFaceUpMonsterAtk();
            var gyBs = CountBlackSaintCardsInOurGraveyard();
            var ikkiField = BotControlsFaceUpBlackSaint(CardId.Ikki);

            switch (id)
            {
                case CardId.BossReassembled:
                    // Fusion Boss — distinct Fragments on field/GY gate the Extra Deck proc (c922100162.lua).
                    {
                        var s = 12;
                        if (frSeen >= 3)
                            s += 18;
                        if (frSeen >= 4)
                            s += 35;
                        if (frSeen >= 5)
                            s += 40;
                        if (distFr >= 5)
                            s += 28;
                        if (distFr >= 6)
                            s += 95;
                        if (distFr == BossFragmentDistinctRequired)
                            s += 220;
                        return s;
                    }
                case CardId.Ikki:
                    // Leader — scales with board; huge bump when 3+ Black Saints (overlaps hard rule).
                    {
                        var s = 48;
                        if (bs >= 1)
                            s += 10;
                        if (bs >= 2)
                            s += 25;
                        if (bs > 2)
                            s += 220;
                        if (HasBlackSaintEquippedWithFragment())
                            s += 20;
                        if (distFr >= 4)
                            s += 14;
                        return s;
                    }
                case CardId.Jango:
                    // Starter / mill — prefer empty or small boards; deprioritize duplicate.
                    {
                        var s = 52;
                        if (bs == 0)
                            s += 42;
                        if (bs == 1)
                            s += 20;
                        if (BotControlsFaceUpBlackSaint(CardId.Jango))
                            s -= 38;
                        if (frGy >= 2)
                            s += 8;
                        if (PursuingBossCombo())
                        {
                            s += 35;
                            s += CountMissingDistinctFragmentNames() * 12;
                        }
                        return s;
                    }
                case CardId.DarkPegasus:
                    // Needs Black Saint + S/T zone for equip line.
                    {
                        var s = 40;
                        if (bs >= 1 && HasFreeSpellZone())
                            s += 26;
                        if (HasBlackSaintEquippedWithFragment())
                            s += 10;
                        return s;
                    }
                case CardId.DarkPhoenix:
                    // Deck line wants Ikki; extender when field is wide.
                    {
                        var s = 32;
                        if (ikkiField)
                            s += 48;
                        if (bs >= 2)
                            s += 14;
                        return s;
                    }
                case CardId.DarkAndromeda:
                    // Draw when Fragments move — reward milling.
                    {
                        var s = 38;
                        s += Math.Min(32, frGy * 5);
                        if (PursuingBossCombo())
                            s += 18 + CountMissingDistinctFragmentNames() * 6;
                        if (frGy >= 2)
                            s += 12;
                        return s;
                    }
                case CardId.DarkCygnus:
                    // Quick negate — slightly higher when opponent shows tall monsters or mid-chain.
                    {
                        var s = 34;
                        if (enemyMax >= 2000)
                            s += 20;
                        if (!ChainIsEmpty())
                            s += 14;
                        return s;
                    }
                case CardId.DarkDragon:
                    // Beater — prefer when opponent has large ATK.
                    {
                        var s = 36;
                        if (enemyMax >= 2200)
                            s += 28;
                        if (bs >= 2)
                            s += 10;
                        return s;
                    }
                case CardId.Esmeralda:
                    // L2 tuner body + Deck search; Maiden-like Ikki lines when targeted (c922100168).
                    {
                        var s = 24;
                        if (bs >= 1)
                            s += 22;
                        if (Bot.LifePoints <= 3500)
                            s += 26;
                        if (frGy >= 2)
                            s += 12;
                        if (Bot.GetRemainingCount(CardId.Ikki, (int)(CardLocation.Hand | CardLocation.Grave | CardLocation.Deck)) > 0)
                            s += 8;
                        return s;
                    }
                case CardId.Guilty:
                    // GY-based boss — prefer when recursion is live.
                    {
                        var s = 26;
                        if (gyBs >= 2)
                            s += 32;
                        if (bs >= 2)
                            s += 14;
                        return s;
                    }
                default:
                    return 0;
            }
        }

        /// <summary>
        /// Pick which Black Saint name to add from Deck (Fragment GY effects, Jango, etc.).
        /// Hard rules: (1) 3+ face-up Black Saints and still building Boss → Ikki; (2) exactly 7 distinct Fragments on field/GY → Boss;
        /// (3) pursuing Boss with &lt;6 distinct → Jango if in Deck; then highest <see cref="BlackSaintDeckSearchScore"/>.
        /// </summary>
        private int ChooseBlackSaintForDeckSearch()
        {
            var distFr = CountDistinctFragmentNamesOnFieldAndGrave();

            if (BlackSaintInMainDeck(CardId.Ikki)
                && CountBlackSaintMonstersFaceUp() > 2
                && distFr < 6)
                return CardId.Ikki;

            if (Bot.GetRemainingCount(CardId.BossReassembled, (int)CardLocation.Extra) > 0 && distFr == BossFragmentDistinctRequired)
                return CardId.BossReassembled;

            if (PursuingBossCombo() && distFr < 6 && BlackSaintInMainDeck(CardId.Jango))
                return CardId.Jango;

            var bestId = CardId.Jango;
            var bestScore = int.MinValue;
            foreach (var mid in BlackSaintMonsterIds)
            {
                if (!BlackSaintInMainDeck(mid))
                    continue;
                var sc = BlackSaintDeckSearchScore(mid);
                if (sc > bestScore)
                {
                    bestScore = sc;
                    bestId = mid;
                }
            }

            if (!BlackSaintInMainDeck(bestId))
            {
                foreach (var mid in BlackSaintMonsterIds)
                {
                    if (BlackSaintInMainDeck(mid))
                        return mid;
                }
            }

            return bestId;
        }

        private bool ActivateHeist()
        {
            if (!HasBlackSaintEquippedWithFragment())
                return false;
            if (ChainIsEmpty())
                return false;
            if (!IsLastChainFromOpponent())
                return false;
            return true;
        }

        private bool ActivateDeathQueenIsland()
        {
            if (!IsMainPhase())
                return false;

            var d = (int)ActivateDescription;
            var equipIgnDesc = (int)Util.GetStringId(CardId.DeathQueenIsland, 1);
            var fragmentGySearchDesc = (int)Util.GetStringId(CardId.DeathQueenIsland, 2);

            var fromHand = (Card.Location & CardLocation.Hand) != 0;

            // Already resolved Field Spell — ignition equip Stringid 1 or Fragment-sent Deck search Stringid 2.
            if (!fromHand)
            {
                if (!Bot.HasInSpellZone(CardId.DeathQueenIsland))
                    return false;

                var equipLegal = DeathQueenIslandEquipFromGraveIgnitionLegal();
                var searchLegal = DeathQueenIslandFragmentSentDeckSearchLegal();

                if (d == equipIgnDesc)
                    return equipLegal;
                if (d == fragmentGySearchDesc)
                    return searchLegal;
                if (d == -1 || d == 0)
                    return equipLegal || searchLegal;
                return false;
            }

            if (Bot.HasInSpellZone(CardId.DeathQueenIsland))
                return false;
            if (PursuingBossCombo() && CountMissingDistinctFragmentNames() > 0)
                return Bot.GetRemainingCount(ChooseMissingFragmentIdFromDeck(), (int)CardLocation.Deck) > 0
                    || CountFragmentsInHand() > 0;
            return true;
        }

        private bool DeathQueenIslandEquipFromGraveIgnitionLegal()
        {
            if (!HasFreeSpellZone())
                return false;
            if (!ControlAnyBlackSaintFaceUp())
                return false;
            return Bot.Graveyard.IsExistingMatchingCard(c => c != null && IsFragmentId(c.Id));
        }

        private bool DeathQueenIslandFragmentSentDeckSearchLegal()
        {
            foreach (var mid in BlackSaintMonsterIds)
            {
                if (mid == CardId.Ikki)
                    continue;
                if (BlackSaintInMainDeck(mid))
                    return true;
            }
            return false;
        }

        private bool ActivateStolenGoldCloth()
        {
            if (!IsMainPhase())
                return false;
            if (!ControlAnyBlackSaintFaceUp())
                return false;
            if (PursuingBossCombo() && CountMissingDistinctFragmentNames() > 0)
            {
                if (!HasFreeSpellZone())
                    return false;
                if (CountFragmentCardsInGraveyard() < 1
                    && Bot.GetRemainingCount(ChooseMissingFragmentIdFromDeck(), (int)CardLocation.Deck) <= 0)
                    return false;
                return true;
            }
            return true;
        }

        /// <summary>Quick-Play buff — bot activates only during Battle Phase (Main Phase idle avoided).</summary>
        private bool ActivateEsmeraldasLastWill()
        {
            if (!IsBattlePhase())
                return false;
            return ControlAnyBlackSaintFaceUp();
        }

        private bool ActivateGuiltysCruelTrial()
        {
            if (!IsMainPhase())
                return false;
            if (Bot.HasInSpellZone(CardId.GuiltysCruelTrial))
                return false;
            return true;
        }

        /// <summary>
        /// Activate <see cref="CardId.OathOfShadow"/> from hand (place Continuous Spell) or use its ignition on field:
        /// send 1 Fragment from hand or face-up field to GY; Special Summon 1 Black Saint from GY (optional equip from GY if Ikki — handled by engine).
        /// </summary>
        private bool ActivateOathOfShadow()
        {
            if (!IsMainPhase())
                return false;

            var hasGyBs = Bot.Graveyard.IsExistingMatchingCard(c => IsBlackSaintMonsterId(c.Id));
            var handFrag = Bot.Hand.IsExistingMatchingCard(c => IsFragmentId(c.Id));
            var fieldFrag = false;
            foreach (var z in Bot.SpellZone)
            {
                if (z == null || !z.IsFaceup())
                    continue;
                if (IsFragmentId(z.Id))
                {
                    fieldFrag = true;
                    break;
                }
            }
            var canPayIgnitionCost = handFrag || fieldFrag;

            // Continuous Spell from hand — only when a follow-up ignition line exists (GY target + Fragment cost).
            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (Bot.HasInSpellZone(CardId.OathOfShadow))
                    return false;
                return hasGyBs && canPayIgnitionCost;
            }

            // Ignition on field: same gates + room to Special Summon.
            if ((Card.Location & CardLocation.SpellZone) == 0)
                return false;
            if (Bot.GetMonsterCount() >= 5)
                return false;
            if (!hasGyBs)
                return false;
            return canPayIgnitionCost;
        }

        /// <summary>
        /// Boss (c922100162): Fusion Summon proc from Extra Deck — WindBot lists under Special Summon in Main Phase.
        /// </summary>
        private bool SpSummonBossReassembled()
        {
            if (Card == null || !Card.IsCode(CardId.BossReassembled))
                return false;
            if ((Card.Location & CardLocation.Extra) == 0)
                return false;
            return BossSummonReady();
        }

        private bool SpSummonDarkPegasusFromHand()
        {
            if (!IsMainPhase())
                return false;
            if (!Card.IsCode(CardId.DarkPegasus))
                return false;
            if ((Card.Location & CardLocation.Hand) == 0)
                return false;
            return ControlAnyBlackSaintFaceUp();
        }

        private bool SpSummonDarkPhoenixFromHand()
        {
            if (!IsMainPhase())
                return false;
            if (!Card.IsCode(CardId.DarkPhoenix))
                return false;
            if ((Card.Location & CardLocation.Hand) == 0)
                return false;
            return Bot.MonsterZone.IsExistingMatchingCard(m => m != null && m.IsFaceup() && m.IsCode(CardId.Ikki));
        }

        private bool SpSummonGuiltyFromHand()
        {
            if (!IsMainPhase())
                return false;
            if (!Card.IsCode(CardId.Guilty))
                return false;
            if ((Card.Location & CardLocation.Hand) == 0)
                return false;
            return ControlAnyBlackSaintFaceUp();
        }

        private bool SpSummonIkkiFromHand()
        {
            if (!IsMainPhase())
                return false;
            if (!Card.IsCode(CardId.Ikki))
                return false;
            if ((Card.Location & CardLocation.Hand) == 0)
                return false;
            return CountBlackSaintMonstersFaceUp() >= 2;
        }

        /// <summary>
        /// Dark Dragon (c922100151): Stringid 0 on-summon equip from Deck; Stringid 1 Quick send equip for protection;
        /// Stringid 2 from GY add Fragment — isolate summon (-1) from Quick so summon does not require existing equip.
        /// </summary>
        private bool ActivateDarkDragon()
        {
            if (Card == null || !Card.IsCode(CardId.DarkDragon))
                return false;

            var summonEqDesc = (int)Util.GetStringId(CardId.DarkDragon, 0);
            var quickDesc = (int)Util.GetStringId(CardId.DarkDragon, 1);
            var gyAddDesc = (int)Util.GetStringId(CardId.DarkDragon, 2);
            var d = (int)ActivateDescription;

            if ((Card.Location & CardLocation.Grave) != 0)
            {
                if (d == gyAddDesc || d == -1 || d == 0)
                    return Bot.Graveyard.IsExistingMatchingCard(c => c != null && IsFragmentId(c.Id));
                return false;
            }

            if ((Card.Location & CardLocation.MonsterZone) == 0)
                return false;

            if (d == summonEqDesc || ((d == -1 || d == 0) && !DarkDragonHasEquipToSendAsCost()))
                return DarkDragonSummonEquipFromDeckLegal();

            if (d == quickDesc || (d == -1 && DarkDragonHasEquipToSendAsCost()))
            {
                if (!DarkDragonHasEquipToSendAsCost())
                    return false;
                if (ChainIsEmpty() && !FragmentQuickContextWorthSpending())
                    return false;
                return true;
            }

            return false;
        }

        private bool DarkDragonSummonEquipFromDeckLegal()
        {
            if (!HasFreeSpellZone())
                return false;
            foreach (var fid in FragmentIds)
            {
                if (Bot.GetRemainingCount(fid, (int)CardLocation.Deck) > 0)
                    return true;
            }
            return false;
        }

        /// <summary>
        /// Boss on field (c922100162): Stringid 1 equip up to 2 from GY after SS; Stringid 2 Quick negate (5+ equips).
        /// </summary>
        private bool ActivateBossOnField()
        {
            if (Card == null || !Card.IsCode(CardId.BossReassembled))
                return false;
            if ((Card.Location & CardLocation.MonsterZone) == 0)
                return false;
            if (Duel.Player != 0 || !IsMainPhase())
                return false;

            var equipDesc = (int)Util.GetStringId(CardId.BossReassembled, 1);
            var negateDesc = (int)Util.GetStringId(CardId.BossReassembled, 2);
            var d = (int)ActivateDescription;

            var equipLegal = BossEquipFromGraveAfterSpecialSummonLegal();
            var negateLegal = !ChainIsEmpty() && IsLastChainFromOpponent() && CountFaceUpEquipsOnCard(Card) >= 5;

            // If both DB prompts are missing, GetStringId returns 0 for both — d==0 would match negate first and block equip.
            if (negateDesc != 0 && d == negateDesc)
                return negateLegal;
            if (equipDesc != 0 && d == equipDesc)
                return equipLegal;

            if (equipDesc == 0 && negateDesc == 0)
            {
                if (ChainIsEmpty() && equipLegal)
                    return true;
                if (negateLegal)
                    return true;
                return false;
            }

            if (d == -1 || d == 0)
            {
                if (ChainIsEmpty() && equipLegal)
                    return true;
                if (negateLegal)
                    return true;
                return false;
            }

            // Engine effect description may not match Util.GetStringId (locale / DB drift); open chain + GY equip is the post-SS trigger (c922100162).
            if (ChainIsEmpty() && equipLegal)
                return true;

            return false;
        }

        private static int CountFaceUpEquipsOnCard(ClientCard m)
        {
            if (m == null || m.EquipCards == null)
                return 0;
            var n = 0;
            foreach (var eq in m.EquipCards)
            {
                if (eq != null && eq.IsFaceup())
                    n++;
            }
            return n;
        }

        private bool BossEquipFromGraveAfterSpecialSummonLegal()
        {
            if (!HasFreeSpellZone())
                return false;
            return Bot.Graveyard.IsExistingMatchingCard(c => c != null && IsFragmentId(c.Id));
        }

        /// <summary>Best Fragment card in GY to equip (by static ATK bonus), optionally excluding one pick.</summary>
        private ClientCard ChooseBestGraveFragmentCardForEquip(ClientCard exclude)
        {
            ClientCard best = null;
            var bestB = -1;
            foreach (var c in Bot.Graveyard)
            {
                if (c == null || !IsFragmentId(c.Id))
                    continue;
                if (exclude != null && ReferenceEquals(c, exclude))
                    continue;
                var b = FragmentStaticEquipAtkBonus(c.Id);
                if (b > bestB)
                {
                    bestB = b;
                    best = c;
                }
            }
            return best;
        }

        /// <summary>
        /// Up to <paramref name="maxPick"/> distinct GY Fragments, greedy by static equip ATK (matches c922100162 SelectMatching max).
        /// </summary>
        private List<ClientCard> ChooseOrderedGraveFragmentsForBossEquip(int maxPick)
        {
            var result = new List<ClientCard>();
            if (maxPick <= 0)
                return result;
            var used = new HashSet<ClientCard>();
            for (var k = 0; k < maxPick; k++)
            {
                ClientCard best = null;
                var bestB = -1;
                foreach (var c in Bot.Graveyard)
                {
                    if (c == null || !IsFragmentId(c.Id) || used.Contains(c))
                        continue;
                    var b = FragmentStaticEquipAtkBonus(c.Id);
                    if (b > bestB)
                    {
                        bestB = b;
                        best = c;
                    }
                }
                if (best == null)
                    break;
                used.Add(best);
                result.Add(best);
            }
            return result;
        }

        private bool DarkDragonHasEquipToSendAsCost()
        {
            if (Card == null || Card.EquipCards == null)
                return false;
            foreach (var eq in Card.EquipCards)
            {
                if (eq != null && eq.IsFaceup())
                    return true;
            }
            return false;
        }

        /// <summary>Best Fragment name still in Main Deck (for Dark Dragon on-summon equip bias).</summary>
        private int ChooseBestFragmentIdStillInDeck()
        {
            var bestId = 0;
            var bestBonus = -1;
            foreach (var fid in FragmentIds)
            {
                if (Bot.GetRemainingCount(fid, (int)CardLocation.Deck) <= 0)
                    continue;
                var b = FragmentStaticEquipAtkBonus(fid);
                if (b > bestBonus)
                {
                    bestBonus = b;
                    bestId = fid;
                }
            }
            return bestId;
        }

        /// <summary>While pursuing Boss, mill/equip a Fragment name not yet on field/GY; else highest static ATK still in Deck.</summary>
        private int ChooseFragmentIdForDeckMill()
        {
            if (PursuingBossCombo())
            {
                var missing = ChooseMissingFragmentIdFromDeck();
                if (missing != 0)
                    return missing;
            }
            return ChooseBestFragmentIdStillInDeck();
        }

        /// <summary>Fragment name in Main Deck that is not yet among distinct names on field/GY (highest remaining copy count).</summary>
        private int ChooseMissingFragmentIdFromDeck()
        {
            var seen = new HashSet<int>();
            CollectDistinctFragmentCodesOnFieldAndGrave(seen);
            var bestId = 0;
            var bestRem = 0;
            foreach (var fid in FragmentIds)
            {
                if (seen.Contains(fid))
                    continue;
                var rem = Bot.GetRemainingCount(fid, (int)CardLocation.Deck);
                if (rem > bestRem)
                {
                    bestRem = rem;
                    bestId = fid;
                }
            }
            return bestId;
        }

        /// <summary>Highest static ATK Fragment in GY for Boss post-summon equip (c922100162 Stringid 1).</summary>
        private int ChooseBestFragmentIdInGraveForBossEquip()
        {
            var bestId = 0;
            var bestBonus = -1;
            foreach (var c in Bot.Graveyard)
            {
                if (c == null || !IsFragmentId(c.Id))
                    continue;
                var b = FragmentStaticEquipAtkBonus(c.Id);
                if (b > bestBonus)
                {
                    bestBonus = b;
                    bestId = c.Id;
                }
            }
            return bestId;
        }

        /// <summary>
        /// Esmeralda (c922100168): Stringid 0 = on-summon search; Stringid 1 = Quick when targeted SS Ikki;
        /// Stringid 2 = battle target negate + position + optional Ikki. Shared once/turn (see c922100168.lua).
        /// On-summon uses OnSelectEffectYn (desc -1) — do not require MMZ yet; follow Seiya-style fallback on our turn.
        /// </summary>
        private bool ActivateEsmeralda()
        {
            if (Card == null || !Card.IsCode(CardId.Esmeralda))
                return false;

            var quickDesc = (int)Util.GetStringId(CardId.Esmeralda, 1);
            var battleDesc = (int)Util.GetStringId(CardId.Esmeralda, 2);
            var d = (int)ActivateDescription;

            // Opponent turn: BE_BATTLE_TARGET / BECOME_TARGET (desc often -1 or 0 while Phase is still Main2).
            if (IsOpponentTurn())
            {
                if ((Card.Location & CardLocation.MonsterZone) == 0)
                    return false;
                if (d == quickDesc)
                {
                    if (Bot.GetMonsterCount() >= 5)
                        return false;
                    return EsmeraldaIkkiAccessible();
                }
                if (d == battleDesc || d == -1 || d == 0)
                    return true;
                return true;
            }

            // Quick (Stringid 1) — only from MMZ.
            if (d == quickDesc)
            {
                if ((Card.Location & CardLocation.MonsterZone) == 0)
                    return false;
                if (Bot.GetMonsterCount() >= 5)
                    return false;
                return EsmeraldaIkkiAccessible();
            }

            if (d == battleDesc)
                return false;

            // Our turn: any other prompt = on-summon search (Ignis often sends desc -1, not id*16+0).
            if (IsEsmeraldaSummonSearchDescription(d))
                return EsmeraldaHasDeckSearchTarget();

            return false;
        }

        /// <summary>On-summon deck search (Stringid 0) — EffectYn uses -1/0; idle cmd may send Stringid hash.</summary>
        private bool IsEsmeraldaSummonSearchDescription(int desc)
        {
            if (IsOpponentTurn())
                return false;
            if (desc == (int)Util.GetStringId(CardId.Esmeralda, 0))
                return true;
            if (desc == -1 || desc == 0)
                return true;
            // Not Quick or battle lines on our turn → treat as summon search (custom desc values).
            if (desc != (int)Util.GetStringId(CardId.Esmeralda, 1)
                && desc != (int)Util.GetStringId(CardId.Esmeralda, 2))
                return true;
            return false;
        }

        /// <summary>Esmeralda on-summon search adds only Death Queen Island (922100163).</summary>
        private int ChooseEsmeraldaDeckSearchCardId()
        {
            if (BlackSaintInMainDeck(CardId.DeathQueenIsland))
                return CardId.DeathQueenIsland;
            return 0;
        }

        /// <summary>Battle negate (Stringid 2) or generic trigger desc during a battle window.</summary>
        private bool IsEsmeraldaBattleActivateDescription(int desc)
        {
            if (desc == (int)Util.GetStringId(CardId.Esmeralda, 2))
                return true;
            if (desc != -1 && desc != 0)
                return false;
            if (IsOpponentTurn())
                return true;
            return IsBattlePhase();
        }

        private bool EsmeraldaHasDeckSearchTarget()
        {
            return ChooseEsmeraldaDeckSearchCardId() != 0;
        }

        private bool EsmeraldaIkkiAccessible()
        {
            return Bot.GetRemainingCount(CardId.Ikki, (int)(CardLocation.Hand | CardLocation.Grave | CardLocation.Deck)) > 0;
        }

        /// <summary>True when engine is offering Esmeralda's Quick (Stringid 1) vs her other MMZ activations.</summary>
        private bool IsEsmeraldaQuickIkkiActivateDescription()
        {
            return ActivateDescription == Util.GetStringId(CardId.Esmeralda, 1);
        }

        /// <summary>First Ikki in Main Deck, then GY, then hand, for SelectNextCard bias in OnPreActivate.</summary>
        private ClientCard ChooseEsmeraldaIkkiClientCardForSelectNext()
        {
            if (Bot.Deck != null && BlackSaintInMainDeck(CardId.Ikki))
            {
                foreach (var c in Bot.Deck)
                {
                    if (c != null && c.IsCode(CardId.Ikki))
                        return c;
                }
            }
            if (Bot.Graveyard != null)
            {
                foreach (var c in Bot.Graveyard)
                {
                    if (c != null && c.IsCode(CardId.Ikki))
                        return c;
                }
            }
            if (Bot.Hand != null)
            {
                foreach (var c in Bot.Hand)
                {
                    if (c != null && c.IsCode(CardId.Ikki))
                        return c;
                }
            }
            return null;
        }

        private bool ActivateGuilty()
        {
            return IsMainPhase();
        }

        /// <summary>c922100148 Stringid 2: optional add Fragment from Deck after N/SS (shared desc -1/0 when texts.str* empty).</summary>
        private bool IsIkkiMonsterZoneOnSummonSearchDescription(int d)
        {
            var qd = (int)Util.GetStringId(CardId.Ikki, 3);
            if (qd != 0 && d == qd)
                return false;
            var sd = (int)Util.GetStringId(CardId.Ikki, 2);
            if (sd != 0)
                return d == sd || d == -1 || d == 0;
            return d == -1 || d == 0;
        }

        private bool IkkiDeckHasSearchableFragment()
        {
            foreach (var fid in FragmentIds)
            {
                if (Bot.GetRemainingCount(fid, (int)CardLocation.Deck) > 0)
                    return true;
            }
            return false;
        }

        /// <summary>
        /// Ikki (c922100148): Stringid 3 Quick (cost + destroy); Stringid 2 on-summon Deck search; Stringid 1 GY SS; Stringid 0 hand SS.
        /// Quick must not match on <c>GetStringId==0</c> + engine <c>desc==0</c> or the on-summon trigger after Esmeralda SS never activates.
        /// On-summon trigger can fire in Battle Phase — do not gate it with <see cref="IsMainPhase"/> only.
        /// </summary>
        private bool ActivateIkki()
        {
            if (Card == null || !Card.IsCode(CardId.Ikki))
                return false;

            var d = ActivateDescription;
            var quickDesc = (int)Util.GetStringId(CardId.Ikki, 3);
            var summonSearchDesc = (int)Util.GetStringId(CardId.Ikki, 2);
            var gySsDesc = (int)Util.GetStringId(CardId.Ikki, 1);
            var handSsDesc = (int)Util.GetStringId(CardId.Ikki, 0);

            // Quick (Stringid 3) — MMZ only
            if ((Card.Location & CardLocation.MonsterZone) != 0
                && quickDesc != 0
                && d == quickDesc)
            {
                if (ChainIsEmpty() && !FragmentQuickContextWorthSpending())
                    return false;
                var cost = ChooseIkkiFragmentEquipForQuickCost();
                var kill = ChooseIkkiDestroyTargetPreferOpponent(Card);
                if (cost != null && kill != null)
                {
                    AI.SelectCard(cost);
                    AI.SelectNextCard(kill);
                    return true;
                }
                return false;
            }

            // On-summon search (Stringid 2) — MMZ (EVENT_SUMMON_SUCCESS / SPSUMMON_SUCCESS, incl. Esmeralda chain end)
            if ((Card.Location & CardLocation.MonsterZone) != 0)
            {
                var summonMatch = (summonSearchDesc != 0 && (d == summonSearchDesc || d == -1 || d == 0))
                    || (summonSearchDesc == 0 && (d == -1 || d == 0));
                if (summonMatch)
                    return IkkiDeckHasSearchableFragment();
            }

            // GY: send face-up Fragment equip to GY; SS this card (Stringid 1)
            if ((Card.Location & CardLocation.Grave) != 0)
            {
                if (gySsDesc != 0 && d != gySsDesc && d != -1 && d != 0)
                    return false;
                if (!IsMainPhase())
                    return false;
                return ChooseIkkiFragmentEquipForQuickCost() != null;
            }

            // Hand: SS if 2+ face-up Black Saints (Stringid 0)
            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (handSsDesc != 0 && d != handSsDesc && d != -1 && d != 0)
                    return false;
                if (!IsMainPhase())
                    return false;
                return CountBlackSaintMonstersFaceUp() >= 2;
            }

            return IsMainPhase() || IsBattlePhase() || !ChainIsEmpty();
        }

        /// <summary>Never send Boss (c922100162) equips to GY as Ikki Quick cost when another Fragment exists.</summary>
        private static bool IsFragmentEquipAttachedToBoss(ClientCard eq)
        {
            return eq != null && eq.EquipTarget != null && eq.EquipTarget.IsCode(CardId.BossReassembled);
        }

        /// <summary>
        /// Ikki Quick cost: face-up Fragment equip, prefer lowest static ATK bonus; skip fragments equipped to Boss
        /// (Reassembled God Cloth) unless it is the only legal cost.
        /// </summary>
        private ClientCard ChooseIkkiFragmentEquipForQuickCost()
        {
            var candidates = new List<ClientCard>();
            if (Bot.SpellZone != null)
            {
                foreach (var z in Bot.SpellZone)
                {
                    if (z != null && z.IsFaceup() && IsFragmentId(z.Id))
                        candidates.Add(z);
                }
            }
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || m.EquipCards == null)
                    continue;
                foreach (var eq in m.EquipCards)
                {
                    if (eq != null && eq.IsFaceup() && IsFragmentId(eq.Id))
                        candidates.Add(eq);
                }
            }
            if (candidates.Count == 0)
                return null;

            var poolList = candidates.Where(c => !IsFragmentEquipAttachedToBoss(c)).ToList();
            if (poolList.Count == 0)
                poolList = candidates;

            ClientCard worst = null;
            var worstBonus = int.MaxValue;
            foreach (var c in poolList)
            {
                var b = FragmentStaticEquipAtkBonus(c.Id);
                if (b < worstBonus)
                {
                    worstBonus = b;
                    worst = c;
                }
            }
            return worst;
        }

        /// <summary>
        /// c922100148 Quick destroy: face-up opponent only (matches Lua). Never our own cards as destroy targets.
        /// </summary>
        private ClientCard ChooseIkkiDestroyTargetPreferOpponent(ClientCard handler)
        {
            ClientCard best = null;
            var bestScore = int.MinValue;

            foreach (var m in Enemy.MonsterZone)
            {
                if (m == null || !m.IsFaceup() || m == handler)
                    continue;
                var sc = 100000 + m.Attack;
                if (sc > bestScore)
                {
                    bestScore = sc;
                    best = m;
                }
            }
            if (Enemy.SpellZone != null)
            {
                foreach (var z in Enemy.SpellZone)
                {
                    if (z == null || !z.IsFaceup() || z == handler)
                        continue;
                    var sc = 50000 + z.Attack;
                    if (sc > bestScore)
                    {
                        bestScore = sc;
                        best = z;
                    }
                }
            }
            return best;
        }

        private bool ActivateJango()
        {
            return IsMainPhase();
        }

        private bool ActivateDarkPegasus()
        {
            if (!IsMainPhase())
                return false;
            if (Card == null || !Card.IsCode(CardId.DarkPegasus))
                return false;

            // c922100150: Stringid 0 = IGNITION from **hand** SS if you control a face-up Black Saint (not SpSummon proc).
            var ssDesc = (int)Util.GetStringId(CardId.DarkPegasus, 0);
            var equipDesc = (int)Util.GetStringId(CardId.DarkPegasus, 1);
            var d = (int)ActivateDescription;

            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (d != ssDesc && d != -1 && d != 0)
                    return false;
                if (Bot.GetMonsterCount() >= 5)
                    return false;
                return ControlAnyBlackSaintFaceUp();
            }

            if ((Card.Location & CardLocation.MonsterZone) != 0)
            {
                if (d != equipDesc && d != -1 && d != 0)
                    return false;
                if (!HasFreeSpellZone())
                    return false;
                return Bot.Hand.IsExistingMatchingCard(c => c != null && IsFragmentId(c.Id))
                    || Bot.Graveyard.IsExistingMatchingCard(c => c != null && IsFragmentId(c.Id));
            }

            return false;
        }

        private bool ActivateDarkCygnus()
        {
            return IsMainPhase() || !ChainIsEmpty();
        }

        private bool ActivateDarkAndromeda()
        {
            if (!IsMainPhase())
                return false;
            if (PursuingBossCombo() && CountFragmentsInHand() > 0 && HasFreeSpellZone())
                return true;
            return true;
        }

        private bool ActivateDarkPhoenix()
        {
            return IsMainPhase();
        }

        /// <summary>
        /// Face-up equip Quick effects share a once/turn limit with the GY deck-search on each Fragment (Lua {id,199}).
        /// Avoid auto-activating FREE_CHAIN Quicks in open Main1 — reserve for chain, battle, Main2, or clear threats.
        /// </summary>
        private bool FragmentQuickContextWorthSpending()
        {
            if (!ChainIsEmpty())
                return true;
            if (IsBattlePhase())
                return true;
            if (Duel.Phase == DuelPhase.Main2 && Duel.Player == 0)
                return true;
            var best = 0;
            foreach (var m in Enemy.MonsterZone)
            {
                if (m == null || !m.IsFaceup())
                    continue;
                if (m.Attack > best)
                    best = m.Attack;
            }
            return best >= FragmentQuickThreatAtkFloor;
        }

        private ClientCard FindMonsterHostingThisEquipSpell()
        {
            if (Card == null)
                return null;
            foreach (var m in Bot.MonsterZone)
            {
                if (m == null || m.EquipCards == null)
                    continue;
                foreach (var eq in m.EquipCards)
                {
                    if (eq != null && eq == Card)
                        return m;
                }
            }
            return null;
        }

        private static bool OpponentControlsFaceUpMonster(ClientField enemy)
        {
            foreach (var m in enemy.MonsterZone)
            {
                if (m != null && m.IsFaceup())
                    return true;
            }
            return false;
        }

        private static bool OpponentControlsFaceUpAttackMonster(ClientField enemy)
        {
            foreach (var m in enemy.MonsterZone)
            {
                if (m != null && m.IsFaceup() && m.Position == (int)CardPosition.FaceUpAttack)
                    return true;
            }
            return false;
        }

        private static bool OpponentSpellTrapZoneOccupied(ClientField enemy)
        {
            if (enemy.SpellZone == null)
                return false;
            foreach (var z in enemy.SpellZone)
            {
                if (z != null)
                    return true;
            }
            return false;
        }

        private bool RightArmQuickHasDestroyableTarget(ClientCard host)
        {
            if (host == null || !host.IsFaceup())
                return false;
            var cap = host.Attack;
            foreach (var m in Enemy.MonsterZone)
            {
                if (m == null || !m.IsFaceup())
                    continue;
                if (m.Attack <= cap)
                    return true;
            }
            return false;
        }

        private bool LeftLegOtherFragmentInGraveToRecycle()
        {
            foreach (var c in Bot.Graveyard)
            {
                if (c != null && IsFragmentId(c.Id) && !c.IsCode(CardId.FragmentLeftLeg))
                    return true;
            }
            return false;
        }

        /// <summary>Face-up equip in SZONE: only the matching Quick (Lua), not the passive GY trigger.</summary>
        private bool ActivateFragmentFaceUpEquipQuick()
        {
            var host = FindMonsterHostingThisEquipSpell();
            if (host == null)
                return false;

            switch (Card.Id)
            {
                case CardId.FragmentHelmet:
                    // Quick negates only on opponent chain targeting equipped monster (approx: chain + opponent).
                    return !ChainIsEmpty() && IsLastChainFromOpponent();

                case CardId.FragmentChestplate:
                    if (!OpponentControlsFaceUpMonster(Enemy))
                        return false;
                    return FragmentQuickContextWorthSpending();

                case CardId.FragmentSkirt:
                    if (!OpponentControlsFaceUpAttackMonster(Enemy))
                        return false;
                    return FragmentQuickContextWorthSpending();

                case CardId.FragmentLeftArm:
                    if (!OpponentSpellTrapZoneOccupied(Enemy))
                        return false;
                    return FragmentQuickContextWorthSpending();

                case CardId.FragmentRightArm:
                    if (!RightArmQuickHasDestroyableTarget(host))
                        return false;
                    return FragmentQuickContextWorthSpending();

                case CardId.FragmentRightLeg:
                    if (!OpponentControlsFaceUpAttackMonster(Enemy))
                        return false;
                    return FragmentQuickContextWorthSpending();

                case CardId.FragmentLeftLeg:
                    if (!LeftLegOtherFragmentInGraveToRecycle())
                        return false;
                    if (!ChainIsEmpty() || IsBattlePhase())
                        return true;
                    return Duel.Phase == DuelPhase.Main2 && Duel.Player == 0;

                default:
                    return false;
            }
        }

        private bool ActivateAnyFragment()
        {
            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (!IsMainPhase())
                    return false;
                if (!HasFreeSpellZone())
                    return false;
                var target = BestBlackSaintForEquip();
                if (target == null)
                    return false;
                AI.SelectCard(target);
                return true;
            }

            if ((Card.Location & CardLocation.Grave) != 0)
            {
                AI.SelectCard(ChooseBlackSaintForDeckSearch());
                return true;
            }

            if ((Card.Location & CardLocation.SpellZone) != 0)
                return ActivateFragmentFaceUpEquipQuick();

            return false;
        }

        private int NormalSummonPriority(int id)
        {
            for (var i = 0; i < NormalSummonPriorityIds.Length; i++)
            {
                if (NormalSummonPriorityIds[i] == id)
                    return 100 - i;
            }
            return 0;
        }

        private bool PrioritizedNormalSummon()
        {
            if (!IsMainPhase())
                return false;
            if (Bot.GetMonsterCount() >= 5)
                return false;

            var myPrio = NormalSummonPriority(Card.Id);
            if (myPrio <= 0)
                return false;

            foreach (var id in NormalSummonPriorityIds)
            {
                if (!Bot.HasInHand(id))
                    continue;
                if (NormalSummonPriority(id) > myPrio)
                    return false;
            }
            return true;
        }

        private bool SpellSetPolicy()
        {
            if (!IsMainPhase())
                return false;
            if (Card == null)
                return false;

            if (Card.IsCode(CardId.StolenGoldCloth))
                return false;

            if (Card.IsCode(CardId.EsmeraldasLastWill))
                return Duel.Player == 0 && Duel.Phase == DuelPhase.Main2;

            if (Card.IsCode(CardId.Heist))
            {
                if (HasBlackSaintEquippedWithFragment())
                    return true;
                if (ControlAnyBlackSaintFaceUp()
                    && Bot.Hand.IsExistingMatchingCard(c => c != null && IsFragmentId(c.Id)))
                    return true;
                return Duel.Player == 0 && Duel.Phase == DuelPhase.Main2;
            }

            if (Card.IsCode(CardId.OathOfShadow))
            {
                // Continuous Spell — set to bluff / end phase; same heuristics as before (card was mis-typed as Trap in DB once).
                if (CountBlackSaintCardsInOurGraveyard() >= 1)
                    return true;
                if (ControlAnyBlackSaintFaceUp())
                    return true;
                return Duel.Player == 0 && Duel.Phase == DuelPhase.Main2;
            }

            if (Card.IsCode(CardId.GuiltysCruelTrial))
                return Duel.Player == 0 && Duel.Phase == DuelPhase.Main2;

            return DefaultSpellSet();
        }
    }
}
