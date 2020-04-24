#!/bin/bash

export TIME='\nElapsed(s) : %e\nUser: %U\nCPU : %P\nMaxResMem : %M\nMajor Page Faults : %F\nMinor Page Faults : %R\nContext Switches(involuntary) : %c\nContext Switches(voluntary) : %w\nCommand : %C\nExit : %x'

cd ..

unset OMP_SCHEDULE
unset OMP_PROC_BIND
unset OMP_NUM_THREADS


for d in $(seq 1 20)
do
	mkdir ./results/test${d}

	export NUMBA_NUM_THREADS=64
	export NUMBA_THREADING_LAYER=tbb

	for n in 12 13 15 18 22 25 
	do
		timeout 5m python3 ./GA_Q3AP_numba.py ../nug/nug${n}.dat 9999999 > ./results/test${d}/nug${n}_64th_tbb 2>&1
	done
		
	for n in 12 13 15 18 22 25 
	do
		timeout 5m python3 ./GA_Q3AP.py ../nug/nug${n}.dat 9999999 > ./results/test${d}/nug${n}_seq 2>&1
	done
done
