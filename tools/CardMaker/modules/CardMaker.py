from _config import *
from Creator import *
from PIL import Image, ImageDraw, ImageFont
import os
import re
import random

serial_id = random.randint(000000000, 999999999)

'''
@Author: DevCycle
@Version: 0.3
@new: Added Classes

@important
 •
'''

class DrawImage():
    global image_with_text
    global image
    global draw
    global attribute_image
    global source_card
    global source_card1
    global image_height
    global image_width

    if card == "Effect":
        source_card = "Card-effect.png"
    elif card == "Trap":
        source_card = "Card-trap.png"
    elif card == "Spell":
        source_card = "Card-spell.png"
    elif card == "XYZ":
        source_card = "Card-xyz.png"
    elif card == "Synchro":
        source_card = "Card-synchro.png"
    elif card == "Token":
        source_card = "Card-token.png"
    elif card == "Ritual":
        source_card = "Card-ritual.png"
    elif card == "Pendel":
        source_card = "Card-effect-pendulum.png"
    elif card == "Fusion":
        source_card = "Card-fusion.png"
    elif card == "Link":
        source_card = "Card-link.png"
    elif card == "Trap Anime":
       source_card = "Card-trap-anime.png"
    elif card == "Spell Anime":
       source_card = "Card-spell-anime.png"

    image = Image.open(souce_path + path_cards + source_card).convert('RGBA')
    image_with_text = Image.new('RGBA', image.size, (255,255,255,0))
    draw = ImageDraw.Draw(image_with_text)
    image_width = image.size[0]
    image_height = image.size[1]
    print("Source Image: " + source_card)

class DrawLevelImage():
    if lvlcolor == "red":
        level_image = "Level-Red.png"
    elif lvlcolor == "blue":
        level_image = "Level-Blue.png"
    elif lvlcolor == "green":
        level_image = "Level-Green.png"
    elif lvlcolor == "black":
        level_image = "Level-black.png"
    else:
        # Sensible default: XYZ uses black levels; others use red.
        level_image = "Level-black.png" if card == "XYZ" else "Level-Red.png"

    level_file = Image.open(souce_path + path_lvl + level_image).convert("RGBA")
    lvl_img = level_file.resize((25, 25), getattr(Image, "Resampling", Image).LANCZOS)

    # IMPORTANT: don't mutate the global `area_x` across cards; it causes drift.
    start_x = 380
    start_y = 76
    for i in range(int(Level or 0)):
        x = start_x - (27 * (i + 1))
        image_with_text.paste(lvl_img, (x, start_y), lvl_img)

class DrawImageCard():
    global image_with_text1
    global image1
    global outanime
    global areaanime
    global card1

    card_image = Image.open(souce_path + path_cardimg + image_card)

    if card == "Spell Anime":
        areaanime = 9, 10 
        card1 = card_image.resize((382,408),Image.ANTIALIAS)
    elif card == "Trap Anime":
        areaanime = 9, 10 
        card1 = card_image.resize((382,408),Image.ANTIALIAS)
    else:
        area = 51, 113 
        card = card_image.resize((320,320),Image.ANTIALIAS)

    if card == "Spell Anime":
        image_with_text.paste(card1, areaanime)
        outanime = Image.alpha_composite(image, image_with_text)
    elif card == "Trap Anime":
        image_with_text.paste(card1, areaanime)
        outanime = Image.alpha_composite(image, image_with_text)
    else:
        image_with_text.paste(card, area)
        print("Card Image: " + image_card + "\n")

