module QAP_module{
	use SysCTypes;
	use instance;
	use single_perm_solution;

	proc QAP_evaluation(ref sol: C_int_Sol, const ref inst: Instance): int{
		
		var cost: int = 0;
		var size: int = sol.size;
		var pi: c_int;
		var pj: c_int;

		for i in 0..#size do{
			pi = sol.perm[i];
			for j in 0..#size do{
				pj = sol.perm[j];
				cost += inst.dist[i,j] * inst.flow[pi,pj];
			}//for
		}//for
		return cost;


	}/////////////

}//////////



//for (i = 0; i < size; ++i) {
//        pi = permutation[i];
//        for (j = 0; j < size; ++j) {
//            pj = permutation[j];

//            cost += dist[i * size + j] * flow[pi * size + pj];
//        }