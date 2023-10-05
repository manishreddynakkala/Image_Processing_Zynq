`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2023 06:43:27
// Design Name: 
// Module Name: conv
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


module conv(
//Inputs
input input_clk,
input [71:0] input_pixel_data,
input input_pixel_data_valid,

//Outputs
output reg [7:0] convoluted_data,
output reg convoluted_data_valid

);
    
//Register definitions and declarations.
integer i;
reg [7:0] kernel [8:0];
reg [15:0] mult_data [8:0];
reg [15:0] sum_data;
reg [15:0] sum_data_int;
reg sum_data_valid;
reg mult_data_valid;

//degfining the mask values-
initial
begin
    for(i=0 ; i<9 ; i= i+1)
    begin
        kernel[i] = 1; //Definnig kernel for blur operation.
    end
end

//Multiplying data with the kernel or mask.
always@(posedge input_clk)
begin
    for(i=0 ; i<9 ; i= i+1)
    begin
        mult_data[i] <= kernel[i]*input_pixel_data[i*8+:8]; //Ouput for multiplication 
    end 
    
    mult_data_valid <= input_pixel_data_valid;
end

//Sum the initial data with that of the multiplied data.
always@(*)
begin
    sum_data_int = 0;
    for(i=0 ; i<9 ; i= i+1)
        begin
           sum_data_int = sum_data_int + mult_data[i]; //Ouput for sum operation. 
        end
end

//Load data into the final output of sum operation.
always@(posedge input_clk)
begin
    sum_data <= sum_data_int;
    sum_data_valid <= mult_data_valid;
end

always@(posedge input_clk)
begin
    convoluted_data <= sum_data / 9;
    convoluted_data_valid <= sum_data_valid; 
end
endmodule
