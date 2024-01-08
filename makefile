test: fetch decode datamem alu

HDLC := ghdl
CARGS := --std=08
# WAVE := --format=fst --gtkw=wave.fst --wave
WAVE := --vcd=wave.vcd

records:
	$(HDLC) -a $(CARGS) records.vhd

auxiliary:
	$(HDLC) -a $(CARGS) alu_ctrl_constants.vhd
	$(HDLC) -a $(CARGS) mem_op_constants.vhd
	$(HDLC) -a $(CARGS) mux2.vhd
	$(HDLC) -a $(CARGS) mux3.vhd
	$(HDLC) -a $(CARGS) comparator.vhd
	$(HDLC) -a $(CARGS) alu.vhd

fetch:
	$(HDLC) -a $(CARGS) datamem.vhd
	$(HDLC) -a $(CARGS) fetch.vhd 
	$(HDLC) -a $(CARGS) test/fetch_tb.vhd
	$(HDLC) -e $(CARGS) fetcher_tb
	$(HDLC) -r $(CARGS) fetcher_tb

execute:
	$(HDLC) -a $(CARGS) execute.vhd test/execute_tb.vhd -e execute_tb -r 

decode:
	$(HDLC) -a $(CARGS) records.vhd
	$(HDLC) -a $(CARGS) decode.vhd test/decode_tb.vhd -e decode_tb -r 

cpu: records auxiliary id_ex ex_mem mem_wb
	$(HDLC) -a $(CARGS) datamem.vhd
	$(HDLC) -a $(CARGS) decode.vhd 
	$(HDLC) -a $(CARGS) execute.vhd 
	$(HDLC) -a $(CARGS) fetch.vhd 
	$(HDLC) -a $(CARGS) alu.vhd 
	$(HDLC) -a $(CARGS) write-back.vhd 
	$(HDLC) -a $(CARGS) cpu.vhd 
	$(HDLC) -a $(CARGS) test/cpu_tb.vhd
	$(HDLC) -e $(CARGS) cpu_tb
	$(HDLC) -r $(CARGS) cpu_tb $(WAVE)

alu: auxiliary
	$(HDLC) -a $(CARGS) alu.vhd test/alu_tb.vhd -e alu_tb -r

datamem: auxiliary
	$(HDLC) -a $(CARGS) datamem.vhd test/memory.vhd -e memory_tb -r

id_ex: records
	$(HDLC) -a $(CARGS) id_ex.vhd

ex_mem: records
	$(HDLC) -a $(CARGS) ex_mem.vhd

mem_wb: records
	$(HDLC) -a $(CARGS) mem_wb.vhd

clean:
	rm -rf work
