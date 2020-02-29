runs = 20
delta = 1 # x 0.01 cm
print("1.0 # file version")
print("{0} # Number of runs".format(runs))
print("")
print("")

for i in range(1,runs+1):
    print("# Specific data for run {0}".format(i))
    d = delta*i/100
    print("Out{0:03d}.mco A".format(i*delta))
    print("1000000")
    print("20e-4    20e-4")
    print("10   20  30")
    print("")
    print("1")
    print("#n   mua.  musx   musz  g    d") 
    print("1.0")
    print("1.4  0.01    158    359    0.86    {0}".format(d))
    print("1.0")
    print("\n")
