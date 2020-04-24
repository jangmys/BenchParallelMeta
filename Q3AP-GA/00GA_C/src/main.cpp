#include "../headers/solution.h"
#include "../headers/qap_instance.h"
#include "../headers/evalQ3AP.h"

#include "../headers/ils.h"
#include "../headers/GA.h"


int
main(int argc, char const *argv[])
{
    srand(time(NULL));

	//pass instance name (e.g. nug12)argument, ex: ./ils nug12 100
    qap_instance * inst = new qap_instance(argv[1]);
    // generate cost matrix
    evalQ3AP * eval = new evalQ3AP(inst);

    GA * ga = new GA(inst->size, eval);

    // parameters (#define POP_SIZE in GA.h)
    // ga->elite_rate=0.0;
    ga->mutate_rate    = 0.3;
    ga->ls_rate        = 0.7;
    if(argc==3)
  		ga->nb_generations=atoi(argv[2]);
	else
		{printf("provide nbGen argument (2nd arg)!\n");exit(0);}

    Solution * bestsol = new Solution(inst->size);

    struct timespec t_start, t_end;
    clock_gettime(CLOCK_MONOTONIC, &t_start);

    ga->randomInitPop();

    for (int i = 0; i < ga->nb_generations; i++) {
        ga->evolve();

        bestsol      = ga->getBest();
        ga->bestcost = ga->getBest()->cost;
        printf("======= GENERATION %d\t Best: %d\t %d\n", i, ga->bestcost, ga->avgcost);
    }

    clock_gettime(CLOCK_MONOTONIC, &t_end);

    std::cout << "\n\tElapsed(s):\t" << ((t_end.tv_sec - t_start.tv_sec) + (t_end.tv_nsec - t_start.tv_nsec) / 1.0e9)
              << std::endl;

    delete ga;
    delete eval;
    delete inst;

    return 0;
} // main
