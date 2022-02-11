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
        cpuAddrBus      : in std_logic_vector(fetchAddrBusWidth-1 downto 0);
        cpuDataBus      : inout std_logic_vector(fetchDataBusWidth-1 downto 0);
        memAddrBus      : out std_logic_vector(fetchAddrBusWidth-1 downto 0);
        memDataBus      : inout std_logic_vector(fetchDataBusWidth-1 downto 0);
        instructionBus  : out std_logic_vector(fetchInstructionWidth-1 downto 0)
    );
    end component;

    for fetchUnit_UUT: fetchUnit use entity work.fetchUnit;

    signal clk              : std_logic;
    signal opCode           : std_logic_vector(fetchOpWidth-1 downto 0);
    signal cpuAddrBus       : std_logic_vector(fetchAddrBusWidth-1 downto 0);
    signal cpuDataBus       : std_logic_vector(fetchDataBusWidth-1 downto 0);
    signal memAddrBus       : std_logic_vector(fetchAddrBusWidth-1 downto 0);
    signal memDataBus       : std_logic_vector(fetchDataBusWidth-1 downto 0);
    signal instructionBus   : std_logic_vector(fetchInstructionWidth-1 downto 0);

begin
    fetchUnit_UUT : fetchUnit port map 
    (
        clk => clk,
        opCode => opCode,
        cpuAddrBus => cpuAddrBus,
        cpuDataBus => cpuDataBus,
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
            cpuDataBus      : std_logic_vector (fetchDataBusWidth-1 downto 0);
            cpuAddrBus      : std_logic_vector (fetchAddrBusWidth-1 downto 0);
            memDataBus      : std_logic_vector (fetchDataBusWidth-1 downto 0);
            memAddrBus      : std_logic_vector (fetchAddrBusWidth-1 downto 0);
            instructionBus  : std_logic_vector (fetchInstructionWidth-1 downto 0);
        end record;
        
        type test_pattern_array is array (natural range <>) of test_pattern_type;
        
        constant test_pattern : test_pattern_array :=
        (
            (fetchNOP, "--------", x"0000", "--------", "ZZZZZZZZZZZZZZZZ", "--------"),  -- NOP
            (fetchNOP, "--------", x"0100", "--------", "ZZZZZZZZZZZZZZZZ", "--------"),  -- NOP
            (fetchLDI, "--------", x"0000", "01010101", "ZZZZZZZZZZZZZZZZ", "ZZZZZZZZ"),  -- Load Instruction
            (fetchLDD, "ZZZZZZZZ", x"0000", "01100110", "ZZZZZZZZZZZZZZZZ", "--------"),  -- Load Data
            (fetchLDD, "ZZZZZZZZ", x"FF10", "11100100", "ZZZZZZZZZZZZZZZZ", "--------"),  -- Load Data
            (fetchSTD, "01110111", x"FF10", "ZZZZZZZZ", "ZZZZZZZZZZZZZZZZ", "--------")  -- Store Data
        );
    begin

        for i in test_pattern'range loop
            -- Set input signals
            opCode <= test_pattern(i).opCode;
            cpuDataBus <= test_pattern(i).cpuDataBus;
            cpuAddrBus <= test_pattern(i).cpuAddrBus;
            memDataBus <= test_pattern(i).memDataBus;
            memAddrBus <= test_pattern(i).memAddrBus;
            instructionBus <= test_pattern(i).instructionBus;
            -- if opcode = fetch or opcode = aluRDT or opcode = aluRDF then
            --     dataBus <= (others => 'Z'); 
            -- else 
            --     dataBus <= test_pattern(i).dataBus;
            -- end if;
            
            wait for 20 ns;
            
            assert memAddrBus = cpuAddrBus
                report "Bad 'Memory Address Bus' value " & to_string(memAddrBus) & 
                    ", expected " & to_string(test_pattern(i).cpuAddrBus) &
                    " at test pattern index " & integer'image(i) severity error;

            if opcode = fetchLDI then
                assert instructionBus = memDataBus
                    report "Bad 'Instruction Bus' value " & to_string(instructionBus) & 
                        ", expected " & to_string(test_pattern(i).memDataBus) &
                        " at test pattern index " & integer'image(i) severity error;
            elsif opcode = fetchLDD then
                assert cpuDataBus = memDataBus
                    report "Bad 'CPU Data Bus' value " & to_string(cpuDataBus) & 
                        ", expected " & to_string(test_pattern(i).memDataBus) &
                        " at test pattern index " & integer'image(i) severity error;
            elsif opcode = fetchSTD then
                assert memDataBus = cpuDataBus
                    report "Bad 'Memory Data Bus' value " & to_string(memDataBus) & 
                        ", expected " & to_string(test_pattern(i).cpuDataBus) &
                        " at test pattern index " & integer'image(i) severity error;
            end if;
        end loop;

        assert false report "End Of Test - All Tests Successful!" severity note;
        wait;
    end process;

end behavioural;