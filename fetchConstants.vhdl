library ieee;
use ieee.std_logic_1164.all;

package fetchConstants is
    constant fetchDataBusWidth      : integer := 8;    
    constant fetchAddrBusWidth      : integer := 16;
    constant fetchOpWidth           : integer := 2;
    constant fetchInstructionWidth  : integer := 8;

    constant fetchNOP : std_logic_vector (fetchOpWidth-1 downto 0) := "00";  -- Do nothing
    constant fetchSTD : std_logic_vector (fetchOpWidth-1 downto 0) := "01";  -- Store data byte in memory
    constant fetchLDI : std_logic_vector (fetchOpWidth-1 downto 0) := "10";  -- Load instruction op code from memory
    constant fetchLDD : std_logic_vector (fetchOpWidth-1 downto 0) := "11";  -- Load data byte from memory
end fetchConstants;

package body fetchConstants is
end fetchConstants;