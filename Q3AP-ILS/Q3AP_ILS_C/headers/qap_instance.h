#ifndef QAP_INSTANCE_H
#define QAP_INSTANCE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fstream>
#include <sstream>

class qap_instance
{
public:
  int size;
  std::stringstream *data;

  qap_instance(const char *inst_name);
  ~qap_instance();

  void generate_instance(const char* file, std::ostream& stream);
};


#endif
