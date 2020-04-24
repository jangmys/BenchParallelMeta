#include <stdio.h>
#include <stdlib.h>

#include "../headers/permutation.h"

Permutation::Permutation(int _size)
{
	size = _size;
	perm = new int[size];
    for (int i = 0; i < size; ++i) {
		perm[i] = i;
	}
	cost=0;
}

Permutation::Permutation(const Permutation &sol)
{
    size = sol.size;
    for (int i = 0; i < size; ++i) {
		perm[i] = sol.perm[i];
	}
    cost = sol.cost;
}

Permutation::~Permutation()
{
	delete[]perm;
}

void
Permutation::operator=(const Permutation& sol)
{
	size = sol.size;
	for (int i = 0; i < size; ++i) {
		perm[i] = sol.perm[i];
	}
	cost = sol.cost;
}

void
Permutation::randomInit()
{
	int i, j, tmp;

	for (i = 0; i < size; i++)
		perm[i] = i;

	for (i = size - 1; i > 0; i--) {
		j = rand() % (i + 1);
		tmp = perm[j];
		perm[j] = perm[i];
		perm[i] = tmp;
	}
}

void
Permutation::print()
{
    printf("%d\t",size);
	for (int i = 0; i < size; ++i)
		printf("%3d", perm[i]);
	printf("\t \t");
	printf("Cost:\t%d\n", cost);
}
