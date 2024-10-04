//////////////////////////////////////////////////////////////////////////////////
// University: Ho Chi Minh university of technology 
// Student: 
// Design Name: Fifo Memory
// Module Name: Memory 
// Project Name: RISC_CPU
// Target Devices: Module Fifo Memory
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
//
module Memory(data_in, data_out, write, read, clk, rst_n, empty, full, overflow, underflow);
//Size of memory and address
parameter DATA_WIDTH = 8;
parameter DEPTH = 32;
parameter ADDRESS_SIZE = 5;

//Port declaration
input[DATA_WIDTH-1:0] data_in;
output[DATA_WIDTH-1:0] data_out;
input write, read, clk, rst_n;
output empty, full, overflow, underflow;

wire[ADDRESS_SIZE-1:0] count;
wire write_en;
//pointer
wire[ADDRESS_SIZE-1:0] write_ptr, read_ptr; 
fifo_write u_fifo_write (.clk(clk), .rst_n(rst_n), .write(write), .count(count), 
                         .write_en(write_en), .write_ptr(write_ptr));
fifo_read u_fifo_read (.clk(clk), .rst_n(rst_n), .read(read),  .count(count), 
                       .read_en(read_en), .read_ptr(read_ptr));
memory_array u_memory_array (.clk(clk), .rst_n(rst_n), .data_in(data_in), .data_out(data_out), .write_en(write_en), .read_en(read_en), 
                             .write_ptr(write_ptr), .read_ptr(read_ptr), .count(count));
fifo_status u_fifo_status (.clk(clk), .rst_n(rst_n), .write(write), .read(read), .count(count), .empty(empty), 
                           .full(full), .overflow(overflow), .underflow(underflow), .read_ptr(read_ptr));
endmodule

module memory_array(clk, rst_n, data_in, data_out, write_en, read_en, write_ptr, read_ptr, count);
input clk, rst_n, write_en, read_en;
input[4:0] write_ptr, read_ptr;
input[7:0] data_in;
output reg[7:0] data_out;
output reg[4:0] count;
reg[7:0] fifo_mem[15:0];
//Write to memory
always @(posedge clk) begin  
    if(write_en)   
        fifo_mem[write_ptr] <=data_in ;  
    else
        fifo_mem[write_ptr] <= fifo_mem[write_ptr];      
end  
//counting
always@(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) 
        count <= 5'b00000;
    else if(write_en)
        count <= count + 1'b1;
    else
        count <= count;
end
//Read from memory
always @(posedge clk) begin
    if(read_en)
        data_out <= fifo_mem[read_ptr];
    else
        data_out <= data_out;
end
endmodule

module fifo_write(clk, rst_n, write, count, write_en, write_ptr);
input clk, rst_n, write; 
input[4:0] count;
output reg[4:0] write_ptr;
output write_en;  
wire full_reg;
assign full_reg = (count == 5'd16);
assign write_en = write & (~full_reg);
always @(posedge clk, negedge rst_n) begin
    if(rst_n==1'b0) 
        write_ptr <= 5'b00000;
    else if(write_en) 
        write_ptr <= write_ptr + 5'b00001;
    else 
        write_ptr <= write_ptr;
end
endmodule

module fifo_read(clk, rst_n, read, count, read_en, read_ptr);
input clk, rst_n, read;
input[4:0] count;
output reg[4:0] read_ptr;
output read_en;  
wire empty_reg;
// FIFO is empty when count is 0
assign empty_reg = (count == 5'd0);
// Read enable is high if read is high, FIFO is not empty, and read pointer is less than count
assign read_en = read && (~empty_reg) && (read_ptr <= count);
// Sequential logic to update the read pointer
always @(posedge clk, negedge rst_n) begin
    if(rst_n==1'b0) 
        read_ptr <= 5'b00000;
    else if(read_en)
        read_ptr <= read_ptr + 5'b00001;
    else
        read_ptr <= read_ptr;
end
endmodule

module fifo_status(clk, rst_n, write, read, count, empty, full, overflow, underflow, read_ptr);
input clk, rst_n, write, read;
input[4:0] count, read_ptr;
output reg empty, full, overflow, underflow;
// Combinational logic for full and empty
always @(count) begin
    full <= (count == 5'd16);
    empty <= (count == 5'd0);    
end
// Sequential logic for overflow
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) overflow <= 0;
    else if (full && write) overflow <= 1;
    else overflow <= overflow;
end 
// Sequential logic for underflow
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) underflow <= 0;
    else if (empty && read) underflow <= 1;
    else if ((read_ptr > count) && read) underflow <= 1;
    else underflow <= underflow;
end 
endmodule

