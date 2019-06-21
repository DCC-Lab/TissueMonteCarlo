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

    def norm(self):
        return self.x*self.x + self.y*self.y + self.z*self.z

    def normalize(self):
        self.v /= self.abs

    def abs(self):
        return np.sqrt(self.norm())

    def crossProduct(self, vector):
        return np.cross(self.v, vector)

    def dotProduct(self, vector):
        return np.dot(self.v, vector)

    def normalizedCrossProduct(self, vector):
        productNorm = self.norm() * vector.norm()
        return np.cross(self.v, vector) / np.sqrt(productNorm)

    def normalizedDotProduct(self, vector):
        productNorm = self.norm() * vector.norm()
        return np.dot(self.v, vector) / np.sqrt(productNorm)

    def orientedAngleBetween(self, u, v, w):
        sinPhi = u.normalizedCrossProduct(v)
        sinPhiAbs = abs(sinPhi)
        phi = np.arcsin(sinPhiAbs);
    
        if u.dotProduct(v) <= 0:
            phi = PI-phi;

        if sinPhi.dotProduct(w) <= 0:
            phi *= -1
    
        return phi;

    def rotateAroundX(self, inPhi):
        v = Vector(self.v)
        u = Vector()
        
        c = np.cos(inPhi);
        s = np.sin(inPhi);
    
        self.y = c * v.y - s * v.z;
        self.z = s * v.y + c * v.z;

    def rotateAroundY(self, inPhi):
        v = Vector(self.v)
        u = Vector()
        
        c = np.cos(inPhi);
        s = np.sin(inPhi);
    
        self.x = c * v.y + s * v.z;
        self.z = -s * v.y + c * v.z;

    def rotateAroundZ(self, inPhi):
        v = Vector(self.v)
        u = Vector()
        
        c = np.cos(inPhi);
        s = np.sin(inPhi);
    
        self.x = c * v.x - s * v.y;
        self.y = s * v.x + c * v.y;
        self.z = v.z;
