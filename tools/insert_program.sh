FILENAME="$1"
INSTR_MEM="../components/instr_mem.vhd"

# restore program
if [ "$FILENAME" = "r" ]; then
	# echo "Restoring $INSTR_MEM"
	cp $INSTR_MEM.bak $INSTR_MEM
	exit 0
fi

PROGRAM=$(./asm2vhdl.sh "$1")
echo """==PROGRAM: $FILENAME==" >> log
echo "$PROGRAM" >> log
echo "======================" >> log
 
# echo "Checking $INSTR_MEM"
grep -q -F "INSERT PROGRAM" $INSTR_MEM || echo "Error: $INSTR_MEM does not contain \"INSERT PROGRAM\""

# backup the original file
cp $INSTR_MEM $INSTR_MEM.bak

[ -z "$PROGRAM" ] && echo "Error: $FILENAME is not a valid program" && exit 1

# remove vhdl comments from the program
PROGRAM=$(echo "$PROGRAM" | sed 's/--.*//g')

echo "$PROGRAM" > program.vhd

# In instruction_mem.vhd replace "-- INSERT PROGRAM" with the program
sed -i -e '/-- INSERT PROGRAM/{r program.vhd' -e 'd}' $INSTR_MEM

rm program.vhd
