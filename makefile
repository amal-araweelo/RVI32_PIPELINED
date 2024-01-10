test: fetch decode datamem alu

# Use this to generate a wave file: --format=fst --gtkw=wave.fst --wave

NVC := nvc --std=2008

records:
	$(NVC) -a constants.vhd

auxiliary:
	$(NVC) -a components/mux2.vhd
	$(NVC) -a components/mux3.vhd
	$(NVC) -a components/comparator.vhd
	$(NVC) -a components/alu.vhd

fetch-test:
	$(NVC) -a fetch.vhd test/fetch_tb.vhd -e fetcher_tb -r

fetch: memory
	$(NVC) -a fetch.vhd

execute:
	$(NVC) -a execute.vhd test/execute_tb.vhd -e execute_tb -r 

decode:
	$(NVC) -a constants.vhd
	$(NVC) -a decode.vhd test/decode_tb.vhd -e decode_tb -r 

cpu: records auxiliary fetch state-regs
	$(NVC) -a decode.vhd 
	$(NVC) -a execute.vhd 
	$(NVC) -a fetch.vhd 
	$(NVC) -a datamem.vhd
	$(NVC) -a components/alu.vhd 
	$(NVC) -a write-back.vhd
	$(NVC) -a test/cpu_tb.vhd -e cpu_tb -r --format=fst --gtkw=wave.fst --wave

alu: auxiliary
	$(NVC) -a components/alu.vhd test/alu_tb.vhd -e alu_tb -r

datamem: auxiliary
	$(NVC) -a datamem_5.vhd test/datamem_5_tb.vhd -e datamem_5_tb -r

memory:
	$(NVC) -a components/instr_mem.vhd

state-regs:
	$(NVC) -a components/stateregisters.vhd

clean:
	rm -rf work
