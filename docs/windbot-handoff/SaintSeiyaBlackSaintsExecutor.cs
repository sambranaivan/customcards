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
  equip Fragments to Black Saints, set The Heist / Oath, end with Ikki + Fragment lines when possible.
- Spend The Heist on meaningful opponent activations while a Black Saint wears a Fragment.
- Use Oath / Guilty / Esmeralda for recursion; Dark Andromeda for draw when Fragments move by effects.
- Boss (922100162): only attempt when 7+ different Fragment names are in GY/field (approximate counter in executor).
- Fragment / Jango / etc. “add 1 Black Saint from Deck”: `ChooseBlackSaintForDeckSearch()` — Boss pivot when **5+**
  Fragment cards across **GY + field (S/T + equips) + hand** (deduped); Ikki when 3+ BS; then scores.

Maintenance: bump BuildVersion / BuildTag when behavior changes.
================================================================================
*/

namespace WindBot.Game.AI.Decks
{
    [Deck("SaintSeiyaBlackSaints", "AI_SaintSeiyaBlackSaints", "Normal")]
    public class SaintSeiyaBlackSaintsExecutor : DefaultExecutor
    {
        private const int BuildVersion = 4;
        private const string BuildTag = "2026-05-13-v4-fragment-count-gy-field-hand";

        /// <summary>Enemy face-up ATK at or above this → Main Phase Quick is allowed (with other gates).</summary>
        private const int FragmentQuickThreatAtkFloor = 1900;
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
            CardId.Jango, CardId.Esmeralda, CardId.DarkPegasus, CardId.DarkDragon,
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

            AddExecutor(ExecutorType.Activate, CardId.Heist, ActivateHeist);
            AddExecutor(ExecutorType.Activate, CardId.DeathQueenIsland, ActivateDeathQueenIsland);
            AddExecutor(ExecutorType.Activate, CardId.StolenGoldCloth, ActivateStolenGoldCloth);
            AddExecutor(ExecutorType.Activate, CardId.EsmeraldasLastWill, ActivateEsmeraldasLastWill);
            AddExecutor(ExecutorType.Activate, CardId.GuiltysCruelTrial, ActivateGuiltysCruelTrial);
            AddExecutor(ExecutorType.Activate, CardId.OathOfShadow, ActivateOathOfShadow);
            AddExecutor(ExecutorType.Activate, CardId.BossReassembled, ActivateBossFromHandOrGrave);

            AddExecutor(ExecutorType.SpSummon, CardId.DarkPegasus, SpSummonDarkPegasusFromHand);
            AddExecutor(ExecutorType.SpSummon, CardId.DarkPhoenix, SpSummonDarkPhoenixFromHand);
            AddExecutor(ExecutorType.SpSummon, CardId.Guilty, SpSummonGuiltyFromHand);
            AddExecutor(ExecutorType.SpSummon, CardId.Ikki, SpSummonIkkiFromHand);

            AddExecutor(ExecutorType.Activate, CardId.Esmeralda, ActivateEsmeralda);
            AddExecutor(ExecutorType.Activate, CardId.Guilty, ActivateGuilty);
            AddExecutor(ExecutorType.Activate, CardId.Ikki, ActivateIkki);
            AddExecutor(ExecutorType.Activate, CardId.Jango, ActivateJango);
            AddExecutor(ExecutorType.Activate, CardId.DarkPegasus, ActivateDarkPegasus);
            AddExecutor(ExecutorType.Activate, CardId.DarkDragon, ActivateDarkDragon);
            AddExecutor(ExecutorType.Activate, CardId.DarkCygnus, ActivateDarkCygnus);
            AddExecutor(ExecutorType.Activate, CardId.DarkAndromeda, ActivateDarkAndromeda);
            AddExecutor(ExecutorType.Activate, CardId.DarkPhoenix, ActivateDarkPhoenix);

            foreach (var fid in FragmentIds)
                AddExecutor(ExecutorType.Activate, fid, ActivateAnyFragment);

