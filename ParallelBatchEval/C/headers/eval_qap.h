#ifndef EVAL_QAP_H
#define EVAL_QAP_H

struct eval_qap
{
    instance_abstract *instance;

	int size;

	int *flow;
	int *dist;

  	int evalSolution(int *permutation);
  	int evalSolution(int *permutation, int* perm2);

	void init();

	void freeMem();
	~eval_qap();

	void bornes_calculer(int  permutation[], int  limite1, int  limite2, int *couts, int);
	void set_instance(instance_abstract *_instance);
};

#endif