class DrawText():
    print("Final font size: ",fontsize)

    def _font_line_height(font: ImageFont.FreeTypeFont) -> int:
        # Use a stable representative bbox for line height.
        bbox = font.getbbox("Ag")
        return max(1, bbox[3] - bbox[1])

    def _text_width(font: ImageFont.FreeTypeFont, text: str) -> float:
        # Pillow >=8 has getlength; fallback to bbox width.
        if hasattr(font, "getlength"):
            return float(font.getlength(text))
        bbox = font.getbbox(text)
        return float(bbox[2] - bbox[0])

    def _wrap_text_to_width(text: str, font: ImageFont.FreeTypeFont, max_width: int) -> str:
        # Preserve explicit newlines; wrap each paragraph independently.
        paragraphs = (text or "").split("\n")
        wrapped_paragraphs: list[str] = []

        for para in paragraphs:
            words = re.split(r"\s+", para.strip()) if para.strip() else [""]
            lines: list[str] = []
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
                    # Single token too wide; hard-split.
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

    def _fit_wrapped_text(font_path: str, text: str, max_width: int, max_height: int, max_size: int, min_size: int):
        for size in range(int(max_size), int(min_size) - 1, -1):
            f = ImageFont.truetype(font_path, size)
            wrapped = _wrap_text_to_width(text, f, max_width)
            lines = wrapped.split("\n") if wrapped else [""]
            line_h = _font_line_height(f)
            total_h = (len(lines) * line_h)
            if total_h <= max_height:
                return wrapped, f
        f = ImageFont.truetype(font_path, int(min_size))
        return _wrap_text_to_width(text, f, max_width), f

    # --- Title auto-fit (prevents overflow, esp. XYZ/Overlay names) ---
    # Title should fit before the Attribute icon at x=355 and with a little padding.
    _title_max_width = 355 - title_x - 8
    TitleFont1 = _fit_font_to_width(TitleFont, Title, _title_max_width, max_size=48, min_size=28)

    # --- Effect text wrap + auto-shrink (prevents overflow) ---
    # Text box ends before ATK/DEF line.
    _desc_max_width = (image_width - desc_x - 35) if "image_width" in globals() else 350
    _desc_bottom_y = atk_y - 6
    _desc_max_height = max(40, _desc_bottom_y - desc_y)
    Description, DescFont1 = _fit_wrapped_text(DescFont, Description, _desc_max_width, _desc_max_height, max_size=17, min_size=10)

    if card == "XYZ":
        draw.text((title_x, title_y), Title, font=TitleFont1, fill=title_color_xyz, align=text_alignment)
        draw.text((type_x, type_y), Type, font=AttrFont1, fill=desc_color, align=text_alignment)
        draw.text((atk_x, atk_y), Attack, font=font3, fill=desc_color, align=text_alignment)
        draw.text((auflage_x, auflage_y), auflage, font=font4, fill=title_color_xyz, align=text_alignment)
        draw.text((card_id_x, card_id_y), card_id, font=font4, fill=title_color_xyz, align=text_alignment)
        draw.text((serial_x, serial_y), str(serial_id), font=font4, fill=title_color_xyz, align=text_alignment)

    elif card == "Trap":
        desc_y = desc_y - 20
        draw.text((title_x, title_y), Title, font=TitleFont1, fill=title_color, align=text_alignment)
        draw.text((type_x, type_y), Type, font=AttrFont1, fill=desc_color, align=text_alignment)
        draw.text((desc_x, desc_y), Description, font=DescFont1, fill=desc_color, align=text_alignment)
        draw.text((auflage_x, auflage_y), auflage, font=font4, fill=title_color, align=text_alignment)
        draw.text((card_id_x, card_id_y), card_id, font=font4, fill=title_color, align=text_alignment)
        draw.text((serial_x, serial_y), str(serial_id), font=font4, fill=title_color, align=text_alignment)            
    
    elif card == "Spell":
        desc_y = desc_y - 20
        draw.text((title_x, title_y), Title, font=TitleFont1, fill=title_color, align=text_alignment)
        draw.text((desc_x, desc_y), Description, font=DescFont1, fill=desc_color, align=text_alignment)
        draw.text((auflage_x, auflage_y), auflage, font=font4, fill=title_color, align=text_alignment)
        draw.text((card_id_x, card_id_y), card_id, font=font4, fill=title_color, align=text_alignment)
        draw.text((serial_x, serial_y), str(serial_id), font=font4, fill=title_color, align=text_alignment)

    elif card == "Link":
        draw.text((atk_x, atk_y), Attack, font=font3, fill=desc_color, align=text_alignment)
        draw.text((auflage_x, auflage_y), "", font=font4, fill=title_color, align=text_alignment)
    else:
        draw.text((title_x, title_y), Title, font=TitleFont1, fill=title_color, align=text_alignment)
        draw.text((type_x, type_y), Type, font=AttrFont1, fill=desc_color, align=text_alignment)
        draw.text((desc_x, desc_y), Description, font=DescFont1, fill=desc_color, align=text_alignment)
        draw.text((serial_x, serial_y), str(serial_id), font=font4, fill=title_color, align=text_alignment)
        draw.text((atk_x, atk_y), Attack, font=font3, fill=desc_color, align=text_alignment)
        draw.text((auflage_x, auflage_y), auflage, font=font4, fill=title_color, align=text_alignment)
        draw.text((def_x, def_y), Defense, font=font3, fill=desc_color, align=text_alignment)
        draw.text((card_id_x, card_id_y), card_id, font=font4, fill=title_color, align=text_alignment)
