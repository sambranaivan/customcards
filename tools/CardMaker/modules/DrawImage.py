from PIL import Image, ImageDraw

_RESAMPLE = getattr(Image, "Resampling", Image).LANCZOS


class DrawImage():

   def __init__(self, card, area, card_image, size=(421, 614)) -> None:
      self.card = card
      self.area = area
      self._original = Image.open(card_image).convert('RGBA')
      self.card_image = self._original.resize(tuple(size), _RESAMPLE)
      self.finishCard = Image.new('RGBA', self.card_image.size, (255,255,255,0))
      # Start from the resized template so compositing always matches dimensions.
      self.finishCard = self.card_image.copy()

   def getimage(self):
      return self.card_image

   def getSourceCard(self):
      return self.finishCard
  