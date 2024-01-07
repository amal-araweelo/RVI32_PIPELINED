test: fetch decode datamem alu

# Use this to generate a wave file: --format=fst --gtkw=wave.fst --wave

NVC := nvc --std=2008

records:
	$(NVC) -a records.vhd

auxiliary:
	$(NVC) -a alu_ctrl_constants.vhd
	$(NVC) -a mem_op_constants.vhd
	$(NVC) -a mux2.vhd
	$(NVC) -a mux3.vhd
	$(NVC) -a comparator.vhd
	$(NVC) -a alu.vhd

fetch:
	$(NVC) -a fetch.vhd test/fetch_tb.vhd -e fetcher_tb -r

execute:
	$(NVC) -a execute.vhd test/execute_tb.vhd -e execute_tb -r 

decode:
	$(NVC) -a records.vhd
	$(NVC) -a decode.vhd test/decode_tb.vhd -e decode_tb -r 

cpu: records auxiliary
	$(NVC) -a decode.vhd 
	$(NVC) -a execute.vhd 
	$(NVC) -a fetch.vhd 
	$(NVC) -a alu.vhd 
	$(NVC) -a cpu.vhd test/cpu_tb.vhd -e cpu_tb -r --format=fst --gtkw=wave.fst --wave

alu: auxiliary
	$(NVC) -a alu.vhd test/alu_tb.vhd -e alu_tb -r

datamem: auxiliary
	$(NVC) -a datamem_5.vhd test/datamem_5_tb.vhd -e datamem_5_tb -r

id_ex: records
	$(NVC) -a id_ex.vhd

clean:
	rm -rf work
