import numpy as np
from vector import *
from material import *

class Photon:
    def __init__(self):
        self.r = Vector(0,0,0)
        self.ez = Vector(0,0,1)    # Propagation
        self.ePerp = Vector(0,1,0) # Perpendicular to scattering plane
        self.weight = 1.0

    @property
    def dir(self) -> Vector:
        return self.ez

    @property
    def ePara(self) -> Vector:
        return self.ez.cross(self.ePerp) 

    @property
    def isDead(self) -> bool :
        return self.weight == 0

    @property
    def isAlive(self) -> bool :
        return self.weight != 0

    def moveBy(self, d):
        self.r += self.ez * d

    def decreaseWeightBy(self, delta):
        self.weight -= delta
        if self.weight < 0:
            self.weight = 0

    def roulette(self):
        chance = 0.1
        if self.weight >= 1e-4 or self.weight == 0:
            return
        elif np.random.random() < chance:
            self.weight /= chance
        else:
            self.weight = 0

    def scatterBy(self, theta, phi):
        el = self.ePara
        # FIXME: erroneous
        # rotateReferenceFrameAroundPropagationDirectionBy(self, phi)
        cos_phi = np.cos(phi);
        sin_phi = np.sin(phi);
        self.ePerp.x = self.ePerp.x * cos_phi + el.x * sin_phi;
        self.ePerp.y = self.ePerp.y * cos_phi + el.y * sin_phi;
        self.ePerp.z = self.ePerp.z * cos_phi + el.z * sin_phi;
        self.ePerp.normalize()
    
        # def changePropagationDirectionAroundEPerpBy(self, theta)    
        cos_theta = np.cos(theta)
        sin_theta = np.sin(theta)
        self.ez.x = - el.x * sin_theta + self.ez.x * cos_theta
        self.ez.y = - el.y * sin_theta + self.ez.y * cos_theta
        self.ez.z = - el.z * sin_theta + self.ez.z * cos_theta
        self.ez.normalize()

    def rotateReferenceFrameAroundPropagationDirectionBy(self, phi):
        cos_phi = np.cos(phi);
        sin_phi = np.sin(phi);
        el = self.ePara
    
        self.ePerp.x = self.ePerp.x * cos_phi + el.x * sin_phi;
        self.ePerp.y = self.ePerp.y * cos_phi + el.y * sin_phi;
        self.ePerp.z = self.ePerp.z * cos_phi + el.z * sin_phi;
        self.ePerp.normalize()
        
    def changePropagationDirectionAroundEPerpBy(self, theta):
        cos_theta = np.cos(theta)
        sin_theta = np.sin(theta)
        el = self.ePara 
    
        self.ez.x = - el.x * sin_theta + self.ez.x * cos_theta
        self.ez.y = - el.y * sin_theta + self.ez.y * cos_theta
        self.ez.z = - el.z * sin_theta + self.ez.z * cos_theta
        self.ez.normalize()

    def _scatterBy(self, theta, phi):
        cost = np.cos(theta)
        sint = np.sqrt(1-cost*cost)
        cosp = np.cos(phi)
        sinp = np.sin(phi)
        ux = self.x
        uy = self.y
        uz = self.z

        if abs(uz) > 0.9999:
            self.ez = Vector(sint*cosp, sint*sinp, cost*uz/abs(uz))
        else:
            temp = np.sqrt(1.0 - uz*uz)
            self.ez = Vector(sint*(ux*uz*cosp - uy*sinp)/temp + ux*cost,
                             sint*(uy*uz*cosp + ux*sinp)/temp + uy*cost,
                             -sint*cosp*temp + uz*cost)
