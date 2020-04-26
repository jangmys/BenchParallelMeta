BIN = ./bin/
SRC = ./src/
HDRS = ./headers/

CXX = g++
OPT = -O3 -std=c++11 -fopenmp

FILES = main GA ils qap_instance evalQ3AP solution

OBJS=$(addprefix $(BIN), $(addsuffix .o, $(FILES)))

ga:	$(OBJS)
	@echo $(OBJS)
	$(CXX) $(OBJS) -o $@ $(OPT)

$(BIN)%.o: $(SRC)%.cpp #$(HDRS)%.h
	$(CXX) -c $< -o $@ $(OPT)

clean:
	rm $(OBJS) ga
