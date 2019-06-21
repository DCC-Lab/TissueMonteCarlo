import numpy as np

class Vector:
    def __init__(self, x=0,y=0,z=0):
        if isinstance(x, list):
            self.v = np.array(x,dtype=float)
        else:
            self.v = np.array([x,y,z],dtype=float)

    @property
    def x(self):
        return self.v[0]

    @property
    def y(self):
        return self.v[1]

    @property
    def z(self):
        return self.v[2]

    def __getitem__(self, index):
        return self.v[index]

    def __mul__(self, scale):
        return self.v * scale

    def __rmul__(self, scale):
        return self.v * scale

    def __div__(self, scale):
        return self.v / scale

    def __add__(self, vector):
        return self.v + vector

    def __radd__(self, vector):
        return self.v + vector

    def __sub__(self, vector):
        return self.v - vector

    def __rsub__(self, vector):
        return vector - self.v
