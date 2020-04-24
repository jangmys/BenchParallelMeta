module tsp_chpl_c_headers{
	use SysCTypes;
	require "headers/tsp.h";

	extern var tsp_N: c_int;
	extern var xcoord: c_ptr(c_double);
	extern var ycoord: c_ptr(c_double);

	extern proc initFromFile(instance_path: c_string);
	extern proc eval(perm : c_ptr(c_int)): c_double;

}