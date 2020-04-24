module Q3AP
    using DelimitedFiles
	using JLD

	dim = Int(0)
	C6 = Array{Int,6} #(undef, 0, 0, 0, 0, 0, 0)

	export read_in_Q3AP,evaluate_Q3AP,evaluate_Q3APP
	export dim,C6

#####################################
    function read_in_Q3AP(instname)
        #for large instances the generation of Q3AP 6D matrix may be slow...
        #on first call instance data is serialized and saved...
        load_filename = string("../../instances/JLD/",instname,".jld")
        if isfile(load_filename)
            global dim = load(load_filename,"dim")
            global C6 = load(load_filename, "C6")
        else
            # println(string("../../instances/nug/",instname,".dat"))
            file = open(string("../../instances/nug/",instname,".dat"))

            global dim = parse(Int,readline(file, keep=false))
            mat = readdlm(file,Int)
            flow=mat[1:dim,:]
            dist=mat[dim+1:2*dim,:]
            global C6 = generateQ3AP(dist,flow)
            save(load_filename, "dim", dim, "C6", C6)
        end
    end

	function read_in_Q3AP()
		# read from file...
        # file = open(ARGS[1])
        # global dim = parse(Int,readline(file, keep=false))
        # mat = readdlm(file,Int)
    	# flow=mat[1:dim,:]
    	# dist=mat[dim+1:2*dim,:]
		# global C6 = generateQ3AP(dist,flow)
		# save("./nug25.jld", "dim", dim, "C6", C6)

		#read from JLD
		global dim = load(string("../JLD/",ARGS[1],".jld"),"dim")
		global C6 = load(string("../JLD/",ARGS[1],".jld"), "C6")
    end
#####################################

#####################################
	function generateQ3AP(dist,flow)
		C6=Array{Int,6}(undef, dim, dim, dim, dim, dim, dim)

		for i=1:dim,k=1:dim
			fik2=flow[i,k]*flow[i,k]
			for j=1:dim,n=1:dim
				djn=dist[j,n]
				for p=1:dim,q=1:dim
					dpq=dist[p,q]
					global C6[i,j,p,k,n,q] = fik2*djn*dpq
				end
			end
		end
		return C6
	end
#####################################

    function evaluate_Q3AP(sol,C6,dim)
        cost::Int=0

        for i=1:dim,j=1:dim
            cost += C6[i,sol.perm1[i],sol.perm2[i],j,sol.perm1[j],sol.perm2[j]]
        end
        return cost
    end


    function evaluate_Q3APP(perm1,perm2,C6,dim)
        cost::Int=0

        for i=1:dim,j=1:dim
            cost += C6[i,perm1[i],perm2[i],j,perm1[j],perm2[j]]
        end
        return cost
    end


end
