#ifndef EVAL_TSP_H
#define EVAL_TSP_H

struct eval_tsp
{
    instance_abstract *instance;

	int size;

	float *xcoord;
	float *ycoord;

	float getCost(const int a, const int b);

  	float evalSolution(int *permutation);
  	float evalSolution(int *permutation, int* perm2);

	void init();

	void freeMem();
	~eval_tsp();

	// void bornes_calculer(int  permutation[], int  limite1, int  limite2, int *couts, int);
	void set_instance(instance_abstract *_instance);
};


#endif
