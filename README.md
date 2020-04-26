# BenchParallelMeta

This repository contains the source code for the comparative study presented in the paper

Jan Gmys, Tiago Carneiro, Nouredine Melab, El-Ghazali Talbi, Daniel Tuyttens, *A comparative study of high-productivity high-performance programming languages for parallel metaheuristics*, Swarm and Evolutionary Computation

=================
-----------------
# Content

Parallel implementations in **C++/OpenMP**, **Julia**, **Python-Numba** and **Chapel**:

1. For the 3-dimensional Quadratic Assignment Problem (Q3AP)

    * **Q3AP-ILS**: *Iterated Local Search* (ILS) metaheuristic using multi-threaded parallel neighborhood evaluations.
    * **Q3AP-GA**: Genetic Algorithm, hybridized with Parallel Local Search.

2. **ParallelBatchEval**: A micro-benchmark evaluating the performance of  parallel batch evaluation of solutions for different batchsizes and different cost functions:

    * Permutation Flowshop Scheduling Problem (PFSP)
    * Quadratic Assignment Problem (QAP)
    * Traveling Salesman Problem (TSP)
    * Q3AP  

=================
-----------------
# How to run

## ILS
### Python
* no numba, instance nug12-d, 10 ILS iterations
    * `python3 ./ilsQ3AP_numpy.py nug12 10`
* no numba + multiprocessing
    * `python3 ./ilsQ3AP_numpy_par.py nug12 10`
* with numba
    * sequential: `python3 ./ilsQ3AP_numba_seq.py nug12 100`
    * parallel: `python3 ./ilsQ3AP_numba_seq.py nug12 100`

To set the number of threads in the parallel numba version
* ex.: `export NUMBA_NUM_THREADS=4`
* OpenMP environment variables should be unset as they may interfere

### Julia
* sequential (nug12-d, 100 iterations)
    * `julia ./ils_q3ap_seq.jl nug12 100`

* parallel (8 threads)
    * `export JULIA_NUM_THREADS=8`
    * `julia ./ils_q3ap_par.jl nug12 100`

### C
* compile:
    * `make`
* run with 8 threads (nug12-d, 100 iterations)
    * `OMP_NUM_THREADS=8 ./ils nug12 100`

-----------------
## ParallelBatchEval

### Python
3 arguments required: problem | instance| batchsize

Examples:
* `python3 ./bench.py TSP berlin52 1000`
* `python3 ./bench.py FSP ta020 10000`
* `python3 ./bench.py QAP nug15 100`
* `python3 ./bench.py Q3AP nug12 1000`

### Julia
3 arguments required: problem | instance| batchsize

Examples:
* `julia ./bench.jl TSP berlin52 1000`

### C
* `make`
* `./bench -z p=fsp,i=ta120 -b 1000`
* `./bench --help` gives some help
