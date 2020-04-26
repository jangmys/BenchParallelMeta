#ifndef EVALQ3AP_H
#define EVALQ3AP_H

#include "../headers/qap_instance.h"
// #include "../headers/ils.h"

//forward declaration
class Solution;
struct LargeMove;

class evalQ3AP
{
public:
  int size;
  int *costMatrix;

  evalQ3AP(qap_instance* inst);
  ~evalQ3AP();

  int I6D(const int x1,const int x2,const int x3,const int x4,const int x5,const int x6) const;

  int fullEval(const Solution* sol)const;
  int deltaEval(const Solution* sol,const LargeMove mv);
};

#endif
