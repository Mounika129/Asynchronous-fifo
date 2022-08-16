`timescale 1ns / 1ps


module asy_fifo(data_out, write_full, read_empty,
rd_clk, wr_clk, rst);

parameter WIDTH = 8;
parameter POINTER = 4;
output [WIDTH-1 : 0] data_out;
output write_full;
output read_empty;
wire [WIDTH-1 : 0] data_in;
input rd_clk, wr_clk;
input rst;

reg [POINTER : 0] read_pointer, read_sync_1, read_sync_2;
reg [POINTER : 0] write_pointer, write_sync_1, write_sync_2;
wire [POINTER:0] rd_pt_g,wr_pt_g;

parameter DEPTH = 1 << POINTER;

reg [WIDTH-1 : 0] mem [DEPTH-1 : 0];

wire [POINTER : 0] read_pointer_sync;
wire [POINTER: 0] write_pointer_sync;
reg full,empty;
reg [7:0] tr_ptr;

//--write logic--//

always @(posedge wr_clk or posedge rst) begin
if (rst) begin
write_pointer <= 0;
tr_ptr<=0;
end
else if (full == 1'b0) begin
write_pointer <= write_pointer + 1;
tr_ptr<=tr_ptr+1;
mem[write_pointer[POINTER-1 : 0]] <= data_in;
end
end

send s(tr_ptr,data_in);

//--read pointer synchronizer controled by write clock--//

always @(posedge wr_clk) begin
read_sync_1 <= rd_pt_g;
read_sync_2 <= read_sync_1;
end

//--read logic--//

always @(posedge rd_clk or posedge rst) begin
if (rst) begin
read_pointer <= 0;
end
else if (empty == 1'b0) begin
read_pointer <= read_pointer + 1;
end
end

//--write pointer synchronizer controled by read clock--//

always @(posedge rd_clk) begin
write_sync_1 <= wr_pt_g;
write_sync_2 <= write_sync_1;
end

//--Combinational logic--//
//--Binary pointer--//

always @(*)
begin
if({~write_pointer[POINTER],write_pointer[POINTER-1:0]}==read_pointer_sync)
full = 1;
else
full = 0;
end


always @(*)
begin
if(write_pointer_sync==read_pointer)
empty = 1;
else
empty = 0;
end

assign data_out = mem[read_pointer[POINTER-1 : 0]];


//--binary code to gray code--//

assign wr_pt_g = write_pointer ^ (write_pointer >> 1);
assign rd_pt_g = read_pointer ^ (read_pointer >> 1);

//--gray code to binary code--//

assign write_pointer_sync[4]=write_sync_2[4];
assign write_pointer_sync[3]=write_sync_2[3] ^ write_pointer_sync[4];
assign write_pointer_sync[2]=write_sync_2[2] ^ write_pointer_sync[3];
assign write_pointer_sync[1]=write_sync_2[1] ^ write_pointer_sync[2];
assign write_pointer_sync[0]=write_sync_2[0] ^ write_pointer_sync[1];


assign read_pointer_sync[4]=read_sync_2[4];
assign read_pointer_sync[3]=read_sync_2[3] ^ read_pointer_sync[4];
assign read_pointer_sync[2]=read_sync_2[2] ^ read_pointer_sync[3];
assign read_pointer_sync[1]=read_sync_2[1] ^ read_pointer_sync[2];
assign read_pointer_sync[0]=read_sync_2[0] ^ read_pointer_sync[1];

assign write_full = full;
assign read_empty = empty;

endmodule

module send(wr_ptr,data_out);

output [7:0] data_out;
input [7:0] wr_ptr;
reg [7:0] input_rom [127:0];
integer i;
initial begin

for(i=0;i<128;i=i+1)
input_rom[i] = i+10;
end

assign data_out = input_rom[wr_ptr];

endmodule






