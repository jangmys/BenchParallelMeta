#include "../headers/instance_abstract.h"
#include "../headers/eval_tsp.h"

#include <math.h>

eval_tsp::~eval_tsp(){
	free(xcoord);
	free(ycoord);
}

float
eval_tsp::getCost(const int a, const int b)
{
    float dx = xcoord[a] - xcoord[b];
    float dy = ycoord[a] - ycoord[b];

    return dx * dx + dy * dy;
}

float eval_tsp::evalSolution(int *perm){
    float cost = 0;

    cost = sqrt(getCost(0, perm[1]));
    for (int i = 1; i + 1 < size; ++i) {
        cost += sqrt(getCost(perm[i], perm[i + 1]));
    }
    cost += sqrt(getCost(perm[size - 1], 0));

    return cost;
}

void eval_tsp::init()
{
	(instance->data)->seekg (0);
	(instance->data)->clear ();

	*(instance->data)>>size;

	xcoord=(float*)malloc(size * sizeof(float));
	ycoord=(float*)malloc(size * sizeof(float));

	int ind;
	for(int i=0; i<size; i++){
        *(instance->data)>>ind;
        *(instance->data)>>xcoord[ind-1];
        *(instance->data)>>ycoord[ind-1];
    }
}

void eval_tsp::freeMem()
{
	free(xcoord);
	free(ycoord);
}

void eval_tsp::set_instance(instance_abstract*_instance)
{
	instance=_instance;
	init();
}
