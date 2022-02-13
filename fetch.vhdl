use work.fetchConstants.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetchUnit is
    port (
        clk             : in std_logic;
        opCode          : in std_logic_vector(fetchOpWidth-1 downto 0);
        addrBusLock     : in std_logic;
        cpuAddrBus      : in std_logic_vector(fetchAddrBusWidth-1 downto 0);
        cpuDataBus      : inout std_logic_vector(fetchDataBusWidth-1 downto 0);
        memEn           : out std_logic;
        memWriteEn      : out std_logic;
        memAddrBus      : out std_logic_vector(fetchAddrBusWidth-1 downto 0);
        memDataBus      : inout std_logic_vector(fetchDataBusWidth-1 downto 0);
        instructionBus  : out std_logic_vector(fetchInstructionWidth-1 downto 0)
    );
end fetchUnit;

architecture rtl of fetchUnit is
begin
    addrBusLocking : process (clk) is
    begin
        if rising_edge(clk) and addrBusLock = '1' then
            memAddrBus <= cpuAddrBus;
        end if;
    end process;

    enableSignals : process (opCode) is
    begin
        if opCode = fetchLDI or opCode = fetchLDD then
            memEn <= '1';
            memWriteEn <= '0';
        elsif opcode = fetchSTD then
            memEn <= '1';
            memWriteEn <= '1';
        else
            memEn <= '0';
            memWriteEn <= '0';
        end if;
    end process;

    readFromMemory : process (clk) is
    begin
        if rising_edge(clk) then
            if opCode = fetchLDI then
                instructionBus <= memDataBus;
            end if;
        end if;

        if opCode = fetchLDD then
            cpuDataBus <= memDataBus;
        else
            cpuDataBus <= (others => 'Z');
        end if;
    end process;

    writeToMemory : process (clk) is
    begin
        if rising_edge(clk) then
            if opCode = fetchSTD then
                memDataBus <= cpuDataBus;
            else
                memDataBus <= (others => 'Z');
            end if;
        end if;
    end process;


end rtl;








