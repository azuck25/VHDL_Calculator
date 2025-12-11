LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;  
PACKAGE math_binary IS
    FUNCTION add(register_A: std_logic_vector(7 downto 0); register_B: std_logic_vector(7 downto 0)) return std_logic_vector;

    FUNCTION subtract(register_C: std_logic_vector(7 downto 0); register_D: std_logic_vector(7 downto 0)) return std_logic_vector;
END PACKAGE math_binary;
							
PACKAGE BODY math_binary IS
    FUNCTION add(register_A: std_logic_vector(7 downto 0); register_B: std_logic_vector(7 downto 0)) return std_logic_vector IS
        VARIABLE x,y,c,sum : std_logic_vector(7 downto 0);
    BEGIN
        x := register_A;
        y := register_B;
        c := (others => '0');
        sum := (others => '0');
		
        c(0) := (x(0) and y(0)) or (x(0) and '0') or (y(0) and '0');
        c(1) := (x(1) and y(1)) or (x(1) and c(0)) or (y(1) and c(0));
        c(2) := (x(2) and y(2)) or (x(2) and c(1)) or (y(2) and c(1));	
        c(3) := (x(3) and y(3)) or (x(3) and c(2)) or (y(3) and c(2));
        c(4) := (x(4) and y(4)) or (x(4) and c(3)) or (y(4) and c(3));
        c(5) := (x(5) and y(5)) or (x(5) and c(4)) or (y(5) and c(4));
        c(6) := (x(6) and y(6)) or (x(6) and c(5)) or (y(6) and c(5));
        c(7) := (x(7) and y(7)) or (x(7) and c(6)) or (y(7) and c(6));
		
        sum(0) := (x(0) xor y(0)) xor '0';
        sum(1) := (x(1) xor y(1)) xor c(0);	
        sum(2) := (x(2) xor y(2)) xor c(1);
        sum(3) := (x(3) xor y(3)) xor c(2);
        sum(4) := (x(4) xor y(4)) xor c(3);
        sum(5) := (x(5) xor y(5)) xor c(4);
        sum(6) := (x(6) xor y(6)) xor c(5);
        sum(7) := (x(7) xor y(7)) xor c(6);

        return sum;
    END FUNCTION add;

    FUNCTION subtract(register_C: std_logic_vector(7 downto 0); register_D: std_logic_vector(7 downto 0)) return std_logic_vector IS
        VARIABLE x,y,c,sum : std_logic_vector(7 downto 0);
    BEGIN
        x := register_C;
        y := register_D;
        c := (others => '0');
        sum := (others => '0');
		
        c(0) := (x(0) and not y(0)) or (x(0) and '0') or (not y(0) and '0');
				
        for i in 1 to 7 loop
            c(i) := ( x(i) and  not y(i)) or ( x(i) and c(i - 1)) or ( not y(i) and c(i - 1));
        end loop;	
        sum(0) := (x(0) xor y(0)) xor '0';
        for j in 1 to 7 loop
            sum(j) := (x(j) xor y(j)) xor c(j -1);
        end loop;
		
        return sum;
		
    END FUNCTION subtract;
END PACKAGE BODY math_binary;
