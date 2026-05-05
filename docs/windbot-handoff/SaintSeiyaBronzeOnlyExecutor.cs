using System;
using System.Collections.Generic;
using System.Linq;
using YGOSharp.OCGWrapper.Enums;
using WindBot;
using WindBot.Game;
using WindBot.Game.AI;

namespace WindBot.Game.AI.Decks
{
    [Deck("SaintSeiyaBronzeOnly", "AI_SaintSeiyaBronzeOnly", "Normal")]
    public class SaintSeiyaBronzeOnlyExecutor : DefaultExecutor
    {
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

            // Cloth equips (discard to search a Level 4 "Saint")
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
            public const int AwakeningOfTheCosmos = 922100086;
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
            // Counter traps / interaction (reactive)
            AddExecutor(ExecutorType.Activate, CardId.CrystalWall, ActivateCrystalWall);
            AddExecutor(ExecutorType.Activate, CardId.PopesVerdict, ActivatePopesVerdict);
            AddExecutor(ExecutorType.Activate, CardId.AthenaExclamation, ActivateAthenaExclamation);

            // Protection / setup
            AddExecutor(ExecutorType.Activate, CardId.AwakeningOfTheCosmos, ActivateAwakening);
            AddExecutor(ExecutorType.Activate, CardId.BondOfBrotherhood, ActivateBond);
            AddExecutor(ExecutorType.Activate, CardId.AthenasSanctuary, ActivateSanctuary);

            // Starters / consistency
            AddExecutor(ExecutorType.Activate, CardId.AthenasCall, ActivateAthenasCall);
            AddExecutor(ExecutorType.Summon, CardId.Seiya, SummonSeiya);
            AddExecutor(ExecutorType.Activate, CardId.Seiya, ResolveSeiyaEffect);
            AddExecutor(ExecutorType.Activate, CardId.RaiseYourCosmos, ActivateRaiseYourCosmos);
            foreach (var cloth in Cloths)
                AddExecutor(ExecutorType.Activate, cloth, ActivateClothDiscardSearch);

            // Extenders
            AddExecutor(ExecutorType.Summon, CardId.Mu, SummonMu);
            AddExecutor(ExecutorType.Activate, CardId.Mu, ResolveMuEffect);
            AddExecutor(ExecutorType.Activate, CardId.Kiki, ActivateKikiEquip);
            AddExecutor(ExecutorType.Summon, CardId.Jabu, SummonJabu);
            AddExecutor(ExecutorType.Activate, CardId.Jabu, ResolveJabuEffect);
            AddExecutor(ExecutorType.Activate, CardId.Ikki, ResolveIkkiEffect);

            // Setting traps near end of turn
            AddExecutor(ExecutorType.SpellSet, SpellSetPolicy);

            // Repos last
            AddExecutor(ExecutorType.Repos, DefaultMonsterRepos);
        }

