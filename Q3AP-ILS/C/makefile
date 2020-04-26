BUILD = ./build/
BIN = ./bin/
SRC = ./src/
HDRS = ./headers/

CXX = g++
# CXX = clang++
OPT = -O3 -fopenmp

FILES = main ils qap_instance evalQ3AP solution

OBJS=$(addprefix $(BUILD), $(addsuffix .o, $(FILES)))

ils:	$(OBJS)
	@echo $(OBJS)
	$(CXX) $(OBJS) -o $@ $(OPT)

$(BUILD)%.o: $(SRC)%.cpp #$(HDRS)%.h
	@mkdir -p $(BUILD)
	$(CXX) -c $< -o $@ $(OPT)

clean:
	rm -r $(BUILD)
	rm ./ils
