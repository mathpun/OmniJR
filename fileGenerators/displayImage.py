import sys
import json
import genImage
import numpy as np

alphabet = int(sys.argv[1])
letter = int(sys.argv[2])
rendition = int(sys.argv[3])

images = json.load(open('../processed_data/images.json','r'))
image_array = images[alphabet][letter][rendition]
img = genImage.Image()
img.pixels = np.array(image_array)
img.display()