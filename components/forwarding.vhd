library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- DOESNT work yet

entity forwarding_unit is
  port
  (
    -- Inputs
    REG_src_idx_1  : in std_logic_vector(4 downto 0) := (others => '0'); -- rs2 ID
    REG_src_idx_1    : in std_logic_vector(4 downto 0) := (others => '0'); -- rs1 ID
    REG_we  : in std_logic                    := '0';
    WB_dst_reg: in std_logic_vector(4 downto 0) := (others => '0');
    MEM_dst_reg : in std_logic_vector(4 downto 0) := (others => '0');
    MEM_we  : in std_logic                    := '0';

    -- Outputs
    forward_1 : out std_logic_vector(1 downto 0) := (others => '0');
    forward_2 : out std_logic_vector(1 downto 0) := (others => '0')
    
  );
end forwarding_unit;

architecture behavorial of forwarding_unit is

begin
  process (all)
  begin
    if (((mem_reg_wr_en = '1') and (mem_reg_wr_idx /= 0) and (mem_reg_wr_idx = id_reg1_idx))) then
      forward_1 <= "10";
    end if;
    if (((mem_reg_wr_en = '1') and WB_dst_reg/= 0) and WB_dst_reg= id_reg1_idx))) then
      forward_1 <= "01";
    end if;
    if (((mem_reg_wr_en = '1') and (mem_reg_wr_idx /= 0) and (mem_reg_wr_idx = id_reg2_idx))) then
      forward_2 <= "10";
    end if;
    if (((mem_reg_wr_en = '1') and WB_dst_reg/= 0) and WB_dst_reg= id_reg2_idx))) then
      forward_2 <= "01";
    end if;
  end process;
end architecture;