import numpy as np
import pickle

ixcoord = []
iycoord = []

# read from input file
def read_input(instname):
    filename="../../instances/tsp/"+instname+".tsp"
    with open(filename, 'r') as f:
        content = f.read()
        lines = content.split('\n')
        # print(lines)

        dim = int(lines[3].split()[-1])

        for line in lines[6:]:
            if line.startswith('EOF'):
                break
            else:
                X, Y = line.split()[1:]
                ixcoord.append(float(X))
                iycoord.append(float(Y))

        xcoord = np.zeros(dim,dtype=float)
        ycoord = np.zeros(dim,dtype=float)

        for i in range(0,dim):
            xcoord[i] = ixcoord[i]
            ycoord[i] = iycoord[i]

    return xcoord,ycoord,dim
