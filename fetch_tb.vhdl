use work.fetchConstants.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch_tb  is
end fetch_tb ;
    
architecture behavioural of fetch_tb is
    component fetchUnit
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
    end component;

    for fetchUnit_UUT: fetchUnit use entity work.fetchUnit;

    signal clk              : std_logic;
    signal opCode           : std_logic_vector(fetchOpWidth-1 downto 0);
    signal addrBusLock      : std_logic;
    signal cpuAddrBus       : std_logic_vector(fetchAddrBusWidth-1 downto 0);
    signal cpuDataBus       : std_logic_vector(fetchDataBusWidth-1 downto 0);
    signal memEn            : std_logic;
    signal memWriteEn       : std_logic;
    signal memAddrBus       : std_logic_vector(fetchAddrBusWidth-1 downto 0);
    signal memDataBus       : std_logic_vector(fetchDataBusWidth-1 downto 0);
    signal instructionBus   : std_logic_vector(fetchInstructionWidth-1 downto 0);

begin
    fetchUnit_UUT : fetchUnit port map 
    (
        clk => clk,
        opCode => opCode,
        addrBusLock => addrBusLock,
        cpuAddrBus => cpuAddrBus,
        cpuDataBus => cpuDataBus,
        memEn => memEn,
        memWriteEn => memWriteEn,
        memAddrBus => memAddrBus,
        memDataBus => memDataBus,
        instructionBus => instructionBus
    );

    process 
    begin 
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    process
        type test_pattern_type is record
            opCode          : std_logic_vector (fetchOpWidth-1 downto 0);
            addrBusLock     : std_logic;
            cpuDataBus      : std_logic_vector (fetchDataBusWidth-1 downto 0);
            cpuAddrBus      : std_logic_vector (fetchAddrBusWidth-1 downto 0);
            memEn           : std_logic;
            memWriteEn      : std_logic;
            memDataBus      : std_logic_vector (fetchDataBusWidth-1 downto 0);
            memAddrBus      : std_logic_vector (fetchAddrBusWidth-1 downto 0);
            instructionBus  : std_logic_vector (fetchInstructionWidth-1 downto 0);
        end record;
        
        type test_pattern_array is array (natural range <>) of test_pattern_type;
        
        constant test_pattern : test_pattern_array :=
        (
            (fetchNOP, '0', "--------", x"0000", '0', '0', "--------", "----------------", "--------"),  -- NOP
            (fetchNOP, '0', "--------", x"0100", '0', '0', "--------", "----------------", "--------"),  -- NOP
            (fetchLDI, '0', "--------", x"0000", '1', '0', "01010101", "----------------", "01010101"),  -- Load Instruction
            (fetchLDD, '1', "ZZZZZZZZ", x"0000", '1', '0', "01100110", x"0000",            "01010101"),  -- Load Data
            (fetchLDD, '1', "ZZZZZZZZ", x"FF10", '1', '0', "11100100", x"FF10",            "01010101"),  -- Load Data
            (fetchLDI, '0', "--------", x"0000", '1', '0', "11001001", "----------------", "11001001"),  -- Load Instruction
            (fetchSTD, '1', "01110111", x"FF10", '1', '1', "ZZZZZZZZ", x"FF10",            "11001001")   -- Store Data
        );
    begin

        for i in test_pattern'range loop
            -- Set input signals
            opCode <= test_pattern(i).opCode;
            addrBusLock <= test_pattern(i).addrBusLock;
            cpuDataBus <= test_pattern(i).cpuDataBus;
            cpuAddrBus <= test_pattern(i).cpuAddrBus;
            memDataBus <= test_pattern(i).memDataBus;
            
            wait for 20 ns;
            
            assert std_match(memAddrBus, test_pattern(i).memAddrBus)
                report "Bad 'Memory Address Bus' value " & to_string(memAddrBus) & 
                    ", expected " & to_string(test_pattern(i).memAddrBus) &
                    " at test pattern index " & integer'image(i) severity error;

            assert std_match(memEn, test_pattern(i).memEn)
                report "Bad 'Memory Enable' value " & to_string(memEn) & 
                    ", expected " & to_string(test_pattern(i).memEn) &
                    " at test pattern index " & integer'image(i) severity error;

            assert std_match(memWriteEn, test_pattern(i).memWriteEn)
                report "Bad 'Memory Address Bus' value " & to_string(memWriteEn) & 
                    ", expected " & to_string(test_pattern(i).memWriteEn) &
                    " at test pattern index " & integer'image(i) severity error;

            assert std_match(instructionBus, test_pattern(i).instructionBus)
                report "Bad 'Instruction Bus' value " & to_string(instructionBus) & 
                    ", expected " & to_string(test_pattern(i).instructionBus) &
                    " at test pattern index " & integer'image(i) severity error;
            
            if opcode = fetchLDD then
                assert std_match(cpuDataBus, memDataBus)
                    report "Bad 'CPU Data Bus' value " & to_string(cpuDataBus) & 
                        ", expected " & to_string(test_pattern(i).memDataBus) &
                        " at test pattern index " & integer'image(i) severity error;
            elsif opcode = fetchSTD then
                assert std_match(memDataBus, cpuDataBus)
                    report "Bad 'Memory Data Bus' value " & to_string(memDataBus) & 
                        ", expected " & to_string(test_pattern(i).cpuDataBus) &
                        " at test pattern index " & integer'image(i) severity error;
            end if;
        end loop;

        assert false report "End Of Test - All Tests Successful!" severity note;
        wait;
    end process;

end behavioural;