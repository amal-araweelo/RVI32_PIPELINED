test: fetch

fetch:
	nvc  --std=2008 -a fetch.vhd test/fetch_tb.vhd -e fetcher_tb -r

execute:
	nvc  --std=2008 -a execute.vhd test/execute_tb.vhd -e execute_tb -r --format=fst --gtkw=wave.fst --wave

decode:
	nvc --std=2008 -a records.vhd
	nvc --std=2008 -a decode.vhd test/decode_tb.vhd -e decode_tb -r 

cpu:
	nvc --std=2008 -a records.vhd
	nvc --std=2008 -a decode.vhd 
	nvc --std=2008 -a fetch.vhd 
	nvc --std=2008 -a cpu.vhd test/cpu_tb.vhd -e cpu_tb -r
