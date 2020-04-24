#include "../headers/GA.h"

#include "omp.h"


GA::GA(int _size, evalQ3AP * _eval)
{
    size = _size;
    eval = _eval;

    elite_flag   = new int[POPSIZE];
    select_proba = new float[POPSIZE];

    iterLS = new ils(size, eval);
}

GA::~GA()
{
	delete[]elite_flag;
	delete[]select_proba;
	delete iterLS;
    // erasePop();
}

int
GA::findIndex(int * arr, int x)
{
    int ret = 0;
    while (arr[ret] != x && ret<size) ret++;
//	if(ret>size)std::cout<<"Error\n";
    return ret;
}

void
GA::mutate(Solution * sol)
{

	float r1 = (float)rand() / (float)RAND_MAX;
    float r2 = (float)rand() / (float)RAND_MAX;

    if (r1 < mutate_rate) {
        if (r2 < ls_rate) {
            iterLS->searchLocalLarge(sol, 10);
        } else {
            int a, b, c, d;

            a = rand() % size;
            b = rand() % size;

            c = rand() % size;
            d = rand() % size;

            LargeMove mv = { a, b, c, d };

            int delta = eval->deltaEval(sol, mv);
            iterLS->apply22ex(sol, mv);
            sol->cost -= delta;
        }
    }
}

// position-based
void
GA::POSCrossover(Solution* offspring, Solution * par1, Solution * par2)
{
    //Solution * offspring = new Solution(size);

    int a, b;
    int j;

    int * flag  = new int[size];
    int * flag2 = new int[size];

    for (int i = 0; i < size; i++) {
        offspring->perm[0][i] = -1;
        offspring->perm[1][i] = -1;
    }

    // for both permutations
    for (int k = 0; k <= 1; k++) {
        for (int i = 0; i < size; i++) {
            flag[i]  = 0;
            flag2[i] = 0;
        }
        // randomly choose b positions in permutati	on
        int b = 3 + rand() % (size - 5); // [3,size-3]
        int j = 0;
        while (j < b) {
            a = rand() % size;
            if (!flag[a]) {
                flag[a] = 1;
                j++;
            }
        }
        // copy flagged elements from par1 to child
        for (int i = 0; i < size; i++) {
            if (flag[i]) {
                offspring->perm[k][i] = par1->perm[k][i];

                int ind = findIndex(par2->perm[k], par1->perm[k][i]);
                flag2[ind] = 1;// already in offspring!
            }
        }
        // if valid, copy remaining from par2
        for (int i = 0; i < size; i++) {
            if (offspring->perm[k][i] < 0) {
                if (!flag2[i]) {
                    offspring->perm[k][i] = par2->perm[k][i];
                    flag2[i] = 1;
                }
            }
        }
        j = 0;
        for (int i = 0; i < size; i++) {
            if (offspring->perm[k][i] < 0) {// [-] in child
                while (flag2[j]) j++;  // next available in par2
                offspring->perm[k][i] = par2->perm[k][j];
                flag2[j] = 1;
            }
        }
    }

    delete[]flag;
    delete[]flag2;

    // return offspring;
} // GA::POSCrossover

void
GA::setSelectProba()
{
    float sum = 0.0f;

	//assume costs > 0...
    for (int i = 0; i < POPSIZE; i++) {
        sum += (1.0f / pop[i]->cost);
    }

    for (int i = 0; i < POPSIZE; i++) {
        select_proba[i] = (1.0f / (float) pop[i]->cost) / sum;
		// printf("%f ",select_proba[i]);
    }
}



void
GA::randomInitPop()
{
    for (int i = 0; i < POPSIZE; i++) {
        pop[i] = new Solution(size);
        pop[i]->randomInit();
        // ================
        pop[i]->cost=eval->fullEval(pop[i]);
		// std::cout<<pop[i]->cost<<" aaaa\n";
    }

    for (int i = 0; i < POPSIZE; i++) {
        off[i] = new Solution(size);
    }
}

void
GA::printPop()
{
    for (int i = 0; i < POPSIZE; i++) {
        printf("%d/\t", i);
        pop[i]->print();
    }
}

void
GA::erasePop()
{
    for (int i = 0; i < POPSIZE; i++) {
        if (pop[i]) delete pop[i];
        if (off[i]) delete pop[i];
    }
}

void
GA::roulette(int &ind1, int &ind2, float prob[])
{
    float a = ((float) rand() / (float) (RAND_MAX));

    ind1 = 0;
    ind2 = 0;

    float cumul = 0.0f;
    for (int i = 0; i < POPSIZE; i++) {
        if (a > cumul) {
            ind1 = i;
        }
        cumul += prob[i];// (1.0f/pop[i]->cost);
    }

  	do{
	  	float b = ((float) rand() / (float) (RAND_MAX));
		cumul = 0.0f;
		for (int i = 0; i < POPSIZE; i++) {
	//        if (i == ind1) continue;
		    if (b > cumul) {
		        ind2 = i;
		    }
		    cumul += prob[i];// (1.0f/pop[i]->cost);
		}
	}while(ind1==ind2);
}

Solution *
GA::getBest()
{
    int ind      = 0;
    int bestCost = INT_MAX;
    int sum      = 0;
    int cost;

    for (int i = 0; i < POPSIZE; i++) {
        cost = pop[i]->cost;
        sum += cost;
        if (cost < bestCost) {
            bestCost = cost;
            ind      = i;
        }
    }

    bestind = ind;
    avgcost = (int) sum / POPSIZE;

    return pop[ind];
}

void
GA::evolve()
{
    // elitism : save best individual
    // JUST FIND MIN INDEX...
    int bestind;
    int min = INT_MAX;

    for (int i = 0; i < (POPSIZE); i++) {
        if (pop[i]->cost < min) {
            min     = pop[i]->cost;
            bestind = i;
        }
    }
    // ...AND COPY TO NEXT GEN
    *off[0] = *pop[bestind];

    // CROSSOVER
    // ...ROULETTE SELECTION
    int ind1, ind2;
    setSelectProba();

	//calls random...
    for (int i = 1; i < POPSIZE; i++) {
        roulette(parents_index[i][0], parents_index[i][1], select_proba);
    }

	//calls random...
    for (int i = 1; i < POPSIZE; i++) {
        ind1 = parents_index[i][0];
        ind2 = parents_index[i][1];

         POSCrossover(off[i], pop[ind1], pop[ind2]);
    }
    // (PARALLEL) EVALUATION of FITNESS
    #pragma omp parallel for schedule(static,1)
    for (int i = 1; i < POPSIZE; i++) {
        off[i]->cost=eval->fullEval(off[i]);
    }

    // MUTATION (!!!costly (parallelized) LOCAL SEARCH inside)
    for (int i = 1; i < POPSIZE; i++) {
        mutate(off[i]);
    }

    // full replacement
    for (int i = 0; i < POPSIZE; i++) {
        *pop[i] = *off[i];
    }

    // print costs;...
    // for (int i = 0; i < POPSIZE; i++) {
    //     printf("%d ", pop[i]->cost);
    // }
    // printf("\n");
} // GA::evolve
