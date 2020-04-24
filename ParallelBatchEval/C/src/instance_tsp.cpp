#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../headers/instance_abstract.h"
#include "../headers/instance_tsp.h"

instance_tsp::instance_tsp(const char* inst_name)
{
	data=new std::stringstream();

//	const char* qapdirname = "../qap_parameters/qap_instances/";
	const char qapdirname[] = "../../instances/tsp/";
	const char ext[] = ".tsp";

	char* file;
	file = (char*)malloc(strlen(inst_name)+strlen(qapdirname)+strlen(ext)+1); /* make space for the new string*/

	strcpy(file, qapdirname); /* copy dirname into the new var */
	strcat(file, inst_name); /* add the instance name */
	strcat(file, ext); /* add the extension */

	generate_instance(file,*data);

	free(file);
}

instance_tsp::~instance_tsp()
{
	delete data;
}

#define MAXLINELEN 100
void instance_tsp::generate_instance(const char* file, std::ostream& stream)
{
    FILE * fp = fopen(file, "r");

    //    FILE* fp = fopen("./all_tsplib/eil51.tsp","r");
    if (fp == NULL) {
        printf("%s no such file.\n",file);
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
            sscanf(buf, "%*s : %d", &size);
            printf("size\t: %d\n", size);

            stream << size << " ";
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

    float* xcoord = (float *) malloc(size * sizeof(float));
    float* ycoord = (float *) malloc(size * sizeof(float));

    while (fgets(buf, MAXLINELEN, fp) != NULL) {
        buf[strcspn(buf, "\n")] = '\0';
        if (buf[0] == '\0')
            continue;

        int ind;
        float x, y;

        if (strcmp(buf, "EOF") == 0) break;

        sscanf(buf, "%d %f %f", &ind, &x, &y);
        // printf("%d %f %f\n",ind,x,y);

        stream << ind << " " << x << " " << y << " ";

        // xcoord[ind - 1] = x;// tsp files: 1-based numbering of cities
        // ycoord[ind - 1] = y;
    }
    fclose(fp);

	// ifstream infile(file);
	//
	// if(!infile.eof())
	// 	infile >> size;
	//
	// stream << size << " ";
	//
	// while(1){
	// 	//string str;
    //     int s;
	// 	infile >> s;
	//
	// 	if(infile.eof())break;
	//
	// 	stream << s << " ";
	// }
}
