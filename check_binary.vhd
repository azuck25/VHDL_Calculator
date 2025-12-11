LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE check_binary IS
    FUNCTION add_three(binary_input : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR;
END PACKAGE check_binary;

PACKAGE BODY check_binary IS
    FUNCTION add_three(binary_input : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE return_value : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    BEGIN
        CASE binary_input IS
            WHEN "0101" =>
                return_value := "1000";
            WHEN "0110" =>
                return_value := "1001";
            WHEN "0111" =>
                return_value := "1010";
            WHEN "1000" =>
                return_value := "1011";
            WHEN "1001" =>
                return_value := "1100";
            WHEN OTHERS =>
                return_value := binary_input;  -- Default case to handle other inputs
        END CASE;

        RETURN return_value;
    END FUNCTION add_three;
END PACKAGE BODY check_binary;
