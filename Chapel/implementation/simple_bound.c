#include "../headers/simple_bound.h"
#include "../headers/aux.h"
#include <stdio.h>
#include <limits.h>
#include <stdlib.h>


int evalsolution(const int permutation[],const int machines, const int jobs, 
    const int *times){

    //lets change for malloc
    //int temp= new int[jobs];

    int temp[jobs];

 	for(int mm=0;mm<machines;mm++) temp[mm]=0;

 	for(int j=0;j<jobs;j++)
   	{
   		int job=permutation[j];
  
        temp[0]=temp[0]+times[0*jobs + job]; 
         
   		for(int m=1;m<machines;m++){
   	
            temp[m]=max(temp[m],temp[m-1])+times[m*jobs+job];
        }
   	}

   	return temp[machines-1];
}

