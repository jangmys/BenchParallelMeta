#ifndef INSTANCE_TSP_H
#define INSTANCE_TSP_H

struct instance_tsp : public instance_abstract {
    char * file;

    instance_tsp(const char * inst_name);
    ~instance_tsp();

    int
    get_size(const char * file);
    void
    generate_instance(const char * file, std::ostream& stream);
};

#endif