class DrawSpellTrapText():
    stText_x = 275
    stText_y = 77

    if card == "Trap":
        if cardkind == "Counter":
            draw.text((stText_x, stText_y), "[Trap     ]", font=AttrFont1, fill=title_color, align=text_alignment)
            cardkind_img = "Counter.png"
            symbol_path = Image.open(souce_path + path_symbol + cardkind_img)
            symbol_img = symbol_path.resize((17,17),Image.ANTIALIAS)
            stArea = stText_x + 50, stText_y + 1
            image_with_text.paste(symbol_img, stArea)
        if cardkind == "Continuous":
            draw.text((stText_x, stText_y), "[Trap     ]", font=AttrFont1, fill=title_color, align=text_alignment)
            cardkind_img = "Continuous.png"
            symbol_path = Image.open(souce_path + path_symbol + cardkind_img)
            symbol_img = symbol_path.resize((17,17),Image.ANTIALIAS)
            stArea = stText_x + 50, stText_y + 1
            image_with_text.paste(symbol_img, stArea)
        if cardkind == "":
            stText_x = 280
            stText_y = 77
            draw.text((stText_x, stText_y), "[Trap Card]", font=AttrFont1, fill=title_color, align=text_alignment)

    elif card == "Spell":
        if cardkind == "Counter":
            stText_x = 280
            stText_y = 77
            draw.text((stText_x, stText_y), "[Spell Card    ]", font=AttrFont1, fill=title_color, align=text_alignment) 
        if cardkind == "Continuous":
            draw.text((stText_x, stText_y), "[Spell Card    ]", font=AttrFont1, fill=title_color, align=text_alignment)
            cardkind_img = "Continuous.png"
            symbol_path = Image.open(souce_path + path_symbol + cardkind_img)
            symbol_img = symbol_path.resize((17,17),Image.ANTIALIAS)
            stArea = stText_x + 55, stText_y + 1
            image_with_text.paste(symbol_img, stArea)
        if cardkind == "":
            stText_x = 280
            stText_y = 77
            draw.text((stText_x, stText_y), "[Spell Card]", font=AttrFont1, fill=title_color, align=text_alignment)

class DrawCardType():
    if Attribute == "Void":
        attribute_image = "Void.png"
    elif Attribute == "Time":
        attribute_image = "Time.png"
    elif Attribute == "Trap":
        attribute_image = "Trap.png"
    elif Attribute == "Spell":
        attribute_image = "Spell.png"
    elif Attribute == "Wind":
        attribute_image = "Wind.png"
    elif Attribute == "Light":
        attribute_image = "Light.png" 
    elif Attribute == "Fire":
        attribute_image = "Fire.png"
    elif Attribute == "Earth":
        attribute_image = "Earth.png"
    elif Attribute == "Divine":
        attribute_image = "Divine.png"
    elif Attribute == "Dark":
        attribute_image = "Dark.png"
    elif Attribute == "":
        attribute_image = "Empty.png"    

    attribute_path = Image.open(souce_path + path_type + attribute_image).convert('RGBA')
    attribute_img = attribute_path.resize((40,40),Image.ANTIALIAS)
    area_x = 355
    area_y = 29
    area = area_x, area_y
    image_with_text.paste(attribute_img, area)

class DrawCornerSign():
    corner_img = "Cornerdefault.png"
    attribute_path = Image.open(souce_path + path_extras + corner_img)
    attribute_img = attribute_path.resize((20,20),Image.ANTIALIAS)
    area_x = 387
    area_y = 580
    area = area_x, area_y
    image_with_text.paste(attribute_img, area)

class DrawCardRarity():
    global tmpout
    tmpout = Image.alpha_composite(image, image_with_text)
    tmpout.save("tmpout.png")
    if rarity == "Shatterfoil":
        card_border = Image.open(souce_path + path_rarity + "Shatter.png")
        image_with_text.paste(card_border)
        print("Card Rarity: Shatterfoil Rare")    
    elif rarity == "Mosaic":
        card_border = Image.open(souce_path + path_rarity + "Mosaic.png")
        image_with_text.paste(card_border)
        print("Card Rarity: Mosaic Rare")  
    elif rarity == "Secret":
        area = 51, 113 
        card_image = Image.open(souce_path + path_rarity + "Secret.png")
        card = card_image.resize((320,320),Image.ANTIALIAS)
        image_with_text.paste(card, area)
        print("Card Rarity: Secret Rare")    
    else:
        print("Card Rarity: None")

