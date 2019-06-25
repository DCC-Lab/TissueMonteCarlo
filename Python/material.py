import numpy as np
from collections import namedtuple
import matplotlib.pyplot as plt

class Material:
    def __init__(self, mu_s, mu_a, g, L = (0.1, 0.1, 0.01), N = (11,11,11)):
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.mu_t = self.mu_a + self.mu_s
        self.g = g
        self.L = L
        self.N = N
        self.energy = np.zeros(N)
        self.figure = None

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
        self.score(photon.r, delta)

    def score(self, position, delta):
        i = int(position.x/self.L[0]) + int((self.N[0]-1)/2)
        if i < 0:
            i = 0
        elif i > self.N[0]-1:
            i = self.N[0]-1
        j = int(position.y/self.L[1]) + int((self.N[1]-1)/2)
        if j < 0:
            j = 0
        elif j > self.N[1]-1:
            j = self.N[1]-1
        k = int(position.z/self.L[2]) + int((self.N[2]-1)/2)
        if k < 0:
            k = 0
        elif k > self.N[2]-1:
            k = self.N[2]-1
        self.energy[i,j,k] += delta

    def contains(self, photon):
        return True

    def showEnergyDeposition(self, plane:str, cutAt:int = None, title=""):
        if self.figure == None:
            plt.ion()
            self.figure = plt.figure()

        plt.title(title)
        if plane == 'xy':
            if cutAt is None:
                cutAt = int((self.N[2]-1)/2)
            plt.imshow(np.log(self.energy[:,:,cutAt]+0.0001),cmap='hsv',extent=[-self.L[0],self.L[0],-self.L[1],self.L[1]])
        elif plane == 'yz':
            if cutAt is None:
                cutAt = int((self.N[0]-1)/2)
            plt.imshow(np.log(self.energy[cutAt,:,:]+0.0001),cmap='hsv',extent=[-self.L[1],self.L[1],-self.L[2],self.L[2]])
        elif plane == 'xz':
            if cutAt is None:
                cutAt = int((self.N[1]-1)/2)
            plt.imshow(np.log(self.energy[:,cutAt,:]+0.0001),cmap='hsv',extent=[-self.L[0],self.L[0],-self.L[2],self.L[2]])
        plt.show()
        plt.pause(0.0001)



