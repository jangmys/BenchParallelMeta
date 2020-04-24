module micro_bench{
	
	use SysCTypes;
	use single_perm_solution;
	use fsp_simple_chpl_c_headers;
	use tsp_chpl_c_headers;
    use DynamicIters;
    use Time;
    use QAP_module;
	use solution;
	use instance;
	use evalQ3AP;

	proc micro_bench_q3ap_eval(const ref sol: Solution, const ref eval: evalQ3AP){
			var size: int = eval.size;
			var cost: int = 0;
			for (i,j) in {0..size-1,0..size-1} do
				cost += eval.costMatrix[i, sol.perm[0,i], sol.perm[1,i], j, sol.perm[0,j], sol.perm[1,j]];
			//sol.cost = cost;
			return cost;
	}/////////////////////////////////////////////////////////////////////////
	
	proc micro_bench_qap_sol_eval(ref sol: C_int_Sol, const ref instance: Instance){
		sol.i_cost = QAP_evaluation(sol,instance):c_int;
	}////////////

	proc micro_bench_tsp_sol_eval(ref sol:  C_int_Sol){
		sol.d_cost = eval(c_ptrTo(sol.perm));
	}////////////

	proc micro_bench_fsp_sol_eval(ref sol:  C_int_Sol,
		const machines : c_int, const jobs : c_int, times : c_ptr(c_int)){
		sol.i_cost = evalsolution( c_ptrTo(sol.perm), machines, jobs, times);
	}////////////
	
	proc micro_bench_tsp_eval(const pop_size: int, const fileinst: string, 
		const repetitions: int, const verbose: bool){

		var total: real = 0.0;
		var total_random_init: real = 0.0;
		var timer_create_pop: Timer;
		var timer_instance: Timer;
		var timer_random_init: Timer;
		var timer: Timer;

		timer_instance.start();

		initFromFile(fileinst.c_str());

		timer_instance.stop();
				
		if(verbose){
			for i in 0..#tsp_N do writeln(xcoord[i]);	
			writeln("\n################\n");
			for i in 0..#tsp_N do writeln(ycoord[i]);
		}

		tsp_N+=1; //tsp needs to be 0.....0

		timer_create_pop.start();
		var pop = [i in 0..(pop_size-1)] new  C_int_Sol(tsp_N);
		timer_create_pop.stop();

		for r in 0..#repetitions do{

			timer_random_init.start();

			forall i in 0..(pop_size-1) do pop[i].tsp_randomInit();

			timer_random_init.stop();
			total_random_init+=timer_random_init.elapsed();
			timer_random_init.clear();

			timer.start();
			forall p in pop do micro_bench_tsp_sol_eval(p);
			timer.stop();
			total+=timer.elapsed();
			timer.clear();

		}//repetition

		if(verbose){
			var (bestCost, ind) = minloc reduce zip([p in pop] p.d_cost, 0..(pop_size-1));
			writeln(pop[ind]);
			writeln("\nBest permutation: ", ind, "\n\t Cost: ", pop[ind].d_cost);
		}


		writeln("\nProblem: TSP");
		writeln("Threads: ", here.maxTaskPar);
		writeln("Instance: ", fileinst);
		writeln("Number of repetitions: ", repetitions);
		writeln("Size of the population: ", pop_size);
		

		writeln("Evaluation(s): ", total );
		writeln("\tCreating the populaton: ", timer_create_pop.elapsed());
		writeln("\tStarting the instance: ", timer_instance.elapsed());
		writeln("\tRandom init: ", total_random_init);
		writeln("\tTOTAL: ", total+timer_create_pop.elapsed()+timer_instance.elapsed()+total_random_init);	
		
		timer_create_pop.clear();
		timer_instance.clear();
		timer_random_init.clear();
	
	}////////////////



	proc micro_bench_fsp_eval(const pop_size: int, const fsp_instance: c_short, 
		const repetitions: int, const verbose: bool){
		
		var total: real = 0.0;
		var total_random_init: real = 0.0;
		var timer_create_pop: Timer;
		var timer_create_inst: Timer;
		var timer_random_init: Timer;
		var timer: Timer;

		timer_create_inst.start();

		var jobs: c_int;
    	var machines: c_int;
    	var times: c_ptr(c_int) = get_instance(machines,jobs, fsp_instance); //Get FSP problem

		if(verbose) then print_instance(machines, jobs, times);
		
		timer_create_inst.stop();

		timer_create_pop.start();

		var pop = [i in 0..(pop_size-1)] new  C_int_Sol(jobs:int);

		timer_create_pop.stop();

		
		for r in 0..#repetitions do{

			timer_random_init.start();

			forall i in 0..(pop_size-1) do pop[i].randomInit();
			
			timer_random_init.stop();
			total_random_init+=timer_random_init.elapsed();
			timer_random_init.clear();

			//for times in 0..1000 
			timer.start();
			forall p in pop do micro_bench_fsp_sol_eval(p,machines,jobs,times);
		
			timer.stop();
			total+=timer.elapsed();
			timer.clear();
		}//repetitions

		if(verbose){
			var (bestCost, ind) = minloc reduce zip([p in pop] p.i_cost, 0..(pop_size-1));
			writeln(pop);
			writeln("\nBest permutation: ", ind, "\n\t Cost: ", pop[ind].i_cost);
		}

		

		writeln("\nProblem: FSP");
		writeln("Threads: ", here.maxTaskPar);
		writeln("Instance number: ta", fsp_instance, "\n\tMachines: ", machines, "\n\tJobs ", jobs);
		writeln("Number of repetitions: ", repetitions);
		writeln("Size of the population: ", pop_size);
	


		writeln("Evaluation(s): ", total );
		writeln("\tCreating the populaton: ", timer_create_pop.elapsed());
		writeln("\tStarting the instance: ", timer_create_inst.elapsed());
		writeln("\tRandom init: ", total_random_init);
		writeln("\tTOTAL: ", total+timer_create_pop.elapsed()+timer_create_inst.elapsed()+total_random_init);	
		
		timer_create_pop.clear();
		timer_create_inst.clear();
		timer_random_init.clear();
		
	

	}////////////////////////////


	proc micro_bench_qap_eval(const fileinst: string, const pop_size: int, 
		const repetitions: int, const verbose: bool){

		var total: real = 0.0;
		var total_random_init: real = 0.0;
		var timer_create_pop: Timer;
		var timer_create_inst: Timer;
		var timer_random_init: Timer;
		var timer: Timer;



		timer_create_inst.start();

		var instance = new Instance(file=fileinst);
		instance.get_flow_dist(); 


		timer_create_inst.stop();

		timer_create_pop.start();

		if verbose then writeln(instance.flow);

		var pop = [i in 0..(pop_size-1)] new  C_int_Sol(instance.size);

		timer_create_pop.stop();

		for r in 0..#repetitions do{
			
			timer_random_init.start();
			forall i in 0..(pop_size-1) do pop[i].randomInit();
			timer_random_init.stop();
			total_random_init+=timer_random_init.elapsed();
			timer_random_init.clear();

			timer.start();
			forall p in pop do micro_bench_qap_sol_eval(p,instance);
			timer.stop();
			total+=timer.elapsed();
			timer.clear();
		}//repetitions
		
		if(verbose){		
			var (bestCost, ind) = minloc reduce zip([p in pop] p.i_cost, 0..(pop_size-1));
			writeln(pop);
			writeln("\nBest permutation: ", ind, "\n\t Cost: ", pop[ind].i_cost);
		}

		writeln("\nProblem: QAP");
		writeln("Threads: ", here.maxTaskPar);
		writeln("Instance: ", fileinst);
		writeln("Number of repetitions: ", repetitions);
		writeln("Size of the population: ", pop_size);


		writeln("Evaluation(s): ", total );
		writeln("\tCreating the populaton: ", timer_create_pop.elapsed());
		writeln("\tStarting the instance: ", timer_create_inst.elapsed());
		writeln("\tRandom init: ", total_random_init);
		writeln("\tTOTAL: ", total+timer_create_pop.elapsed()+timer_create_inst.elapsed()+total_random_init);	
		
		timer_create_pop.clear();
		timer_create_inst.clear();
		timer_random_init.clear();

	}////////////////////////////


	proc micro_bench_q3ap_eval(const fileinst: string, const pop_size: int, 
		const repetitions: int, const verbose: bool = false){

		var total: real = 0.0;
		var total_random_init: real = 0.0;
		var timer_create_pop: Timer;
		var timer_create_inst: Timer;
		var timer_random_init: Timer;
		var timer: Timer;

		timer_create_inst.start();
		
		var instance = new Instance(file=fileinst);
		instance.get_flow_dist();
		var eval = new evalQ3AP(size=instance.size);
		eval.init_costMatrix(instance);


		timer_create_inst.stop();


		timer_create_pop.start();
		
		var pop = [i in 0..(pop_size-1)] new Solution(instance.size);
		
		timer_create_pop.stop();

		for r in 0..#repetitions do{

			timer_random_init.start();

			forall i in 0..(pop_size-1) do pop[i].randomInit();
			
			timer_random_init.stop();
			total_random_init+=timer_random_init.elapsed();
			timer_random_init.clear();

			timer.start();
			forall p in 0..#pop_size do
				pop[p].cost = micro_bench_q3ap_eval(pop[p], eval);
			
			timer.stop();
			total+=timer.elapsed();
			timer.clear();
		}//repetitions

		if(verbose){
			var (bestCost, ind) = minloc reduce zip([p in pop] p.cost, 0..(pop_size-1));
			writeln("\nBest permutation: ", ind, "\n\t Cost: ", pop[ind].cost);
			writeln(pop);
		}


		writeln("\nProblem: Q3AP");
		writeln("Threads: ", here.maxTaskPar);
		writeln("Instance: ", fileinst);
		writeln("Number of repetitions: ", repetitions);
		writeln("Size of the population: ", pop_size);


		writeln("Evaluation(s): ", total );
		writeln("\tCreating the populaton: ", timer_create_pop.elapsed());
		writeln("\tStarting the instance:", timer_create_inst.elapsed());
		writeln("\tRandom init:", total_random_init);
		writeln("\tTOTAL: ", total+timer_create_pop.elapsed()+timer_create_inst.elapsed()+total_random_init);	
		
		timer_create_pop.clear();
		timer_create_inst.clear();
		timer_random_init.clear();


	}////////////////////////////

	



	proc micro_bench_problem_choice(const problem: string, const fileinst: string, 
		const fsp_instance: c_short, const pop_size: int, const repetitions: int, const verbose: bool){

		select problem {

			when "tsp"{//TSP
				micro_bench_tsp_eval(pop_size, fileinst, repetitions,verbose);
			}///////////////////
			when "fsp"{
				micro_bench_fsp_eval(pop_size,fsp_instance, repetitions,verbose);
			}////////qq
			when "qap"{
				micro_bench_qap_eval(fileinst, pop_size, repetitions,verbose);
			}//////////////////////////
			when "q3ap"{
				micro_bench_q3ap_eval(fileinst, pop_size, repetitions,verbose);
			}////////////////////////
			otherwise{
				halt("### Micro-benchmark: wrong problem choice ###");
			}
		}/////////////
	
	}
}/////////////////////////////////////
