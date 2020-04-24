include("./FSP.jl")
include("./QAP.jl")
include("./Q3AP.jl")
include("./TSP.jl")

using Random
using Base.Threads

using .FSP
using .QAP
using .Q3AP
using .TSP

mutable struct Solution
    perm::Array{Int}
    cost::Int
end

mutable struct Solution2
    perm1::Array{Int,1}
    perm2::Array{Int,1}
    cost::Int
end

##################################### "constructors"
function randSol(n)
    sol=Solution(randperm(n),0)
end

function randSol2(n)
    sol=Solution2(randperm(n),randperm(n),0)
end

function FSPbatch(pop,PTM,nbJob,nbMach)
    t=@elapsed Threads.@threads for s in pop
        s.cost = evalMakespan(s.perm,PTM,nbJob,nbMach)
    end
    return t
end

function QAPbatch(pop,dist,flow,dim)
    t=@elapsed Threads.@threads for s in pop
        s.cost = evaluate_QAP(s.perm,dist,flow,dim)
    end
    return t
end

function Q3APbatch(pop,C6,dim)
    t=@elapsed Threads.@threads for s in pop
        s.cost = evaluate_Q3APP(s.perm1,s.perm2,C6,dim)
    end
    return t
end

function TSPbatch(pop,xcoord,ycoord,dim)
    t=@elapsed Threads.@threads for s in pop
        c = evaluate_TSP(s.perm,xcoord,ycoord,dim)
    end
    return t
end

###########################################################
if ARGS[1]=="FSP"
###########################################################
    println("flowshop --> instance? (ta001,...,ta120) : ",ARGS[2])
    read_in_FSP(ARGS[2])
    #warmup
    a=randSol(nbJob)
    println("first eval:")
    @time cmax1=evalMakespan(a.perm,PTM,nbJob,nbMach)
    println("second eval:")
    a=randSol(nbJob)
    @time cmax1=evalMakespan(a.perm,PTM,nbJob,nbMach)

    #read batchsize
    batchsize=parse(Int,ARGS[3])
    repeat=1e6/batchsize

    pop=[randSol(nbJob) for x in 1:batchsize]
    testFSP(pop,PTM,nbJob,nbMach)

    evaltime=0
    elap = @elapsed for i in 1:repeat
        pop=[randSol(nbJob) for x in 1:batchsize]
        global evaltime += FSPbatch(pop,PTM,nbJob,nbMach)
    end
    println("EvalLoop(s)\t",evaltime)
    println("TotElapsed(s)\t",elap)
###########################################################
elseif ARGS[1]=="QAP"
###########################################################
    println("QAP --> instance? (nug12,tho150,...) : ",ARGS[2])
    read_in_QAP(ARGS[2])
    #warmup
    a=randSol(QAP.dim)
    println("first eval:")
    @time a.cost=evaluate_QAP(a.perm,dist,flow,QAP.dim)
    println("second eval:")
    a=randSol(QAP.dim)
    @time a.cost=evaluate_QAP(a.perm,dist,flow,QAP.dim)

    #read batchsize
    batchsize=parse(Int,ARGS[3])
    repeat=1e6/batchsize
    #warmup
    pop=[randSol(QAP.dim) for x in 1:batchsize]
    QAPbatch(pop,dist,flow,QAP.dim)

    evaltime=0
    elap = @elapsed for i in 1:repeat
        pop=[randSol(QAP.dim) for x in 1:batchsize]
        global evaltime += QAPbatch(pop,dist,flow,QAP.dim)
    end
    println("EvalLoop(s)\t",evaltime)
    println("TotElapsed(s)\t",elap)
###########################################################
elseif ARGS[1]=="Q3AP"
###########################################################
    println("Q3AP --> instance? (nug12,...,nug25) : ",ARGS[2])
    read_in_Q3AP(ARGS[2])

    #warmup
    a=randSol2(Q3AP.dim)
    println("first eval:")
    @time a.cost=evaluate_Q3AP(a,C6,Q3AP.dim)
    println("second eval:")
    a=randSol2(Q3AP.dim)
    @time a.cost=evaluate_Q3AP(a,C6,Q3AP.dim)

    #read batchsize
    batchsize=parse(Int,ARGS[3])
    repeat=1e6/batchsize

    pop=[randSol2(Q3AP.dim) for x in 1:batchsize]
    Q3APbatch(pop,C6,Q3AP.dim)

    evaltime=0
    elap = @elapsed for i in 1:repeat
        pop=[randSol2(Q3AP.dim) for x in 1:batchsize]
        global evaltime += Q3APbatch(pop,C6,Q3AP.dim)
    end
    println("EvalLoop(s)\t",evaltime)
    println("TotElapsed(s)\t",elap)
###########################################################
elseif ARGS[1]=="TSP"
    println("Q3AP --> instance? (berlin52,...,) : ",ARGS[2])
    read_in_TSP(ARGS[2])

    #warmup
    a=randSol(TSP.dim)
    println("first eval:")
    @time c=evaluate_TSP(a.perm,xcoord,ycoord,TSP.dim)
    println("second eval:")
    a=randSol(TSP.dim)
    @time c=evaluate_TSP(a.perm,xcoord,ycoord,TSP.dim)

    #read batchsize
    batchsize=parse(Int,ARGS[3])
    repeat=1e6/batchsize

    #warmup
    pop=[randSol(TSP.dim) for x in 1:batchsize]
    TSPbatch(pop,xcoord,ycoord,TSP.dim)

    evaltime=0
    elap = @elapsed for i in 1:repeat
        pop=[randSol(TSP.dim) for x in 1:batchsize]
        global evaltime += TSPbatch(pop,xcoord,ycoord,TSP.dim)
    end
    println("EvalLoop(s)\t",evaltime)
    println("TotElapsed(s)\t",elap)
end
