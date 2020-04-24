import os




_threads = [8]
problems  = ["tsp", "fsp", "qap", "q3ap"]
repetitions = [1, 10, 100, 1000, 10000, 100000]
population  = [1000000,100000,10000,1000,100,10]


for th in _threads:
	
	os.putenv("CHPL_RT_NUM_THREADS_PER_LOCALE", str(th))

	os.system("echo Problem: TSP")	
	os.system("echo Number of threads: $CHPL_RT_NUM_THREADS_PER_LOCALE")
	for index in range(0,6):
		os.system("echo repetitions - %d population - %d" % (repetitions[index], population[index]))
		os.system("./ga.out --problem=\"tsp\" --repetitions=%d --fileinst=\"tsp/pr2392.tsp\" --pop=%d >> results/tsp/pr.txt" % (repetitions[index],population[index]) )
		os.system("./ga.out --problem=\"tsp\" --repetitions=%d --fileinst=\"tsp/berlin52.tsp\" --pop=%d >> results/tsp/berlin.txt" % (repetitions[index],population[index]) )
				

for th in _threads:
	
	os.putenv("CHPL_RT_NUM_THREADS_PER_LOCALE", str(th))

	os.system("echo Problem: FSP")	
	os.system("echo Number of threads: $CHPL_RT_NUM_THREADS_PER_LOCALE")
	for index in range(0,6):
		os.system("echo repetitions - %d population - %d" % (repetitions[index], population[index]))
		os.system("./ga.out --problem=\"fsp\" --repetitions=%d --fsp_instance=120 --pop=%d >> results/fsp/120.txt" % (repetitions[index],population[index]) )
		os.system("./ga.out --problem=\"fsp\" --repetitions=%d --fsp_instance=20  --pop=%d >> results/fsp/20.txt" % (repetitions[index],population[index]) )



for th in _threads:
	
	os.putenv("CHPL_RT_NUM_THREADS_PER_LOCALE", str(th))

	os.system("echo Problem: QAP")	
	os.system("echo Number of threads: $CHPL_RT_NUM_THREADS_PER_LOCALE")
	for index in range(0,6):
		os.system("echo repetitions - %d population - %d" % (repetitions[index], population[index]))
		os.system("./ga.out --problem=\"qap\" --repetitions=%d --fileinst=\"q3ap/nug12.dat\" --pop=%d >> results/qap/nug.txt" % (repetitions[index],population[index]) )
		os.system("./ga.out --problem=\"qap\" --repetitions=%d --fileinst=\"q3ap/tho150.dat\" --pop=%d >> results/qap/tho.txt" % (repetitions[index],population[index]) )



for th in _threads:
	
	os.putenv("CHPL_RT_NUM_THREADS_PER_LOCALE", str(th))

	os.system("echo Problem: Q3AP")	
	os.system("echo Number of threads: $CHPL_RT_NUM_THREADS_PER_LOCALE")
	for index in range(0,6):
		os.system("echo repetitions - %d population - %d" % (repetitions[index], population[index]))
		os.system("./ga.out --problem=\"q3ap\" --repetitions=%d --fileinst=\"q3ap/nug12.dat\" --pop=%d >> results/q3ap/nug12.txt" % (repetitions[index],population[index]) )
		os.system("./ga.out --problem=\"q3ap\" --repetitions=%d --fileinst=\"q3ap/nug25.dat\" --pop=%d >> results/q3ap/nug25.txt" % (repetitions[index],population[index]) )




