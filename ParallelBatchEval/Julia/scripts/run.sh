#!/bin/bash

export TIME='\nElapsed(s) : %e\nUser: %U\nCPU : %P\nMaxResMem : %M\nMajor Page Faults : %F\nMinor Page Faults : %R\nContext Switches(involuntary) : %c\nContext Switches(voluntary) : %w\nCommand : %C\nExit : %x'

cd ..

unset OMP_SCHEDULE
unset OMP_NUM_THREADS
unset OMP_PROC_BIND

#julia ./bench.jl FSP ta020 100
#julia ./bench.jl QAP nug12 1000
#julia ./bench.jl Q3AP nug12 10000
#julia ./bench.jl TSP berlin52 1000

#FSP
for i in ta020 ta120
do
	for t in 1 2 4 8 16 32 64
	do
		export JULIA_NUM_THREADS=${t}
		for l in 100 1000 10000 100000
		do
			/usr/bin/time julia ./bench.jl FSP ${i} ${l} > ./results/FSP_${i}_${t}_${l} 2>&1
		done
	done
done

#QAP
for i in nug12 tho150
do
	for t in 1 2 4 8 16 32 64
	do
		export JULIA_NUM_THREADS=${t}
		for l in 100 1000 10000 100000
		do
			/usr/bin/time julia QAP ${i} ${l} > ./results/QAP_${i}_${t}_${l} 2>&1
		done
	done
done

#TSP
for i in berlin52 pr2392
do
	for t in 1 2 4 8 16 32 64
	do
		export JULIA_NUM_THREADS=${t}
		for l in 100 1000 10000 100000
		do
			/usr/bin/time julia ./bench.jl ../tsp_instances/${i}.tsp TSP ${l} > ./results/TSP_${i}_${t}_${l} 2>&1
		done
	done
done

#Q3AP
for i in nug12 nug25
do
	for t in 1 2 4 8 16 32 64
	do
		export JULIA_NUM_THREADS=${t}
		for l in 100 1000 10000 100000
		do
			/usr/bin/time julia ./bench.jl ${i} Q3AP ${l} > ./results/Q3AP_${i}_${t}_${l} 2>&1
		done
	done
done
