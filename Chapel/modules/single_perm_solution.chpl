module single_perm_solution{

	use Random;
	use SysCTypes;

	record C_int_Sol{

		var size: int;
		var dimension = {0..size-1};
		var perm: [dimension] c_int;
		var d_cost: c_double = 0.0;
		var i_cost: c_int = 0;

		proc randomInit(){

		 	var randStream = new owned RandomStream(c_int);
		 	var j: c_int;
		 	var tmp: c_int;
	
		 	for i in 0..(size-1) do
		 		perm[i] = i:c_int;

		 	for i in 1..(size-1) by -1 do{
		 		j = abs(randStream.getNext()) % (i + 1):c_int;           //randomise j for shuffle with Fisher Yates
		 		tmp = perm[j];
		 		perm[j] = perm[i];
		 		perm[i] = tmp;
		 	}//for

		}//proc
	
		proc tsp_randomInit(){

		 	var randStream = new owned RandomStream(c_int);
		 	var j: c_int;
		 	var tmp: c_int;
			
			perm[0] = 0;
			perm[size-1] = 0;

		 	for i in 1..(size-2) do
		 		perm[i] = i:c_int;

		 	for i in 1..(size-2) by -1 do{
		 		
		 		j = abs(randStream.getNext()) % (i + 1):c_int; //randomise j for shuffle with Fisher Yates
		 		
		 		if(j == 0 || j==size-1) then continue;
		 		
		 		tmp = perm[j];
		 		perm[j] = perm[i];
		 		perm[i] = tmp;
		 	}//for

		}// Random/////////////

	}// c_int sol ////////////////

	record Single_perm_Sol{
		var size: int;
		var dimension = {0..size-1};
		var perm: [dimension] int;
		var cost: int = 0;
		
		proc randomInit(){

		 	var randStream = new owned RandomStream(int);
		 	var j: int;
		 	var tmp: int;
	
		 	for i in 0..(size-1) do
		 		perm[i] = i;

		 	for i in 1..(size-1) by -1 do{
		 		j = abs(randStream.getNext()) % (i + 1);           //randomise j for shuffle with Fisher Yates
		 		tmp = perm[j];
		 		perm[j] = perm[i];
		 		perm[i] = tmp;
		 	}//for

		}//proc
	}// record ////////////////

}/////////////////////////////////////////////////

