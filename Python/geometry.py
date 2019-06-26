from vector import *

class Geometry:
    def __init__(self, origin=Vector(0,0,0)):
        self.origin = origin # Global coordinates
        self.boudingBox = None # Local coordinates
        self.objects = []
        self.container = None

    def placeInto(self, container, position):
        # position in local coordinates of container
        self.translate(container.origin + position) 
        self.container = container
        container.append(self)

    def translate(self, position:Vector)
        self.origin += position
    
