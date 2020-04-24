#include <getopt.h>
#include <string.h>
#include <iostream>

#include "../headers/arguments.h"

// -z p=arguments::problem,i=arguments::inst_name[50] -b arguments::batch_size
char arguments::problem;
char arguments::inst_name[50];
int arguments::batch_size = 1;

void
arguments::printHelp()
{
    printf("===== required arguments =====\n");
    printf("-z\t p=<problem>,i=<instance> \n");
    printf("\t\t problem = <f[fsp],q[qap],t[tsp],a[q3ap]>\n");
    printf("\t\t instance -> \n \t\tex: ta20 [fsp], nug12 [qap], berlin52 [tsp], nug12 [q3ap]\n");
    printf("-b\t batch size\n");

    printf("\n===== example =====\n");
    printf("./bin/bench -z p=fsp,i=ta120 -b 1000\n\n");
    printf("\t evaluates 1M flowshop solutions in batches of 1000 (for FSP instance ta120) \n");
}

#define OPTIONS "z:bh"
bool
arguments::parse_arguments(int argc, char ** argv)
{
    bool ok = false;

    char * subopts, * value;
    int opt;

    enum { PROBLEM = 0, INST, OPT };
    char * const problem_opts[] = {
        [PROBLEM] = (char *) "p",
        [INST]    = (char *) "i",
        NULL
    };

    struct option long_options[] =
    {
        { "help",             0, 0, 'h' },
        {                  0, 0, 0, 0   }
    };
    int c = getopt_long(argc, argv, OPTIONS, long_options, NULL);

    while (c != -1) {
        switch (c) {
            case 'z': {
                subopts = optarg;

                while (*subopts != '\0')
                    switch (getsubopt(&subopts, problem_opts, &value)) {
                        case PROBLEM:
                            problem = value[0];
                            printf("problem:\t %s\n", value);
                            break;
                        case INST:
                            strcpy(inst_name, value);
                            printf("instance:\t %s\n", inst_name);
                            break;
                    }
                ok = true;
                break;
            }
            // ===============================
            case 'h': {
                printHelp();
                exit(0);
            }
            case 'b': {
                batch_size = strtol(argv[optind], 0, 10);
                printf("batch size:\t %d\n",batch_size);
                break;
            }
        }
        c = getopt_long(argc, argv, OPTIONS, long_options, NULL);
    }

    return ok;
} // arguments::parse_arguments
