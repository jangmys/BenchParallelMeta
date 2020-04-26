include("./Q3AP.jl")

using Random
using Base.Threads

using .Q3AP

#####################################
#"!" means function modifies arguments
function applyMove!(sol,move)
    sol.perm1[move[1]],sol.perm1[move[2]] = sol.perm1[move[2]],sol.perm1[move[1]]
    sol.perm2[move[3]],sol.perm2[move[4]] = sol.perm2[move[4]],sol.perm2[move[3]]
    nothing
end
######################################
#evaluation of neighbours
#"deltas" is local, but declared outside to avoid reallocation
#"sol" : current solution
#passing global constants as arguments
#returning best value with index
function computeDeltas(sol,deltas,moves,C6,dim)
    for i in 1:size(moves)[2]
        deltas[i]=deltaQ3AP(sol,moves[:,i],C6,dim)
    end
    return findmax(deltas)
end

#####################################
#local search with "double-swap" neighborhood (O(n^4))
function localSearch!(sol,maxiter)
    iter=0
    #for storage of incremental cost of neighbors
    #declared here to minimize memory allocation overhead
    deltas = Array{Int,1}(undef,size(moves)[2])

    for i=1:maxiter
        #parallel evaluation
        bestdelta,bestind = computeDeltas(sol,deltas,moves,C6,dim)
        #count iterations
        iter += 1
        #if improving neighbour found... (could add acceptance criterion here)
		if bestdelta>0
            #move to best neighbour
            applyMove!(sol,moves[:,bestind])
            #update current cost
            sol.cost -= bestdelta
        else
            #reached local minimum
            break
        end
    end
    return iter
end
####################################
#randomly select "strength" elements in array a an shuffle those elts randomly
function perturb!(a,strength)
    #"strength" distinct random positions
	arr1=randperm(dim)[1:strength]
	arr2=shuffle!(copy(arr1))
    #shuffled subarray
	arr2[:]=a[arr2[:]]
    #replace in a
	for i=1:strength
		a[arr1[i]]=arr2[i]
	end
end
#####################################
function iterLS(sol,ils_iter)
    println("======== ITERATED LOCAL SEARCH ======== ",ils_iter)
	iter=0
    b::Int=0 #permutation 1 or 2
    perturbStrength::Int=3 #perturbation strength

    for i=1:ils_iter
        #save current solution
        tmpsol=deepcopy(sol)
        #perturb current solution
        #(alternating perturbations in p1 and p2)
        b=1-b
        if b==0 perturb!(sol.perm1,perturbStrength) end
        if b==1 perturb!(sol.perm2,perturbStrength) end
        #local search (go to new local minimum)
    	sol.cost=evalQ3AP(sol,C6,dim)
        iter += localSearch!(sol,100)
        #if previous local min was better : revert...
        if sol.cost >= tmpsol.cost
            sol=deepcopy(tmpsol)
            #... and increase perturbation strength, ...
            perturbStrength += b
        else
            #...else, keep local min and set perturbation to minimum
            perturbStrength=3
        end
        #after complete random perturbation, reset to min
        if perturbStrength>=dim+1
            perturbStrength=3
        end
		# println((i,sol.cost))
    end
    return iter,sol
end
#################################################
#################################################
#################################################

if size(ARGS)[1]!=2
	println("Need 2 arguments (instance, batchsize), ex: ./ils_q3ap.jl nug12 1000")
	exit()
end

#read instance and initialize data
ils_iter=parse(Int,ARGS[2])
elap1=@elapsed read_in_file()
println("Time (Init instance):\t",elap1)

#Warmup (="compilation")
sol=Solution(collect(1:dim),collect(1:dim),0)
elap2 = @elapsed iterLS(sol,1)
println("Time (First LS/Compilation):\t",elap2)

#initial solution
sol=Solution(randperm(dim),randperm(dim),0)
sol.cost = evalQ3AP(sol,C6,dim)
#run local search
elap3=@elapsed iter,sol=iterLS(sol,ils_iter)

println("\tBest solution\n\n",sol,"\n")

println("\tTotalTime:\t",elap1+elap2+elap3)
println("\tILSTime:\t",elap3)
println("\tNhood evals:\t",iter)
#iteration count varies, so compare in terms of nhood/sec
println("\tNhoodPerSec:\t",iter/elap3)
