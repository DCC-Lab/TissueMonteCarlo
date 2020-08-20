from ctypes import *
from vector import *
import numpy as np
from numpy.ctypeslib import ndpointer

lib = cdll.LoadLibrary('libCVector.dylib')
lib.RealV_x.restype = c_double
lib.RealV_y.restype = c_double
lib.RealV_z.restype = c_double
lib.RealV_rotateAround.restype = ndpointer(dtype=c_double, shape=(3,))
lib.RealV_newWithArray.argtypes = [ndpointer(dtype=c_double, shape=(3,))]

class FastVector:
    def __init__(self, x,y, z):
        self.obj = lib.RealV_newWith( c_double(x), c_double(y), c_double(z))

    def __del__(self):
        lib.RealV_delete(self.obj)

    def rotateAround(self, u, phi:float):
        lib.RealV_rotateAround(self.obj, c_double(u.x), c_double(u.y), c_double(u.z), c_double(phi))

    def rotateAroundFast(self, uFast, phi:float):
        lib.RealV_rotateAroundFast(self.obj, uFast.obj, c_double(phi))

    @property
    def x(self):
        return lib.RealV_x(self.obj)
    
    @property
    def y(self):
        return lib.RealV_y(self.obj)

    @property
    def z(self):
        return lib.RealV_z(self.obj)


for i in range(1000000):
    v = FastVector(1.0,2.0,3.0)
    v2 = FastVector(1,-1,3)
    v.rotateAroundFast(v2, 0.01)

