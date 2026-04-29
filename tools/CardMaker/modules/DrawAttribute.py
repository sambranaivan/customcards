from PIL import Image, ImageDraw

_RESAMPLE = getattr(Image, "Resampling", Image).LANCZOS


class DrawAttribute():
   def __init__(self, attribute, area, attribute_image) -> None:
      self.attribute = attribute
      self.area = area
      self.attribute_image = Image.open(attribute_image).convert('RGBA')
      self.attribute_image = self.attribute_image.resize((40, 40), _RESAMPLE)

   def getAttribute(self):
      return self.attribute_image