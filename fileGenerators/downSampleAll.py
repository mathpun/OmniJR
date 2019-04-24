import sys
import glob
import csv
import json
import numpy as np
import downSample
import genImage


data_file_path = sys.argv[1]
old_folder_name = data_file_path[data_file_path.rfind('/') + 1:]

new_folder_name = 'Downsampled_'+old_folder_name

ORIGINAL_MAX_DIM = 600

def subdirs(fp):
	return glob.glob(fp+"/*/")

num_alphabets = len(subdirs(data_file_path))


i = 1

#Loop through each alphabet
for alphabet in subdirs(data_file_path):
	print(f"Downsampling alphabet {i}/{num_alphabets}", end = '\r')
	i+=1

	for letter in subdirs(alphabet):

		for individual in glob.glob(letter+"/*.csv"):

			new_file_path = individual.replace(old_folder_name, new_folder_name)
			downSample.compressTo(individual, new_file_path, ORIGINAL_MAX_DIM)

			