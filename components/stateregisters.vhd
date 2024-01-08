library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.records_pkg.all;

-- TODO access indival record fields for clearing for ALL registers :))))

--  ENTITY DECLARATIONS

-- IF/ID register
entity reg_ifid is
	port (
    clk, clr, en    : in    std_logic;
    in_ifid_record  : in    t_ifid_reg; 
    out_ifid_record : out   t_ifid_reg; 
	); 
end reg_ifid;

entity reg_idex is
    port (
        clk, clr, en    : in    std_logic;    
        in_idex_record  : in    t_idex_reg; 
        out_idex_record : out   t_idex_reg; 
        ); 
end reg_idex;

entity reg_exmem is
    port (
        clk, clr, en    : in    std_logic;    
        in_exmem_record   : in    t_exmem_reg; 
        out_exmem_record  : out   t_exmem_reg; 
        ); 
end reg_exmem;

--  ARCHITECTURE DECLARATIONS

-- IF/ID register
architecture behavioral of reg_ifid is
    begin
        process(clk, clr, en)
        begin
        if (rising_edge(clk)) then		-- do stuff on rising clk edge
            if (clr = '0')  then		-- if the signal is not to clr the reg
                    if (en = '1') then		-- do stuff if enabled
                            out_ifid_record <= in_ifid_record;
                    end if;
          else						-- clr the reg
            out_ifid_record.pc <= (others=>'0');
            out_ifid_record.instruction <= (others=>'0');
          end if;	
            end if;
        end process;
end behavioral;


-- ID/EX register
architecture behavioral of reg_idex is
    begin
        process(clk, clr, en)
        begin
        if (rising_edge(clk)) then		-- do stuff on rising clk edge
            if (clr = '0')  then		-- if the signal is not to clr the reg
                    if (en = '1') then		-- do stuff if enabled
                            out_idex_record <= in_idex_record;
                    end if;
          else						-- clr the reg
            out_idex_record <= (others=>'0');       --TODO fix me!
          end if;	
            end if;
        end process;
end behavioral;

-- EX/MEM register
architecture behavioral of reg_exmem is
    begin
        process(clk, clr, en)
        begin
        if (rising_edge(clk)) then		-- do stuff on rising clk edge
            if (clr = '0')  then		-- if the signal is not to clr the reg
                    if (en = '1') then		-- do stuff if enabled
                            out_exmem_record <= in_exmem_record;
                    end if;
          else						-- clr the reg
            out_exmem_record <= (others=>'0');       --TODO fix me!
          end if;	
            end if;
        end process;
end behavioral;