class DrawLinkArrow():
    global linkLevel
    linkLevel = 0

    tmpout = Image.alpha_composite(tmpout, image_with_text)
    tmpout.save("tmpout.png")
    if card == "Link":

        if linkField[0][0] == 1:
            linkTM_image = "LM-TopLefta.png"
            linkLevel = linkLevel + 1
        else:
            linkTM_image = "LM-TopLeft-false.png"

        area_lx = 35
        area_ly = 95
        area = area_lx, area_ly
        link_file = Image.open(souce_path + path_linkarrow + linkTM_image)
        image_with_text.paste(link_file, area)


        if linkField[0][1] == 1:
            linkTM_image = "LM-Top.png"
            linkLevel = linkLevel + 1
        else:    
            linkTM_image = "LM-Top-false.png"

        area_lx = 163
        area_ly = 89
        area = area_lx, area_ly
        link_file = Image.open(souce_path + path_linkarrow + linkTM_image)
        image_with_text.paste(link_file, area)


        if linkField[0][2] == 1:
            linkTM_image = "LM-TopRight.png"
            linkLevel = linkLevel + 1
        else:
            linkTM_image = "LM-TopRight-false.png"
        
        area_lx = 345
        area_ly = 95
        area = area_lx, area_ly
        link_file = Image.open(souce_path + path_linkarrow + linkTM_image)
        image_with_text.paste(link_file, area)


        if linkField[1][0] == 1:
            linkTM_image = "LM-Left.png"
            linkLevel = linkLevel + 1
        else:
            linkTM_image = "LM-Left-false.png"
        
        area_lx = 25
        area_ly = 225
        area = area_lx, area_ly
        link_file = Image.open(souce_path + path_linkarrow + linkTM_image)
        image_with_text.paste(link_file, area)


        if linkField[1][1] == 1:
            print("Empty")

        if linkField[1][2] == 1:
            linkTM_image = "LM-Right.png" 
            linkLevel = linkLevel + 1 
        else:
            linkTM_image = "LM-Right-false.png"
        
        area_lx = 370
        area_ly = 225
        area = area_lx, area_ly
        link_file = Image.open(souce_path + path_linkarrow + linkTM_image)
        image_with_text.paste(link_file, area)


        if linkField[2][0] == 1:
            linkTM_image = "LM-BottomLeft.png"
            linkLevel = linkLevel + 1
        else:
            linkTM_image = "LM-BottomLeft-false.png"

        area_lx = 35
        area_ly = 406
        area = area_lx, area_ly
        link_file = Image.open(souce_path + path_linkarrow + linkTM_image)
        image_with_text.paste(link_file, area)

        if linkField[2][1] == 1:
            linkTM_image = "LM-Bottom.png"  
            linkLevel = linkLevel + 1  
        else:
            linkTM_image = "LM-Bottom-false.png"  

        area_lx = 163
        area_ly = 430
        area = area_lx, area_ly
        link_file = Image.open(souce_path + path_linkarrow + linkTM_image)
        image_with_text.paste(link_file, area)


        if linkField[2][2] == 1:
            linkTM_image = "LM-BottomRight.png"
            linkLevel = linkLevel + 1
        else:
            linkTM_image = "LM-BottomRight-false.png"
        
        area_lx = 345
        area_ly = 405
        area = area_lx, area_ly
        link_file = Image.open(souce_path + path_linkarrow + linkTM_image)
        image_with_text.paste(link_file, area)

    if card == "Link":
        Defense = str(linkLevel)
        draw.text((375, def_y), Defense, font=font3, fill=desc_color, align=text_alignment)

image = Image.open("tmpout.png").convert('RGBA')
os.remove("tmpout.png")

if card == "Spell Anime":   
    outanime.show()  

    file_name = re.sub(r"[^a-zA-Z0-9 | ]*","", Title).replace(" ", "_")+'.png'
    outanime.save(os.path.join(output_dir, file_name))
elif card == "Trap Anime":
    image_with_text.paste(card1, areaanime)
    outanime.show()  

    file_name = re.sub(r"[^a-zA-Z0-9 | ]*","", Title).replace(" ", "_")+'.png'
    outanime.save(os.path.join(output_dir, file_name))
else:
    out = Image.alpha_composite(image, image_with_text)
    out.show()  

    file_name = re.sub(r"[^a-zA-Z0-9 | ]*","", Title).replace(" ", "_")+'.png'
    out.save(os.path.join(output_dir, file_name))
l = 0
N = 0
with open("modules/_config.py", "a+") as file:
    for lines in file:
        print(lines)
    file.writelines('\n"../' + output_dir + file_name + '",')


print(l)