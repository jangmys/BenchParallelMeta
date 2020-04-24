module evalQ3AP{
	use SysCTypes;
	use solution;
	use instance;

	record LargeMove {
  		var a: int = 0;
  		var b: int = 0;
  		var c: int = 0;
  		var d: int = 0;
	}

	record evalQ3AP{

		var size: int;
		var dimension = {0..#size,0..#size,0..#size,0..#size,0..#size,0..#size};
		var D = {0..#size, 0..#size};
		var costMatrix: [dimension] int;

		proc init_costMatrix(const instance: Instance){
			for (i,k) in D{
		 		var fik2 = instance.flow[i,k]**2;
		 		for(j,n) in D{
		 			var djn = instance.dist[j,n];
		 			for(p,q) in D{
		 				costMatrix[i,j,p,k,n,q]=fik2*djn*instance.dist[p,q];}}}
		}///////////////////////////////////////////////////////////////////////////


		proc fullEval(ref sol: Solution){
			var cost: int = 0;
			for (i,j) in {0..size-1,0..size-1} do
				cost += costMatrix[i, sol.perm[0,i], sol.perm[1,i], j, sol.perm[0,j], sol.perm[1,j]];
			sol.cost = cost;
			//return cost;
		}/////////////////////////////////////////////////////////////////////////


		proc deltaEval(ref sol: Solution , ref mv:LargeMove): int{
		  
			  var delta: int =0;

			  var a: int = mv.a;
			  var b: int = mv.b;
			  var c: int = mv.c;
			  var d: int = mv.d;

			  var p0,q0,p1,q1: int;

			  for i in 0..size-1 do{
			  	//check operators!!!!
			    if(!(i==a || i==b || i==c || i==d)) then continue;

			    p0=sol.perm[0,i];
			    q0=sol.perm[1,i];

			    if(i==a) then p0=sol.perm[0,b];
			    if(i==b) then p0=sol.perm[0,a];
			    if(i==c) then q0=sol.perm[1,d];
			    if(i==d) then q0=sol.perm[1,c];

			    for j in 0..(size-1) do{

			      p1=sol.perm[0,j];
			      q1=sol.perm[1,j];

			      if(j==a) then p1=sol.perm[0,b];
			      if(j==b) then p1=sol.perm[0,a];
			      if(j==c) then q1=sol.perm[1,d];
			      if(j==d) then q1=sol.perm[1,c];

			      delta+=costMatrix[i, sol.perm[0,i], sol.perm[1,i], j, sol.perm[0,j], sol.perm[1,j]];
			      delta-=costMatrix[i, p0, q0, j, p1, q1];

			      if(!(j==a || j==b || j==c || j==d)){
			        delta+=costMatrix[j, sol.perm[0,j], sol.perm[1,j], i, sol.perm[0,i], sol.perm[1,i]];
			        delta-=costMatrix[j, p1, q1, i, p0, q0];
			      }//if
			    }
			  }////for

			return delta;
		}//////////////////////////////////

	}/////////////////record


}//MODULE
