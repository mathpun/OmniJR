import sys
import glob
import csv
import json
import numpy as np
import os
import genImage

names = []
drawings = []
timing = []
images = []


data_file_path = sys.argv[1]

processed_data_file_path = data_file_path[:data_file_path.rfind('/')] + '/processed_data/'
print(processed_data_file_path)
if(not os.path.exists(os.path.dirname(processed_data_file_path))):
	os.makedirs(os.path.dirname(processed_data_file_path))

def subdirs(fp):
	return glob.glob(fp+"/*/")

num_alphabets = len(subdirs(data_file_path))

#REPLACE ONCE OFFSET FIGURED OUT
dummy_offsets = [[0, 0] for i in range(num_alphabets)]
json.dump(dummy_offsets, open("processed_data/offsets.json",'w'))


i = 1

#Loop through each alphabet
for alphabet in subdirs(data_file_path):
	print(f"Processing alphabet {i}/{num_alphabets}", end = '\r')
	i+=1

	#Alphabet name is last name in filepath
	alphabet_name = alphabet[:-1][alphabet[:-1].rfind('/')+1:]

	#Each alphabet gets its own lists
	names.append(alphabet_name)
	drawings.append([])
	timing.append([])
	images.append([])

	alphabet_drawings = drawings[-1]
	alphabet_timing = timing[-1]
	alphabet_images = images[-1]

	for letter in subdirs(alphabet):

		#Each letter gets its own lists
		alphabet_drawings.append([])
		alphabet_timing.append([])
		alphabet_images.append([])

		letter_drawings = alphabet_drawings[-1]
		letter_timing = alphabet_timing[-1]
		letter_images = alphabet_images[-1]

		for individual in glob.glob(letter+"/*.csv"):

			stroke_data = csv.reader(open(individual,'r'))

			#Each individual gets its own lists
			letter_drawings.append([])
			letter_timing.append([])
			letter_images.append([])

			this_drawing = letter_drawings[-1]
			this_timing = letter_timing[-1]

			#See genImage but ultimately gets back binary generated image
			letter_images[-1] = genImage.getImageArray(individual)

			cur_stroke_drawing, cur_stroke_time = None, None

			prev_stroke_num = None

			#Loops through rows which are formatted x, y, time, stroke no.
			for row in stroke_data:

				stroke_num = row[3]

				if(stroke_num!=prev_stroke_num):

					#Each stroke gets its own list
					this_drawing.append([])
					this_timing.append([])

					cur_stroke_drawing = this_drawing[-1]
					cur_stroke_time = this_timing[-1]

					prev_stroke_num = stroke_num

				cur_stroke_drawing.append([float(row[0]), float(row[1])])
				cur_stroke_time.append(float(row[2]))

json.dump(names,open('processed_data/names.json','w'))
json.dump(drawings,open('processed_data/drawings.json','w'))
json.dump(timing,open('processed_data/timing.json','w'))
json.dump(images,open('processed_data/images.json','w'))





	

	




