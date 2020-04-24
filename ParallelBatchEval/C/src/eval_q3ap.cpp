#include "../headers/instance_abstract.h"
#include "../headers/eval_q3ap.h"

eval_q3ap::~eval_q3ap(){
    freeMem();
}

int
eval_q3ap::I6D(const int x1, const int x2, const int x3, const int x4, const int x5, const int x6)
{
    return x1 * (size * size * size * size * size) \
           + x2 * (size * size * size * size) \
           + x3 * (size * size * size) \
           + x4 * (size * size) \
           + x5 * size \
           + x6;
}


int
eval_q3ap::evalSolution(int * perm1, int * perm2)
{
    int cost = 0;

    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j) {
            cost += costMatrix[I6D(i, perm1[i], perm2[i], j, perm1[j], perm2[j])];
            // cost += c6[i][perm1[i]][perm2[i]][j][perm1[j]][perm2[j]];
        }
    }

    return cost;
}

void
eval_q3ap::init()
{
    (instance->data)->seekg(0);
    (instance->data)->clear();

    *(instance->data) >> size;

    int *dist=(int*)malloc(size * size * sizeof(int));
    int *flow=(int*)malloc(size * size * sizeof(int));

    for (int i = 0; i < size; i++)
        for (int j = 0; j < size; j++)
            *(instance->data) >> dist[i * size + j];

    for (int i = 0; i < size; i++)
        for (int j = 0; j < size; j++)
            *(instance->data) >> flow[i * size + j];

    costMatrix=(int*)malloc(size * size * size * size * size * size * sizeof(int));

    // loop to generate 6D cost matrix for Q3AP (from QAP)
    for (int i = 0; i < size; ++i) {
        for (int k = 0; k < size; ++k) {
            int fik2 = flow[i * size + k] * flow[i * size + k];
            for (int j = 0; j < size; ++j) {
                for (int n = 0; n < size; ++n) {
                    int djn = dist[j * size + n];
                    for (int p = 0; p < size; ++p) {
                        for (int q = 0; q < size; ++q) {
                            // c6[i][j][p][k][n][q] = fik2 * djn * dist[p * size + q];
                            // ...or use indexing function I6D
                            costMatrix[I6D(i, j, p, k, n, q)] = fik2 * djn * dist[p * size + q];
                        }
                    }
                }
            }
        }
    }

    free(flow);
    free(dist);
}

void
eval_q3ap::freeMem()
{
    free(costMatrix);
}

void
eval_q3ap::set_instance(instance_abstract * _instance)
{
    instance = _instance;
    init();
}
