import numpy as np
import pickle

# read from input file
def read_input(instname):
    filename="../../instances/fsp/"+instname+".dat"
    with open(filename, 'r') as f:
        content = f.read()
        lines = content.split('\n')

        nbJob = int(lines[0].split()[0])
        nbMach = int(lines[0].split()[1])

        PTM = np.zeros([nbMach,nbJob],dtype=int)

        i = 0
        for l in lines[1:]:
            # print(l)
            if not l.strip():
                continue
            if l.startswith('EOF'):
                break
            else:
                PTM[i] = [int(x) for x in l.split()]
                i += 1

    return PTM,nbJob,nbMach
