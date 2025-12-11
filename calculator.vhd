LIBRARY IEEE;
LIBRARY LPM;
USE LPM.LPM_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.check_binary.ALL;
USE work.math_binary.ALL;


ENTITY calculator IS
	PORT(SW0, SW1, SW2, SW3,sW4, SW5, SW6, SW7,SW8, SW9, KEY0, KEY1, clock_in : IN STD_LOGIC;
		  HEX00, HEX01, HEX02, HEX03, HEX04, HEX05, HEX06, HEX10, HEX11, HEX12, HEX13, HEX14, HEX15, HEX16, HEX20, HEX21, HEX22, HEX23, HEX24, HEX25, HEX26, HEX36 : OUT STD_LOGIC;
		  LEDR0, LEDR1, LEDR2, LEDR3, LEDR4, LEDR5, LEDR6, LEDR7, LEDR8, LEDR9 : OUT STD_LOGIC;
		  Qs : buffer STD_LOGIC_VECTOR(11 DOWNTO 0);
		  data_ready, reset : buffer STD_LOGIC;
		  Qm: buffer STD_LOGIC_VECTOR(7 DOWNTO 0);
		  R_A, R_B, R_C, data_request : buffer STD_LOGIC;
		  
		  register_A, register_B, register_C : buffer STD_LOGIC_VECTOR(7 DOWNTO 0));
		 
	
END calculator;


ARCHITECTURE logic OF calculator IS
	signal div, q : STD_LOGIC_VECTOR(19 DOWNTO 0);
	
	
	type State_type is (reset_machine, request_input, Load_Data, Calculate_Data, Copy_Data);
	signal y : State_type;
	


	COMPONENT lpm_counter
	GENERIC (
		lpm_direction		: STRING;
		lpm_port_updown		: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL
	);
	PORT (
			clock	: IN STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (19 DOWNTO 0)
	);
	END COMPONENT;

	
BEGIN
	q <= div(19 DOWNTO 0);
	reset <= KEY1;
	data_ready <= KEY0;

	
	LPM_COUNTER_component : LPM_COUNTER
	GENERIC MAP (
		 lpm_direction => "UP",
		 lpm_port_updown => "PORT_UNUSED",
		 lpm_type => "LPM_COUNTER",
		 lpm_width => 20
					 )
					 
	PORT MAP(
		clock => clock_in,
		q => div
		);
		
	FSM_transitions : PROCESS(reset, q(19), data_ready, data_request, R_A, R_B, R_C)
		BEGIN 
			if data_request = '0' then
				y <= request_input;
			elsif reset = '1' then
				y <= reset_machine;
			elsif rising_edge(q(19)) then
				case y is 
					when reset_machine => 
						if reset = '0' then
							y <= reset_machine;
						else
							y <= request_input;
						end if;
					when request_input => 
						if data_request = '0' then
							y <= request_input;
						elsif data_request = '1' then 
							y <= load_data;
						end if;
					when Load_Data => 
						if data_ready = '0' and R_A = '0' then
							y <= load_data;
						elsif data_ready = '1' and R_A = '0' then
							y <= load_data;
						elsif data_ready = '0' and R_A = '1' then
							y <= Calculate_Data;
						end if;
					when Calculate_Data => 
						if R_A = '1' then
							y <= Calculate_Data;
						elsif R_C = '1' and R_A = '0' then
							y <= Copy_Data;
						end if;
					when Copy_Data => 
						if R_C = '1' then
							y <= Copy_Data;
						else 
							y <= request_input;
						end if;
				end case;
			end if;
	end process FSM_transitions;
	
	FSM_Outputs : PROCESS(data_request, y, q(19), R_A, R_C , register_A, register_C, SW9)
		begin
			if rising_edge(q(19)) then
				IF reset = '1' and y = reset_machine then
					register_A <= (others => '0');
					register_B <= (others => '0');
					register_C <= (others => '0');
					data_request <= '0';
					R_A <= '0';
					R_B <= '0';
					R_C <= '0';
					
				end if;	
				
				if y = request_input and data_request = '0' then
					data_request <= '1';
					LEDR0 <= data_request;
				end if;
			
				if y = Load_Data and data_ready = '1' then
					register_A <= Qm(7 downto 0);
					data_request <= '0';
					R_A <= '1';
					LEDR0 <= data_request;
				end if;

				if y = Calculate_Data and R_A = '1' then
					if SW9 = '0' then
						register_C <= add(register_C, register_A);
						register_A <= (others => '0');
						R_A <= '0';
						R_C <= '1';
					elsif SW9 = '1' then
						register_C <= subtract(register_A, register_C);
						register_A <= (others => '0');
						R_A <= '0';
						R_C <= '1';
					end if;
				end if;
				
				if y = Copy_Data and R_C = '1' then
					register_B <= register_C;
					R_C <= '0';
					
				end if;
			end if;
	end process FSM_Outputs;
	
	device_one : PROCESS(data_ready, data_request, SW0, SW1, SW2, SW3,sW4, SW5, SW6, SW7)
		begin
			if rising_edge(data_ready) and data_request = '1' THEN 
				Qm <= (SW7&SW6&SW5&SW4&SW3&SW2&SW1&SW0);
			end if;	
	END PROCESS device_one;
	
				
	BCD_converter : PROCESS(Register_B)
		VARIABLE bcd : STD_LOGIC_VECTOR (11 DOWNTO 0);
		VARIABLE temp1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
		VARIABLE temp2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
		VARIABLE temp3 : STD_LOGIC_VECTOR(3 DOWNTO 0);
		VARIABLE loop_count :  INTEGER := 0;
		CONSTANT loop_limit : INTEGER := 7;
		CONSTANT shift_limit : INTEGER := 7;
	BEGIN
		
		loop_count := 0;
		bcd := (others => '0');
		

		if to_integer(unsigned(Register_B)) > 9 then
		
		WHILE loop_count <= loop_limit loop
	
			
			for i in 10 DOWNTO 0 loop
				bcd(i + 1) := bcd(i);	
			end loop;
			bcd(0) := Register_B(shift_limit - loop_count);
		
		
			if loop_count < 7 then
			
			temp3 := bcd(3 DOWNTO 0);
			temp3 := add_three(temp3);
			bcd(3 DOWNTO 0) := temp3;
			
			temp2 := bcd(7 DOWNTO 4);
			temp2 := add_three(temp2);
			bcd(7 DOWNTO 4) := temp2;
		
			temp1 := bcd(11 DOWNTO 8);
			temp1 := add_three(temp1);
			bcd(11 DOWNTO 8) := temp1;
			end if;
					
			loop_count := loop_count + 1;
		END LOOP;
		Qs <= bcd(11 DOWNTO 0);
		
		ELSE 
		Qs(3 DOWNTO 0) <= Register_B(3 DOWNTO 0);
		Qs(11 DOWNTO 4) <= (others => '0');
		END IF;
		
	END PROCESS BCD_converter;
	
	

	Light_Control: PROCESS(Qs)	
	BEGIN
