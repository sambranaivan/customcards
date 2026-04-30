from PIL import Image, ImageDraw

_RESAMPLE = getattr(Image, "Resampling", Image).LANCZOS


class DrawLevel():
   def __init__(self, level, area, level_image, size=(25, 25)) -> None:
      self.level = level
      self.area = area
      self.level_image = Image.open(level_image).convert('RGBA')
      self.level_image = self.level_image.resize(tuple(size), _RESAMPLE)

   def getLevel(self):
      return self.level_image