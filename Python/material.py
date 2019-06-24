import numpy as np
from collections import namedtuple

class Material:
    def __init__(self, mu_s, mu_a, g, L = (0.1, 0.1, 0.01), N = (11,11,11)):
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.mu_t = self.mu_a + self.mu_s
        self.g = g
        self.L = L
        self.N = N
        self.energy = np.zeros(N)
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

        i = int(photon.r.x/self.L[0]) + int((self.N[0]-1)/2)
        if i < 0:
            i = 0
        elif i > self.N[0]-1:
            i = self.N[0]-1
        j = int(photon.r.y/self.L[1]) + int((self.N[1]-1)/2)
        if j < 0:
            j = 0
        elif j > self.N[1]-1:
            j = self.N[1]-1
        k = int(photon.r.z/self.L[2]) + int((self.N[2]-1)/2)
        if k < 0:
            k = 0
        elif k > self.N[2]-1:
            k = self.N[2]-1
        self.energy[i,j,k] += delta

    def contains(self, photon):
        return True
