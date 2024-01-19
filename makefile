test: hazard-test datamem-test fetch-test forward-test decode-test alu-test reg-file-test comparator-test execute-test

test-integration:
	make -C tools

NVC := nvc --std=2008
WAVE := --format=fst --gtkw=wave.fst --wave

records:
	$(NVC) -a constants.vhd

auxiliary: records
	$(NVC) -a components/alu.vhd
	$(NVC) -a components/mux2.vhd
	$(NVC) -a components/mux3.vhd
	$(NVC) -a components/comparator.vhd
	$(NVC) -a components/forwarding.vhd
	$(NVC) -a components/hazard.vhd
	$(NVC) -a registerfile.vhd


hazard-test: auxiliary
	$(NVC) -a test/hazard_tb.vhd -e hazard_unit_tb -r

fetch-test: fetch
	$(NVC) -a test/fetch_tb.vhd -e fetcher_tb -r

decode-test: decode
	$(NVC) -a test/decode_tb.vhd -e decode_tb -r 

datamem-test: datamem
	$(NVC) -a test/datamem_tb.vhd -e data_mem_tb -r

forward-test: auxiliary
	$(NVC) -a test/forwarding_tb.vhd -e forwarding_unit_tb -r

alu-test: auxiliary
	$(NVC) -a components/alu.vhd test/alu_tb.vhd -e alu_tb -r

reg-file-test: auxiliary
	$(NVC) -a registerfile.vhd test/registerfile_tb.vhd -e reg_file_tb -r
	

comparator-test:
	$(NVC) -a components/comparator.vhd test/comparator_tb.vhd -e comparator_tb -r

fetch: memory auxiliary records
	$(NVC) -a fetch.vhd

execute-test:
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
	$(NVC) -a test/cpu_tb.vhd -e cpu_tb -r $(WAVE)

datamem: auxiliary
	$(NVC) -a datamem.vhd 

memory: auxiliary
	$(NVC) -a components/instr_mem.vhd

state-regs:
	$(NVC) -a components/stateregisters.vhd

clean:
	rm -rf work
