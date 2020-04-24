#ifndef EVAL_Q3AP_H
#define EVAL_Q3AP_H

struct eval_q3ap
{
    instance_abstract *instance;

	int I6D(const int x1,const int x2,const int x3,const int x4,const int x5,const int x6);

	int size;

	int *costMatrix;
	// int c6[25][25][25][25][25][25];

  	int evalSolution(int *perm);
  	int evalSolution(int *perm, int *perm2);

	void init();

	void freeMem();
	~eval_q3ap();

	void set_instance(instance_abstract *_instance);
};


#endif
