import sys
import time
import math
import numpy as np

from numba import jitclass, prange
from numba import int64, njit, threading_layer

from numba.typed import List

import Q3AP
import QAP
import TSP
import FSP

spec = [
    ('perm1', int64[:]),
    ('perm2', int64[:]),
    ('cost', int64),
]

@jitclass(spec)
class solution(object):
    def __init__(self, perm1, perm2, cost):
        self.perm1 = perm1
        self.perm2 = perm2
        self.cost = cost

    def solcopy(self):
        return solution(self.perm1.copy(), self.perm2.copy(), self.cost)

#=====================================
spec = [
    ('perm', int64[:]),
    ('cost', int64),
]

@jitclass(spec)
class solution1(object):
    def __init__(self, perm, cost):
        self.perm = perm
        self.cost = cost

    def solcopy(self):
        return solution(self.perm.copy(), self.cost)

########################################################
#Evaluation functions
########################################################
#EVAL Q3AP
@njit
def evalQ3AP(perm1,perm2):
    cost = 0
    for i in range(dim):
        for j in range(dim):
            cost += C[i, perm1[i], perm2[i],
                      j, perm1[j], perm2[j]]
    return cost

#EVAL QAP
@njit
def evalQAP(perm):
    cost = 0
    for i in range(dim):
        for j in range(dim):
            cost += dist[i,j]*flow[perm[i], perm[j]]
    return cost


#EVAL FSP
@njit
def evalFSP(perm):
    tmp = np.zeros(nbMach,dtype=int64)

    for i in range(nbJob):
        jb = perm[i]
        tmp[0] += PTM[0,jb]
        for j in range(1,nbMach):
            tmp[j] = max(tmp[j],tmp[j-1]) + PTM[j,jb]

    return tmp[nbMach-1]


@njit
def getCost(a, b):
    dx = xcoord[a] - xcoord[b]
    dy = ycoord[a] - ycoord[b]
    return dx * dx + dy * dy


@njit
def evalTSP(perm):
	# global dim
	cost = math.sqrt(getCost(0, perm[1]))
	for i in range(1,dim-1):
		cost += math.sqrt(getCost(perm[i], perm[i + 1]))
	cost += math.sqrt(getCost(perm[dim - 1], 0))
	return cost
########################################################

########################################################
#Parallel Batch Evaluation functions
########################################################
@njit(parallel=True)
def testQAP(pop):
    costs = np.zeros(batchsize)
    for i in prange(batchsize):
        costs[i] = evalQAP(pop[i]['perm'])
    return costs

#fails!
# @njit(parallel=True)
# def testQAPP(lst):
#     for i in prange(batchsize):
#         c=evalQAP(lst[i])

# @njit
# def popGen(size,batchsize):
#     lst = List()
#     for i in range(batchsize):
#         lst.append(np.random.permutation(size))
#     return lst

@njit(parallel=True)
def testFSP(pop):
    costs = np.zeros(batchsize)
    for i in prange(batchsize):
        costs[i] = evalFSP(pop[i]['perm'])
    # print(costs)
    return costs

@njit(parallel=True)
def testTSP(pop):
    costs = np.zeros(batchsize)
    for i in prange(batchsize):
        costs[i] = evalTSP(pop[i]['perm'])
    return costs

@njit(parallel=True)
def testQ3AP(pop):
    costs = np.zeros(batchsize)
    for i in prange(batchsize):
        costs[i] = evalQ3AP(pop[i]['perm1'],pop[i]['perm2'])
    return costs

########################################################
batchsize = int(sys.argv[3])
repeat = int(1e6/batchsize)

