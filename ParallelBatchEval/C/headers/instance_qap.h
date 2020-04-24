#ifndef INSTANCE_QAP_H
#define INSTANCE_QAP_H

struct instance_qap : public instance_abstract
{
	char* file;

	instance_qap(const char *inst_name);
	~instance_qap();

  int get_size(const char *file);
	void generate_instance(const char* file, std::ostream& stream);
};

#endif
