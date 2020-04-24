module QAP
    using DelimitedFiles

	dim = Int(0)
	moves = Array{Int,2}
    flow = Array{Int,2}
    dist = Array{Int,2}

	export read_in_QAP,evaluate_QAP
	export dim,flow,dist

#####################################
	function read_in_QAP(instname)
		filename = string("../../instances/qaplib/",instname,".dat")

        # read from file...
        file = open(filename)
        global dim = parse(Int,readline(file, keep=false))
        mat = readdlm(file,Int)
    	global flow=mat[1:dim,:]
    	global dist=mat[dim+1:2*dim,:]
    end
#####################################

#####################################
	function evaluate_QAP(perm,dist,flow,dim)
        cost = 0
		for i=1:dim,j=1:dim
			cost += flow[i,j]*dist[perm[i],perm[j]]
        end
		return cost
	end
#####################################

end
