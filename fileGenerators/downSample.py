import csv
import os

MAX_COORD = 105

def compressTo(original_file, new_file, original_dim, new_dim = MAX_COORD):
	original = csv.reader(open(original_file, 'r'))
	
	if (not os.path.exists(os.path.dirname(new_file))):
		os.makedirs(os.path.dirname(new_file))
	new = csv.writer(open(new_file, 'w'))

	scaling_factor = new_dim/original_dim

	for original_row in original:
		newX = float(original_row[0])*scaling_factor
		newY = float(original_row[1])*scaling_factor

		new_row = [newX, newY] + original_row[2:]
		new.writerow(new_row)