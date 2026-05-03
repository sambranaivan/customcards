# from _config import *
from PIL import Image, ImageDraw, ImageFont
import random
import re

from modules.DrawImage import DrawImage
from modules.DrawArtwork import DrawArtwork
from modules.DrawAttribute import DrawAttribute
from modules.DrawLevel import DrawLevel
from modules.sleep import sleeper

serial_id = random.randint(000000000, 999999999)



class CardConstructor:

   config = None
   card_img = None
   card_img_draw = None

   def __init__(self, json_card) -> None:
      self.loadConfig()

      if isinstance(json_card, dict):
         self.json_card = json_card
      
      self.getSources()
   
   def loadConfig(self):
      scale = 2  # render at 2x for readability
      def s(v):
         if isinstance(v, tuple):
            return (int(v[0] * scale), int(v[1] * scale))
         return int(v * scale)

      self.config = {
         'scale': scale,
         'source_path': "img/",
         'path_cards': "cards/",
         'path_img':   "cardimages/",
         'path_attr':   "type/",
         'path_level': "lvl/",
         'i': 0,
         'areas': {
            'card_area': s((0,0)),
            'img_area':  s((51,113)),
            'attr_area': s((355,29)),
            'level_area': s((380,76)),
            'level_x': s(380),
            'level_y': s(76),
         },
         'text': {
            'title_xy': s((30,28)),
            'atk_xy': s((265,557)),
            'def_xy': s((350,557)),
            'type_xy': s((35,460)),
            'desc_xy': s((35,480)),
            'fontsize48': s(48),
            'fontsize23': s(23),
            'fontsize15': s(15),
            'fontsize12': s(14),
            'titleFont': 'fonts/Yu-Gi-Oh! Matrix Regular Small Caps 2.ttf',
            'AttrFont': "fonts\Yu-Gi-Oh! ITC Stone Serif Small Caps Bold.ttf",
            'DescFont': 'fonts\Yu-Gi-Oh! Matrix Book.ttf',
            'title_color': 'black',
            'title_color_xyz': 'white',
            'text_alignment': 'left'
         }
      }

   def getSources(self):
      self.source_card_path      = self.config['source_path'] + self.config['path_cards'] +'Card-' + self.json_card['card'].lower().replace(' ', '-') + '.png'
      self.attribute_path        = self.config['source_path'] + self.config['path_attr'] + self.json_card['attribute'] + '.png'

      # XYZ/Overlay ranks should use the black level stars; others use red by default.
      level_asset = 'Level-black.png' if self.json_card.get('card') == 'XYZ' else 'Level-Red.png'
      self.level_path            = self.config['source_path'] + self.config['path_level'] + level_asset

      card_size = (421 * self.config['scale'], 614 * self.config['scale'])
      self.image                 = DrawImage(self.json_card['card'], self.config['areas']['card_area'], self.source_card_path, size=card_size).getimage()
      self.source_card1          = DrawImage(self.json_card['card'], self.config['areas']['card_area'], self.source_card_path, size=card_size).getSourceCard()

      art_size = (320 * self.config['scale'], 320 * self.config['scale'])
      self.artwork               = DrawArtwork(self.json_card['image_card'], self.config['areas']['img_area'], self.config['source_path'] + self.config['path_img'] + self.json_card['image_card'], size=art_size).getArtwork()
      
      attr_size = (40 * self.config['scale'], 40 * self.config['scale'])
      self.attribute             = DrawAttribute(self.json_card['attribute'], self.config['areas']['attr_area'], self.attribute_path, size=attr_size).getAttribute()

      lvl_size = (25 * self.config['scale'], 25 * self.config['scale'])
      self.level                 = DrawLevel(self.json_card['Level'], self.config['areas']['level_area'], self.level_path, size=lvl_size).getLevel()

   def setLevel(self):
      # Link monsters use Link Rating instead of Level/Rank stars.
      if self.json_card.get('card') == 'Link':
         return

      level = int(self.json_card.get('Level') or 0)
      if level <= 0:
         return

      start_x, start_y = self.config['areas']['level_area']
      is_xyz = self.json_card.get('card') == 'XYZ'
      step = 27 * self.config['scale']

      # In official layout, XYZ Ranks are left-aligned; other Levels are right-aligned.
      if is_xyz:
         left_start_x = 55 * self.config['scale']  # left margin of the rank row
         for i in range(level):
            x = left_start_x + (step * i)
            self.source_card1.paste(self.level, (x, start_y), self.level)
      else:
         for i in range(level):
            x = start_x - (step * (i + 1))
            self.source_card1.paste(self.level, (x, start_y), self.level)

   def pasteImages(self):
      self.draw                  = ImageDraw.Draw(self.source_card1) 

      self.source_card1.paste(self.artwork, self.config['areas']['img_area'])
      sleeper(self.image, self.json_card['Title'],self.source_card1,"Rendering Artwork")
      self.source_card1.paste(self.attribute, self.config['areas']['attr_area']) 
      sleeper(self.image, self.json_card['Title'],self.source_card1,"Rendering Attribute")  

   def linkArrows(self):
      pass

   def writeText(self):
      def _font_line_height(font: ImageFont.FreeTypeFont) -> int:
         bbox = font.getbbox("Ag")
         return max(1, bbox[3] - bbox[1])

      def _text_width(font: ImageFont.FreeTypeFont, text: str) -> float:
         if hasattr(font, "getlength"):
            return float(font.getlength(text))
         bbox = font.getbbox(text)
         return float(bbox[2] - bbox[0])

      def _wrap_text_to_width(text: str, font: ImageFont.FreeTypeFont, max_width: int) -> str:
         paragraphs = (text or "").split("\n")
         wrapped_paragraphs = []

         for para in paragraphs:
            words = re.split(r"\s+", para.strip()) if para.strip() else [""]
            lines = []
            current = ""

            for w in words:
               if not w:
                  continue
               candidate = w if not current else f"{current} {w}"
               if _text_width(font, candidate) <= max_width:
                  current = candidate
                  continue

               if current:
                  lines.append(current)
                  current = w
               else:
                  token = w
                  chunk = ""
                  for ch in token:
                     cand = chunk + ch
                     if _text_width(font, cand) <= max_width or not chunk:
                        chunk = cand
                     else:
                        lines.append(chunk)
                        chunk = ch
                  if chunk:
                     current = chunk

            if current or not lines:
               lines.append(current)

            wrapped_paragraphs.append("\n".join(lines))

         return "\n".join(wrapped_paragraphs)

      def _fit_font_to_width(font_path: str, text: str, max_width: int, max_size: int, min_size: int) -> ImageFont.FreeTypeFont:
         for size in range(int(max_size), int(min_size) - 1, -1):
            f = ImageFont.truetype(font_path, size)
            if _text_width(f, text) <= max_width:
               return f
         return ImageFont.truetype(font_path, int(min_size))

      def _render_shrunk_title(text: str, font: ImageFont.FreeTypeFont, color: str, max_width: int, max_height: int):
         """
         Render a 1-line title at full font size, then shrink non-uniformly (X/Y) to fit the
         nameband without cropping. This avoids making long names tiny just by reducing font size.
         Returns (img, (w,h)) where img is RGBA with text and size is its dimensions.
         """
         if not text:
            blank = Image.new("RGBA", (1, 1), (255, 255, 255, 0))
            return blank, (1, 1)

         # Render onto a generous canvas, then crop to content bbox.
         pad = max(4, int(font.size * 0.2))
         tmp_w = max_width + (pad * 4)
         tmp_h = max_height + (pad * 6)
         layer = Image.new("RGBA", (tmp_w, tmp_h), (255, 255, 255, 0))
         d = ImageDraw.Draw(layer)
         d.text((pad, pad), text, font=font, fill=color)
         bbox = layer.getbbox()
         if not bbox:
            blank = Image.new("RGBA", (1, 1), (255, 255, 255, 0))
            return blank, (1, 1)
         cropped = layer.crop(bbox)
         cw, ch = cropped.size

         # Compute non-uniform shrink factors (never upscale; only shrink to fit).
         sx = min(1.0, max_width / max(1, cw))
         sy = min(1.0, max_height / max(1, ch))

         # Avoid absurd over-condensing; beyond this, fall back to font size reduction.
         # User preference: keep 1 line and shrink X/Y instead of wrapping.
         min_sx = 0.35
         min_sy = 0.60
         if sx < min_sx or sy < min_sy:
            return None, (0, 0)

         new_w = max(1, int(round(cw * sx)))
         new_h = max(1, int(round(ch * sy)))
         resized = cropped.resize((new_w, new_h), getattr(Image, "Resampling", Image).LANCZOS)
         return resized, (new_w, new_h)

      def _fit_wrapped_text(font_path: str, text: str, max_width: int, max_height: int, max_size: int, min_size: int):
         for size in range(int(max_size), int(min_size) - 1, -1):
            f = ImageFont.truetype(font_path, size)
            wrapped = _wrap_text_to_width(text, f, max_width)
            lines = wrapped.split("\n") if wrapped else [""]
            line_h = _font_line_height(f)
            total_h = (len(lines) * line_h) + (max(0, len(lines) - 1) * DESC_LINE_SPACING)
            if total_h <= max_height:
               return wrapped, f
         f = ImageFont.truetype(font_path, int(min_size))
         return _wrap_text_to_width(text, f, max_width), f

      title_font_path = self.config['text']['titleFont']
      desc_font_path = self.config['text']['DescFont']
      title_x, title_y = self.config['text']['title_xy']
      desc_x, desc_y_default = self.config['text']['desc_xy']
      type_x, type_y = self.config['text']['type_xy']
      atk_x, atk_y = self.config['text']['atk_xy']
      scale = int(self.config.get('scale') or 1)
      is_spell_trap = self.json_card.get('card') in ("SPELL", "TRAP")

      # Pillow adds extra spacing between multiline lines by default; keep it tight.
      DESC_LINE_SPACING = max(1, scale // 2)

      # Title: fit into the title box (stops before attribute icon at x=355).
      # NOTE: 355 and padding were authored at 1x; scale them up for hi-res rendering.
      title_max_width = (355 * scale) - title_x - (8 * scale)
      title_text = (self.json_card.get('Title', '') or "").strip()

      # Title band height depends on template; for monsters with Level/Rank row, don't let the
      # title collide with the star row.
      level_row_y = int(self.config['areas']['level_area'][1])
      inferred_title_band_height = max(20 * scale, (level_row_y - (6 * scale)) - title_y)
      title_box_height = min(44 * scale, inferred_title_band_height) if not is_spell_trap else (44 * scale)

      # Use max font size, then shrink non-uniformly if needed to fit.
      TitleFont = ImageFont.truetype(title_font_path, self.config['text']['fontsize48'])

      ATKDEFFont                 = ImageFont.truetype(self.config['text']['titleFont'], self.config['text']['fontsize23'])
      AttrFont                   = ImageFont.truetype(self.config['text']['AttrFont'], self.config['text']['fontsize15'])

      # For Spell/Trap, the textbox no longer has a [TYPE] label line, so start effect higher.
      desc_y = type_y if is_spell_trap else desc_y_default

      # Description: wrap and shrink to fit the effect box above ATK/DEF.
      desc_max_width = self.source_card1.size[0] - desc_x - (35 * scale)
      if is_spell_trap:
         # Spell/Trap templates have no ATK/DEF line; the textbox extends lower.
         desc_bottom_y = (614 * scale) - (36 * scale)
      else:
         desc_bottom_y = atk_y - (6 * scale)
      desc_max_height = max(40 * scale, desc_bottom_y - desc_y)

      # Some DB texts (esp. XYZ/Overlay) contain hard newlines; treat them as spaces so the
      # text can fully utilize the box width before wrapping.
      raw_desc = self.json_card.get('Descripton', '')
      raw_desc = (raw_desc or "").replace("\r\n", "\n").replace("\r", "\n")

      is_extra_deck = self.json_card.get('card') in ("XYZ", "FUSION", "LINK", "SYNCHRO")
      if is_extra_deck and "\n" in raw_desc:
         # Preserve the FIRST newline (materials vs effects), flatten the rest.
         first, rest = raw_desc.split("\n", 1)
         first = re.sub(r"\s+", " ", first).strip()
         rest = re.sub(r"\s+", " ", rest.replace("\n", " ")).strip()
         normalized_desc = f"{first}\n{rest}".strip()
      else:
         normalized_desc = re.sub(r"\s+", " ", raw_desc.replace("\n", " ")).strip()
      wrapped_desc, DescFont = _fit_wrapped_text(
         desc_font_path,
         normalized_desc,
         desc_max_width,
         desc_max_height,
         max_size=self.config['text']['fontsize12'],
         min_size=int(7 * scale),
      )
      
      title_color = self.config['text']['title_color_xyz'] if self.json_card['card'] == "XYZ" else self.config['text']['title_color']

      title_img, (tw, th) = _render_shrunk_title(title_text, TitleFont, title_color, title_max_width, title_box_height)
      if title_img is None:
         # Fallback: reduce font size if shrink would be too extreme.
         TitleFont = _fit_font_to_width(
            title_font_path,
            title_text,
            title_max_width,
            max_size=self.config['text']['fontsize48'],
            min_size=int(18 * scale),
         )
         title_img, (tw, th) = _render_shrunk_title(title_text, TitleFont, title_color, title_max_width, title_box_height)

      title_y_draw = title_y + max(0, (title_box_height - th) // 2)
      self.source_card1.paste(title_img, (title_x, title_y_draw), title_img)
      sleeper(self.image, self.json_card['Title'],self.source_card1,"Rendering Title")

      if not is_spell_trap:
         self.draw.text((self.config['text']['atk_xy']), self.json_card['Atk'], font=ATKDEFFont, fill=self.config['text']['title_color'], align=self.config['text']['text_alignment'])
         self.draw.text((self.config['text']['def_xy']), self.json_card['Def'], font=ATKDEFFont, fill=self.config['text']['title_color'], align=self.config['text']['text_alignment'])
         sleeper(self.image, self.json_card['Title'],self.source_card1,"Rendering ATK/DEF")
      if is_spell_trap:
         # Official Spell/Trap header label, e.g. [Spell Card (icon)] / [Trap Card (icon)]
         st_x = 275 * scale
         st_y = 77 * scale
         st_type = (self.json_card.get("Type") or "").lower()
         icon_name = None
         # Map common sub-types to available symbol icons.
         if "quick" in st_type or "quick-play" in st_type:
            icon_name = "Quick-Play.png"
         elif "continuous" in st_type:
            icon_name = "Continuous.png"
         elif "equip" in st_type:
            icon_name = "Equip.png"
         elif "field" in st_type:
            icon_name = "Field.png"
         elif "ritual" in st_type:
            icon_name = "Ritual.png"
         elif self.json_card.get("card") == "TRAP" and "counter" in st_type:
            icon_name = "Counter.png"

         if icon_name:
            sym_path = self.config['source_path'] + "symbols/" + icon_name
            sym = Image.open(sym_path).convert("RGBA")
            sym = sym.resize((17 * scale, 17 * scale), getattr(Image, "Resampling", Image).LANCZOS)
            base = "[Spell Card" if self.json_card.get("card") == "SPELL" else "[Trap Card"
            # draw base text (without closing bracket)
            self.draw.text((st_x, st_y), base, font=AttrFont, fill=self.config['text']['title_color'], align=self.config['text']['text_alignment'])
            space_w = _text_width(AttrFont, " ")
            base_w = _text_width(AttrFont, base)
            icon_x = int(st_x + base_w + space_w)
            icon_y = int(st_y + (1 * scale))
            self.source_card1.paste(sym, (icon_x, icon_y), sym)
            close_x = int(icon_x + (17 * scale) + space_w)
            self.draw.text((close_x, st_y), "]", font=AttrFont, fill=self.config['text']['title_color'], align=self.config['text']['text_alignment'])
         else:
            label = "[Spell Card]" if self.json_card.get("card") == "SPELL" else "[Trap Card]"
            self.draw.text((st_x, st_y), label, font=AttrFont, fill=self.config['text']['title_color'], align=self.config['text']['text_alignment'])
         sleeper(self.image, self.json_card['Title'],self.source_card1,"Rendering Type")
      else:
         self.draw.text((self.config['text']['type_xy']), "[" + self.json_card['Type'] + "]", font=AttrFont, fill=self.config['text']['title_color'], align=self.config['text']['text_alignment'])
         sleeper(self.image, self.json_card['Title'],self.source_card1,"Rendering Type")
      def _draw_justified_text(xy, text, font, fill, max_width, line_spacing, skip_first_line=False):
         x0, y0 = xy
         y = y0
         line_h = _font_line_height(font)
         lines = (text or "").split("\n")
         for li, line in enumerate(lines):
            words = [w for w in line.split(" ") if w != ""]
            is_last_line = li == (len(lines) - 1)

            if skip_first_line and li == 0:
               self.draw.text((x0, y), " ".join(words), font=font, fill=fill)
            elif is_last_line or len(words) <= 1:
               self.draw.text((x0, y), " ".join(words), font=font, fill=fill)
            else:
               # justify: distribute extra space across gaps
               base = " ".join(words)
               gaps = len(words) - 1
               w_no_extra = _text_width(font, base)
               extra = max(0.0, max_width - w_no_extra)
               extra_per_gap = (extra / gaps) if gaps else 0.0
               # If the required stretch is too large, keep normal spacing (prevents ugly gaps).
               if extra_per_gap > (_text_width(font, " ") * 2.5):
                  self.draw.text((x0, y), base, font=font, fill=fill)
                  y += line_h + line_spacing
                  continue

               xx = x0
               for wi, w in enumerate(words):
                  self.draw.text((xx, y), w, font=font, fill=fill)
                  xx += _text_width(font, w)
                  if wi < gaps:
                     xx += _text_width(font, " ") + extra_per_gap

            y += line_h + line_spacing

      _draw_justified_text(
         (desc_x, desc_y),
         wrapped_desc,
         DescFont,
         self.config['text']['title_color'],
         desc_max_width,
         DESC_LINE_SPACING,
         skip_first_line=is_extra_deck and "\n" in normalized_desc,
      )
      sleeper(self.image, self.json_card['Title'],self.source_card1,"Rendering Description")

   def generateCard(self):
      self.getSources()
      self.pasteImages()
      self.writeText()
      self.setLevel()
      # Persist the final composite after adding Level/Rank stars.
      sleeper(self.image, self.json_card['Title'], self.source_card1, "Rendering Level")
      print("finished..")


