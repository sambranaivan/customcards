import unittest

import import_pokemon_set_from_excel as mod


class PokemonImportMappingTests(unittest.TestCase):
    def test_parse_level_handles_dash_as_zero(self):
        self.assertEqual(mod.parse_level("—"), 0)
        self.assertEqual(mod.parse_level("-"), 0)
        self.assertEqual(mod.parse_level("7"), 7)

    def test_parse_monster_card_type(self):
        self.assertEqual(mod.parse_monster_type("Monstruo"), 33)
        self.assertEqual(mod.parse_monster_type("Fusión"), 97)
        self.assertEqual(mod.parse_monster_type("Link-3"), 67108897)
        self.assertEqual(mod.parse_monster_type("Xyz Rango 4"), 8388641)

    def test_parse_xyz_rank(self):
        self.assertEqual(mod.parse_xyz_rank("Xyz Rango 4"), 4)
        self.assertEqual(mod.parse_xyz_rank("Xyz Rango 7"), 7)
        self.assertEqual(mod.parse_xyz_rank("Monstruo"), 0)

    def test_parse_spell_card_type(self):
        self.assertEqual(mod.parse_spell_type("Normal Spell"), 2)
        self.assertEqual(mod.parse_spell_type("Quick-Play Spell"), 65538)
        self.assertEqual(mod.parse_spell_type("Field Spell"), 524290)
        self.assertEqual(mod.parse_spell_type("Equip Spell"), 262146)
        self.assertEqual(mod.parse_spell_type("Continuous Spell"), 131074)

    def test_parse_trap_card_type(self):
        self.assertEqual(mod.parse_trap_type("Normal Trap"), 4)
        self.assertEqual(mod.parse_trap_type("Counter Trap"), 1048580)
        self.assertEqual(mod.parse_trap_type("Continuous Trap"), 131076)

    def test_pack_setcodes_uses_16bit_segments(self):
        values = [0x3001, 0x3002, 0x3003]
        packed = mod.pack_setcodes(values)
        self.assertEqual(packed, 0x3001 | (0x3002 << 16) | (0x3003 << 32))

    def test_ranges_are_deterministic(self):
        self.assertEqual(mod.monster_id_for_index(1), 920000001)
        self.assertEqual(mod.monster_id_for_index(239), 920000239)
        self.assertEqual(mod.spell_id_for_index(1), 921000001)
        self.assertEqual(mod.spell_id_for_index(102), 921000102)
        self.assertEqual(mod.trap_id_for_index(1), 922000001)
        self.assertEqual(mod.trap_id_for_index(38), 922000038)


if __name__ == "__main__":
    unittest.main()
