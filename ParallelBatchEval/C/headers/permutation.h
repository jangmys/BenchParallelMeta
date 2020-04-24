#ifndef PERMUTATION_H_
#define PERMUTATION_H_

class Permutation
{
public:
  Permutation(int _size);
  Permutation(const Permutation&); //copy constr

  ~Permutation();

  int size;
  int* perm;
  int cost;

  void operator=(const Permutation& sol);

  void randomInit();
  void print();
  bool isEqual(const Permutation* sol);
};

#endif
