#ifndef EVAL_FLOWSHOP_H
#define EVAL_FLOWSHOP_H

struct eval_flowshop // : public bound_abstract_int
{
    instance_abstract * instance;

    int nbJob;         /*number of jobs*/
    int nbMachines;    /*number of machines*/
    int **tempsJob;    /*matrix of processing times*/

    int evalSolution(int * permutation);

    int max(int i, int j);

    void init();
    void set_instance(instance_abstract * _instance);

    void freeMem();
};

#endif
