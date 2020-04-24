#include <stdio.h>
#include <iostream>

#include "../headers/arguments.h"
#include "../headers/permutation.h"

#include "../headers/instance_abstract.h"
#include "../headers/instance_flowshop.h"
#include "../headers/instance_qap.h"
#include "../headers/instance_tsp.h"

#include "../headers/eval_flowshop.h"
#include "../headers/eval_qap.h"
#include "../headers/eval_q3ap.h"
#include "../headers/eval_tsp.h"

#include "omp.h"

#define MAXPOP 100000

int
main(int argc, char ** argv)
{
    if(argc==1){
        arguments::printHelp();
        exit(0);
    }

    srand(time(NULL));

    arguments::parse_arguments(argc, argv);

    int outer_loop_count = 1e6/arguments::batch_size;

    if(arguments::batch_size>MAXPOP){
        printf("Max Batch Size: %d",MAXPOP);
    }

    instance_abstract * inst;
    eval_flowshop* fspEval = NULL;
    eval_qap* qapEval = NULL;
    eval_q3ap* q3apEval = NULL;
    eval_tsp *tspEval = NULL;

    //set up problem
    switch (arguments::problem) {
        case 'f': {
            inst  = new instance_flowshop(arguments::inst_name);
            fspEval = new eval_flowshop();
            fspEval->set_instance(inst);
            break;
        }
        case 'q': {
            inst  = new instance_qap(arguments::inst_name);
            qapEval = new eval_qap();
            qapEval->set_instance(inst);
            break;
        }
        case 'a': {
            inst  = new instance_qap(arguments::inst_name);
            q3apEval = new eval_q3ap();
            q3apEval->set_instance(inst);
            break;
        }
        case 't':
        {
            inst  = new instance_tsp(arguments::inst_name);
            tspEval = new eval_tsp();
            tspEval->set_instance(inst);
            break;
        }
    }

    // =========================
    struct timespec t_start, t_end, t_elapsed;
    struct timespec t2_start, t2_end;
    // =========================
    clock_gettime(CLOCK_MONOTONIC, &t2_start);

    Permutation *pop[MAXPOP];
    Permutation *pop2[MAXPOP];
    for (int i=0;i<arguments::batch_size;i++){
        pop[i]=new Permutation(inst->size);
        /*only for Q3AP (permutation pair)*/
        if(arguments::problem=='a')
            pop2[i]=new Permutation(inst->size);
    }

    t_elapsed.tv_sec=0;
    t_elapsed.tv_nsec=0;

    for(int i=0;i<outer_loop_count;i++)
    {
        for(int j=0;j<arguments::batch_size;++j){
            pop[j]->randomInit();
            if(arguments::problem=='a')
                pop2[j]->randomInit();
        }

        clock_gettime(CLOCK_MONOTONIC, &t_start);
        switch(arguments::problem){
            case 'f':
            {
                #pragma omp parallel for schedule(runtime)
                for (int i=0;i<arguments::batch_size;i++) {
                    pop[i]->cost = fspEval->evalSolution(pop[i]->perm);
                }
                break;
            }
            case 'q':
            {
                #pragma omp parallel for schedule(runtime)
                for (int i=0;i<arguments::batch_size;i++) {
                    pop[i]->cost = qapEval->evalSolution(pop[i]->perm);
                }
                break;
            }
            case 't':
            {
                #pragma omp parallel for schedule(runtime)
                for (int i=0;i<arguments::batch_size;i++) {
                    pop[i]->cost = tspEval->evalSolution(pop[i]->perm);
                }
                break;
            }
            case 'a':
            {
                #pragma omp parallel for schedule(runtime)
                for (int i=0;i<arguments::batch_size;i++) {
                    pop[i]->cost = q3apEval->evalSolution(pop[i]->perm,pop2[i]->perm);
                }
                break;
            }
        }
        clock_gettime(CLOCK_MONOTONIC, &t_end);

        t_elapsed.tv_sec += (t_end.tv_sec - t_start.tv_sec);
        t_elapsed.tv_nsec += (t_end.tv_nsec - t_start.tv_nsec);
    }


    delete inst;

    switch (arguments::problem) {
        case 'f': {
            delete fspEval;
            break;
        }
        case 'q': {
            delete qapEval;
            break;
        }
        case 'a': {
            delete q3apEval;
            break;
        }
        case 't':
        {
            delete tspEval;
            break;
        }
    }



    // switch (arguments::problem) {
    //     case 'f':{
    //         // for(int i=0;i<outer_loop_count;i++)
    //         // {
    //         //     for(int j=0;j<arguments::batch_size;++j){
    //         //         pop[j]->randomInit();
    //         //     }
    //         //
    //         //     clock_gettime(CLOCK_MONOTONIC, &t_start);
    //         //
    //         //     #pragma omp parallel for schedule(runtime)
    //         //     for (int i=0;i<arguments::batch_size;i++) {
    //         //         pop[i]->cost = fspEval->evalSolution(pop[i]->perm);
    //         //     }
    //         //
    //         //     clock_gettime(CLOCK_MONOTONIC, &t_end);
    //         //
    //         //     t_elapsed.tv_sec += (t_end.tv_sec - t_start.tv_sec);
    //         //     t_elapsed.tv_nsec += (t_end.tv_nsec - t_start.tv_nsec);
    //         // }
    //         break;
    //     }
    //     case 'q': {
    //         // for(int i=0;i<outer_loop_count;i++)
    //         // {
    //         //     for(int j=0;j<arguments::batch_size;++j){
    //         //         pop[j]->randomInit();
    //         //     }
    //         //
    //         //     clock_gettime(CLOCK_MONOTONIC, &t_start);
    //         //
    //         //     #pragma omp parallel for schedule(runtime)
    //         //     for (int i=0;i<arguments::batch_size;i++) {
    //         //         pop[i]->cost = qapEval->evalSolution(pop[i]->perm);
    //         //     }
    //         //
    //         //     clock_gettime(CLOCK_MONOTONIC, &t_end);
    //         //
    //         //     t_elapsed.tv_sec += (t_end.tv_sec - t_start.tv_sec);
    //         //     t_elapsed.tv_nsec += (t_end.tv_nsec - t_start.tv_nsec);
    //         // }
    //         break;
    //     }
    //     case 'a': {
    //         // for(int i=0;i<outer_loop_count;i++)
    //         // {
    //         //     for(int j=0;j<arguments::batch_size;++j){
    //         //         pop[j]->randomInit();
    //         //         pop2[j]->randomInit();
    //         //     }
    //         //
    //         //     clock_gettime(CLOCK_MONOTONIC, &t_start);
    //         // //
    //         //     #pragma omp parallel for schedule(runtime)
    //         //     for (int i=0;i<arguments::batch_size;i++) {
    //         //         pop[i]->cost = q3apEval->evalSolution(pop[i]->perm,pop2[i]->perm);
    //         //     }
    //         // //
    //         //     clock_gettime(CLOCK_MONOTONIC, &t_end);
    //         // //
    //         //     t_elapsed.tv_sec += (t_end.tv_sec - t_start.tv_sec);
    //         //     t_elapsed.tv_nsec += (t_end.tv_nsec - t_start.tv_nsec);
    //         // }
    //         //
    //         break;
    //     }
    //     case 't': {
    //         // for(int i=0;i<outer_loop_count;i++)
    //         // {
    //         //     for(int j=0;j<arguments::batch_size;++j){
    //         //         pop[j]->randomInit();
    //         //     }
    //         //
    //         //     clock_gettime(CLOCK_MONOTONIC, &t_start);
    //         //     //
    //         //     #pragma omp parallel for schedule(runtime)
    //         //     for (int i=0;i<arguments::batch_size;i++) {
    //         //         pop[i]->cost = tspEval->evalSolution(pop[i]->perm);
    //         //     }
    //         //     //
    //         //     clock_gettime(CLOCK_MONOTONIC, &t_end);
    //         //     //
    //         //     t_elapsed.tv_sec += (t_end.tv_sec - t_start.tv_sec);
    //         //     t_elapsed.tv_nsec += (t_end.tv_nsec - t_start.tv_nsec);
    //         // }
    //         break;
    //     }
    // }

    for(int j=0;j<arguments::batch_size;++j){
        delete pop[j];
        if(arguments::problem=='a')delete pop2[j];
    }
    clock_gettime(CLOCK_MONOTONIC, &t2_end);

    std::cout << "\n\tEvalLoop(s):\t"  \
          << t_elapsed.tv_sec + t_elapsed.tv_nsec / 1.0e9 \
          << std::endl;

    std::cout << "\n\tTotElapsed(s):\t" \
          << ((t2_end.tv_sec - t2_start.tv_sec) + (t2_end.tv_nsec - t2_start.tv_nsec) / 1.0e9) \
          << std::endl;
} // main



