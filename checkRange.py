import os
import csv

data = 'Downsampled2_Omniglot_JR_ALL2'
# data = '../omniglot/python/strokes_background_small1'

max_x = float('-inf')
max_y = float('-inf')

min_x = float('inf')
min_y = float('inf')

for file in os.listdir(data):
	if os.path.isdir(data + '/' + file):
		for file2 in os.listdir(data + '/' + file):
			if os.path.isdir(data + '/' + file + '/' + file2):
				for file3 in os.listdir(data + '/' + file + '/' + file2):
					if file3.endswith('.csv'):
						with open(data + '/' + file + '/' + file2 + '/' + file3) as f:
							rows = csv.reader(f, delimiter=',')
							for row in rows:
								if len(row) == 1:
									continue
								x = float(row[0])
								y = float(row[1])

								if x > max_x:
									max_x = x
								if y > max_y:
									max_y = y
								if x < min_x:
									min_x = x
								if y < min_y:
									min_y = y

# for file3 in os.listdir(data):
# 	if file3.endswith('.csv'):
# 		with open(data + '/' + file3) as f:
# 			rows = csv.reader(f, delimiter=',')
# 			for row in rows:
# 				x = float(row[0])
# 				y = float(row[1])

# 				if x > max_x:
# 					max_x = x
# 				if y > max_y:
# 					max_y = y
# 				if x < min_x:
# 					min_x = x
# 				if y < min_y:
# 					min_y = y


print('max x %f, max y %f' % (max_x, max_y))
print('min x %f, min y %f' % (min_x, min_y))

