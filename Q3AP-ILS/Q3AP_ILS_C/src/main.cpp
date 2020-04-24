#include <iostream>

#include "../headers/solution.h"
#include "../headers/qap_instance.h"
#include "../headers/evalQ3AP.h"

#include "../headers/ils.h"


int main(int argc, char const *argv[])
{
	srand(time(NULL));

	//pass instance name (e.g. nug12)argument, ex: ./ils nug12 100
	qap_instance *inst = new qap_instance(argv[1]);
	//generate cost matrix
	evalQ3AP *eval = new evalQ3AP(inst);

	//ILS operators etc...
	ils *iterLS = new ils(inst->size, eval);
	Solution* bestsol = new Solution(inst->size);

	iterLS->ilsiter=atoi(argv[2]);

	//timing ILS ...
	struct timespec t_start, t_end;
	clock_gettime(CLOCK_MONOTONIC, &t_start);

	int nhood_evals = iterLS->run(bestsol);

	clock_gettime(CLOCK_MONOTONIC, &t_end);

	//output statistics
	std::cout << "\n\t=== Best solution:\n\n";
	bestsol->print();

	std::cout << "\n\tNhood-eval:\t" << nhood_evals << std::endl;
	std::cout << "\n\tElapsed(s):\t" << ((t_end.tv_sec - t_start.tv_sec) + (t_end.tv_nsec - t_start.tv_nsec) / 1.0e9) << std::endl;
	std::cout << "\n\tnhood/src:\t" << (nhood_evals * 1.0f) / ((t_end.tv_sec - t_start.tv_sec) + (t_end.tv_nsec - t_start.tv_nsec) / 1.0e9) << std::endl;

	//clean up
	delete iterLS;
	delete bestsol;
	delete eval;
	delete inst;

	return 0;
}
