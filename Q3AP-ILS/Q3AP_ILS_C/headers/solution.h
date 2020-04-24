#ifndef SOLUTION_H_
#define SOLUTION_H_

#include "../headers/evalQ3AP.h"

#include <stdlib.h>

class Solution
{
public:
  Solution(int _size);
//  Solution(const Solution&);
  ~Solution();

  int size;
  int* perm[2];
  int cost;

  Solution& operator=(const Solution& sol);

  void randomInit();
  void print() const;

  bool isEqual(const Solution* sol);
  // void eval();
};

#endif
