#include "../headers/instance_abstract.h"
#include "../headers/eval_flowshop.h"

/*evaluate C_max for permutation schedule
requires MN add/max operations
access to constant MxN matrix "tempsJob" (processing times)
*/
int
eval_flowshop::evalSolution(int * permutation)
{
    int * temps = new int[nbMachines];

    for (int mm = 0; mm < nbMachines; mm++) temps[mm] = 0;
    for (int j = 0; j < nbJob; j++) {
        int job = permutation[j];
        temps[0] = temps[0] + tempsJob[0][job];
        for (int m = 1; m < nbMachines; m++)
            temps[m] = max(temps[m], temps[m - 1]) + tempsJob[m][job];
    }
    delete[]temps;
    //
    return temps[nbMachines - 1]; // return makespan
}

int
eval_flowshop::max(int i, int j)
{
    return (i > j) ? i : j;
}

void
eval_flowshop::init()
{
    (instance->data)->seekg(0);
    (instance->data)->clear();
    *(instance->data) >> nbJob;
    *(instance->data) >> nbMachines;

    tempsJob = (int **) malloc(nbMachines * sizeof(int *));
    for (int i = 0; i < nbMachines; i++) {
        tempsJob[i] = (int *) malloc(nbJob * sizeof(int));
    }

    for (int j = 0; j < nbMachines; j++)
        for (int i = 0; i < nbJob; i++)
            *(instance->data) >> tempsJob[j][i];
}

void
eval_flowshop::set_instance(instance_abstract * _instance)
{
    instance = _instance;
    init();
}

void
eval_flowshop::freeMem()
{
    for (int i = 0; i < nbMachines; i++) {
        free(tempsJob[i]);
    }
    free(tempsJob);
}
