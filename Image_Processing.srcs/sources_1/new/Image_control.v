`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2023 07:47:05
// Design Name: 
// Module Name: Image_control
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


module Image_control(

//Inputs
input input_clk,
input input_rst,
input [7:0] input_pixel_data,
input input_pixel_data_valid,

//Outputs
output reg [71:0] output_pixel_data,
output output_pixel_data_valid,
output reg o_interrupt
);

//Registers
reg [8:0] pixel_counter;
reg [1:0] currentwrlinebuffer;
reg [3:0] linebufferdatavalid;
reg [1:0] currentrdlinebuffer;
reg [3:0] linebufferreaddata;
reg [8:0] read_counter;
reg rd_line_buffer;
reg [11:0] total_pixel_counter;
reg rdstate;

wire [23:0] lb0data;
wire [23:0] lb1data;
wire [23:0] lb2data;
wire [23:0] lb3data;

localparam IDLE = 'b0;
localparam RD_BUFFER = 'b1;

assign output_pixel_data_valid = rd_line_buffer; //Had a typo...Need to check if this is the reason..


always@(posedge input_clk)
begin
    if(input_rst)
        total_pixel_counter <= 0;
    else
    begin
        if(input_pixel_data_valid & !rd_line_buffer)
            total_pixel_counter <= total_pixel_counter + 1;
        else if (!input_pixel_data_valid & rd_line_buffer)
            total_pixel_counter <= total_pixel_counter - 1;
    end
end

always@(posedge input_clk)
begin
    if(input_rst)
    begin
        rdstate <= IDLE;
        rd_line_buffer <= 1'b0;
        o_interrupt <= 1'b0; //Interrupt generator for a free line buffer.
    end
    else
    begin
    case(rdstate)
        IDLE:begin
            o_interrupt <= 1'b0; //Interrupt generator for a free line buffer.
            if(total_pixel_counter >= 1536)
            begin
                rd_line_buffer <= 1'b1;
                rdstate <= RD_BUFFER;
            end
        end
        RD_BUFFER:begin
            if(read_counter == 511)
            begin
                rdstate <= IDLE;
                rd_line_buffer <= 1'b0;
                o_interrupt <= 1'b1; //Interrupt generator for a free line buffer.
            end
        end
     endcase
    end
end
always@(posedge input_clk)
begin
    if(input_rst)
    pixel_counter <= 0;
    else
    begin
        if(input_pixel_data_valid)
            pixel_counter <= pixel_counter + 1;
    end
end

always@(posedge input_clk)
begin
    if(input_rst)
    currentwrlinebuffer <= 0;
    else
    begin
        if(pixel_counter == 511 & input_pixel_data_valid)
        begin
            currentwrlinebuffer <= currentwrlinebuffer + 1;
        end
    end
end

always@(*)
begin
    linebufferdatavalid = 4'h0;
    linebufferdatavalid[currentwrlinebuffer] = input_pixel_data_valid;
end

always@(posedge input_clk)
begin
    if(input_rst)
        read_counter <= 0;
    else
    begin
        if (rd_line_buffer)
            read_counter <= read_counter + 1;
    end
end

always@(posedge input_clk)
begin
    if(input_rst)
    begin
        currentrdlinebuffer <= 0;
    end
    else
    begin
    if(read_counter == 511 & rd_line_buffer)
            begin
                currentrdlinebuffer <= currentrdlinebuffer + 1;
            end
    end
end




always@(*)
begin
    case(currentrdlinebuffer)
    0:begin
        output_pixel_data = {lb2data,lb1data,lb0data};  
      end
    1:begin
        output_pixel_data = {lb3data,lb2data,lb1data};  
        end
    2:begin
        output_pixel_data = {lb0data,lb3data,lb2data};  
        end
    3:begin
        output_pixel_data = {lb1data,lb0data,lb3data};  
        end
    endcase
end

always@(*)
begin
    case(currentrdlinebuffer)
    
    0:begin
        linebufferreaddata[0] = rd_line_buffer;
        linebufferreaddata[1] = rd_line_buffer;
        linebufferreaddata[2] = rd_line_buffer;
        linebufferreaddata[3] = 1'b0;    
    end
    1:begin
        linebufferreaddata[0] = 1'b0;
        linebufferreaddata[1] = rd_line_buffer;
        linebufferreaddata[2] = rd_line_buffer;
        linebufferreaddata[3] = rd_line_buffer;    
    end
    2:begin
        linebufferreaddata[0] = rd_line_buffer;
        linebufferreaddata[1] = 1'b0;
        linebufferreaddata[2] = rd_line_buffer;
        linebufferreaddata[3] = rd_line_buffer;    
    end
    3:begin
        linebufferreaddata[0] = rd_line_buffer;
        linebufferreaddata[1] = rd_line_buffer;
        linebufferreaddata[2] = 1'b0;
        linebufferreaddata[3] = rd_line_buffer;    
    end
    endcase
end


Line_Buffer lb0(
.input_clk(input_clk),
.input_rst(input_rst),
.input_data(input_pixel_data),
.input_data_valid(linebufferdatavalid[0]),
.input_rd_data(linebufferreaddata[0]),
.output_data(lb0data)
);
Line_Buffer lb1(
.input_clk(input_clk),
.input_rst(input_rst),
.input_data(input_pixel_data),
.input_data_valid(linebufferdatavalid[1]),
.input_rd_data(linebufferreaddata[1]),
.output_data(lb1data)
);
Line_Buffer lb2(
.input_clk(input_clk),
.input_rst(input_rst),
.input_data(input_pixel_data),
.input_data_valid(linebufferdatavalid[2]),
.input_rd_data(linebufferreaddata[2]),
.output_data(lb2data)
);
Line_Buffer lb3(
.input_clk(input_clk),
.input_rst(input_rst),
.input_data(input_pixel_data),
.input_data_valid(linebufferdatavalid[3]),
.input_rd_data(linebufferreaddata[3]),
.output_data(lb3data)
);
endmodule
