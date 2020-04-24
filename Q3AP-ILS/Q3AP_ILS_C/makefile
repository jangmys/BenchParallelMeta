BIN = ./bin/
SRC = ./src/
HDRS = ./headers/

CXX = g++
# CXX = clang++
OPT = -O3 -fopenmp

FILES = main ils qap_instance evalQ3AP solution

OBJS=$(addprefix $(BIN), $(addsuffix .o, $(FILES)))

ils:	$(OBJS)
	@echo $(OBJS)
	$(CXX) $(OBJS) -o $@ $(OPT)

$(BIN)%.o: $(SRC)%.cpp #$(HDRS)%.h
	$(CXX) -c $< -o $@ $(OPT)

clean:
	rm $(OBJS) ./ils
