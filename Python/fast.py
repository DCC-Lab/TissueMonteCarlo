import numpy as np

class Fast:
    def __init__(self, xMin, xMax, N):
        self.xMin = xMin
        self.xMax = xMax
        self.dx = (xMax-xMin)/N
        self.dTheta = 2*np.pi/N
        self.N = N
        self.sqrtTable = []
        self.sinTable = []
        self.cosTable = []
        # self.sqrtTable = self.computeSqrt()
        # self.sinTable = self.computeSin()
        # self.cosTable = self.computeCos()
        print("Computing sqrt")
        for i in range(self.N):
            x = self.xMin + i * self.dx
            self.sqrtTable.append(np.sqrt(x))
        for i in range(self.N):
            x = i * self.dTheta
            self.cosTable.append(np.cos(x))
        for i in range(self.N):
            x = i * self.dTheta
            self.sinTable.append(np.sin(x))
        print("Computing done")

    def computeSqrt(self):
        print("Computing sqrt")
        for i in range(self.N):
            x = self.xMin + i * self.dx
            self.sqrtTable.append(np.sqrt(x))
        print("Ready")

    def computeCos(self):
        print("Computing cos")
        for i in range(self.N):
            x = i * self.dTheta
            self.cosTable.append(np.cos(x))
        print("Ready")

    def computeSin(self):
        print("Computing sin")
        for i in range(self.N):
            x = i * self.dTheta
            self.sinTable.append(np.sin(x))
        print("Ready")

    def sqrt(self, x):
        # if x < self.xMin or x > self.xMax:
        #     print("Out of range")
        #     return np.sqrt(x)
        # else:
        i = int((x - self.xMin)/self.dx)
        return self.sqrtTable[i]

    def cos(self, x):
        # theta = x % (2 * np.pi)
        # if x < 0 or x > 2 * np.pi:
        #     return np.cos(theta)
        # else:
        i = int(x/self.dTheta)
        return self.cosTable[i]

    def sin(self, x):
        # theta = x % (2 * np.pi)
        # if x < 0 or x > 2 * np.pi:
        #     return np.sin(theta)
        # else:
        i = int(x/self.dTheta)
        return self.sinTable[i]
