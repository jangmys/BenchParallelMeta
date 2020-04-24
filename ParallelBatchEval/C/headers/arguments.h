#ifndef ARGUMENTS_H
#define ARGUMENTS_H

class arguments
{
public:
    static char problem;
    static char inst_name[50];
    static int batch_size;

    static void printHelp();
    static bool parse_arguments(int argc, char **argv);
};

#endif /* ifndef ARGUMENTS_H */
