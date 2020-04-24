module FSP
    using DelimitedFiles

    nbJob = Int(0)
    nbMach = Int(0)
    PTM = Array{Int,2}

    export nbJob,nbMach,PTM
    export read_in_FSP, evalMakespan

    function read_in_FSP(instname)
		filename = string("../../instances/fsp/",instname,".dat")
        file=open(filename)

        str=readline(file)
        global nbJob = parse(Int,split(str)[1])
        global nbMach = parse(Int,split(str)[2])
        global PTM = readdlm(file,Int)
    end

	### works, but slow
    # function evalMakespan(perm)
    #     tmp=zeros(Int,nbMach)
	#
    #     for i in 1:nbJob
    #         job=perm[i]
    #         tmp[1]+=PTM[1,job]
    #         for j in 2:nbMach
    #             tmp[j]=max(tmp[j-1],tmp[j])+PTM[j,job]
    #         end
    #     end
    #     cmax=tmp[nbMach]
    # end

    function evalMakespan(perm,PTM,nbJob,nbMach)
        tmp=zeros(Int,nbMach)

        for i in 1:nbJob
            job=perm[i]
            tmp[1]+=PTM[1,job]
            for j in 2:nbMach
                tmp[j]=max(tmp[j-1],tmp[j])+PTM[j,job]
            end
        end

        cmax=tmp[nbMach]
    end
end
