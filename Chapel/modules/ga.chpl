module ga{

	use Random;
	use solution;
	use evalQ3AP;
	use ils;
	use QAP_module;
	use SysCTypes;
	
	//This parameter was fixed for some experiments of the paper. 
	//could be passed by command line
	const POP_SIZE: int = 100;
	
	record GA{

		var size: int;
		var mutate_rate: real;
		var ls_rate: real;

		var nb_generations: int;
		var bestcost: int;
		var avgcost: int;
		var bestind: int;
		var pop_size: uint;
		var randStream = new owned RandomStream(int);

		var parents_index: [0..(POP_SIZE-1), 0..1] int;
		var elite_flag: [0..(POP_SIZE-1)] int;
		var select_proba: [0..(POP_SIZE-1)] real;
		var pop = [i in 0..(POP_SIZE-1)] new Solution(size);
		var off = [i in 0..(POP_SIZE-1)] new Solution(size);

		proc findIndex(ref arr: [] int, x: int): int{
			var _ret: int = 0;
			while( arr[_ret] != x){_ret += 1;}
			return _ret;
		}///////////////////////

		proc mutate(ref sol: Solution, const ref interLS: ILS, const ref eval: evalQ3AP){

			var r1: int = abs(randStream.getNext()) % 100;
			var r2: int = abs(randStream.getNext()) % 100;

			if (r1 < (mutate_rate * 100):int){
				if (r2 < (ls_rate * 100):int){
					interLS.searchLocalLarge(sol,10,eval);
				}
				else{

					var _a,_b,_c,_d: int;
					_a = abs(randStream.getNext()) % size;
		            _b = abs(randStream.getNext()) % size;
		            _c = abs(randStream.getNext()) % size;
		            _d = abs(randStream.getNext()) % size;

		            var mv = new LargeMove( a=_a, b=_b, c=_c, d=_d);
		            var delta: int = eval.deltaEval(sol, mv);
		            interLS.apply22ex(sol,mv);
    				sol.cost-=delta;
				}//if r2
			}//if r1

		}/////////////////

		//position-based
		proc POSCrossover(ref par1: Solution,ref par2: Solution): Solution{

			var offspring= new Solution(this.size);

			var a,b,j: int;
			var flag: [0..(size-1)] int;
			var flag2: [0..(size-1)] int;

			for i in 0..(size-1) do{
				offspring.perm[0,i] = -1;
				offspring.perm[1,i] = -1;
			}
			//for both permutations
			for k in 0..1 do{
				for i in 0..(size-1) do{ 
					flag[i]  = 0;
					flag2[i] = 0;
				}
				//randomly choose b positions in permutati	
				var b: int = 3 + abs(randStream.getNext())%(size-5);
				var j: int = 0;
		  
				while(j<b){
					a= abs(randStream.getNext())%size;
					if(!flag[a]){
						flag[a]=1;
						j+=1;
					}//
				}//while
				//copy flagged elements from par1 to child
				for i in 0..(size-1) do{
				
					if(flag[i]){
						offspring.perm[k,i]=par1.perm[k,i];
						ref A = par2.perm[k,0..(size-1)];
						var ind: int = findIndex(A,par1.perm[k,i]);
				
						flag2[ind]=1;//already in offspring!
					}//
				}//for
				//if valid copy remaining from par2
				for i in 0..(size-1) do{
					if(offspring.perm[k,i]<0){
						if(!flag2[i]){
							offspring.perm[k,i]=par2.perm[k,i];
							flag2[i]=1;
						}
					}
				}//for
				j=0;
				for i in 0..(size-1) do{
					if(offspring.perm[k,i]<0){//[-] in child
						while(flag2[j]){j+=1;}//next available in par2
						offspring.perm[k,i]=par2.perm[k,j];
						flag2[j]=1;
					}//
				}//
			}//////////////////////////for k

			return offspring;
		}/////////////////////proc POSCrossover
	
		proc setSelectProba(){
			var sum: real = 0.0;
			for i in 0..(POP_SIZE-1) do sum+=(1.0/(pop[i].cost:real));
			for i in 0..(POP_SIZE-1) do select_proba[i] = (1.0/(pop[i].cost:real)/sum);
		}

		proc randomInitPop(ref eval: evalQ3AP){

			forall i in 0..(POP_SIZE-1) do pop[i].randomInit();
			eval.fullEval(pop);
			//writeln(pop);

		}////RandomInitPop

		proc roulette(ref ind1: int, ref ind2: int, ref prob: [] real){

			var randStream = new owned RandomStream(real);
			var a: real = abs(randStream.getNext());		
			var b: real = abs(randStream.getNext());
			ind1 = 0;
			ind2 = 0;

			var cumul: real = 0.0;

			for i in 0..(POP_SIZE-1) do {
				if( a > cumul ) then 
					ind1=i;
				cumul += prob[i];
			}

			cumul = 0.0;

			for i in 0..(POP_SIZE-1) do {
				if(i==ind1) then continue;
				
				if(b>cumul) then 
					ind2 = i;

				cumul += prob[i];
			}//for
		}////////////////////////////////////////////////////


		proc getBest(ref eval: evalQ3AP): Solution{
		
			var (bestCost, ind) = minloc reduce zip([p in pop] p.cost, 0..(POP_SIZE-1));
			var sum: int = + reduce ([p in pop] p.cost);
			bestind=ind;
			avgcost= ((sum/POP_SIZE):int);

			return pop[ind];
		}///////////////////////


		proc evolve(ref eval: evalQ3AP, ref interLS: ILS){

			var (min,bestind) = minloc reduce zip([p in pop] p.cost, 0..(POP_SIZE-1));

			off[0] = pop[bestind];
			// CROSSOVER
	    	// ...ROULETTE SELECTION
	    	var ind1, ind2: int;
	    	setSelectProba();

	    	// COULD BE DONE IN PARALLEL
	    	for i in 1..(POP_SIZE-1) do roulette(parents_index[i,0], parents_index[i,1], select_proba);
			
			for i in 1..(POP_SIZE-1) do {
				ind1 = parents_index[i,0];
				ind2 = parents_index[i,1];
				off[i] = POSCrossover(pop[ind1],pop[ind2]);
			} 

			eval.fullEval(off);
			
			// MUTATION (costly, LOCAL SEARCH inside)
			for i in 1..(POP_SIZE-1) do mutate(off[i], interLS, eval);

			pop = off;
		}////////////////////////////////
	}///RECORD/////	
}//ga