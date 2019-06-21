import numpy as np
import scipy

class Photon:
    def __init__(self):
        self.r = np.array([0,0,0],dtype=float)
        self.u = np.array([0,0,1],dtype=float)
        self.weight = 1.0

    def moveBy(self, d):
        self.r = self.r + self.u * d

    def scatterBy(self, theta, phi):
        cost = np.cos(theta)
        sint = np.sqrt(1-cost*cost)
        cosp = np.cos(phi)
        sinp = np.sin(phi)
        ux = self.u[0]
        uy = self.u[1]
        uz = self.u[2]

        if abs(uz) > 0.9999:
            self.u[0] = sint*cosp
            self.u[1] = sint*sinp
            self.u[2] = cost*uz/abs(uz)
        else:
            temp = np.sqrt(1.0 - uz*uz)
            self.u[0] = sint*(ux*uz*cosp - uy*sinp)/temp + ux*cost;
            self.u[1] = sint*(uy*uz*cosp + ux*sinp)/temp + uy*cost;
            self.u[2] = -sint*cosp*temp + uz*cost;

    def decreaseWeightBy(self, delta):
        self.weight -= delta
        if self.weight < 0:
            self.weight = 0

    @property
    def isDead(self):
        return self.weight == 0

    @property
    def isAlive(self):
        return self.weight != 0

    def roulette(self):
        chance = 0.1
        if self.weight >= 1e-5:
            return
        elif self.weight == 0:
            return
        elif np.random.random() < chance:
            self.weight /= chance
        else:
            self.weight = 0

class Material:
    def __init__(self, mu_s, mu_a, g):
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.g = g

    def getScatteringDistance(self, photon) -> float:
        return np.random.exponential(self.mu_s + self.mu_a)

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
        delta = photon.weight * self.mu_a/(self.mu_a + self.mu_s)
        photon.decreaseWeightBy(delta)

if __name__ == "__main__":
    photon = Photon()
    mat = Material(mu_s=30, mu_a = 0.01, g = 0.9)

    for i in range(100000):
        while photon.isAlive:
            d = mat.getScatteringDistance(photon)
            (theta, phi) = mat.getScatteringAngles(photon)
            photon.moveBy(d)
            photon.scatterBy(theta, phi)
            mat.absorbEnergy(photon)
            photon.roulette()
        # print(p.r)

