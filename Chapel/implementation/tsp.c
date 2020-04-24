
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include "../headers/tsp.h"

void tsp_swap(int * ptrA, int * ptrB)
{
    int tmp = *ptrA;

    *ptrA = *ptrB;
    *ptrB = tmp;
}


void
readCoord(const char path[]){
	
    FILE * fp = fopen(path, "r");

    //    FILE* fp = fopen("./all_tsplib/eil51.tsp","r");
    if (fp == NULL) {
        printf("no such file.");
        return;
    }

    char buf[MAXLINELEN];
    char word[1000];

    while (fgets(buf, MAXLINELEN, fp) != NULL) {
        buf[strcspn(buf, "\n")] = '\0';
        if (buf[0] == '\0')
            continue;

        sscanf(buf, "%s", word);
        if (strcmp(word, "NAME") == 0) {
            sscanf(buf, "%*s : %s", word);
            printf("instance\t: %s\n", word);
        }
        if (strcmp(word, "DIMENSION") == 0) {
            sscanf(buf, "%*s : %d", &tsp_N);
            printf("size\t: %d\n", tsp_N);
        }
        if (strcmp(word, "COMMENT") == 0) {
            sscanf(buf, "%*s : %[^\t\n]", word);
            printf("%s\n", word);
        }
        if (strcmp(word, "EDGE_WEIGHT_TYPE") == 0) {
            sscanf(buf, "%*s : %s", word);
            if (strcmp(word, "EUC_2D") != 0) {
                printf("only EUC_2D distance\n");
                exit(0);
            }
        }
        if (strcmp(word, "NODE_COORD_SECTION") == 0) {
            break;
        }
    }
    printf(" ===================\n");

    xcoord = (double *) malloc(tsp_N * sizeof(double));
    ycoord = (double *) malloc(tsp_N * sizeof(double));

    while (fgets(buf, MAXLINELEN, fp) != NULL) {
        buf[strcspn(buf, "\n")] = '\0';
        if (buf[0] == '\0')
            continue;

        int ind;
        double x, y;

        if (strcmp(buf, "EOF") == 0) break;

        sscanf(buf, "%d %lf %lf", &ind, &x, &y);
        // printf("%d %f %f\n",ind,x,y);
        xcoord[ind - 1] = x;// tsp files: 1-based numbering of cities
        ycoord[ind - 1] = y;
    }
    fclose(fp);
} // readCoord

void initFromFile(const char instance_path[])
{
    #ifdef COORD
    readCoord(instance_path);
    #endif
}

// 2D euclidean distance
// ========================================
double getCost(const int a, const int b)
{
    double dx = xcoord[a] - xcoord[b];
    double dy = ycoord[a] - ycoord[b];


    //printf("\nMove: %d, %d", a,b );

    return dx * dx + dy * dy;
}

double eval(const int * perm)
{
    double cost = 0;

    cost = sqrtf(getCost(0, perm[1]));
    for (int i = 1; i + 1 < tsp_N; ++i) {
        cost += sqrtf(getCost(perm[i], perm[i + 1]));
    }
    cost += sqrtf(getCost(perm[tsp_N - 1], 0));

    return cost;
}

// 2-opt moves
void
apply2opt(int * perm, const Move mv)
{
    int * temp;

    temp = (int *) malloc(tsp_N * sizeof(int));

    for (int i = 0; i < mv.a; ++i) {
        temp[i] = perm[i];
    }

    for (int i = mv.a, j = mv.b; i <= mv.b; ++i, --j) {
        temp[i] = perm[j];
    }

    for (int i = mv.b + 1; i < tsp_N; ++i) {
        temp[i] = perm[i];
    }

    memcpy(perm, temp, tsp_N * sizeof(int));

    free(temp);
}

// double eval2opt(const int* perm, const int a, const int b){
double
eval2opt(const int * perm, const Move mv)
{
    int a = mv.a;
    int b = mv.b;

    double delta = 0.0f;

    delta = getCost(perm[a - 1], perm[a]) - getCost(perm[a - 1], perm[b]) + getCost(perm[b], perm[b + 1]) - getCost(perm[a], perm[b + 1]);


    return delta;
}

