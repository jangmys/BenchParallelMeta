# BenchParallelMeta

This repository contains the source code for the comparative study presented in the paper

Jan Gmys, Tiago Carneiro, Nouredine Melab, El-Ghazali Talbi, Daniel Tuyttens, *A comparative study of high-productivity high-performance programming languages for parallel metaheuristics*, Swarm and Evolutionary Computation

## Content

Parallel implementations in **C++/OpenMP**, **Julia**, **Python-Numba** and **Chapel**:

1. For the 3-dimensional Quadratic Assignment Problem (Q3AP)

    * **Q3AP-ILS**: *Iterated Local Search* (ILS) metaheuristic using multi-threaded parallel neighborhood evaluations.
    * **Q3AP-GA**: Genetic Algorithm, hybridized with Parallel Local Search.

2. **ParallelBatchEval**: A micro-benchmark evaluating the performance of  parallel batch evaluation of solutions for different batchsizes and different cost functions:

    * Permutation Flowshop Scheduling Problem (PFSP)
    * Quadratic Assignment Problem (QAP)
    * Traveling Salesman Problem (TSP)
    * Q3AP  
