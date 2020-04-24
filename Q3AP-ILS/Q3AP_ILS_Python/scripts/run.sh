#!/bin/bash

export TIME='\nElapsed(s) : %e\nUser: %U\nCPU : %P\nMaxResMem : %M\nMajor Page Faults : %F\nMinor Page Faults : %R\nContext Switches(involuntary) : %c\nContext Switches(voluntary) : %w\nCommand : %C\nExit : %x'

cd ..

#CAUTION: OpenMP environment variables may interfere with Numba (especially if OpenMP threading layer is used!)
unset OMP_SCHEDULE
unset OMP_NUM_THREADS
unset OMP_PROC_BIND

for d in $(seq 1 10)
do
	mkdir ./results/test${d}

	for n in 12 13 15 18 22 25
	do
		/usr/bin/time python3 ./ilsQ3AP_numba_seq.py nug${n} 100 > ./results/test${d}/nug${n}_sequential 2>&1
	done
done


export NUMBA_THREADING_LAYER=omp

for d in $(seq 1 10)
do
	for n in 12 13 15 18 22 25
	do
		for t in 1 2 4 8 14 28 56
		do
			export NUMBA_NUM_THREADS=${t}
			/usr/bin/time python3 ./ilsQ3AP_numba.py nug${n} 100 > ./results/test${d}/nug${n}_th${t}_omp 2>&1
		done
	done
done

export NUMBA_THREADING_LAYER=tbb

for d in $(seq 1 10)
do
	for n in 12 13 15 18 22 25
	do
		for t in 1 2 4 8 14 28 56
		do
			export NUMBA_NUM_THREADS=${t}
			/usr/bin/time python3 ./ilsQ3AP_numba.py nug${n} 100 > ./results/test${d}/nug${n}_th${t}_tbb 2>&1
		done
	done
done


#only 10 ILS iterations because this is very slow..........
for d in $(seq 1 10)
do
	mkdir ./results/nptest${d}

	for n in 12 13 15 18 22 25
	do
		/usr/bin/time python3 ./ilsQ3AP_numpy.py ./pickle/nug${n}.pkl 10 > ./results/nptest${d}/nug${n}_sequential 2>&1
	done
done

#only 10 ILS iterations because this is very slow..........
for d in $(seq 1 10)
do
	for n in 12 13 15 18 22 25
	do
		/usr/bin/time python3 ./ilsQ3AP_numpy_par.py ./pickle/nug${n}.pkl 10 > ./results/nptest${d}/nug${n}_par 2>&1
	done
done
