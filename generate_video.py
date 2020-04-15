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
sns.set_style("white")
dataFolder = 'PilotData_K/'
outputFolder = dataFolder + "allOutput_Extra/"


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
    xs = list(map(getx,onestroke))
    ys = list(map(gety,onestroke))
    ySizeOfImage = 500
    xSizeOfImage = 500
    assert(len(xs) == len(ys))
    #this flips the axis 
    ax.invert_yaxis()
    
    for i in range(len(xs)):
        x, y = xs[:i], ys[:i]
        temp_plot = ax.plot(x,y,lw=3, color=onecolor)
        savefig(outputDirectory + 'image%02d_%04d' %(file_ind, i))
    
    ax.invert_yaxis()
    
#     ## TOMER EDITING HERE
#     strokeDirectory = outputFolder + "tomerInsanity/"
#     f2 = figure()
#     ax2 = f2.gca()
#     ax2.invert_yaxis()
#     for i in range(len(xs)):
#         x, y = xs[:i], ys[:i]
#         temp_plot = ax2.plot(x,y,lw=3, color=onecolor)
#     ## TOMER EDITING HERE
#     savefig(strokeDirectory + "stroke" + str(file_ind))
#     ax2.invert_yaxis()
#     ## TOMER END EDITING HERE
    


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
    f = figure() # ray
    ax = f.gca() # ray
    yticks([])
    xticks([])
    xlim(0,500)
    ylim(0,500)
    allX = []
    allY = []
    allStrokeNumbers = []
    
    #Added
    allTimes = []
    init_time = list(strokes[0])[0][0]
    init_time_index = dateutil.parser.parse(init_time)
    def rel_time_index(p):
        time = p[0]
        td =  dateutil.parser.parse(time) - init_time_index
        ms = int(td.seconds*1000 + td.microseconds/1000)
        return ms
    
    for i in range(len(strokes)):
        color = strokeColors[i]
        stroke = strokes[i]
        stroke = [w for w in stroke]
        xs = map(getx, stroke)
        ys = map(gety, stroke)
        times = map(rel_time_index, stroke)
        allX.append(xs)
        allY.append(ys)
        allStrokeNumbers.append([i+1]*len(stroke))
        #Added
        allTimes.append(times)
        
        plotstroke_new(ax, stroke, color, i, outputDirectory) 
    allX = flatList(allX)
    allY = flatList(allY)
    allStrokeNumbers = flatList(allStrokeNumbers)
    
    #Added
    allTimes = flatList(allTimes)
    joint = array([allX, allY, allTimes, allStrokeNumbers]).transpose()
    savetxt(outputDirectory + "data.csv", joint, delimiter=",")
   

allSubjects = loadDataFromFolder(dataFolder)
for subjectIndex, subject in enumerate(allSubjects):
    for letterIndex, letter in enumerate(subject):
        try:
            withinChildOutputDirectory = outputFolder + "/" + \
                                         subject.name + \
                                         "/" + str(letterIndex) + "/"
            if os.path.isdir(withinChildOutputDirectory):
                shutil.rmtree(withinChildOutputDirectory)
            os.makedirs(withinChildOutputDirectory)
            makeimage(letter, withinChildOutputDirectory) 


            #Makes movie and gif

            #directoryToImages = "/Users/cocosci/Desktop/ray_out/"
            os.system("ffmpeg -framerate 30 -pattern_type glob -i '" + \
                      terminalUnfuck(withinChildOutputDirectory) + \
                       "*.png' -c:v libx264 -pix_fmt yuv420p " + 
                      terminalUnfuck(withinChildOutputDirectory) + "out.mp4")

            os.system("convert -delay 1.5 " + terminalUnfuck(withinChildOutputDirectory) +  \
                       "/*.png " + terminalUnfuck(withinChildOutputDirectory) + "tout.gif")
        except:
            # sometimes files are missing watchagonnado move on
            pass
        plt.close()