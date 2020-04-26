#include <iostream>

#include "../headers/solution.h"
#include "../headers/evalQ3AP.h"

evalQ3AP::evalQ3AP(qap_instance* inst)
{
  (inst->data)->seekg (0);
  (inst->data)->clear ();

  *(inst->data)>>size;

  //initialize cost matrix
    int * dist = new int[size*size];
    int * flow = new int[size*size];

  for(int i=0; i<size; i++)
	  for(int j=0; j<size; j++)
	    *(inst->data)>>flow[i*size+j];

	for(int i=0; i<size; i++)
	  for(int j=0; j<size; j++)
	    *(inst->data)>>dist[i*size+j];

    costMatrix = new int[size*size*size*size*size*size];

  //loop to generate 6D cost matrix for Q3AP (from QAP)
  for(int i=0;i<size;++i){
    for(int k=0;k<size;++k){
      int fik2=flow[i*size+k]*flow[i*size+k];
      for(int j=0;j<size;++j){
        for(int n=0;n<size;++n){
          int djn=dist[j*size+n];
          for(int p=0;p<size;++p){
            for(int q=0;q<size;++q){
              //...use indexing function I6D
              costMatrix[I6D(i,j,p,k,n,q)]=fik2*djn*dist[p*size+q];
            }
          }
        }
      }
    }
  }

  //keep them if QAP ...
    delete[]dist;
    delete[]flow;
}

evalQ3AP::~evalQ3AP()
{
    delete[]costMatrix;
}

// indexing function (helper)
int
evalQ3AP::I6D(const int x1, const int x2, const int x3, const int x4, const int x5, const int x6) const
{
    return x1 * (size * size * size * size * size) \
           + x2 * (size * size * size * size) \
           + x3 * (size * size * size) \
           + x4 * (size * size) \
           + x5 * size \
           + x6;
}

int
evalQ3AP::fullEval(const Solution* sol) const
{
  int cost=0;

    for (int i = 0; i < size; ++i)
        for (int j = 0; j < size; ++j)
      cost += costMatrix[I6D(i, sol->perm[0][i], sol->perm[1][i], j, sol->perm[0][j], sol->perm[1][j])];

  return cost;
}

int
evalQ3AP::deltaEval(const Solution * sol, const LargeMove mv)
{
    int delta = 0;

    int a = mv.a;
    int b = mv.b;
    int c = mv.c;
    int d = mv.d;

    int p0, q0, p1, q1;

    for (int i = 0; i < size; ++i) {
        if (!(i == a || i == b || i == c || i == d)) continue;

        p0 = sol->perm[0][i];
        q0 = sol->perm[1][i];

        if (i == a) p0 = sol->perm[0][b];
        if (i == b) p0 = sol->perm[0][a];
        if (i == c) q0 = sol->perm[1][d];
        if (i == d) q0 = sol->perm[1][c];

        for (int j = 0; j < size; ++j) {
            p1 = sol->perm[0][j];
            q1 = sol->perm[1][j];

            if (j == a) p1 = sol->perm[0][b];
            if (j == b) p1 = sol->perm[0][a];
            if (j == c) q1 = sol->perm[1][d];
            if (j == d) q1 = sol->perm[1][c];

            delta += costMatrix[I6D(i, sol->perm[0][i], sol->perm[1][i], j, sol->perm[0][j], sol->perm[1][j])];
            delta -= costMatrix[I6D(i, p0, q0, j, p1, q1)];

            if (!(j == a || j == b || j == c || j == d)) {
                delta += costMatrix[I6D(j, sol->perm[0][j], sol->perm[1][j], i, sol->perm[0][i], sol->perm[1][i])];
                delta -= costMatrix[I6D(j, p1, q1, i, p0, q0)];
            }
        }
    }

    return delta;
} // evalQ3AP::deltaEval
