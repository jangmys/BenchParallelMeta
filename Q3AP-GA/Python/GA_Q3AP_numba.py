import sys
import time

import copy
import random
import numpy as np
import numba as nb
from numba import jitclass, int64
from numba import njit, prange

import Q3AP

####################################
POPSIZE = 100
#read input
C,dim = Q3AP.read_input(sys.argv[1])

def generateNhood(dim):
    moves = np.empty([0,4],dtype=np.int64)
    for i in range(dim):
        for k in range(dim):
            for j in range(i, dim):
                for l in range(k, dim):
                    moves = np.vstack([moves, np.int64([i, j, k, l])])
    return moves

moves = generateNhood(dim)

sol_type = np.dtype([('perm1', np.int64, (dim,)), ('perm2', np.int64, (dim,)), ('cost', np.int64, (1,))])
nb_sol_type = nb.from_dtype(sol_type)


@njit
def CC(i,j,p,k,n,q):
    return C[i,j,p,k,n,q]


@njit
def eval(sol):
    cost = 0
    for i in range(dim):
        for j in range(dim):
            cost += CC(i, sol['perm1'][i], sol['perm2'][i],
                      j, sol['perm1'][j], sol['perm2'][j])
    return cost


@njit
def applyMove(sol, mv):
    sol['perm1'][mv[0]], sol['perm1'][mv[1]] = sol['perm1'][mv[1]], sol['perm1'][mv[0]]
    sol['perm2'][mv[2]], sol['perm2'][mv[3]] = sol['perm2'][mv[3]], sol['perm2'][mv[2]]


#unpack solution before and pass [perm1,perm2]
#unpacking of dtype in jitted prange loop fails for some reason [file bug report?]
@njit #(parallel=True) #(int64(nb_sol_type,int64[:]))
def evalDelta(perm1,perm2,mv):
    delta = 0
    #
    for i in range(dim):
        if i != mv[0] and i != mv[1] and i != mv[2] and i != mv[3]:
            continue

        # avoid actually performing the swap
        p1i = perm1[i]
        p2i = perm2[i]
        if i == mv[0]:
            p1i = perm1[mv[1]]
        if i == mv[1]:
            p1i = perm1[mv[0]]
        if i == mv[2]:
            p2i = perm2[mv[3]]
        if i == mv[3]:
            p2i = perm2[mv[2]]

        for j in range(dim):
            p1j = perm1[j]
            p2j = perm2[j]
            if j == mv[0]:
                p1j = perm1[mv[1]]
            if j == mv[1]:
                p1j = perm1[mv[0]]
            if j == mv[2]:
                p2j = perm2[mv[3]]
            if j == mv[3]:
                p2j = perm2[mv[2]]

            delta += CC(i, perm1[i], perm2[i],
                       j, perm1[j], perm2[j])
            delta -= CC(i, p1i, p2i, j, p1j, p2j)

            if j != mv[0] and j != mv[1] and j != mv[2] and j != mv[3]:
                delta += CC(j, perm1[j], perm2[j],
                           i, perm1[i], perm2[i])
                delta -= CC(j, p1j, p2j, i, p1i, p2i)
    return np.int64(delta)


@njit(parallel=True)
def evalDeltas(sol):
    cost_arr = np.zeros(len(moves),dtype=int64)
    p1 = sol['perm1']
    p2 = sol['perm2']

    for i in prange(len(moves)):
        cost_arr[i] = evalDelta(p1,p2,moves[i])

    bestind = np.argmax(cost_arr)
    delta = cost_arr[bestind]

    return delta,bestind


@njit(parallel=True)
def evalPop(pop):
    c=np.zeros(len(pop))
    for i in prange(len(pop)):
        c[i]=eval(pop[i])
    return c


@njit
def localSearch(sol, maxiter):
    iter = 0
    # eval(sol) -- better...make same change in Julia and C codes

    for i in range(maxiter):
        delta,bestind = evalDeltas(sol)
        # bestind = np.argmax(csts)
        #delta = csts[bestind]

        iter += 1
        if delta > 0:
            applyMove(sol, moves[bestind])
            sol['cost'][0] -= delta
        else:
            break
    return iter


def POSxover(par1, par2):
    off = (np.negative(np.ones(dim, dtype=int)), np.negative(np.ones(dim, dtype=int)), 0)

    for k in range(2):  # for both permutations
        flag = np.zeros(dim)
        # randomly choose between 3 and dim-3 positions
        pos = np.random.choice(np.arange(dim), np.random.randint(3, dim-3), False)
        # copy
        off[k][pos] = par1[k][pos]

        # flag elements in par2 that are already copied to offspring...
        for i in pos:
            flag[np.where(par2[k] == par1[k][i])[0][0]] = 1
        # if possible, copy remaining from par2
        for i in range(dim):
            if off[k][i] < 0:
                if flag[i] == 0:
                    off[k][i] = par2[k][i]
                    flag[i] = 1

        j = 0
        for i in range(dim):
            if off[k][i] < 0:
                while(flag[j] > 0):
                    j += 1
                off[k][i] = par2[k][j]
                flag[j] = 1
    return off


def roulette():
    prob = [(1.0/p['cost'][0]) for p in pop]
    prob /= np.linalg.norm(prob, 1)
    [a, b] = np.random.choice(len(pop), 2, replace=False, p=prob)
    return a, b



tstart = time.time()

pop = np.array([(np.random.permutation(dim), np.random.permutation(dim), 0) for x in range(POPSIZE)], dtype=sol_type)
newgen = np.array([(np.zeros(dim), np.zeros(dim), 0) for x in range(POPSIZE)], dtype=sol_type)

costs=evalPop(pop)
for i in range(len(pop)):
    pop[i]['cost'][0]=costs[i]

max_gen = 100
max_gen = int(sys.argv[2])

for i in range(max_gen):
    bestind = np.argmin([p['cost'][0] for p in pop])
    print("Gen:",i,"\t",pop[bestind]['cost'][0])
    #elitism
    newgen[0]=pop[bestind]
    #generate offspring
    for i in range(1,len(pop)):
        ind1, ind2 = roulette()
        newgen[i] = POSxover(pop[ind1], pop[ind2])
    #evaluate Offspring
    costs=evalPop(newgen)
    for i in range(len(newgen)):
        newgen[i]['cost'][0]=costs[i]
    #mutate
    for p in newgen[1:]:
        if np.random.binomial(1,0.3,1)[0]:
            if np.random.binomial(1,0.7,1)[0]:
                localSearch(p,10)
            else:
                a=np.random.randint(0,dim,4)
                p1 = p['perm1']
                p2 = p['perm2']
                p['cost'][0] -= evalDelta(p1,p2,a)
                applyMove(p,a)
    #replace population
    pop = np.copy(newgen)


bestind = np.argmin([p['cost'][0] for p in pop])
bestsol = pop[bestind]
# print("BestCost:\t",pop[bestind]['cost'][0])

print("BestSol:\t",bestsol)

elapsed_time = time.time() - tstart
print('Elapsed:\t', elapsed_time)
