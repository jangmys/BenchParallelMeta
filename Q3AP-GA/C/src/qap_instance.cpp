#include "../headers/qap_instance.h"

qap_instance::qap_instance(const char* inst_name)
{
	data=new std::stringstream();

    const char qapdirname[] = "../../instances/nug/";
    const char ext[]        = ".dat";

	char* file;

    file = (char *) malloc(strlen(inst_name) + strlen(qapdirname) + strlen(ext) + 1);

    strcpy(file, qapdirname); /* copy dirname into the new var */
    strcat(file, inst_name);  /* add the instance name */
    strcat(file, ext);        /* add the extension */

	generate_instance(file,*data);

	free(file);
}

qap_instance::~qap_instance()
{
	delete data;
}

void qap_instance::generate_instance(const char* file, std::ostream& stream)
{
	std::ifstream infile(file);

	if(!infile.eof())
		infile >> size;

	stream << size << " ";

	while(1){
    int s;
		infile >> s;

		if(infile.eof())break;

		stream << s << " ";
	}
}
