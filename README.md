# VHDL_Calculator
VHDL Calculator - Boolean Algebra implementation for FPGA control signals
Uses boolean algebra to implement a ripple adder carry circuit to preform calculation on binary numbers.
Two buttons on the FPGA board controlled addition/substraction operations. The button's were debounced and timed to the rising edge of the processor's clock cycle.
Karanaugh Circuit minimization was performed to create efficient digital circuits which controlled the logic behind the LEDs.
Uses a finite state machine to transition between the calculators states of loading data, requesting data, calculating data, copying data, and reseting data.
Implements a double dabble algorithm to preform bitshifting for add/sub operations.

[![Watch the video](https://img.youtube.com/vi/zBZQYhI3wdc/0.jpg)](https://www.youtube.com/watch?v=zBZQYhI3wdc)

