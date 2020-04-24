#include <sstream>

#ifndef INSTANCE_ABSTRACT_H
# define INSTANCE_ABSTRACT_H
struct instance_abstract
{
    int size;
    union { std::stringstream *data; int *donnee; };
};
#endif /* ifndef INSTANCE_ABSTRACT_H */
