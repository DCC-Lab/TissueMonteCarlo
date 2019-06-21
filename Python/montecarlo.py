import numpy as np
from vector import *
import time

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

class Material:
    def __init__(self, mu_s, mu_a, g):
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.mu_t = self.mu_a + self.mu_s
        self.g = g
    
    def getScatteringDistance(self, photon) -> float:
        rnd = 0
        while rnd == 0:
            rnd = np.random.random()
        return -np.log(rnd)/self.mu_t

    def getScatteringAngles(self, photon) -> (float, float):
        phi = np.random.random()*2*np.pi
        g = self.g
        if g == 0:
            cost = 2*np.random.random()-1 
        else:
            temp = (1-g*g)/(1-g+2*g*np.random.random())
            cost = (1+g*g - temp*temp)/(2*g)
        return (np.arccos(cost), phi)

    def absorbEnergy(self, photon):
        delta = photon.weight * self.mu_a/self.mu_t
        photon.decreaseWeightBy(delta)

    def contains(self, photon):
        return True

if __name__ == "__main__":
    mat = Material(mu_s=30, mu_a = 0.5, g = 0.8)

    startTime = time.time()
    N = 100
    for i in range(N):
        # print("Photon {0}".format(i))
        photon = Photon()
        while photon.isAlive and mat.contains(photon):
            d = mat.getScatteringDistance(photon)
            (theta, phi) = mat.getScatteringAngles(photon)
            photon.moveBy(d)
            photon.scatterBy(theta, phi)
            mat.absorbEnergy(photon)
            photon.roulette()
    
    elapsed = time.time() - startTime
    print('{0:.1f} ms per photon'.format(elapsed/N*1000))
 