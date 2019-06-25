import numpy as np
from vector import *
from material import *
from photon import *
import matplotlib.pyplot as plt

import time

if __name__ == "__main__":
    N = 10000
    M = 21
    mat = Material(mu_s=30, mu_a = 1, g = 0., L = (0.1, 0.1, 0.3), N = (M,M,M))
    plt.ion()
    fig = plt.figure()
    startTime = time.time()
    photon = Photon()
    for i in range(N):
        photon.reset()
        while photon.isAlive:
            d = mat.getScatteringDistance(photon)
            (theta, phi) = mat.getScatteringAngles(photon)
            photon.scatterBy(theta, phi)
            photon.moveBy(d)
            mat.absorbEnergy(photon)
            photon.roulette()
        if i % 100 == 0:
            plt.imshow(np.log(mat.energy[:,:,int((M-1)/2)]+0.0001),cmap='hsv')
            plt.title("{0} photons".format(i))
            plt.show()
            plt.pause(0.0001)
    elapsed = time.time() - startTime
    print('{0:.1f} s for {2} photons, {1:.1f} ms per photon'.format(elapsed, elapsed/N*1000, N))
