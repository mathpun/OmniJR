import numpy as np
import csv
import matplotlib.pyplot as plt
import downSample

#Image class used for representing general images
class Image:

	#CHANGE IF NOT CORRECT randomly guessed max coords for images in omniJr
	maxC = downSample.MAX_COORD

	#Pixel array maintains binary representation.  0 -> ink, 1 -> no ink
	def __init__(self):
		self.pixels = np.ones([self.maxC, self.maxC], dtype='int32')
		self.ones = []

	def copy(self):
		c = Image()
		c.pixels = np.copy(self.pixels)
		return c

	def ink(self, x, y):
		if (x >= 0 and x < self.maxC and y >= 0 and y < self.maxC):
			self.pixels[y][x] = 0
			self.ones.append((x, y))

	def isInked(self, x, y):
		return self.pixels[y][x] == 0

	#draw on pixels on line between (x1,y1) and (x2,y2)
	def draw(self, x1, y1, x2, y2, d=0.5):
		start = np.array([x1, y1])
		end = np.array([x2, y2])
		delta = end - start

		distance = np.linalg.norm(delta)
		if(distance ==0):
			return
		direction = delta / distance

		step = direction * d
		num_steps = int(distance / d)

		for i in range(num_steps+1):
			pos = start + step * i
			x, y = int(pos[0]), int(pos[1])
			self.ink(x, y)


	#Add thickness to stroke by inking on pixels near currently inked on pixels
	#Repeat process n times
	def thicken(self, n):
		if (n <= 0):
			return

		c = self.copy()

		for x, y in self.ones:
			c.inkAround(x, y)

		self.pixels = c.pixels
		self.thicken(n-1)


	def inkAround(self, x, y):
		for i in range(x-1, x+2):
			for j in range(y-1, y+2):
				self.ink(i, j)

	def display(self):
		plt.imshow(self.pixels * 256, cmap = "gray")
		plt.show()


def getImageArray(csv_file_path):

	img = Image()


	stroke_data = csv.reader(open(csv_file_path, 'r'))

	prev_stroke = None
	prev_point = None

	for row in stroke_data:

		stroke_num = row[3]

		if (stroke_num != prev_stroke):

			prev_stroke = stroke_num
			prev_point = None

		x = float(row[0])
		y = float(row[1])

		if (prev_point != None):

			img.draw(prev_point[0], prev_point[1], x, y)

		prev_point = (x, y)

	img.thicken(2)

	return np.ndarray.tolist(img.pixels)



