#ifndef SOLUTION_H_
#define SOLUTION_H_

#include "../headers/evalQ3AP.h"

#include <stdlib.h>

class Solution
{
public:
  Solution(int _size);
  Solution(const Solution&); //copy constr

  ~Solution();

  int size;
  int* perm[2];
  int cost;

  void operator=(const Solution& sol);

  void randomInit();
  void print();

  bool isEqual(const Solution* sol);
  // void eval();
};

#endif
