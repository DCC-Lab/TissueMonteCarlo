import numpy as np
import matplotlib.pyplot as plt

class Stats:
    def __init__(self, min = (-1, -1, 0), max = (1, 1, 0.5), N = (21,21,21)):
        self.min = min
        self.max = max
        self.L = (self.max[0]-self.min[0],self.max[1]-self.min[1],self.max[2]-self.min[2])
        self.N = N
        self.energy = np.zeros(N)
        self.figure = None

    def score(self, position, delta):
        i = int((self.N[0]-1)*(position.x-self.min[0])/self.L[0])
        j = int((self.N[1]-1)*(position.y-self.min[1])/self.L[1])
        k = int((self.N[2]-1)*(position.z-self.min[2])/self.L[2])

        # print(position, self.min, self.max, self.L)
        # print(i,j,k)

        if i < 0:
            i = 0
        elif i > self.N[0]-1:
            i = self.N[0]-1    

        if j < 0:
            j = 0
        elif j > self.N[1]-1:
            j = self.N[1]-1    

        if k < 0:
            k = 0
        elif k > self.N[2]-1:
            k = self.N[2]-1    

        self.energy[i,j,k] += delta

    def show3D(self):
        raise NotImplementedError()

    def show2D(self, plane:str, cutAt:int= None, integratedAlong:str=None, title="", realtime=True):
        if integratedAlong is None and cutAt is None:
            raise ValueError("You must provide cutAt= or integratedAlong=")
        elif integratedAlong is not None and cutAt is not None:
            raise ValueError("You cannot provide both cutAt= and integratedAlong=")
        elif integratedAlong is None and cutAt is not None:
            if plane == 'xy':
                cutAt = int((self.N[2]-1)/2)
            elif plane == 'yz':
                cutAt = int((self.N[0]-1)/2)
            elif plane == 'xz':
                cutAt = int((self.N[1]-1)/2)

        if self.figure == None:
            plt.ion()
            self.figure = plt.figure()

        plt.title(title)
        if cutAt is not None:
            if plane == 'xy':
                plt.imshow(np.log(self.energy[:,:,cutAt]+0.0001),cmap='hsv',extent=[-self.L[0],self.L[0],-self.L[1],self.L[1]],aspect='auto')
            elif plane == 'yz':
                plt.imshow(np.log(self.energy[cutAt,:,:]+0.0001),cmap='hsv',extent=[-self.L[1],self.L[1],-self.L[2],self.L[2]],aspect='auto')
            elif plane == 'xz':
                plt.imshow(np.log(self.energy[:,cutAt,:]+0.0001),cmap='hsv',extent=[-self.L[0],self.L[0],-self.L[2],self.L[2]],aspect='auto')
        else:
            if plane == 'xy':
                sum = self.energy.sum(axis=2)
                plt.imshow(np.log(sum+0.0001),cmap='hsv',extent=[-self.L[0],self.L[0],-self.L[1],self.L[1]],aspect='auto')
            elif plane == 'yz':
                sum = self.energy.sum(axis=0)
                plt.imshow(np.log(sum+0.0001),cmap='hsv',extent=[-self.L[1],self.L[1],-self.L[2],self.L[2]],aspect='auto')
            elif plane == 'xz':
                sum = self.energy.sum(axis=1)
                plt.imshow(np.log(sum+0.0001),cmap='hsv',extent=[-self.L[0],self.L[0],-self.L[2],self.L[2]],aspect='auto')

        if realtime:
            plt.show()
            plt.pause(0.0001)
            plt.clf()
        else:
            plt.ioff()
            plt.show()

    def show1D(self, axis:str, cutAt=None, integratedAlong=None, title="", realtime=True):
        if integratedAlong is None and cutAt is None:
            # Assume integral
            raise ValueError("You should provide cutAt=(x0, x1) or integratedAlong='xy'.")
        elif integratedAlong is not None and cutAt is not None:
            raise ValueError("You cannot provide both cutAt= and integratedAlong=")
        elif integratedAlong is None and cutAt is not None:
            if axis == 'x':
                cutAt = (int((self.N[1]-1)/2),int((self.N[2]-1)/2))
            elif axis == 'y':
                cutAt = (int((self.N[0]-1)/2),int((self.N[2]-1)/2))
            elif axis == 'z':
                cutAt = (int((self.N[0]-1)/2),int((self.N[1]-1)/2))

        if self.figure == None:
            plt.ion()
            self.figure = plt.figure()

        plt.title(title)
        if cutAt is not None:
            if axis == 'z':
                plt.plot(np.log(self.energy[cutAt[0],cutAt[1],:]+0.0001))
            elif axis == 'y':
                plt.plot(np.log(self.energy[cutAt[0],:,cutAt[1]]+0.0001))
            elif axis == 'x':
                plt.plot(np.log(self.energy[:,cutAt[0],cutAt[1]]+0.0001))
        else:
            if axis == 'z':
                sum = self.energy.sum(axis=(0,1))
                plt.plot(np.log(sum+0.0001))
            elif axis == 'y':
                sum = self.energy.sum(axis=(0,2))
                plt.plot(np.log(sum+0.0001))
            elif axis == 'x':
                sum = self.energy.sum(axis=(1,2))
                plt.plot(np.log(sum+0.0001))


        if realtime:
            plt.show()
            plt.pause(0.0001)
            plt.clf()
        else:
            plt.ioff()
            plt.show()
