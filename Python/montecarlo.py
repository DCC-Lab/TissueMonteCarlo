import numpy as np
import scipy
from vector import *

class Photon:
    def __init__(self):
        self.r = Vector(0,0,0)
        self.u = Vector(0,0,1)
        
        self.ePara = Vector(1,0,0)
        self.ePerp = Vector(0,1,0)
        self.weight = 1.0

    @property
    def isDead(self):
        return self.weight == 0

    @property
    def isAlive(self):
        return self.weight != 0

    def moveBy(self, d):
        self.r += self.u * d

    def scatterBy(self, theta, phi):
        self.rotateReferenceFrameAroundPropagationDirectionBy(phi)
        self.changePropagationDirectionAroundEPerpBy(theta)

    def explicitScatterBy(self, theta, phi):
        cost = np.cos(theta)
        sint = np.sqrt(1-cost*cost)
        cosp = np.cos(phi)
        sinp = np.sin(phi)
        ux = self.u[0]
        uy = self.u[1]
        uz = self.u[2]

        if abs(uz) > 0.9999:
            self.u = Vector(sint*cosp, sint*sinp, cost*uz/abs(uz))
        else:
            temp = np.sqrt(1.0 - uz*uz)
            self.u = Vector(sint*(ux*uz*cosp - uy*sinp)/temp + ux*cost,
                             sint*(uy*uz*cosp + ux*sinp)/temp + uy*cost,
                             -sint*cosp*temp + uz*cost)

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

    def rotateReferenceFrameAroundPropagationDirectionBy(self, phi):
        el = Vector(self.ePara.x, self.ePara.y, self.ePara.z)
        er = Vector(self.ePerp.x, self.ePerp.y, self.ePerp.z)
        ez = Vector(self.u.x, self.u.y, self.u.z)
    
        cos_phi = np.cos(phi);
        sin_phi = np.sin(phi);
    
        self.ePerp.x = er.x * cos_phi + el.x * sin_phi;
        self.ePerp.y = er.y * cos_phi + el.y * sin_phi;
        self.ePerp.z = er.z * cos_phi + el.z * sin_phi;
        
        self.ePara.x = - er.x * sin_phi + el.x * cos_phi;
        self.ePara.y = - er.y * sin_phi + el.y * cos_phi;
        self.ePara.z = - er.z * sin_phi + el.z * cos_phi;

    def changePropagationDirectionAroundEPerpBy(self, inTheta):
        el = Vector(self.ePara.x, self.ePara.y, self.ePara.z)
        er = Vector(self.ePerp.x, self.ePerp.y, self.ePerp.z)
        ez = Vector(self.u.x, self.u.y, self.u.z)

        cos_theta = np.cos(inTheta)
        sin_theta = np.sin(inTheta)
    
        self.ePara.x = el.x * cos_theta + ez.x * sin_theta
        self.ePara.y = el.y * cos_theta + ez.y * sin_theta
        self.ePara.z = el.z * cos_theta + ez.z * sin_theta
        
        self.u.x = - el.x * sin_theta + ez.x * cos_theta
        self.u.y = - el.y * sin_theta + ez.y * cos_theta
        self.u.z = - el.z * sin_theta + ez.z * cos_theta

    def _checkReferenceFrame(self):
        if not self.ePara.isPerpendicularTo(self.ePerp):
            raise ValueError()

        if not self.ePerp.isPerpendicularTo(self.u):
            raise ValueError()

        if not self.u.isPerpendicularTo(self.ePara):
            raise ValueError()

        if not self.ePara.isUnitary:
            raise ValueError()

        if not self.ePerp.isUnitary:
            raise ValueError()

        if not self.u.isUnitary:
            raise ValueError()

class Material:
    def __init__(self, mu_s, mu_a, g):
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.g = g

    @property
    def mu_t(self):
        return self.mu_a + self.mu_s
    
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
    photon = Photon()
    mat = Material(mu_s=60, mu_a = 0.01, g = 0.7)
 
    for i in range(1000000):
        while photon.isAlive and mat.contains(photon):
            d = mat.getScatteringDistance(photon)
            (theta, phi) = mat.getScatteringAngles(photon)
            photon.moveBy(d)
            photon.scatterBy(theta, phi)
            mat.absorbEnergy(photon)
            photon.roulette()
            photon._checkReferenceFrame()
     #       print(photon.r)
