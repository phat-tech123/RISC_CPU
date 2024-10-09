module Memory(data_in, data_out, write, read, clk, rst);
//Size of memory and address
parameter DATA_WIDTH = 8;
parameter DEPTH = 32;
parameter ADDRESS_SIZE = 5;

//Port declaration
input[DATA_WIDTH-1:0] data_in;
output[DATA_WIDTH-1:0] data_out;
input write, read, clk, rst_n;
endmodule

