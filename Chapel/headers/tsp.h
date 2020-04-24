#ifndef __TSP__H_

#define COORD
#define MAXLINELEN 100


//ok
int tsp_N;

double * xcoord;
double * ycoord;
//ok
typedef struct Move {
    int a;
    int b;
} Move;


//ok
void tsp_swap(int * ptrA, int * ptrB);

// Coordinate representation (TSP)
// ===============================
void readCoord(const char path[]);
void initFromFile(const char instance_path[]);

// 2D euclidean distance
// ========================================
double getCost(const int a, const int b);

double eval(const int * perm);

// 2-opt moves
void apply2opt(int * perm, const Move mv);
// double eval2opt(const int* perm, const int a, const int b){
double eval2opt(const int * perm, const Move mv);


//nao precisa
// void
// randomizeTour(int * tour, unsigned int seed)
// {
//     srand(seed);
//     int rnd;
//     for (int i = 2; i < N; ++i) {
//         rnd = i + rand() % (N - i);
//         swap(&tour[i], &tour[rnd]);
//     }
// }

#endif