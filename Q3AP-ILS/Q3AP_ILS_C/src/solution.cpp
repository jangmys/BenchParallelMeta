#include "../headers/solution.h"

Solution::Solution(int _size)
{
    size    = _size;
    perm[0] = new int[size];
    perm[1] = new int[size];
}

Solution::~Solution()
{
    delete[]perm[0];
    delete[]perm[1];
}

Solution&
Solution::operator = (const Solution& sol)
{
    size = sol.size;
    for (int i = 0; i < size; ++i) {
        perm[0][i] = sol.perm[0][i];
        perm[1][i] = sol.perm[1][i];
    }
    cost = sol.cost;

    return *this;
}

bool
Solution::isEqual(const Solution * sol)
{
    bool ret = true;

    int i=0;

    while (i < size && ret) {
        if (perm[0][i] == sol->perm[0][i] && perm[1][i] == sol->perm[1][i]) i++;
        else ret = false;
    }

    return ret;
}

void
Solution::randomInit()
{
    int i, j, tmp;

    for (int k = 0; k <= 1; k++)
        for (i = 0; i < size; i++)
            perm[k][i] = i;

    for (i = size - 1; i > 0; i--) {   // for loop to shuffle
        j          = rand() % (i + 1); // randomise j for shuffle with Fisher Yates
        tmp        = perm[0][j];
        perm[0][j] = perm[0][i];
        perm[0][i] = tmp;
    }
    for (i = size - 1; i > 0; i--) {   // for loop to shuffle
        j          = rand() % (i + 1); // randomise j for shuffle with Fisher Yates
        tmp        = perm[1][j];
        perm[1][j] = perm[1][i];
        perm[1][i] = tmp;
    }
}

void
Solution::print() const
{
    for (int k = 0; k <= 1; k++) {
        for (int i = 0; i < size; ++i)
            printf("%3d", perm[k][i]);
        printf("\t \t");
    }
    printf("Cost:\t%d\n", cost);
}
