module fsp_simple_chpl_c_headers{
	
	use SysCTypes;
	require "headers/simple_bound.h";
	require "headers/aux.h";

	extern const _MAX_S_MCHN_ : c_int;
	extern const _MAX_S_JOBS_ : c_int;
	extern var minTempsDep : c_ptr(c_int);
	extern var minTempsArr : c_ptr(c_int);
	extern var c_temps: c_ptr(c_int);

	extern proc evalsolution( permutation : c_ptr(c_int), 
		machines : c_int, jobs : c_int, times : c_ptr(c_int)) : c_int;
	extern proc get_instance(ref machines : c_int, ref jobs : c_int, p:c_short) : c_ptr(c_int);
	extern proc print_instance(machines : c_int, jobs : c_int, times : c_ptr(c_int)) : void;
	
}