####################################
#read input
if sys.argv[1] == "QAP":
    print("QAP")
    dist,flow,dim = QAP.read_input(sys.argv[2])
    # print(dim,dist,flow)

    sol = solution1(np.arange(dim, dtype=np.int64), 0)
    sol.cost = evalQAP(sol.perm)
    print(sol.cost)

    sol1_type = np.dtype([('perm', np.int64, (dim,)), ('cost', np.int64, (1,))])
    pop = np.array([(np.random.permutation(dim), 0) for x in range(batchsize)], dtype=sol1_type)
    testQAP(pop)

    t1start = time.time()
    t2elapsed = 0.0

    for i in range(repeat):
        pop = np.array([(np.random.permutation(dim), 0) for x in range(batchsize)], dtype=sol1_type)

        t2start = time.time()
        testQAP(pop)
        t2elapsed += time.time() - t2start

    elapsed_time = time.time() - t1start
    print('EvalLoop:\t', t2elapsed)
    print('Elapsed:\t', elapsed_time)

###########################################################
if sys.argv[1] == "Q3AP":
###########################################################
    print("Q3AP - instance? (nug12,...): ",sys.argv[2])
    C,dim = Q3AP.read_input(sys.argv[2])
	#warmup
    sol = solution(np.arange(dim, dtype=np.int64), np.arange(dim, dtype=np.int64), 0)
    sol.cost = evalQ3AP(sol.perm1,sol.perm2)

	#needed....
    sol_type = np.dtype([('perm1', np.int64, (dim,)), ('perm2', np.int64, (dim,)), ('cost', np.int64, (1,))])
    pop = np.array([(np.random.permutation(dim), np.random.permutation(dim), 0) for x in range(batchsize)], dtype=sol_type)
    testQ3AP(pop)

    t1start = time.time()
    t2elapsed = 0.0
    for i in range(repeat):
        pop = np.array([(np.random.permutation(dim), np.random.permutation(dim), 0) for x in range(batchsize)], dtype=sol_type)
        t2start = time.time()
        testQ3AP(pop)
        t2elapsed += time.time() - t2start

    elapsed_time = time.time() - t1start
    print('EvalLoop:\t', t2elapsed)
    print('Elapsed:\t', elapsed_time)

###########################################################
if sys.argv[1] == "TSP":
###########################################################
    print("TSP - instance? (berlin52,...): ",sys.argv[2])
    xcoord,ycoord,dim = TSP.read_input(sys.argv[2])
	#warmup
    sol = solution1(np.arange(dim, dtype=np.int64), 0)
    sol.cost = evalTSP(sol.perm)

    sol1_type = np.dtype([('perm', np.int64, (dim,)), ('cost', np.int64, (1,))])
    pop = np.array([(np.random.permutation(dim), 0) for x in range(batchsize)], dtype=sol1_type)
    testTSP(pop)

    t1start = time.time()
    t2elapsed = 0.0
    for i in range(repeat):
        pop = np.array([(np.random.permutation(dim), 0) for x in range(batchsize)], dtype=sol1_type)
        t2start = time.time()
        testTSP(pop)
        t2elapsed += time.time() - t2start

    elapsed_time = time.time() - t1start
    print('EvalLoop:\t', t2elapsed)
    print('Elapsed:\t', elapsed_time)

###########################################################
if sys.argv[1] == "FSP":
###########################################################
    print("FSP - instance? (ta001,...): ",sys.argv[2])
    PTM,nbJob,nbMach = FSP.read_input(sys.argv[2])
	#warmup
    sol = solution1(np.arange(nbJob, dtype=np.int64), 0)
    sol.cost = evalFSP(sol.perm)

    sol1_type = np.dtype([('perm', np.int64, (nbJob,)), ('cost', np.int64, (1,))])
    pop = np.array([(np.random.permutation(nbJob), 0) for x in range(batchsize)], dtype=sol1_type)
    testFSP(pop)

    t1start = time.time()
    t2elapsed = 0.0
    for i in range(repeat):
        pop = np.array([(np.random.permutation(nbJob), 0) for x in range(batchsize)], dtype=sol1_type)
        t2start = time.time()
        testFSP(pop)
        t2elapsed += time.time() - t2start

    elapsed_time = time.time() - t1start
    print('EvalLoop:\t', t2elapsed)
    print('Elapsed:\t', elapsed_time)
