import numpy as np

# There is no gain in speed with this...! 

N = 1000
xMin = 0.8
xMax = 1.2
dx = (xMax-xMin)/N
dTheta = 2*np.pi/N
sqrtTable = []
sinTable = []
cosTable = []

def Sqrt(x):
    i = int((x - xMin)/dx)
    return sqrtTable[i]

def Cos(x):
    i = int(x/dTheta)
    return cosTable[i]

def Sin(x):
    i = int(x/dTheta)
    return sinTable[i]

def InitTables():
    for i in range(N):
        x = xMin + i * dx
        sqrtTable.append(np.sqrt(x))
    for i in range(N):
        x = i * dTheta
        cosTable.append(np.cos(x))
    for i in range(N):
        x = i * dTheta
        sinTable.append(np.sin(x))
