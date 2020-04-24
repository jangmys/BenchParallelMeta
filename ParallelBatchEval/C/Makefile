BIN = ./bin/
SRC = ./src/
HDRS = ./headers/
BUILD = ./build/

OPT =  -O3 -fopenmp -ffast-math
CXX = g++ #clang++

OBJ = main instance_flowshop instance_qap instance_tsp arguments eval_flowshop eval_qap eval_q3ap eval_tsp permutation
OBJS=$(addprefix $(BUILD), $(addsuffix .o, $(OBJ)))

bench:	$(OBJS)
	@echo $(OBJS)
	$(CXX) $(OBJS) -o $(BIN)$@ $(OPT) -ldl

$(BUILD)%.o: $(SRC)%.cpp
	@mkdir -p $(BUILD)
	$(CXX) -c $< -o $@ $(OPT)

clean :
	rm -r $(BUILD)
