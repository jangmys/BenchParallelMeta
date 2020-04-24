#!/bin/bash

export TIME='\nElapsed(s) : %e\nUser: %U\nCPU : %P\nMaxResMem : %M\nMajor Page Faults : %F\nMinor Page Faults : %R\nContext Switches(involuntary) : %c\nContext Switches(voluntary) : %w\nCommand : %C\nExit : %x'

cd ..

unset OMP_SCHEDULE
unset OMP_NUM_THREADS
unset OMP_PROC_BIND

export NUMBA_THREADING_LAYER=tbb

for i in ta020 ta120
do
	for t in 1 2 4 8 16 32 64
	do
		export NUMBA_NUM_THREADS=${t}
		for l in 100 1000 10000 100000
		do
			/usr/bin/time python3 ./test.py ../fsp/${i}.dat fsp ${l} > ./results/FSP_${i}_${t}_${l} 2>&1
		done
	done
done

#QAP
for i in nug12 tho150
do
	for t in 1 2 4 8 16 32 64
	do
		export NUMBA_NUM_THREADS=${t}
		for l in 100 1000 10000 100000
		do
			/usr/bin/time python3 ./test.py ../qaplib/${i}.dat qap ${l} > ./results/QAP_${i}_${t}_${l} 2>&1
		done
	done
done

#TSP
for i in berlin52 pr2392
do
	for t in 1 2 4 8 16 32 64
	do
		export NUMBA_NUM_THREADS=${t}
		for l in 100 1000 10000 100000
		do
			/usr/bin/time python3 ./test.py ../tsp_instances/${i}.tsp tsp ${l} > ./results/TSP_${i}_${t}_${l} 2>&1
		done
	done
done

#Q3AP
for i in nug12 nug25
do
	for t in 1 2 4 8 16 32 64
	do
		export NUMBA_NUM_THREADS=${t}
		for l in 100 1000 10000 100000
		do
			/usr/bin/time python3 ./test.py ../pickle/${i}.pkl q3ap ${l} > ./results/Q3AP_${i}_${t}_${l} 2>&1
		done
	done
done
