from PIL import Image, ImageDraw

_RESAMPLE = getattr(Image, "Resampling", Image).LANCZOS


class DrawImage():

   def __init__(self, card, area, card_image) -> None:
      self.card = card
      self.area = area
      self.card_image = Image.open(card_image).convert('RGBA')
      self.finishCard = Image.new('RGBA', self.card_image.size, (255,255,255,0))
      self.finishCard = self.card_image.resize((421, 614), _RESAMPLE)

   def getimage(self):
      return self.card_image

   def getSourceCard(self):
      return self.finishCard
  