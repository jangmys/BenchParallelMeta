include("./Q3AP.jl")

using Random
using Base.Threads
using StatsBase

using .Q3AP

global const popsize = 100
global const mutate_rate = 0.3
global const ls_rate = 0.7

#different structure than in ILS ...
#Need to be able to access both permuations by index
mutable struct Solution
    perm::Array{Array{Int}}
    cost::Int
end

##################################### "constructors"
function emptySol(dim)
	sol=Solution([zeros(dim),zeros(dim)],0)
end
##################################### "constructors"
function randSol(dim)
	sol=Solution([randperm(dim),randperm(dim)],0)
end
#####################################
function evalQ3AP(sol,C6,dim)::Int
	cost::Int=0
	for i=1:dim,j=1:dim
		cost += C6[i,sol.perm[1][i],sol.perm[2][i],j,sol.perm[1][j],sol.perm[2][j]]
	end

	return cost
end
#####################################
function applyMove!(sol,move)
	sol.perm[1][move[1]],sol.perm[1][move[2]] = sol.perm[1][move[2]],sol.perm[1][move[1]]
	sol.perm[2][move[3]],sol.perm[2][move[4]] = sol.perm[2][move[4]],sol.perm[2][move[3]]
	nothing
end
#####################################
function swappedPerm(perm1,perm2,move,i)
	π=perm1[i]
	ϕ=perm2[i]

	if i==move[1] π=perm1[move[2]]
	elseif i==move[2] π=perm1[move[1]] end
	if i==move[3] ϕ=perm2[move[4]]
	elseif i==move[4] ϕ=perm2[move[3]] end

	return π,ϕ
end
#####################################
function deltaQ3AP(perm1::Array{Int,1},perm2::Array{Int,1},move,C6,dim)::Int
    Δ::Int=0

	# for i in unique(move) (nice but slow!)
	for i in 1:dim
		if i!=move[1] && i!=move[2] && i!=move[3] && i!=move[4]
			continue
		end
		π1,ϕ1=swappedPerm(perm1,perm2,move,i)

        for j in 1:dim
			π2,ϕ2=swappedPerm(perm1,perm2,move,j)

            Δ += C6[i,perm1[i],perm2[i],j,perm1[j],perm2[j]]
            Δ -= C6[i,π1,ϕ1,j,π2,ϕ2]

			# if !(j in move)
			if j!=move[1] && j!=move[2] && j!=move[3] && j!=move[4]
                Δ += C6[j, perm1[j], perm2[j], i, perm1[i], perm2[i]]
                Δ -= C6[j,π2,ϕ2,i,π1,ϕ1]
            end
        end
    end

    return Δ::Int
end
#####################################
function computeDeltas(sol::Solution, deltas::Array{Int,1}, moves::Array{Int,2}, C6, dim)
	Threads.@threads for i in 1:size(moves)[2]
		deltas[i] = deltaQ3AP(sol.perm[1],sol.perm[2],view(moves,:,i),C6, dim)
	end
	return findmax(deltas)
end
#####################################
function evalPop!(pop,C6,dim)
	Threads.@threads for s in pop
		s.cost = evalQ3AP(s,C6,dim)
	end
end
#####################################
function localSearch!(sol,C6,dim,maxiter::Int)
	iter::Int=0
	deltas = similar(moves[1,:])

	for i=1:maxiter
		bestdelta,bestind = computeDeltas(sol,deltas,moves,C6,dim) #findmax(deltas)
		iter += 1
		if bestdelta>0
			applyMove!(sol,moves[:,bestind])
			sol.cost -= bestdelta
		else
			break
		end
	end

	return iter
end
#####################################
function copyPop(pop,newgen,popsize)
	for i in 1:popsize
		pop[i].perm[1]=copy(newgen[i].perm[1])
		pop[i].perm[2]=copy(newgen[i].perm[2])
		pop[i].cost = newgen[i].cost
	end
end
#####################################
function sample_wo_repl!(A,n)
    sample = Array{eltype(A)}(undef,n)
    for i in 1:n
        sample[i] = splice!(A, rand(eachindex(A)))
    end
    return sample
end
#####################################
function POSXover(sol1,sol2)
	off=emptySol(dim)

	for k=1:2
		#randomly choose b positions in permutation
		b=sample_wo_repl!(collect(1:dim),rand(3:dim-3))
		flag=[(x in b) ? 1 : 0 for x in 1:dim]
		flag2=zeros(Int,dim)
        #copy flagged elements from par1 to child
		for i=1:dim
			if flag[i]==1
				off.perm[k][i]=sol1.perm[k][i]
				ind=findfirst(x->x==sol1.perm[k][i],sol2.perm[k])
				flag2[ind]=1
			end
		end
     	# if valid, copy remaining from par2
		for i=1:dim
			if off.perm[k][i]==0 && flag2[i]==0
				off.perm[k][i]=sol2.perm[k][i]
				flag2[i]=1
			end
		end

		for i=1:dim
			if off.perm[k][i]==0
				ind=findfirst(x->x==0,flag2)
				off.perm[k][i]=sol2.perm[k][ind]
				flag2[ind]=1
			end
		end
	end

	return off
end
#####################################
function setProbas(pop) #cumulprob,pop)
	probas = [(1.0/p.cost) for p in pop]
	probas ./= sum(probas)
	return probas
end
#####################################
function reproduce!(pop,newgen,popsize)
	probas = setProbas(pop)
	for i=2:popsize
		par1,par2 = sample(collect(1:popsize),pweights(probas),2,replace=false)
		newgen[i]=POSXover(pop[par1],pop[par2])
	end
end
#####################################
function mutate!(newgen,C6,dim,mutate_rate,ls_rate)
	for p in newgen[2:end]
		if rand()<mutate_rate
			if rand()<ls_rate
				localSearch!(p,C6,dim,10)
			else
				m=rand(1:dim,4)
				p.cost -= deltaQ3AP(p.perm[1],p.perm[2],m,C6,dim)
				applyMove!(p,m)
			end
		end
	end
end
#####################################
function evolve!(pop,C6,dim,nbGen)
	newgen=[randSol(dim) for x in 1:popsize] #Array{Any,1}
	for i=1:nbGen
		#elitism
		bestind = argmin([p.cost for p in pop])
		newgen[1]=deepcopy(pop[bestind])
		#generate offspring
		reproduce!(pop,newgen,popsize)
		#evaluate offspring
		evalPop!(newgen,C6,dim)
		#mutate
		mutate!(newgen,C6,dim,mutate_rate,ls_rate)
		copyPop(pop,newgen,popsize)
		#		GC.gc()

		min = findmin([p.cost for p in pop])
		println("Gen:\t",i,"\t",min) #; flush(stdout)
	end
end

function runGA(C6,dim,nbGen)
	pop=[randSol(dim) for x in 1:popsize]

    evalPop!(pop,C6,dim)
	evolve!(pop,C6,dim,nbGen)
end


if size(ARGS)[1]!=2
	println("Need 2 arguments (instance, nbGeneration), ex: ./GA.jl nug12 10")
	exit()
end

#generate instance
elap1=@elapsed read_in_file()
println("Time (Init instance):\t",elap1)

nbGen=parse(Int,ARGS[2])
elap=@elapsed runGA(C6,dim,nbGen)
#
println("\tElapsedTime:\t",elap)
