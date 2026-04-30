from PIL import Image

_RESAMPLE = getattr(Image, "Resampling", Image).LANCZOS


class DrawArtwork():
   def __init__(self, artwork, artarea, art_image, size=(320, 320)) -> None:
      self.artwork = artwork
      self.artarea = artarea
      self.art_image = Image.open(art_image).convert('RGBA')
      self.art_image1 = self.art_image.resize(tuple(size), _RESAMPLE)

   def getArtwork(self):
      return self.art_image1