module Q3AP
    using DelimitedFiles
    using JLD
    using Base.Threads

    dim = Int(0)
    C6 = Array{Int,6} #(undef, 0, 0, 0, 0, 0, 0)
    moves = Array{Int,2} #(undef,0,0)

    #functions and variables exposed by module
    export read_in_file,evalQ3AP,deltaQ3AP
    export dim,C6,moves
    export Solution

#####################################
#Julia doc: "Composite objects declared with struct are immutable; they cannot be modified after construction. This may seem odd at first, but it has several advantages..."
mutable struct Solution
    perm1::Array{Int,1}
    perm2::Array{Int,1}
    cost::Int
end

#####################################
    function read_in_file()
        #for large instances the generation of Q3AP 6D matrix may be slow...
        #on first call instance data is serialized and saved...
        load_filename = string("../../instances/JLD/",ARGS[1],".jld")
        if isfile(load_filename)
            global dim = load(load_filename,"dim")
            global C6 = load(load_filename, "C6")
        else
            println(string("../../instances/nug/",ARGS[1],".dat"))

            file = open(string("../../instances/nug/",ARGS[1],".dat"))

            global dim = parse(Int,readline(file, keep=false))
            mat = readdlm(file,Int)
            flow=mat[1:dim,:]
            dist=mat[dim+1:2*dim,:]
            global C6 = generateQ3AP(dist,flow)
            save(load_filename, "dim", dim, "C6", C6)
        end

        #generate moves
        global moves=Array{Int,2}(undef,4,0)
        for i=1:dim,k=1:dim,j=i:dim,l=k:dim
            moves = hcat(moves,[i,j,k,l])
        end

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

#####################################
#From Julia "Performance Tips":
#A global variable might have its value, and therefore its type, change at any point. This makes it difficult for the compiler to optimize code using global variables. Variables should be local, or passed as arguments to functions, whenever possible.
#Any code that is performance critical or being benchmarked should be inside a function.
function evalQ3AP(sol,C6,dim)
    cost::Int=0

    for i=1:dim,j=1:dim
        cost += C6[i,sol.perm1[i],sol.perm2[i],j,sol.perm1[j],sol.perm2[j]]
    end
    return cost
end
#####################################

#####################################
#return move(solution)[i]
#(avoids actually creating neighbour)
function swappedPerm(sol,move,i)
	π=sol.perm1[i]
	ϕ=sol.perm2[i]

	if i==move[1] π=sol.perm1[move[2]]
	elseif i==move[2] π=sol.perm1[move[1]] end
	if i==move[3] ϕ=sol.perm2[move[4]]
	elseif i==move[4] ϕ=sol.perm2[move[3]] end

	return π,ϕ
end

#####################################
#compute cost(move(solution)) incrementatally from cost(solution)
#global variables passed as arguments for performance...
function deltaQ3AP(sol,move,C6,dim)
    Δ::Int=0

    #next 4 lines could be replaced by
    # for i in unique(move)
    #which is nice but slow!
    for i in 1:dim
        if i!=move[1] && i!=move[2] && i!=move[3] && i!=move[4]
            continue
        end

		π1,ϕ1=swappedPerm(sol,move,i)

        for j in 1:dim
			π2,ϕ2=swappedPerm(sol,move,j)

            Δ += C6[i,sol.perm1[i],sol.perm2[i],j,sol.perm1[j],sol.perm2[j]]
            Δ -= C6[i,π1,ϕ1,j,π2,ϕ2]

			# if !(j in move) //poor performance
			if j!=move[1] && j!=move[2] && j!=move[3] && j!=move[4]
                Δ += C6[j,sol.perm1[j],sol.perm2[j], i,sol.perm1[i],sol.perm2[i]]
                Δ -= C6[j,π2,ϕ2,i,π1,ϕ1]
            end
        end
    end

    return Δ
end


end
