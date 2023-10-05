`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2023 06:27:16
// Design Name: 
// Module Name: tb
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

//define  headersize 1080
//define  imagesize 512*512    //Defined later on as integers. Caused problems during simulation.

module tb(
    );
    
reg clk;
reg reset;
reg [7:0] img_data;
reg img_data_valid;

wire intr;
wire [7:0] out_data;
wire out_data_valid;

integer  headersize = 1080;
integer  imagesize = 512*512;

integer i;
integer file, file1;
//integer fileid;
integer send_size;
integer recieved_data;
 //Square wave with a time period of ten ns.
 
 initial
 begin
    clk = 1'b0;
    forever
    begin
        #5 clk = ~clk;
    end
 end

initial
begin
    reset = 0;
	send_size = 0;
    img_data_valid = 0;
    //recieved_data = 0;
    #100;
    reset = 1;
    #100;
    
    file = $fopen("lena_gray.bmp" , "rb");
    //$fread(file , fileid); //Trying to read the file using it's id.
    file1 = $fopen("blurred_lena.bmp" , "wb");
    
    for(i=0 ; i < headersize ; i = i +1)
    begin
        $fscanf(file , "%c" , img_data);
        $fwrite(file1 , "%c" , img_data);
    end
    
    for(i=0 ; i < 4*512 ; i = i+1)
    begin
        @(posedge clk);
        $fscanf(file , "%c" , img_data);
        img_data_valid <= 1'b1;
    end
    send_size = 4*512;
    @(posedge clk);
    img_data_valid <= 1'b0;
    
    while(send_size < imagesize)
    begin
        @(posedge intr);
            for(i=0 ; i < 512 ; i = i+1)
            begin
                @(posedge clk);
                $fscanf(file , "%c" , img_data);
                img_data_valid <= 1'b1;                
            end
            @(posedge clk);
            img_data_valid <= 1'b0;
            send_size = send_size + 512;
    end
    
    @(posedge clk);
    img_data_valid <= 1'b0;
    @(posedge intr);
    for(i=0 ; i < 512 ; i = i+1)
    begin
        @(posedge clk)
        img_data <= 0;
        img_data_valid <= 1'b1;                             
    end
    @(posedge clk);
    img_data_valid <= 1'b0;
    @(posedge intr);
    for(i=0 ; i < 512 ; i = i+1)
    begin
        @(posedge clk);
        img_data <= 0;
        img_data_valid <= 1'b1;                
    end
    @(posedge clk);
    img_data_valid <= 1'b0;
    $fclose(file);
end

always@(posedge clk)
begin
    recieved_data = 0;
    if(out_data_valid)
    begin
        $fwrite(file1 , "%c" , out_data);
        recieved_data <= recieved_data + 1; //Edit has been made here... Giving a continuous assignment inside the loop.
    end
    if(recieved_data == imagesize)
    begin
        $fclose(file1);
        $stop;
    end
    
end



Image_processing_Top DUT(
    
    //Inputs
    
    .axi_clk(clk),
    .axi_rst_n(reset),
    
    //Slave Interface
    .i_data_valid(img_data_valid),
    .i_data(img_data),
    .o_data_ready(),
    
    //Master interface
    .i_data_ready(1'b1),
    .o_data_valid(out_data_valid),
    .o_data(out_data),
    
    //Interrupts
    .o_interrupt(intr)
        
    );
        
        
        
endmodule
