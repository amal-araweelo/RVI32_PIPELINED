use std.textio.all;

impure function init_ram_hex return ram_type is 
		file text_file : text open read_mode is "instructions.hex";
		variable text_line : line;
		variable ram_content : ram_type;
begin
		for i in 0 to ram_depth - 1 loop
				readline(text_file, text_line);
				hread(text_line, ram_content(i));
		end loop;

		return ram_content;
end function;
