import fileinput
import numpy as np

table = None
for line in fileinput.input():
    floatValues = [ float(v) for v in line.split()]
    for value in floatValues:
        if table is None:
            table = np.ndarray(shape=(1))
            table[0] = value
        else:
            table = np.append(table, value)

table = table.reshape(50,20)
for i in range(50):
    for j in range(20):
        print(table[i,j],end="")
        print("\t",end="")
    print("")