#include <iostream>

#include "../headers/ils.h"

#include "omp.h"

#define MAX_ITER_LS 100

ils::ils(int _size, evalQ3AP * _eval)
{
    size = _size;
    eval = _eval;

    ilsiter = 100; // default value (may be changed from main)

    generate_neighborhood();
}

// destructor
ils::~ils()
{
    free(index_nhood);
}

void
ils::generate_neighborhood()
{
    nhood_size = 0;
    for (int i = 0; i < size; ++i)
        for (int k = 0; k < size; ++k)
            for (int j = i; j < size; ++j)
                for (int l = k; l < size; ++l)
                    nhood_size++;

    int cpt = 0;
    index_nhood = (int *) malloc(4 * nhood_size * sizeof(int));

    for (int i = 0; i < size; ++i)
        for (int j = i; j < size; ++j)
            for (int k = 0; k < size; ++k)
                for (int l = k; l < size; ++l) {
                    index_nhood[4 * cpt]     = i;
                    index_nhood[4 * cpt + 1] = j;
                    index_nhood[4 * cpt + 2] = k;
                    index_nhood[4 * cpt + 3] = l;
                    cpt++;
                }
}

int
ils::run(Solution * bestsol)
{
    Solution * tmpsol = new Solution(size);

    // starting solution
    Solution * sol = new Solution(size);
    sol->randomInit();                  // init at random
    sol->cost=eval->fullEval(sol);      // evaluate initial solution

    *bestsol = *sol;
    // std::cout << "initial solution\t";
    // bestsol->print();

    int b = 0;

    int minPerturbStrength = 3;
    int maxPerturbStrength = size;
    int perturbStrength    = 3;

    int nhood_evals = 0;

    // ILS main-loop
    for (int k = 0; k < ilsiter; k++) {
        // save solution
        *tmpsol = *sol;

        // perturb current solution: alternate perturbations in PERM-0 and PERM-1
        b = 1 - b;
        randomKopt(sol, (int) perturbStrength, b);

        // get cost of perturbed solution
        sol->cost = eval->fullEval(sol);
        // move to local optimum
        nhood_evals += searchLocalLarge(sol, MAX_ITER_LS);

        // acceptance criterion : if new local optimum is worse than previous...
        if (sol->cost >= tmpsol->cost) {
            *sol = *tmpsol;       // go back to previous local opt
            perturbStrength += b; // perturb more!
        } else {
            perturbStrength = minPerturbStrength; // switched to new local opt: perturb less!
        }
        if (perturbStrength >= maxPerturbStrength + 1) {
            perturbStrength = minPerturbStrength;
        }
    }

    *bestsol = *tmpsol;

    delete sol;
    delete tmpsol;

    return nhood_evals;
} // ils::run

void
ils::swap(int * a, int * b)
{
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

// randomly select k positions in permutation sol->perm[p] and perturb randomly
void
ils::randomKopt(Solution * sol, int k, int p)
{
    int * arr1 = new int[size];
    int * arr2 = new int[k];

    for (int i = 0; i < size; i++) arr1[i] = i;

    // select k out of n (randomly swap k elements to front of arr1)
    for (int i = 0; i < k; i++) {
        int r = rand() % (size - i) + i; // select one remaining....
        swap(&arr1[r], &arr1[i]);
    }

    // copy selected positions to arr2
    for (int i = 0; i < k; i++) arr2[i] = arr1[i];
    // shuffle arr2...
    for (int i = k - 1; i > 0; i--) {
        int j = rand() % (i + 1);
        swap(&arr2[i], &arr2[j]);
    }
    // apply bijection arr1[:]->arr2[:]
    for (int i = 0; i < k; i++)
        arr2[i] = sol->perm[p][arr2[i]];
    for (int i = 0; i < k; i++)
        sol->perm[p][arr1[i]] = arr2[i];

    delete[] arr1;
    delete[] arr2;
}

void
ils::apply22ex(Solution * sol, LargeMove mv)
{
    swap(&sol->perm[0][mv.a], &sol->perm[0][mv.b]);
    swap(&sol->perm[1][mv.c], &sol->perm[1][mv.d]);
}

int
ils::searchLocalLarge(Solution * sol, int max_iter)
{
    int iter = 0;

    LargeMove best_move  = { 0, 0, 0, 0 };
    LargeMove local_move = { 0, 0, 0, 0 };

    int delta_max = 0;
    int ok = 1; // flag to break out of parallel

    //parallel region outside to minimize fork-join overhead
    #pragma omp parallel shared(best_move,delta_max,ok) private(local_move)
    {
        //LS outer loop
        for (int it = 0; it < max_iter; ++it) {
            int delta_loc = 0;

            //parallel neighborhood eval
            #pragma omp for schedule(runtime) nowait
            for (int i = 0; i < nhood_size; ++i) {
                LargeMove mv =
                { index_nhood[4 * i], index_nhood[4 * i + 1], index_nhood[4 * i + 2], index_nhood[4 * i + 3] };
                int delta = eval->deltaEval(sol, mv);
                if (delta > delta_loc) {
                    delta_loc  = delta;
                    local_move = mv;
                }
            }//implicit barrier removed by nowait

            //max reduce on (max,maxloc)
            #pragma omp critical
            {
                if (delta_loc > delta_max) {
                    delta_max = delta_loc;
                    best_move = local_move;
                }
            }
            #pragma omp barrier
            //wait until all partial neighborhoods evaluated

            //apply best move
            #pragma omp single
            {
                if (delta_max > 0) {
                    apply22ex(sol, best_move);
                    sol->cost -= delta_max;
                } else {
                    //nothing found
                    ok = 0;
                }
                //reset delta_max
                delta_max = 0;
                iter++;
            }//implicit barrier here !

            if (ok == 0)
                break;
        } // for
    }     // omp parallel

    return iter;
} // ils::searchLocalLarge
