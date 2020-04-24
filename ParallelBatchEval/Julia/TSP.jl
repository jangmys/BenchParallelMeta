module TSP
    using DelimitedFiles

	dim = Int(0)

    xcoord = Array{Float64,1}
    ycoord = Array{Float64,1}

	export read_in_TSP,evaluate_TSP
	export dim,xcoord,ycoord

#####################################
	function read_in_TSP(instname)
		filename = string("../../instances/tsp/",instname,".tsp")
		# read from file...
		file = open(filename)

        title = readline(file, keep=false)
        tsp_type = readline(file, keep=false)
        comment = readline(file, keep=false)

        dimString = readline(file, keep=true)
        global dim = parse(Int64,split(dimString,":")[2])

        edge_weight = readline(file, keep=false)
        dummy = readline(file, keep=false)

        index = 1

        global xcoord = zeros(dim)
        global ycoord = zeros(dim)

        while index <= dim #eof(file) != true
            tmp = readline(file, keep=true)
            # println(tmp)
            global xcoord[index] = parse(Float64, split(tmp," ")[2])
            global ycoord[index] = parse(Float64, split(tmp," ")[3])
            index += 1
        end

        close(file)
    end
#####################################

    function dist(xcoord,ycoord,a,b)
        dx = xcoord[a]-xcoord[b]
        dy = ycoord[a]-ycoord[b]
        return dx*dx + dy*dy
    end

#####################################
	function evaluate_TSP(perm,xcoord,ycoord,dim)
        cost = sqrt(dist(xcoord,ycoord,perm[1],perm[2]))
        for i=2:dim-1
            cost += sqrt(dist(xcoord,ycoord,perm[i],perm[i+1]))
        end
        cost += sqrt(dist(xcoord,ycoord,perm[dim],perm[1]))
        return cost
	end
#####################################
end
