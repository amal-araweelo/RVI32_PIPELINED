library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Forwarding unit

entity forwarding_unit is
  port
  (
    -- Inputs
    REG_src_idx_1 : in std_logic_vector(4 downto 0); -- rs2 ID
    REG_src_idx_2 : in std_logic_vector(4 downto 0); -- rs1 ID
    WB_REG_we     : in std_logic := '0'; -- REG_we from the write back stage
    MEM_REG_we    : in std_logic := '0'; -- REG_we from the memory stage

    WB_dst_idx  : in std_logic_vector(4 downto 0);
    MEM_dst_idx : in std_logic_vector(4 downto 0);

    -- Outputs
    forward_reg_src_1 : out std_logic_vector(1 downto 0);
    forward_reg_src_2 : out std_logic_vector(1 downto 0)

  );
end forwarding_unit;

architecture behavorial of forwarding_unit is

begin
  process (all)
  begin
    -- report "[FORWARD] REG_src_idx_1: " & to_string(REG_src_idx_1);
    -- report "[FORWARD] REG_src_idx_2: " & to_string(REG_src_idx_2);
    -- report "[FORWARD] WB_REG_we: " & to_string(WB_REG_we);

    forward_reg_src_1 <= "01";
    forward_reg_src_2 <= "01";

    -- Forwarding from write back stage
    if ((((WB_REG_we = '1') and (WB_dst_idx /= 0) and (WB_dst_idx = REG_src_idx_1))) and (not((((MEM_REG_we = '1') and (MEM_dst_idx /= 0) and (MEM_dst_idx = REG_src_idx_1)))))) then
      forward_reg_src_1 <= "00";
    -- Forwarding from memory stage
    elsif (((MEM_REG_we = '1') and (MEM_dst_idx /= 0) and (MEM_dst_idx = REG_src_idx_1))) then
      forward_reg_src_1 <= "10"; 
    end if;

    -- Forwarding from write back stage
    if ((((WB_REG_we = '1') and (WB_dst_idx /= 0) and (WB_dst_idx = REG_src_idx_2))) and (not((((MEM_REG_we = '1') and (MEM_dst_idx /= 0) and (MEM_dst_idx = REG_src_idx_2)))))) then
      forward_reg_src_2 <= "00";
    -- Forwarding from memory stage
    elsif (((MEM_REG_we = '1') and (MEM_dst_idx /= 0) and (MEM_dst_idx = REG_src_idx_2))) then
      forward_reg_src_2 <= "10"; 
    end if;

  end process;
end architecture;

