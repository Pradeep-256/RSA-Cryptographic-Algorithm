`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 6.09.2025 21:43:26
// Design Name: 
// Module Name: rsa_without_timing
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

//module rsa(clk_o,clk,rst,pt,wren,rden,wraddr,rdaddr,rdaddr1,e_d,d_d,ds,HEX7,HEX6,HEX5,HEX4,HEX3,HEX2);
//input clk_o;
//input rst,wren,rden,ds;
//input [4:0]pt;
//input [2:0]wraddr;
//input [2:0]rdaddr;
//input [2:0]rdaddr1;
//wire [5:0]dataout;
//wire [5:0]pt_org;
//wire [5:0]cipher_text;
//output e_d,d_d,clk;
//output [6:0]HEX7;//plain_text_tens
//output [6:0]HEX6;//plain_text_ones
//output [6:0]HEX5;//cipher_text_tens
//output [6:0]HEX4;//cipher_text_ones
//output [6:0]HEX3;//plaint_text_org_tens
//output [6:0]HEX2;//plaintext_org_ones

//reg [25:0]count;

//rsa_without_timing r1(clk,rst,pt,wren,rden,wraddr,rdaddr,dataout,pt_org,rdaddr1,e_d,d_d,ds,cipher_text);

//always @ (posedge clk_o)
//count<=count+1;

//assign clk=count[25];

//wire [3:0]dataout_ones;
//wire [3:0]pt_org_ones;
//wire [3:0]cipher_text_ones;
//wire [3:0]dataout_tens;
//wire [3:0]pt_org_tens;
//wire [3:0]cipher_text_tens;

//assign dataout_tens=dataout/4'd10;
//assign dataout_ones=dataout%4'd10;

//assign cipher_text_tens=cipher_text/4'd10;
//assign cipher_text_ones=cipher_text%4'd10;

//assign pt_org_tens=pt_org/4'd10;
//assign pt_org_ones=pt_org%4'd10;

//segment7 s1(dataout_tens,HEX7);
//segment7 s2(dataout_ones,HEX6);
//segment7 s3(cipher_text_tens,HEX5);
//segment7 s4(cipher_text_ones,HEX4);
//segment7 s5(pt_org_tens,HEX3);
//segment7 s6(pt_org_ones,HEX2);

//endmodule

module rsa(clk,rst,pt,wren,rden,wraddr,rdaddr,dataout,pt_org,rdaddr1,e_d,d_d,ds,cipher_text );
input clk;
input rst                                                                                                                                                                                                                     ,wren,rden,ds;
input [4:0]pt;
input [2:0]wraddr;
input [2:0]rdaddr;
input [2:0]rdaddr1;
output [5:0]dataout;
output [5:0]pt_org;
output [5:0]cipher_text;
wire [2:0]count,dcount;
output e_d,d_d;
wire [63:0]dr1,y,r1,r2;
wire  [5:0]ct_out;
dual_port_ram m1(clk,rst,pt,wraddr,wren,rdaddr,rden,dataout);
encryption e1(clk,!rden,dataout,e_d,cipher_text,r1,y,r2,count);
dual_port_ram m2(clk,rst,cipher_text,rdaddr,e_d,rdaddr1,ds,ct_out);
decryption d1(clk,!ds,ct_out,d_d,pt_org,dcount,dr1);

endmodule

module encryption(clk,rst,a,d,cipher_text,r1,y,r2,count);
input clk,rst;
input [4:0]a;
reg [2:0]b=3'd7;
output reg d;
output reg [2:0]count;
output reg [63:0]r1,y,r2;//,product;
output [4:0]cipher_text;
always @ (posedge clk)
if(rst==1)
begin
count<=0;
r1<=1;
end
else
begin
if(count<b)
begin
r1<=r1*a;
count<=count+1;
end
else
begin
r1<=1;
count<=count+1;
end
end

always @(posedge clk)
r2<=r1;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        d <= 0;
        y<=0;
    end else begin
        if (count == 3'd7) begin
            y<=r1;
            d <= 1;
        end else begin
            d <= 0;
            y<=y;
            // z holds its previous value
        end
    end
end

assign cipher_text=y%6'd33;
endmodule

module decryption(clk,rst,a,d,pt_org,count,r1);
input clk,rst;
input [4:0]a;
reg [2:0]b=3'd3;
reg[63:0]y;
output [5:0]pt_org;
output reg d;
//y=a^b;
 output reg [1:0]count;
output reg [63:0]r1;

always @ (posedge clk)
if(rst==1)
begin
count<=0;
r1<=1;
end
else
begin
if(count<b)
begin
r1<=r1*a;
count<=count+1;
end
else
begin
r1<=1;
count<=count+1;
end
end

reg [63:0]r2;
always @ (posedge clk)
r2<=r1;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        d <= 0;
        y<=0;
    end else begin
        if (count == 3'd3) begin
            d <= 1;
            y<=r1;
        end else begin
            d <= 0;
            y<=y;
        end
    end
end
assign pt_org=y%6'd33;
endmodule


module dual_port_ram(clk, rst, datain, wraddr, wren, rdaddr, rden, dataout);
 parameter ram_width = 8;
 parameter ram_depth = 8;
 parameter address_size =3;

input clk,rst,wren,rden;
input [ram_width-1:0]datain;
input [address_size-1:0]wraddr,rdaddr;
output reg [ram_width-1:0]dataout;

reg [ram_width-1:0]mem [ram_depth-1:0];

always @ (posedge clk)
if(rst)
mem[wraddr]<=8'h0;
else if(wren)
mem[wraddr]<=datain;
else
mem[wraddr]<=mem[wraddr];

always @(posedge clk)
if(rst)
 dataout<=8'h0;
else if(rden)
 dataout<=mem[rdaddr];
else
 dataout<=dataout;

endmodule

