import numpy as np
import pickle

# read from input file
def read_input(filename):
    with open(filename, 'r') as f:
        content = f.read()
        lines = content.split('\n')
        dim = np.int64(lines[0])
        A = [[0 for x in range(dim)] for x in range(2 * dim)]
        i = 0

        for l in lines[1:]:
            if not l.strip():
                continue
            if l.startswith('EOF'):
                break
            else:
                A[i] = [int(x) for x in l.split()]
                i += 1

    flow = np.array(A[0:dim])
    dist = np.array(A[dim:2 * dim])
    #C = generateQ3AP(dist,flow,dim)

    #with open('nug25.pkl', 'wb') as save_file:
    #	pickle.dump([dim,C], save_file)

    # with open('nug12.pkl','rb') as read_file:
    #     [dim,C] = pickle.load(read_file)

    return dist,flow,dim


def read_pickle(filename):
    with open(filename,'rb') as read_file:
        [dim,C] = pickle.load(read_file)
    return C,dim
