import datetime
import json
import os

def loadDataFromFolder(datadir):
    """Loads all of the drawcopy data from the specified directory into a list of TestSubject"""
    norm_datadir = os.path.expanduser(datadir)
    dircontents = [os.path.normcase(x) for x in os.listdir(os.path.expanduser(norm_datadir))]
    files = {x: os.path.join(norm_datadir, x) for x in dircontents if os.path.splitext(x)[1]==".json"}

    test_image_jsons = jsonFromFile(files.pop("test-image-data.json"))
    test_sequence_jsons = jsonFromFile(files.pop("test-sequence-data.json"))
    test_subject_jsons = [jsonFromFile(files.pop(x + ".json")) for x in jsonFromFile(files.pop("manifest.json"))]

    print([x for x in test_image_jsons])
    
    
    test_images = {int(key): TestImage(test_image_jsons[key]) for key in test_image_jsons.keys()}
    test_sequences = {int(key): TestSequence(test_images, test_sequence_jsons[key]) for key in test_sequence_jsons.keys()}
    test_subjects = [TestSubject(test_sequences, x) for x in test_subject_jsons]
    return test_subjects

def jsonFromFile(file):
    with open(file) as data:
        return json.load(data)

def parseIsoTime(str):
    try:
        return datetime.datetime.strptime(str,"%Y-%m-%dT%H:%M:%S.%fZ")
    except ValueError:
        return datetime.datetime.strptime(str,"%Y-%m-%dT%H:%M:%SZ")

class TestImage:
    """TestImage represents a particular image used to test the subjects."""
    def __init__(self,json):
        self.name = json[u"name"]
        self.strokes = [{parseIsoTime(y[0]): y[1]
            for y in x} for x in json[u"data"][u""]]

class TestSequence:
    """TestSequence represents a list (with possible repetitions) of images that constitute a test template."""
    def __init__(self, test_images, json):
        self.name = json[u"name"]
        self.tests = [test_images[x] for x in json[u"tests"]]

class TestSubject:
    """TestSubject represents a particular run of a test sequence for a particular subject.

    The images that make up the individual test results of a TestSubject can be iterated over with a for loop.
    """
    def __init__(self, test_sequences, json):
        self.name = json[u"name"]
        self.time = parseIsoTime(json[u"time"])
        self.sequence = test_sequences[json[u"sequence"]]
        self.results = [TestInstance(x) for x in json[u"results"]]
    def __iter__(self):
        return self.results.__iter__()

class TestInstance:
    """TestInstance represents a particular element of a subject's test sequence

    The strokes that make up the individual test instance can be iterated over with a for loop.
    """
    def __init__(self, json):
        #Changed
        self.results = [TestStroke(x) for x in json[u"data"][u""]]

    def __iter__(self):
        return self.results.__iter__()

class TestStroke:
    """TestStroke represents a particular stroke of an image created by a subject.

    The points of the image can either by accessed as a dictionary from datetime object
    to a dictionary of the {x: x-coord, y: y-coord} coordinates.
    The points can also be accessed in the order that they were drawn by a for loop.
    The elements of this loop are again of the shape {x: x-coord, y: y-coord}.
    """
    def __init__(self, json):
        self.results = {parseIsoTime(key): [key,json[key]] for key in json.keys()}

    def __iter__(self):
        sortedKeys = sorted(list(self.results.keys()))
        sortedValues = [self.results.get(x) for x in sortedKeys]
        return sortedValues.__iter__()

def exampleFun():
    """Example which iterates through all the points recorded in the dataset."""
    for x in loadDataFromFolder("~/Dropbox/Apps/drawcopy-dan/"):
        # x is a particular test subject's results
        for y in x:
            #y is a particular image the test subject created
            for z in y:
                #z is a particular stroke in the subject's image
                for w in z:
                    #w is a point in the subject's stroke
                    #these are looped over in the order they were drawn
                    print(w)