// int
// main(int argc, char ** argv)
// {
//     srand(time(NULL));
//
//     bool ok = arguments::parse_arguments(argc, argv);
//
//     int outer_loop_count = 1e6/arguments::batch_size;
//
//     if(arguments::batch_size>MAXPOP){
//         printf("Max Batch Size: %d",MAXPOP);
//     }
//
//     instance_abstract * inst;
//
//     eval_flowshop* fspEval = NULL;
//     eval_qap* qapEval = NULL;
//     eval_q3ap* q3apEval = NULL;
//     eval_tsp *tspEval = NULL;
//
//     int * perm;
//     int cost;
//
//     //set up problem
//     switch (arguments::problem) {
//         case 'f': {
//             printf("fsp\n");
//             inst  = new instance_flowshop(arguments::inst_name);
//             fspEval = new eval_flowshop();
//             fspEval->set_instance(inst);
//             break;
//         }
//         case 'q': {
//             printf("qap\n");
//             inst  = new instance_qap(arguments::inst_name);
//             qapEval = new eval_qap();
//             qapEval->set_instance(inst);
//             break;
//         }
//         case 'n': {
//             printf("q3ap\n");
//             inst  = new instance_qap(arguments::inst_name);
//             q3apEval = new eval_q3ap();
//             q3apEval->set_instance(inst);
//
//             break;
//         }
//         case 't':
//         {
//             printf("tsp\n");
//             inst  = new instance_tsp(arguments::inst_name);
//             tspEval = new eval_tsp();
//             tspEval->set_instance(inst);
//
//             break;
//         }
//     }
//
//     // =========================
//     struct timespec t_start, t_end, t_elapsed;
//     struct timespec t2_start, t2_end;
//     // =========================
//
//     switch (arguments::problem) {
//         case 'f':{
//             Permutation *pop[MAXPOP];
//
//             for (int i=0;i<arguments::batch_size;i++){
//                 pop[i]=new Permutation(inst->size);
//             }
//
//             t_elapsed.tv_sec=0;
//             t_elapsed.tv_nsec=0;
//
//             clock_gettime(CLOCK_MONOTONIC, &t2_start);
//
//             for(int i=0;i<outer_loop_count;i++)
//             {
//                 for(int j=0;j<arguments::batch_size;++j){
//                     pop[j]->randomInit();
//                 }
//
//                 clock_gettime(CLOCK_MONOTONIC, &t_start);
//
//                 #pragma omp parallel for schedule(runtime)
//                 for (int i=0;i<arguments::batch_size;i++) {
//                     pop[i]->cost = fspEval->evalSolution(pop[i]->perm);
//                 }
//
//                 clock_gettime(CLOCK_MONOTONIC, &t_end);
//
//                 t_elapsed.tv_sec += (t_end.tv_sec - t_start.tv_sec);
//                 t_elapsed.tv_nsec += (t_end.tv_nsec - t_start.tv_nsec);
//             }
//
//             for(int j=0;j<arguments::batch_size;++j){
//                 delete pop[j];
//             }
//
//             clock_gettime(CLOCK_MONOTONIC, &t2_end);
//             break;
//         }
//         case 'q': {
//             Permutation *pop[MAXPOP];
//
//             for (int i=0;i<arguments::batch_size;i++){
//                 pop[i]=new Permutation(inst->size);
//             }
//
//             t_elapsed.tv_sec=0;
//             t_elapsed.tv_nsec=0;
//
//             clock_gettime(CLOCK_MONOTONIC, &t2_start);
//
//             for(int i=0;i<outer_loop_count;i++)
//             {
//                 for(int j=0;j<arguments::batch_size;++j){
//                     pop[j]->randomInit();
//                 }
//
//                 clock_gettime(CLOCK_MONOTONIC, &t_start);
//
//                 #pragma omp parallel for schedule(runtime)
//                 for (int i=0;i<arguments::batch_size;i++) {
//                     pop[i]->cost = qapEval->evalSolution(pop[i]->perm);
//                 }
//
//                 clock_gettime(CLOCK_MONOTONIC, &t_end);
//
//                 t_elapsed.tv_sec += (t_end.tv_sec - t_start.tv_sec);
//                 t_elapsed.tv_nsec += (t_end.tv_nsec - t_start.tv_nsec);
//             }
//
//             for(int j=0;j<arguments::batch_size;++j){
//                 delete pop[j];
//             }
//
//             clock_gettime(CLOCK_MONOTONIC, &t2_end);
//
//             std::cout << "\n\tEvalLoop(s):\t"
//                       << t_elapsed.tv_sec + t_elapsed.tv_nsec / 1.0e9
//                       << std::endl;
//
//             std::cout << "\n\tTotElapsed(s):\t"
//                       << ((t2_end.tv_sec - t2_start.tv_sec) + (t2_end.tv_nsec - t2_start.tv_nsec) / 1.0e9)
//                       << std::endl;
//
//             break;
//         }
//         case 'n': {
//             printf("q3ap\n");
//
//             //should make an object "permutation pair" ..
//             Permutation *pop[MAXPOP];
//             Permutation *pop2[MAXPOP];
//
//             for (int i=0;i<arguments::batch_size;i++){
//                 pop[i]=new Permutation(inst->size);
//                 pop2[i]=new Permutation(inst->size);
//             }
//
//             struct timespec t_start, t_end, t_elapsed;
//             struct timespec t2_start, t2_end;
//             t_elapsed.tv_sec=0;
//             t_elapsed.tv_nsec=0;
//
//             clock_gettime(CLOCK_MONOTONIC, &t2_start);
//             //
//             for(int i=0;i<outer_loop_count;i++)
//             {
//                 for(int j=0;j<arguments::batch_size;++j){
//                     pop[j]->randomInit();
//                     pop2[j]->randomInit();
//                 }
//
//                 clock_gettime(CLOCK_MONOTONIC, &t_start);
//             //
//                 #pragma omp parallel for schedule(runtime)
//                 for (int i=0;i<arguments::batch_size;i++) {
//                     pop[i]->cost = q3apEval->evalSolution(pop[i]->perm,pop2[i]->perm);
//                 }
//             //
//                 clock_gettime(CLOCK_MONOTONIC, &t_end);
//             //
//                 t_elapsed.tv_sec += (t_end.tv_sec - t_start.tv_sec);
//                 t_elapsed.tv_nsec += (t_end.tv_nsec - t_start.tv_nsec);
//             }
//             //
//             for(int j=0;j<arguments::batch_size;++j){
//                 delete pop[j];
//                 delete pop2[j];
//             }
//
//             clock_gettime(CLOCK_MONOTONIC, &t2_end);
//
//             std::cout << "\n\tEvalLoop(s):\t"
//                       << t_elapsed.tv_sec + t_elapsed.tv_nsec / 1.0e9
//                       << std::endl;
//
//             std::cout << "\n\tTotElapsed(s):\t"
//                       << ((t2_end.tv_sec - t2_start.tv_sec) + (t2_end.tv_nsec - t2_start.tv_nsec) / 1.0e9)
//                       << std::endl;
//
//             break;
//         }
//         case 't': {
//             // std::cout<<"helloe "<<inst->size<<"\n";
//             Permutation *pop[MAXPOP];
//
//             for (int i=0;i<arguments::batch_size;i++){
//                 pop[i]=new Permutation(inst->size);
//             }
//
//             // std::cout<<"helloe\n";
//             struct timespec t_start, t_end, t_elapsed;
//             struct timespec t2_start, t2_end;
//             t_elapsed.tv_sec=0;
//             t_elapsed.tv_nsec=0;
//
//             clock_gettime(CLOCK_MONOTONIC, &t2_start);
//
//             for(int i=0;i<outer_loop_count;i++)
//             {
//                 for(int j=0;j<arguments::batch_size;++j){
//                     pop[j]->randomInit();
//                 }
//
//                 clock_gettime(CLOCK_MONOTONIC, &t_start);
//                 //
//                 #pragma omp parallel for schedule(runtime)
//                 for (int i=0;i<arguments::batch_size;i++) {
//                     pop[i]->cost = tspEval->evalSolution(pop[i]->perm);
//                 }
//                 //
//                 clock_gettime(CLOCK_MONOTONIC, &t_end);
//                 //
//                 t_elapsed.tv_sec += (t_end.tv_sec - t_start.tv_sec);
//                 t_elapsed.tv_nsec += (t_end.tv_nsec - t_start.tv_nsec);
//             }
//
//             for(int j=0;j<arguments::batch_size;++j){
//                 delete pop[j];
//             }
//
//             clock_gettime(CLOCK_MONOTONIC, &t2_end);
//
//             break;
//         }
//     }
//
//     std::cout << "\n\tEvalLoop(s):\t"  \
//           << t_elapsed.tv_sec + t_elapsed.tv_nsec / 1.0e9 \
//           << std::endl;
//
//     std::cout << "\n\tTotElapsed(s):\t" \
//           << ((t2_end.tv_sec - t2_start.tv_sec) + (t2_end.tv_nsec - t2_start.tv_nsec) / 1.0e9) \
//           << std::endl;
// } // main