            foreach (var mid in NormalSummonPriorityIds)
                AddExecutor(ExecutorType.Summon, mid, PrioritizedNormalSummon);

            AddExecutor(ExecutorType.SpellSet, SpellSetBlackBackrow);
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

        private bool IsMainPhase()
        {
            return Duel.Phase == DuelPhase.Main1 || Duel.Phase == DuelPhase.Main2;
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

        private int CountDistinctFragmentNamesOnFieldAndGrave()
        {
            var set = new HashSet<int>();
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
            return set.Count;
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
                    // Desecrated Sagittarius — “fragment mass” uses GY + field + hand (see CountFragmentCardsInGraveFieldAndHand).
                    {
                        var s = 12;
                        if (frSeen >= 3)
                            s += 18;
                        if (frSeen >= 4)
                            s += 35;
                        if (frSeen >= 5)
                            s += 120;
                        if (distFr >= 5)
                            s += 22;
                        if (distFr >= 6)
                            s += 45;
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
                    // Low scale extender / LP utility.
                    {
                        var s = 24;
                        if (bs >= 1)
                            s += 22;
                        if (Bot.LifePoints <= 3500)
                            s += 26;
                        if (frGy >= 2)
                            s += 12;
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
        /// Hard rules: (1) more than 2 face-up Black Saints → Ikki; (2) else 5+ Fragment cards in **GY+field+hand** → Boss;
        /// then highest <see cref="BlackSaintDeckSearchScore"/> among cards still in Deck.
        /// </summary>
        private int ChooseBlackSaintForDeckSearch()
        {
            if (BlackSaintInMainDeck(CardId.Ikki) && CountBlackSaintMonstersFaceUp() > 2)
                return CardId.Ikki;

            if (BlackSaintInMainDeck(CardId.BossReassembled) && CountFragmentCardsInGraveFieldAndHand() >= 5)
                return CardId.BossReassembled;

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
            if (Bot.HasInSpellZone(CardId.DeathQueenIsland))
                return false;
            return true;
        }

        private bool ActivateStolenGoldCloth()
        {
            if (!IsMainPhase())
                return false;
            if (!ControlAnyBlackSaintFaceUp())
                return false;
            return true;
        }

        private bool ActivateEsmeraldasLastWill()
        {
            if (!IsMainPhase())
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

        private bool ActivateOathOfShadow()
        {
            if (!IsMainPhase())
                return false;
            if (!Bot.Graveyard.IsExistingMatchingCard(c => IsBlackSaintMonsterId(c.Id)))
                return false;
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
            return handFrag || fieldFrag;
        }

        private bool ActivateBossFromHandOrGrave()
        {
            if (!IsMainPhase())
                return false;
            if (CountDistinctFragmentNamesOnFieldAndGrave() < 7)
                return false;
            return true;
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

        private bool ActivateEsmeralda()
        {
            return IsMainPhase();
        }

        private bool ActivateGuilty()
        {
            return IsMainPhase();
        }

        private bool ActivateIkki()
        {
            return IsMainPhase() || !ChainIsEmpty();
        }

        private bool ActivateJango()
        {
            return IsMainPhase();
        }

        private bool ActivateDarkPegasus()
        {
            if (!IsMainPhase())
                return false;
            if ((Card.Location & CardLocation.MonsterZone) == 0)
                return false;
            return HasFreeSpellZone();
        }

        private bool ActivateDarkDragon()
        {
            return IsMainPhase();
        }

        private bool ActivateDarkCygnus()
        {
            return IsMainPhase() || !ChainIsEmpty();
        }

        private bool ActivateDarkAndromeda()
        {
            return IsMainPhase();
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

        private bool SpellSetBlackBackrow()
        {
            if (Card == null)
                return false;
            if (!Card.IsTrap())
                return false;
            if (Duel.Phase == DuelPhase.Main2 && Duel.Player == 0)
                return true;
            return false;
        }
    }
}
