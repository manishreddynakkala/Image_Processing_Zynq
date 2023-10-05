`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2023 05:50:33
// Design Name: 
// Module Name: Image_processing_Top
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


module Image_processing_Top(

//Inputs

input axi_clk,
input axi_rst_n,

//Slave Interface
input i_data_valid,
input [7:0]i_data,
output o_data_ready,

//Master interface
input i_data_ready,
output o_data_valid,
output [7:0] o_data,

//Interrupts
output o_interrupt
    );
 
 wire [71:0] pixel_data;
 wire pixel_data_valid;
 wire axis_prog_full;
 wire [7:0] convoluted_data;
 wire convoluted_data_valid;
 
 assign o_data_ready = !axis_prog_full;
 
    
Image_control IC (
    
    //Inputs
    .input_clk(axi_clk),
    .input_rst(!axi_rst_n),
    .input_pixel_data(i_data),
    .input_pixel_data_valid(i_data_valid),
    
    //Outputs
    .output_pixel_data(pixel_data),
    .output_pixel_data_valid(pixel_data_valid),
    .o_interrupt(o_interrupt)
    );
 
 conv conv(
    //Inputs
    .input_clk(axi_clk),
    .input_pixel_data(pixel_data),
    .input_pixel_data_valid(pixel_data_valid),
    
    //Outputs
    .convoluted_data(convoluted_data),
    .convoluted_data_valid(convoluted_data_valid)   
    );
    
OutputBuffer OB (
      .s_aclk(axi_clk),                  // input wire s_aclk
      .s_aresetn(axi_rst_n),            // input wire s_aresetn
      .s_axis_tvalid(convoluted_data_valid),    // input wire s_axis_tvalid
      .s_axis_tready(),    // output wire s_axis_tready
      .s_axis_tdata(convoluted_data),      // input wire [7 : 0] s_axis_tdata
      .m_axis_tvalid(o_data_valid),    // output wire m_axis_tvalid
      .m_axis_tready(i_data_ready),    // input wire m_axis_tready
      .m_axis_tdata(o_data),      // output wire [7 : 0] m_axis_tdata
      .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
    );
    
        
endmodule
