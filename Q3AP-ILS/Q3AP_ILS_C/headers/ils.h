#ifndef ILS_H
#define ILS_H

#include "../headers/qap_instance.h"
#include "../headers/solution.h"
#include "../headers/evalQ3AP.h"

class evalQ3AP;
class Solution;

typedef struct LargeMove {
    int a;
    int b;
    int c;
    int d;
} LargeMove;

class ils
{
public:
  ils(int _size, evalQ3AP *_eval);
  ~ils();

  int size;
  int ilsiter;

  int nhood_size;
  int *index_nhood;

  evalQ3AP *eval;

  void generate_neighborhood();

  int searchLocalLarge(Solution* sol,int max_iter);

  void swap(int *a,int *b);
  void randomKopt(Solution* sol,int k,int p);
  void apply22ex(Solution* sol, LargeMove mv);

  int run(Solution* sol);
};

#endif
