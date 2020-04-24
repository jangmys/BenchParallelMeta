
module instance{
		
	const _MAX_: int = 150;
	use IO;

	record Instance{

		var size: int;
		var file: string;
		var flow: [0..#_MAX_,0..#_MAX_] int;
		var dist: [0..#_MAX_,0..#_MAX_] int;

		proc get_flow_dist(){

			var x:int;
			var myFile = open(this.file, iomode.r);
			var myReadingChannel = myFile.reader();
			var readSomething = myReadingChannel.read(x);

			this.size = x;

			var i: int = size;
			var j: int = size;

			for (i,j) in {0..#i, 0..#i} do flow[i,j] = myReadingChannel.read(int);
			for (i,j) in {0..#i, 0..#i} do dist[i,j] = myReadingChannel.read(int);
		}//////////////////////

	}///////////////////////////
}