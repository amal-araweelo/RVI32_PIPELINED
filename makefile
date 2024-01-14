test: datamem-test
# Use this to generate a wave file: --format=fst --gtkw=wave.fst --wave

NVC := nvc --std=2008

records:
	$(NVC) -a constants.vhd

auxiliary: records
	$(NVC) -a components/alu.vhd
	$(NVC) -a components/mux2.vhd
	$(NVC) -a components/mux3.vhd
	$(NVC) -a components/comparator.vhd
	$(NVC) -a components/forwarding.vhd
	$(NVC) -a registerfile.vhd


fetch-test: fetch
	$(NVC) -a test/fetch_tb.vhd -e fetcher_tb -r

decode-test: decode
	$(NVC) -a test/decode_tb.vhd -e decode_tb -r 

datamem-test: datamem
	$(NVC) -a test/datamem_tb.vhd -e datamem_tb -r

forward-test: auxiliary
	$(NVC) -a test/forwarding_tb.vhd -e forwarding_unit_tb -r

alu-test: auxiliary
	$(NVC) -a components/alu.vhd test/alu_tb.vhd -e alu_tb -r

clk_div: 
	$(NVC) -a clk_div.vhd test/clk_div_tb.vhd -e clk_div_tb -r

reg-file-test: auxiliary
	$(NVC) -a registerfile.vhd test/registerfile_tb.vhd -e reg_file_tb -r
	

comparator-test:
	$(NVC) -a components/comparator.vhd test/comparator_tb.vhd -e comparator_tb -r

fetch: memory auxiliary records
	$(NVC) -a fetch.vhd

execute:
	$(NVC) -a execute.vhd test/execute_tb.vhd -e execute_tb -r 

decode:
	$(NVC) -a constants.vhd
	$(NVC) -a decode.vhd

cpu: records auxiliary fetch state-regs
	$(NVC) -a components/alu.vhd 
	$(NVC) -a decode.vhd 
	$(NVC) -a execute.vhd 
	$(NVC) -a fetch.vhd 
	$(NVC) -a datamem.vhd
	$(NVC) -a write-back.vhd
	$(NVC) -a cpu.vhd
	$(NVC) -a test/cpu_tb.vhd -e cpu_tb -r

datamem: auxiliary
	$(NVC) -a datamem.vhd 

memory: auxiliary
	$(NVC) -a components/instr_mem.vhd

state-regs:
	$(NVC) -a components/stateregisters.vhd

clean:
	rm -rf work
