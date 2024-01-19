TESTS=$(find tests -type f -name "*.s")

echo "" > log
mkdir results

for TEST in $TESTS; do
	# remove the .s form the TEST
	TEST=$(echo $TEST | cut -d'.' -f1)
	echo "Running test $TEST"
	TEST_SRC="$TEST.s"
	mkdir -p results/$TEST

	echo "Compiling $TEST_SRC" | tee -a log
	./insert_program.sh $TEST_SRC

	make -C .. cpu &> results/$TEST.dump

	# restore the original program
	./insert_program.sh r

	# Turn the dump into a list of registers
	cat results/$TEST.dump | grep -E "REG" | grep -oE "REG.+" > results/$TEST.reg

	# Get the original res file 
	RES_FILE="$TEST.res"

	./get-registers.sh $RES_FILE > results/$TEST.res

	DIFF=$(diff results/$TEST.res results/$TEST.reg | tee -a log)

	if [ "$DIFF" != "" ]; then
		echo "Test $TEST [FAILED]" | tee -a log
		echo "======================" | tee -a log
		echo $DIFF | tee -a log
		echo "======================" | tee -a log
		exit 1
	else 
		echo "Test $TEST [PASSED]" | tee -a log
	fi

	echo "======================" | tee -a log
done
