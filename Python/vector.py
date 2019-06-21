import numpy as np
from collections import namedtuple

class Vector:
    def __init__(self, x=0,y=0,z=0):
        if isinstance(x, np.ndarray):
            self.x = x
            self.y = y 
            self.z = z #Vector(x[0],x[1],x[2]) #np.array(x,dtype=float)
        elif isinstance(x, Vector):
            self.x = x.x
            self.y = x.y 
            self.z = x.z #Vector(x[0],x[1],x[2]) #np.array(x,dtype=float)
        else:
            self.x = x
            self.y = y 
            self.z = z

    @property
    def isUnitary(self):
        return abs(self.norm()-1)<1e-7
    
    @property
    def tuple(self):
        Vec = namedtuple('Vec', 'x y z')
        return Vec(self.x, self.y,self.z)

    def __str__(self):
        return "({0:.4f},{1:.4f},{2:.4f})".format(self.x, self.y, self.z)

    def __getitem__(self, index):
        if index == 0:
            return self.x
        elif index == 1:
            return self.y
        else:
            return self.z

    def __mul__(self, scale):
        return Vector(self.x * scale, self.y * scale, self.z * scale)

    def __rmul__(self, scale):
        return Vector(self.x * scale, self.y * scale, self.z * scale)

    def __div__(self, scale):
        return self.v * 1/scale

    def __add__(self, vector):
        return Vector(self.x + vector.x, self.y + vector.y, self.z + vector.z)

    def __radd__(self, vector):
        return Vector(self.x + vector.x, self.y + vector.y, self.z + vector.z)

    def __sub__(self, vector):
        return Vector(self.x - vector.x, self.y - vector.y, self.z - vector.z)

    def __rsub__(self, vector):
        return Vector(-self.x + vector.x, -self.y + vector.y, -self.z + vector.z)

    def norm(self):
        return self.x*self.x + self.y*self.y + self.z*self.z

    def normalize(self):
        length = np.sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
        self.x /= length
        self.y /= length
        self.z /= length

    def abs(self):
        return np.sqrt(self.x*self.x + self.y*self.y + self.z*self.z)

    def cross(self, vector):
        return Vector(self.y*vector.z - self.z*vector.y, 
                      self.z*vector.x - self.x*vector.z, 
                      self.x*vector.y - self.y*vector.x)

    def dot(self, vector):
        return self.x*vector.x + self.y*vector.y + self.z*vector.z 

    def normalizedCrossProduct(self, vector):
        productNorm = self.norm() * vector.norm()
        return self.cross(vector)/ np.sqrt(productNorm)

    def normalizedDotProduct(self, vector):
        productNorm = self.norm() * vector.norm()
        return self.dot(vector)/ np.sqrt(productNorm)

    def orientedAngleBetween(self, u, v, w):
        sinPhi = u.normalizedCrossProduct(v)
        sinPhiAbs = abs(sinPhi)
        phi = np.arcsin(sinPhiAbs)
    
        if u.dot(v) <= 0:
            phi = np.pi-phi

        if sinPhi.dot(w) <= 0:
            phi *= -1 
    
        return phi;

    def rotateAroundX(self, phi):
        v = Vector(self.x, self.y, self.z)
        
        c = np.cos(phi);
        s = np.sin(phi);
    
        self.y = c * v.y - s * v.z;
        self.z = s * v.y + c * v.z;

    def rotateAroundY(self, phi):
        v = Vector(self.x, self.y, self.z)
        
        c = np.cos(phi)
        s = np.sin(phi)
    
        self.x = c * v.x + s * v.z
        self.z = -s * v.x + c * v.z

    def rotateAroundZ(self, phi):
        v = Vector(self.x, self.y, self.z)
        
        c = np.cos(phi)
        s = np.sin(phi)
    
        self.x = c * v.x - s * v.y
        self.y = s * v.x + c * v.y
        self.z = v.z

    def isParallelTo(self, vector):
        return (self.normalizedDotProduct(vector) - 1 < 1e-6)

    def isPerpendicularTo(self, vector):
        return (self.normalizedDotProduct(vector) < 1e-6)
