import numpy as np
from vector import *
from material import *
from photon import *

import time

if __name__ == "__main__":
    mat = Material(mu_s=30, mu_a = 0.5, g = 0.8)

    startTime = time.time()
    N = 200
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
    print('{0:.1f} s for {2} photons, {1:.1f} ms per photon'.format(elapsed, elapsed/N*1000, N))
 