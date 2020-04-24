#!/bin/bash

export TIME='\nElapsed(s) : %e\nUser: %U\nCPU : %P\nMaxResMem : %M\nMajor Page Faults : %F\nMinor Page Faults : %R\nContext Switches(involuntary) : %c\nContext Switches(voluntary) : %w\nCommand : %C\nExit : %x'

cd ..

unset OMP_SCHEDULE
unset OMP_PROC_BIND
unset OMP_NUM_THREADS

export JULIA_NUM_THREADS=64
export JULIA_EXCLUSIVE=1

for d in $(seq 1 20)
do
	mkdir ./results/test${d}

	#5 minute runs
	for n in 12 13 15 18 22 25
	do
		timeout 5m ./julia ./GA.jl nug${n} 99999999 > ./results/test${d}/nug${n}_64th 2>&1
	done
done