        public override bool OnSelectHand()
        {
            return true; // prefer going first
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

        private bool IsMainPhase()
        {
            return Duel.Phase == DuelPhase.Main1 || Duel.Phase == DuelPhase.Main2;
        }

        private int ChooseSaintToMaximizeDistinct()
        {
            var onField = new HashSet<int>(Bot.MonsterZone.Where(c => c != null && c.IsFaceup()).Select(c => c.Id));
            foreach (var id in Lv4Saints)
                if (!onField.Contains(id) && Bot.GetRemainingCount(id, 3) > 0)
                    return id;
            return CardId.Seiya;
        }

        private bool ActivateSanctuary()
        {
            if (!IsMainPhase())
                return false;
            if (Bot.HasInSpellZone(CardId.AthenasSanctuary))
                return false;
            return true;
        }

        private bool ActivateAthenasCall()
        {
            if (!IsMainPhase())
                return false;

            // If we are empty, Kiki is high value to turn on equips quickly.
            if (FieldIsEmpty() && Bot.GetRemainingCount(CardId.Kiki, 3) > 0)
            {
                AI.SelectCard(CardId.Kiki);
                return true;
            }

            // Prefer Seiya as the best starter if available.
            if (!Bot.HasInHand(CardId.Seiya) && Bot.GetRemainingCount(CardId.Seiya, 3) > 0)
            {
                AI.SelectCard(CardId.Seiya);
                return true;
            }

            AI.SelectCard(ChooseSaintToMaximizeDistinct());
            return true;
        }

        private bool SummonSeiya()
        {
            return IsMainPhase();
        }

        private bool ResolveSeiyaEffect()
        {
            if (!IsMainPhase())
                return false;

            // If we have no Cloth access in hand, search a Cloth first.
            if (!Bot.Hand.IsExistingMatchingCard(c => Cloths.Contains(c.Id)))
            {
                AI.SelectCard(new[]
                {
                    CardId.ClothCygnus,
                    CardId.ClothDragon,
                    CardId.ClothAndromeda,
                    CardId.ClothPhoenix,
                    CardId.ClothPegasus
                });
                return true;
            }

            // Otherwise, search a Saint to increase distinct names.
            AI.SelectCard(ChooseSaintToMaximizeDistinct());
            return true;
        }

        private bool ActivateClothDiscardSearch()
        {
            // Cloths: "Discard this card; add 1 Level 4 Saint monster from Deck to hand."
            // Only do this in Main Phase, and only if it helps reach 3 distinct names or fix an empty board.
            if (!IsMainPhase())
                return false;

            if (FieldIsEmpty())
            {
                AI.SelectCard(CardId.Seiya, CardId.Shun, CardId.Shiryu);
                return true;
            }

            if (DistinctSaintNamesOnField() < 3)
            {
                AI.SelectCard(ChooseSaintToMaximizeDistinct());
                return true;
            }

            return false;
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
            AI.SelectNextCard(ChooseSaintToMaximizeDistinct());
            return true;
        }

        private bool ActivateKikiEquip()
        {
            // Kiki (hand): discard -> equip a Cloth from Deck/GY to a Saint you control.
            // We mainly use this proactively going second or when we want Verdict live.
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

            AI.SelectCard(target);

            // Cloth choice priority: interaction > survival > pressure
            AI.SelectNextCard(new[]
            {
                CardId.ClothCygnus,
                CardId.ClothDragon,
                CardId.ClothAndromeda,
                CardId.ClothPhoenix,
                CardId.ClothPegasus
            });

            return true;
        }

        private bool SummonMu()
        {
            return IsMainPhase() && Bot.GetHandCount() > 0;
        }

        private bool ResolveMuEffect()
        {
            if (!IsMainPhase())
                return false;

            // If there are Cloths in GY, Mu is strong to refuel.
            if (Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id)))
            {
                AI.SelectCard(Cloths);
                return true;
            }

            return false;
        }

        private bool SummonJabu()
        {
            return IsMainPhase() && ControlAnySaint();
        }

        private bool ResolveJabuEffect()
        {
            if (!IsMainPhase())
                return false;

            // Prefer recovering an important Cloth from GY if any.
            var clothInGy = Bot.Graveyard.FirstOrDefault(c => c != null && Cloths.Contains(c.Id));
            if (clothInGy != null)
            {
                AI.SelectCard(clothInGy);
                return true;
            }

            return false;
        }

        private bool ResolveIkkiEffect()
        {
            // Ikki revive is generally useful if we have a Saint to discard and need bodies.
            if (!IsMainPhase())
                return false;

            if (DistinctSaintNamesOnField() >= 3)
                return false;

            if (!Bot.Hand.IsExistingMatchingCard(c => Saints.Contains(c.Id) && c.Id != CardId.Ikki))
                return false;

            AI.SelectCard(ChooseSaintToMaximizeDistinct());
            return true;
        }

        private bool ActivateAwakening()
        {
            // Prefer using protection as a response to opponent pressure; allow during opponent turn.
            if (Duel.Player == 0)
                return false;
            return true;
        }

        private bool ActivateBond()
        {
            // Use primarily when responding to opponent effects.
            if (Duel.Player == 0)
                return false;
            return true;
        }

        private bool ActivateCrystalWall()
        {
            // "when opponent targets your Saints" — we rely on the card's own activation legality;
            // keep it conservative: only during opponent's turn.
            return Duel.Player != 0;
        }

        private bool ActivatePopesVerdict()
        {
            // Spell/Trap negate. Card will only be activatable if equip condition is satisfied.
            return Duel.Player != 0;
        }

        private bool ActivateAthenaExclamation()
        {
            // Counter trap; card will only be activatable if "3 distinct Saints" condition is met.
            return Duel.Player != 0;
        }

        private bool SpellSetPolicy()
        {
            // Set counter traps at end of main phase if possible.
            if (!IsMainPhase())
                return false;

            // Prefer keeping Cloths in hand for discard-search instead of setting.
            if (Cloths.Contains(Card.Id))
                return false;

            return DefaultSpellSet();
        }
    }
}

