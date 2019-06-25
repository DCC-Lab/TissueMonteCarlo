import numpy as np
import matplotlib.pyplot as plt

class Stats:
    def __init__(self, L = (0.1, 0.1, 0.01), N = (11,11,11)):
        self.L = L
        self.N = N
        self.energy = np.zeros(N)
        self.figure = None

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
        k = int(position.z/self.L[2])
        if k < 0:
            k = 0
        elif k > self.N[2]-1:
            k = self.N[2]-1
        self.energy[i,j,k] += delta

    def show3D(self):
        raise NotImplementedError()

    def show2DPlaneCut(self, plane:str, cutAt:int = None, title=""):
        if self.figure == None:
            plt.ion()
            self.figure = plt.figure()

        plt.title(title)
        if plane == 'xy':
            if cutAt is None:
                cutAt = int((self.N[2]-1)/2)
            plt.imshow(np.log(self.energy[:,:,cutAt]+0.0001),cmap='hsv',extent=[-self.L[0],self.L[0],-self.L[1],self.L[1]],aspect='auto')
        elif plane == 'yz':
            if cutAt is None:
                cutAt = int((self.N[0]-1)/2)
            plt.imshow(np.log(self.energy[cutAt,:,:]+0.0001),cmap='hsv',extent=[-self.L[1],self.L[1],-self.L[2],self.L[2]],aspect='auto')
        elif plane == 'xz':
            if cutAt is None:
                cutAt = int((self.N[1]-1)/2)
            plt.imshow(np.log(self.energy[:,cutAt,:]+0.0001),cmap='hsv',extent=[-self.L[0],self.L[0],-self.L[2],self.L[2]],aspect='auto')
        plt.show()
        plt.pause(0.0001)

    def show2DPlaneIntegration(self, plane:str, title=""):
        if self.figure == None:
            plt.ion()
            self.figure = plt.figure()

        plt.title(title)
        if plane == 'xy':
            sum = self.energy.sum(axis=2)
            plt.imshow(np.log(sum+0.0001),cmap='hsv',extent=[-self.L[0],self.L[0],-self.L[1],self.L[1]],aspect='auto')
        elif plane == 'yz':
            sum = self.energy.sum(axis=0)
            plt.imshow(np.log(sum+0.0001),cmap='hsv',extent=[-self.L[1],self.L[1],-self.L[2],self.L[2]],aspect='auto')
        elif plane == 'xz':
            sum = self.energy.sum(axis=1)
            plt.imshow(np.log(sum+0.0001),cmap='hsv',extent=[-self.L[0],self.L[0],-self.L[2],self.L[2]],aspect='auto')
        plt.show()
        plt.pause(0.0001)
