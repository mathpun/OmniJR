import json
from parser import *
import io 
import IPython.display
import os 
import base64
import numpy as np
import shutil
import scipy
from scipy import ndimage
import pdb
import seaborn as sns
from datetime import datetime
import dateutil.parser
import csv
import matplotlib.pyplot as plt
sns.set_style("white")
dataFolder = 'OMNIGLOT_JR4_USE/'
outputFolder = 'test_out2/'


## definition statement, helper functions
def terminalUnfuck(string):
    newString = string.replace(" ", "\ ")
    newString = newString.replace("(", "\(" )
    newString = newString.replace(")", "\)" )
    return newString
                               
#Changed
def getx(p):
    return p[1][u'x']

def gety(p):
    return p[1][u'y']

def plotstroke_new(ax, onestroke, onecolor, file_ind, outputDirectory):
    #print onestroke
    xs = list(map(lambda x: x[0], onestroke))
    ys = list(map(lambda x: x[1], onestroke))
    ySizeOfImage = 500
    xSizeOfImage = 500
    assert(len(xs) == len(ys))
    #this flips the axis 
    ax.invert_yaxis()
    
    for i in range(len(xs)):
        x, y = xs[:i], ys[:i]
        temp_plot = ax.plot(x,y,lw=3, color=onecolor)
        plt.savefig(os.path.join(outputDirectory, 'image%02d_%04d' %(file_ind, i)))
    
    ax.invert_yaxis()

def flatList(l):
    return [item for sublist in l for item in sublist]

def makeimage(letter, outputDirectory):

    strokeColors = ["blue","red","green","yellow","magenta","black",
                   "cyan", sns.xkcd_rgb["poop"], sns.xkcd_rgb["faded green"],sns.xkcd_rgb["dusty purple"],
                    sns.xkcd_rgb["hot pink"],sns.xkcd_rgb["golden yellow"],sns.xkcd_rgb["electric purple"],
                    sns.xkcd_rgb["light lime"],sns.xkcd_rgb["egg shell"],sns.xkcd_rgb["brick red"],
                    sns.xkcd_rgb["baby blue"],sns.xkcd_rgb["yellow"],sns.xkcd_rgb["violet"],sns.xkcd_rgb["aqua"],
                    sns.xkcd_rgb["brick red"],sns.xkcd_rgb["lilac"],sns.xkcd_rgb["olive"],sns.xkcd_rgb["olive"],
                    sns.xkcd_rgb["peach"],sns.xkcd_rgb["lime"],sns.xkcd_rgb["dark pink"],
                    sns.xkcd_rgb["navy"],sns.xkcd_rgb["rust"],sns.xkcd_rgb["slate"],
                    sns.xkcd_rgb["coral"],sns.xkcd_rgb["sage"],sns.xkcd_rgb["grape"],
                    sns.xkcd_rgb["wine"],sns.xkcd_rgb["vomit"],sns.xkcd_rgb["sky"],
                    sns.xkcd_rgb["lemon"],sns.xkcd_rgb["maize"],sns.xkcd_rgb["celery"],
                    sns.xkcd_rgb["wheat"],sns.xkcd_rgb["watermelon"],sns.xkcd_rgb["drab"],
                    sns.xkcd_rgb["snot"],sns.xkcd_rgb["berry"],sns.xkcd_rgb["golden"],
                    sns.xkcd_rgb["wine"],sns.xkcd_rgb["vomit"],sns.xkcd_rgb["sky"],
                    sns.xkcd_rgb["lemon"],sns.xkcd_rgb["maize"],sns.xkcd_rgb["celery"]
                   ]
    #strokes = letter[u'strokes']
    strokes = list(letter)
    f = plt.figure() # ray
    ax = f.gca() # ray
    plt.yticks([])
    plt.xticks([])
    plt.xlim(0,500)
    plt.ylim(0,500)
    allX = []
    allY = []
    allStrokeNumbers = []
    
    allTimes = []
    init_time = strokes[0][0][2]
    def rel_time_index(p):
        time = p[0]
        td =  dateutil.parser.parse(time) - init_time_index
        ms = int(td.seconds*1000 + td.microseconds/1000)
        return ms
    
    for i in range(len(strokes)):
        color = strokeColors[i]
        stroke = strokes[i]
        stroke = [w for w in stroke]
        xs = list(map(lambda x: x[0], stroke))
        ys = list(map(lambda x: x[1], stroke))
        times = list(map(lambda x: x[2] - init_time, stroke))
        allX.append(xs)
        allY.append(ys)
        allStrokeNumbers.append([i+1]*len(stroke))
        allTimes.append(times)
        
        plotstroke_new(ax, stroke, color, i, outputDirectory)
    allX = flatList(allX)
    allY = flatList(allY)
    allStrokeNumbers = flatList(allStrokeNumbers)
    allTimes = flatList(allTimes)
    joint = np.array([allX, allY, allTimes, allStrokeNumbers]).transpose()
    with open(os.path.join(outputDirectory, 'data.csv'), 'w+') as f:
        csv_writer = csv.writer(f, delimiter=",")
        for row in joint:
            csv_writer.writerow(row)

def process_file(in_path, out_path):
    with open(in_path, 'r') as f:
        dat = csv.reader(f, delimiter=',')
        new_dat = []
        last_stroke = -1
        curr_stroke = []
        for row in dat:
            x = float(row[0])
            y = float(row[1])
            t = float(row[2])
            stroke = int(float(row[3]))
            if stroke != last_stroke and len(curr_stroke) > 0:
                new_dat.append(curr_stroke)
                curr_stroke = []
            last_stroke = stroke
            curr_stroke.append((x, y, t, stroke))
        if len(curr_stroke) > 0:
            new_dat.append(curr_stroke)
    makeimage(new_dat, out_path)
    print(out_path)
    print(os.path.join(out_path, '\'*.png\''))
    os.system("ffmpeg -framerate 30 -pattern_type glob -i '" + terminalUnfuck(os.path.join(out_path, '*.png\'')) + " -c:v libx264 -pix_fmt yuv420p " + terminalUnfuck(os.path.join(out_path, "out.mp4")))
    os.system("convert -delay 1.5 " + terminalUnfuck(os.path.join(out_path, '*.png')) + ' ' + terminalUnfuck(os.path.join(out_path, "tout.gif")))


for alph in os.listdir(dataFolder):
    if not os.path.isdir(os.path.join(dataFolder, alph)) or alph == '.DS_Store':
        continue
    for letter in os.listdir(os.path.join(dataFolder, alph)):
        if not os.path.isdir(os.path.join(dataFolder, alph, letter)) or letter == '.DS_Store':
            continue
        for char in os.listdir(os.path.join(dataFolder, alph, letter)):
            if '.csv' not in char:
                continue
            if not os.path.exists(os.path.join(outputFolder, alph, letter, char[:-4])):
                os.makedirs(os.path.join(outputFolder, alph, letter, char[:-4]))
            process_file(os.path.join(dataFolder, alph, letter, char), os.path.join(outputFolder, alph, letter, char[:-4]))
            print(alph, letter, char)

