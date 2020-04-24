# OPT =  -O3 -fopenmp -ffast-math #-std=c++11
#
# DEBUG = -g -pg -fno-omit-frame-pointer -no-pie
#
# BIN = ../bin/
# SRC = ../src/
# HDRS = ../headers/
#
# CC = gcc #clang
# CXX = g++ #clang++
#
# LDFLAGS += $(addprefix -L,$(LIBRARY_DIR))
#
# CC += $(CFLAGS)
#
#
# OBJ = main instance_flowshop instance_qap instance_tsp arguments eval_flowshop eval_qap eval_q3ap eval_tsp permutation
#
# OBJS=$(addprefix $(BIN), $(addsuffix .o, $(OBJ)))
#
# all: test
#
# test:	$(OBJS)
# 	@echo $(OBJS)
# 	$(CXX) $(OBJS) -o $(BIN)$@ $(OPT) -ldl
#
# $(BIN)%.o: $(SRC)%.cpp #$(HDRS)%.h
# 	$(CXX) -c $< -o $@ $(OPT)
#
# $(BIN)main.o : $(SRC)main.cpp
# 	$(CXX) -o $(BIN)main.o -c $(SRC)main.cpp $(OPT)
#
# clean :
# 	rm -fr $(HDRS)*~ $(HDRS)*\# $(SRC)*~ $(SRC)*\# $(BRN)*~ $(BRN)*\# $(MTH)*~ $(MTH)*\# *.o
# 	rm -fr $(BIN)*.o
