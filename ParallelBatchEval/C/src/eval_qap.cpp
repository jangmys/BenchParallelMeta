#include <stdlib.h>
#include <fstream>
#include <string.h>

#include "../headers/instance_abstract.h"
#include "../headers/eval_qap.h"

int
eval_qap::evalSolution(int * permutation)
{
    int cost = 0;

    int i, j;
    int pi, pj;

    for (i = 0; i < size; ++i) {
        pi = permutation[i];
        for (j = 0; j < size; ++j) {
            pj = permutation[j];
            cost += dist[i * size + j] * flow[pi * size + pj];
        }
    }

    return cost;
}

eval_qap::~eval_qap(){
    freeMem();
}

void
eval_qap::init()
{
    (instance->data)->seekg(0);
    (instance->data)->clear();

    *(instance->data) >> size;

    flow=(int*)malloc(size * size * sizeof(int));
    dist=(int*)malloc(size * size * sizeof(int));

    for (int i = 0; i < size; i++)
        for (int j = 0; j < size; j++)
            *(instance->data) >> dist[i * size + j];

    for (int i = 0; i < size; i++)
        for (int j = 0; j < size; j++)
            *(instance->data) >> flow[i * size + j];
}

void
eval_qap::freeMem()
{
    free(flow);
    free(dist);
}

void
eval_qap::set_instance(instance_abstract * _instance)
{
    instance = _instance;
    init();
}
