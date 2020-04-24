#!/bin/bash

export TIME='\nElapsed(s) : %e\nUser: %U\nCPU : %P\nMaxResMem : %M\nMajor Page Faults : %F\nMinor Page Faults : %R\nContext Switches(involuntary) : %c\nContext Switches(voluntary) : %w\nCommand : %C\nExit : %x'

cd ..

for n in 12 13 15 18 22 25 30
do
	for t in 1 2 4 8 16 32 64
	do
		export OMP_NUM_THREADS=${t}
		/usr/bin/time ../ga nug${n} 100 > ./results/nug${n}_th${t} 2>&1
	done
done
