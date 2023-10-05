`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.08.2023 12:26:43
// Design Name: 
// Module Name: Line_Buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Line_Buffer(
//Inputs
input input_clk,
input input_rst,
input [7:0] input_data,
input input_data_valid,
input input_rd_data,

//Outputs
output [23:0] output_data //the entire convolution is flattened.
);

reg [7:0] line [511:0]; // Line buffer where the data is stored.
//512 represents the number of bits for the convolution (3x3 matrix).

reg [8:0] write_pointer; // the length is the depth of the memory of the line buffer.
reg [8:0] read_pointer; // the length is the depth of the memory of the line buffer.
//Since we're taking a 3x3 matrix, the number of lements is 9, hence 9 bits for the pointers.

always @(posedge input_clk)
begin
    if (input_data_valid)
        line[write_pointer] <= input_data;
end

//Setting the write pointer value.
always @(posedge input_clk)
begin
    if (input_rst)
        write_pointer <= 'd0;
    else if (input_data_valid)
        write_pointer <= write_pointer + 1;
end

//Produce output values-

assign output_data = {line[read_pointer],line[read_pointer+1],line[read_pointer+2]}; //Concatenating the three points in one line.
//Provides for zero latency.

//Setting the read pointer value.
always @(posedge input_clk)
begin
    if (input_rst)
        read_pointer <= 'd0;
    else if (input_rd_data)
        read_pointer <= read_pointer + 'd1;
end

endmodule
