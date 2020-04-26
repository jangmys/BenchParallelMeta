BUILD = ./build/
BIN = ./bin/
SRC = ./src/
HDRS = ./headers/

CXX = g++
OPT = -O3 -std=c++11 -fopenmp

FILES = main GA ils qap_instance evalQ3AP solution

OBJS=$(addprefix $(BUILD), $(addsuffix .o, $(FILES)))

ga:	$(OBJS)
	@echo $(OBJS)
	$(CXX) $(OBJS) -o $@ $(OPT)

$(BUILD)%.o: $(SRC)%.cpp #$(HDRS)%.h
	@mkdir -p $(BUILD)
	$(CXX) -c $< -o $@ $(OPT)

clean:
	rm -r $(BUILD)
	rm ga
