#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fstream>

#include "../headers/instance_abstract.h"
#include "../headers/instance_qap.h"

instance_qap::instance_qap(const char * inst_name)
{
    data = new std::stringstream();

    const char qapdirname[] = "../../instances/nug/";
    const char ext[]        = ".dat";

    char * file;
    file = (char *) malloc(strlen(inst_name) + strlen(qapdirname) + strlen(ext) + 1); /* make space for the new string*/

    strcpy(file, qapdirname); /* copy dirname into the new var */
    strcat(file, inst_name);  /* add the instance name */
    strcat(file, ext);        /* add the extension */

    generate_instance(file, *data);

    free(file);
}

instance_qap::~instance_qap()
{
    delete data;
}

void
instance_qap::generate_instance(const char * file, std::ostream& stream)
{
    std::ifstream infile(file);

    if (!infile.eof())
        infile >> size;

    stream << size << " ";

    while (1) {
        // string str;
        int s;
        infile >> s;

        if (infile.eof()) break;

        stream << s << " ";
    }
}
