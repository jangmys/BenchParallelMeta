#!/bin/bash

export TIME='\nElapsed(s) : %e\nUser: %U\nCPU : %P\nMaxResMem : %M\nMajor Page Faults : %F\nMinor Page Faults : %R\nContext Switches(involuntary) : %c\nContext Switches(voluntary) : %w\nCommand : %C\nExit : %x'

cd ..

#run 10 repetitions
for d in $(seq 1 10)
do
	mkdir ./results/test${d}
	#nug 12 13 ... 25
	for n in 12 13 15 18 22 25
	do
		/usr/bin/time julia ils_q3ap_seq.jl nug12 100 > ./results/test${d}/nug${n}_sequential 2>&1
	done
done

export JULIA_EXCLUSIVE=1 #If set to anything besides 0, then Julia's thread policy is consistent with running on a dedicated machine: the master thread is on proc 0, and threads are affinitized. Otherwise, Julia lets the operating system handle thread policy. ---> No significant difference observed

for d in $(seq 1 10)
do
	for n in 12 13 15 18 22 25
	do
		for t in 1 2 4 8 14 28 56
			export JULIA_NUM_THREADS=${t} #set number of threads
			/usr/bin/time ../julia ils_q3ap_par.jl nug12 100 > ./results/test${d}/nug${n}_th${t}_excl 2>&1
		done
	done
done

export JULIA_EXCLUSIVE=0

for d in $(seq 1 10)
do
	for n in 12 13 15 18 22 25
	do
		for t in 1 2 4 8 14 28 56
			export JULIA_NUM_THREADS=${t}
			/usr/bin/time ../julia q3ap_opt.jl nug12 100 > ./results/test${d}/nug${n}_th${t}_nexcl 2>&1
		done
	done
done