--HEX00 - HEX06

			  HEX00 <= not ((not Qs(2) and not Qs(0)) or (Qs(1)) or (Qs(2) and Qs(0)) or (Qs(3)));
			  HEX01 <= not ((not Qs(2)) or (not Qs(1) and not Qs(0)) or (Qs(1) and Qs(0)));
			  HEX02 <= not ((not Qs(1)) or (Qs(0)) or (Qs(2)));
			  HEX03 <= not ((not Qs(2) and not Qs(0)) or (not Qs(2) and Qs(1)) or (Qs(2) and not Qs(1) and Qs(0)) or (Qs(1) and not Qs(0)));
			  HEX04 <= not ((not Qs(2) and not Qs(0)) or (Qs(1) and not Qs(0)));
			  HEX05 <= not ((not Qs(3) and Qs(2) and not Qs(1)) or (not Qs(3) and Qs(2) and not Qs(0)) or (Qs(3) and not Qs(2) and not Qs(1)) or (not Qs(3) and not Qs(1) and not Qs(0)));
			  HEX06 <= not ((not Qs(2) and Qs(1)) or (Qs(2) and not Qs(1)) or (Qs(3)) or (Qs(1) and not Qs(0)));
			  

--HEX10 - HEX16

			  HEX10 <= not ((not Qs(6) and not Qs(4)) or (Qs(5)) or (Qs(6) and Qs(4)) or (Qs(7)));
			  HEX11 <= not ((not Qs(6)) or (not Qs(5) and not Qs(4)) or (Qs(5) and Qs(4)));
			  HEX12 <= not ((not Qs(5)) or (Qs(4)) or (Qs(6)));
			  HEX13 <= not ((not Qs(6) and not Qs(4)) or (not Qs(6) and Qs(5)) or (Qs(6) and not Qs(5) and Qs(4)) or (Qs(5) and not Qs(4)));
			  HEX14 <= not ((not Qs(6) and not Qs(4)) or (Qs(5) and not Qs(4)));
			  HEX15 <= not ((not Qs(7) and Qs(6) and not Qs(5)) or (not Qs(7) and Qs(6) and not Qs(4)) or (Qs(7) and not Qs(6) and not Qs(5)) or (not Qs(7) and not Qs(5) and not Qs(4)));
			  HEX16 <= not ((not Qs(6) and Qs(5)) or (Qs(6) and not Qs(5)) or (Qs(7)) or (Qs(5) and not Qs(4)));
			
--HEX20 - HEX26

  			  HEX20 <= not ((not Qs(10) and not Qs(8)) or (Qs(9)) or (Qs(10) and Qs(8)) or (Qs(11)));
			  HEX21 <= not ((not Qs(10)) or (not Qs(9) and not Qs(8)) or (Qs(9) and Qs(8)));
			  HEX22 <= not ((not Qs(9)) or (Qs(8)) or (Qs(10)));
			  HEX23 <= not ((not Qs(10) and not Qs(8)) or (not Qs(10) and Qs(9)) or (Qs(10) and not Qs(9) and Qs(8)) or (Qs(9) and not Qs(8)));
			  HEX24 <= not ((not Qs(10) and not Qs(8)) or (Qs(9) and not Qs(8)));
			  HEX25 <= not ((not Qs(11) and Qs(10) and not Qs(9)) or (not Qs(11) and Qs(10) and not Qs(8)) or (Qs(11) and not Qs(10) and not Qs(9)) or (not Qs(11) and not Qs(9) and not Qs(8)));
			  HEX26 <= not ((not Qs(10) and Qs(9)) or (Qs(10) and not Qs(9)) or (Qs(11)) or (Qs(9) and not Qs(8)));


--Negative Sign
			  IF SW9 = '1' THEN
					HEX36 <= '0';
					
			  ELSE
					HEX36 <= '1';
			  END IF;

	END PROCESS Light_Control;
END ARCHITECTURE logic;				
				
							
					
					
					
					
					
					
				
			
				
		
		
		
		
		
		
		