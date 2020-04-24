#ifndef __SIMPLE_BOUND__
#define __SIMPLE_BOUND__


// void remplirTempsArriverDepart(int *minTempsArr, int *minTempsDep, 
//     const int machines, const int jobs, const int * times);


#define _MAX_S_MCHN_ 20
#define _MAX_S_JOBS_ 30

int c_temps[_MAX_S_MCHN_*_MAX_S_JOBS_];
int minTempsDep[_MAX_S_MCHN_];//read only
int minTempsArr[_MAX_S_MCHN_];//read only -- fill once and fire


int evalsolution(const int permutation[],const int machines, const int jobs, 
    const int *times);




#endif