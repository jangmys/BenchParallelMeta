#ifndef GA_H
#define GA_H

#include <limits.h>

#include "../headers/qap_instance.h"
#include "../headers/solution.h"
#include "../headers/evalQ3AP.h"
#include "../headers/ils.h"

#include <vector>
#include <algorithm>
#include <numeric>

#define POPSIZE 100

class evalQ3AP;
class Solution;
class ils;

class GA
{
public:
    GA(int _size, evalQ3AP * _eval);
    ~GA();

    ils * iterLS;

    float elite_rate;
    float mutate_rate;
    float ls_rate;
    int nb_generations;

    int bestcost;
    int avgcost;
    int bestind;

    int size;
    evalQ3AP * eval;

    void
    mutate(Solution * sol);
    int
    findIndex(int * arr, int x);

    void
    POSCrossover(Solution* off, Solution * par1, Solution * par2);

    void
    evolve();
    void
    randomInitPop();
    void
    erasePop();
    Solution *
    getBest();

    void
    printPop();

    void
    roulette(int &ind1, int &ind2, float prob[]);

    int
    saveElite(std::vector<Solution *>& newpop);

    void
    swap(int * a, int * b);

    void
    setSelectProba();

    Solution * pop[POPSIZE];
    Solution * off[POPSIZE];

    int parents_index[POPSIZE][2];

    int * elite_flag;
    float * select_proba;
};

#endif // ifndef GA_H
