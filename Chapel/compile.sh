#!/bin/bash

echo " ### starting compilation ### "

chpl -M modules --permit-unhandled-module-errors --fast --scalar-replacement implementation/fsp_gen.c implementation/simple_bound.c implementation/aux.c implementation/tsp.c main.chpl -o chplheuristic.out

echo " ### end of compilation ### "