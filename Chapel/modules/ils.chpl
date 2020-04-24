module ils{

	use evalQ3AP;
	use solution;
	use Barriers;
	use Random;
	use DynamicIters;

	//This parameter was fixed for some experiments of the paper. 
	//could be passed by command line
	const  MAX_ITER_LS:  int =  100;//number of moves of the ls
	const  MAX_ITER_ILS: int =  100;//number of iterations

	proc init_nhood_size(const size: int): int{
		var loop = {0..(size-1), 0..(size-1)};
		var x: int = 0;
		for (i,k) in loop do
			for j in i..size-1 do
				for l in k..size-1 do
					x+=1;
		return x;
	}

	record ILS{

		var size: int;
		var	nhood_size: int = init_nhood_size(size);
		var dimension = {0..(4*nhood_size-1)};
		var index_nhood:  [dimension] int;

		proc init_nhood(){
			var cpt: int = 0;
			for i in 0..size-1 do 
				for j in i..size-1 do
					for k in 0..size-1 do
						for l in k..size-1 do{
							index_nhood[4*cpt]=i;
							index_nhood[4*cpt+1]=j;
							index_nhood[4*cpt+2]=k;
							index_nhood[4*cpt+3]=l;
							cpt+=1;}
		}/////////////////////////////////////
		
		proc apply22ex(ref sol: Solution, ref mv: LargeMove){
			sol.perm[0,mv.a] <=> sol.perm[0,mv.b]; //swap operator...
			sol.perm[1,mv.c] <=> sol.perm[1,mv.d]; //swap operator...
		}//////////////////////////////////////



		proc searchLocalLarge(ref sol: Solution, const max_it: int, const ref eval: evalQ3AP): int{
		
		 	var itr: int = 0;
		 	var local_move: [0..nhood_size-1] LargeMove = new LargeMove( a=0, b=0, c=0, d=0);
		 	var local_delta_max: [0..nhood_size-1] int ;
		 	var delta_max: int = 0;
		
		 	var ok: int = 1; //flag to break out of parallel region

		 	for 0..(max_it-1) do{
		 	
		 		forall i in dynamic(0..(nhood_size-1), chunkSize = 18) with (ref sol, ref eval, var delta = 0, var mv: LargeMove) do{
		 		
		 			mv = new LargeMove( a=index_nhood[4*i], b=index_nhood[4*i+1], c=index_nhood[4*i+2], d=index_nhood[4*i+3] );
		 			delta = eval.deltaEval(sol, mv);
		 			local_delta_max[i] = delta;
		 			local_move[i] = mv;
		 	
		 		}//forall

		 		var (delta_max, best_move_loc) = maxloc reduce zip(local_delta_max, local_delta_max.domain);
				
		 		if ( delta_max >  0) {
		 			apply22ex(sol, local_move[best_move_loc]);
		 			sol.cost -= delta_max;
		 		}else{
		 			ok = 0;
		 		}///ifelse	
				
		 		itr+=1;

		 		if (ok == 0) then
		 			break;

		 		local_delta_max = 0;
		 		delta_max = 0;
				
		 	} //for

		 	return itr;
		 }//////////////

		proc randomKopt(ref sol: Solution, k: int, p:int){
			
			var arr1: [0..(size-1)] int = [i in 0..(size-1)] i;
			var arr2: [0..(k-1)] int;
			var randStream = new owned RandomStream(int);		
		 	    
			//select k out of n (randomly swap k elements to front of arr1)
			for i in 0..(k-1) do{
				var r: int = abs(randStream.getNext()) % (size - i) + i; //select one remaining....
				arr1[r]<=>arr1[i];
			}//for

			arr2 = [i in 0..(k-1)] arr1[i]; //init arr2,copy selected positions to arr2.	for (int i = 0; i < k; i++) arr2[i] = arr1[i];

			for i in 1..k-1 by -1 do{//shuffle arr2...
				var j: int = abs(randStream.getNext()) % (i+1);
				arr2[i]<=>arr2[j];
			}//for

			arr2 = [i in 0..(k-1)] sol.perm[p,arr2[i]];
			for i in 0..k-1 do sol.perm[p,arr1[i]] = arr2[i];
			
		}///////////////////////////

		proc runPAR(ref bestsol: Solution, ref eval: evalQ3AP){

			var tmpsol = new Solution(size);
			var sol = new Solution(size);//starting solution
			sol.randomInit();
			eval.fullEval(sol);	//evaluate

			searchLocalLarge(sol, MAX_ITER_LS,eval); 
			bestsol = sol;

			writeln("Initial solution: \n",sol);
			writeln("Initial bestsol: \n",bestsol);

			var b: int = 0;
			var minPerturbStrength: int = 3;
			var maxPerturbStrength: int = size;
			var perturbStrength: int  = 3;
			var nhood_evals: int  = 0;

			for k in 0..(MAX_ITER_ILS-1) do{
				tmpsol = sol;
				b = 1 - b;
				randomKopt(sol, perturbStrength, b);
				//sol.cost = eval.fullEval(sol);
				eval.fullEval(sol);
				
				nhood_evals += searchLocalLarge(sol, MAX_ITER_LS,eval);
				//acceptance criterion : if new local optimum is worse than previous...
				if (sol.cost >= tmpsol.cost) {
					sol = tmpsol;                         //go back to previous local opt
					perturbStrength += b;                   //perturb more!
				}else{
					perturbStrength = minPerturbStrength;   //switched to new local opt: perturb less!
				}
				if (perturbStrength >= maxPerturbStrength + 1) {
					perturbStrength = minPerturbStrength;
				}
					//save best found solution !
				if (sol.cost < bestsol.cost) {
					bestsol = sol;
					eval.fullEval(bestsol);
					//bestsol.cost = eval.fullEval(bestsol);
					writeln(bestsol);
				}//if
			}
			bestsol = tmpsol;
			return nhood_evals;
		}//run////////////////////////////////////
	}//record/////////////////////////////////
}//end of ils module