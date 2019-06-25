import numpy as np
from vector import *
from material import *
from photon import *

import time

if __name__ == "__main__":
    N = 100
    M = 21
    mat = Material(mu_s=100, mu_a = 1, g = 0)

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
            mat.stats.show2D(plane='xy', cutAt=10, title="{0} photons".format(i))
            #mat.stats.show1D(axis='z', title="{0} photons".format(i))

    elapsed = time.time() - startTime
    print('{0:.1f} s for {2} photons, {1:.1f} ms per photon'.format(elapsed, elapsed/N*1000, N))
    mat.stats.show2D(plane='xy', cutAt=10, title="{0} photons".format(i), realtime=False)
