import numpy as np

class Vector:
    def __init__(self, x=0,y=0,z=0):
        if isinstance(x, np.ndarray):
            self.v = x.copy() #np.array(x,dtype=float)
        elif isinstance(x, Vector):
            self.v = Vector(x.x, x.y, x.z)
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

    @x.setter
    def x(self, value):
        self.v[0] = value
        
    @y.setter
    def y(self, value):
        self.v[1] = value
        
    @z.setter
    def z(self, value):
        self.v[2] = value

    @property
    def isUnitary(self):
        return abs(self.norm()-1)<1e-7
    
    def __str__(self):
        return "({0:.4f},{1:.4f},{2:.4f})".format(self.x, self.y, self.z)

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
