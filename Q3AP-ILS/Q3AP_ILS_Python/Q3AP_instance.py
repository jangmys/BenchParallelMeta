import numpy as np
import pickle
import os.path

from numba import jitclass, prange
from numba import int64, njit, threading_layer

######################################
#generate Q3AP 6D cost matrix from flow and dist QAPLIB matrices
def generateQ3AP(dist,flow,dim):
    C = np.int64(np.zeros((dim, dim, dim, dim, dim, dim)))
    for i in range(dim):
        for k in range(dim):
            fik2 = flow[i, k] * flow[i, k]
            for j in range(dim):
                for n in range(dim):
                    djn = dist[j, n]
                    for p in range(dim):
                        for q in range(dim):
                            C[i, j, p, k, n, q] = fik2 * djn * dist[p, q]
    return C
######################################
# read from input file
def read_input(instance):
    #if pickled data available
    picklename="../../instances/pickle/"+instance+".pkl"
    if os.path.isfile(picklename):
        with open(picklename,'rb') as read_file:
            [dim,C] = pickle.load(read_file)
        return C,dim
    #else: read from qaplib and dump pickle
    else:
        filename="../../instances/nug/"+instance+".dat"
        with open(filename, 'r') as f:
            content = f.read()
            lines = content.split('\n')
            dim = np.int64(lines[0])
            A = [[0 for x in range(dim)] for x in range(2 * dim)]
            i = 0

            for l in lines[1:]:
                if not l.strip():
                    continue
                if l.startswith('EOF'):
                    break
                else:
                    A[i] = [int(x) for x in l.split()]
                    i += 1

        flow = np.array(A[0:dim])
        dist = np.array(A[dim:2 * dim])
        C = generateQ3AP(dist,flow,dim)

        with open(picklename, 'wb') as save_file:
        	pickle.dump([dim,C], save_file)

        return C,dim
######################################
