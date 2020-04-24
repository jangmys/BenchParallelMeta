import sys
import time
import numpy as np

from numba import int64, njit, jitclass

import Q3AP_instance

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

    #needed because copy.copy(sol) fails with 'TypeError: can't pickle solution objects'
    def solcopy(self):
        return solution(self.perm1.copy(), self.perm2.copy(), self.cost)

#Q3AP cost function
@njit
def eval(sol):
    cost = 0
    for i in range(dim):
        for j in range(dim):
            cost += C[i, sol.perm1[i], sol.perm2[i],
                      j, sol.perm1[j], sol.perm2[j]]
    return cost

@njit
def applyMove(sol, mv):
    sol.perm1[mv[0]], sol.perm1[mv[1]] = sol.perm1[mv[1]], sol.perm1[mv[0]]
    sol.perm2[mv[2]], sol.perm2[mv[3]] = sol.perm2[mv[3]], sol.perm2[mv[2]]

@njit
def evalDelta(sol, mv):
    delta = 0

    for i in range(dim):
        if i != mv[0] and i != mv[1] and i != mv[2] and i != mv[3]:
            continue
        # avoid actually performing the swap
        p1i = sol.perm1[i]
        p2i = sol.perm2[i]
        if i == mv[0]:
            p1i = sol.perm1[mv[1]]
        if i == mv[1]:
            p1i = sol.perm1[mv[0]]
        if i == mv[2]:
            p2i = sol.perm2[mv[3]]
        if i == mv[3]:
            p2i = sol.perm2[mv[2]]

        for j in range(dim):
            p1j = sol.perm1[j]
            p2j = sol.perm2[j]
            if j == mv[0]:
                p1j = sol.perm1[mv[1]]
            if j == mv[1]:
                p1j = sol.perm1[mv[0]]
            if j == mv[2]:
                p2j = sol.perm2[mv[3]]
            if j == mv[3]:
                p2j = sol.perm2[mv[2]]

            delta += C[i, sol.perm1[i], sol.perm2[i],
                       j, sol.perm1[j], sol.perm2[j]]
            delta -= C[i, p1i, p2i, j, p1j, p2j]

            # if j not in mv:
            if j != mv[0] and j != mv[1] and j != mv[2] and j != mv[3]:
                delta += C[j, sol.perm1[j], sol.perm2[j],
                           i, sol.perm1[i], sol.perm2[i]]
                delta -= C[j, p1j, p2j, i, p1i, p2i]
    return delta


@njit
def findBestMove(sol):
    max_delta = 0
    best_move = 0 #moves[0]

    for i in range(np.shape(moves)[0]):
        delta = evalDelta(sol, moves[i])
        if delta > max_delta:
            max_delta = delta
            best_ind = i

    return max_delta, best_ind

@njit
def localSearch(sol, maxiter):
    iter = 0
    for i in range(maxiter):
        delta, bestind = findBestMove(sol)
        iter += 1
        if delta > 0:
            applyMove(sol, moves[bestind])
            sol.cost -= delta
        else:
            break
    return iter


@njit
def perturb_perm(permut, strength):
    # randomly select x (strength) positions in permutation
    # ... equivalent to np.random.choice(dim, strength, replace=False)
    select = np.random.permutation(dim)[:strength]
    assign = np.copy(select)
    np.random.shuffle(assign)

    assign = permut[assign]

    for i in range(strength):
        permut[select[i]] = assign[i]

@njit
def perturb(sol, strength):
    perturb_perm(sol.perm1, strength)
    perturb_perm(sol.perm2, strength)


def generateNhood(dim):
    moves = np.empty([0,4],dtype=np.int64)
    for i in range(dim):
        for k in range(dim):
            for j in range(i, dim):
                for l in range(k, dim):
                    moves = np.vstack([moves, np.int64([i, j, k, l])])
    return moves

@njit
def runILS(sol,ilsiter):
    nhood_evals=0
    b=0
    strength = 3
    for iter in range(ilsiter):
        tmpsol = sol.solcopy()
        b = 1-b
        if b == 0:
            perturb_perm(sol.perm1, strength)
        else:
            perturb_perm(sol.perm2, strength)

        sol.cost = eval(sol)
        nhood_evals += localSearch(sol, 100)

        # print(sol.perm1,sol.perm2, "\n cost:\t", sol.cost," ",tmpsol.cost)

        if sol.cost >= tmpsol.cost:
            sol = tmpsol.solcopy()
            strength += b
        else:
            strength = 3

        if strength >= dim:
            strength = 3

#     sol = tmpsol.solcopy()
    # sol.cost=1111
    return sol,nhood_evals

####################################
if len(sys.argv)!=3:
    print("Need 2 arguments (instance, batchsize), ex: \n\tpython3 ./ilsQ3AP_numba.py nug12 1000. \n\nExit.")
    exit()

#read input
C,dim = Q3AP_instance.read_input(sys.argv[1])
moves = generateNhood(dim)

tstart = time.time()

#call once to trigger compilation (Warmup)
sol = solution(np.arange(dim, dtype=np.int64),
               np.arange(dim, dtype=np.int64), 0)
sol,nhood_evals=runILS(sol,1)
elapsed_time = time.time() - tstart
print("Time (First LS/Compilation):\t", elapsed_time)

#initial solutions (random)
sol = solution(np.random.permutation(dim), np.random.permutation(dim), 0)
sol.cost = eval(sol)

#nb iterations (ILS outer loop)
ils_iter = 100
ils_iter = int(sys.argv[2])

tstart = time.time()
sol,nhood_evals=runILS(sol,ils_iter)
elapsed_time = time.time() - tstart

print("Best Solution:\n\t",sol.perm1,sol.perm2, "\n\t Cost:\t", sol.cost)
print('nhood-eval:\t', nhood_evals)
print('Elapsed:\t', elapsed_time)
print('nhood/sec:\t', nhood_evals/elapsed_time)
