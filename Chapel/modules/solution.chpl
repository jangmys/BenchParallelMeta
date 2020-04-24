module solution{

	use Random;
	use SysCTypes;
	
	record Solution{
		var size: int;
		var dimension = {0..1, 0..size-1};
		var perm: [dimension] int;
		var cost: int = 0;

		proc randomInit(){

		 	var randStream = new owned RandomStream(int);
		 	var j: int;
		 	var tmp: int;

		 	for k in 0..1 do
		 		for i in 0..(size-1) do
		 			perm[k,i] = i;

		 	for i in 1..(size-1) by -1 do{
		 		j = abs(randStream.getNext()) % (i + 1);           //randomise j for shuffle with Fisher Yates
		 		tmp = perm[0,j];
		 		perm[0,j] = perm[0,i];
		 		perm[0,i] = tmp;
		 	}

		 	for i in 1..(size-1) by -1 do{
		 		j = abs(randStream.getNext()) % (i + 1);           //randomise j for shuffle with Fisher Yates
		 		tmp = perm[1,j];
		 		perm[1,j] = perm[1,i];
		 		perm[1,i] = tmp;
		 	}
		 }///////////////

	}//////////////////

}/////////////////////////////////////////////////