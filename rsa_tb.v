`timescale 1ns / 1ps
///////////////////////////


module tb_rsa_without_timing;
    reg clk, rst;
    reg wren, rden, ds;
    reg [4:0] pt;
    reg [2:0] wraddr, rdaddr, rdaddr1;
    wire [4:0] dataout, pt_org,cipher_text;
    wire e_d, d_d;


    // Instantiate DUT
    rsa dut (clk,rst,pt,wren,rden,wraddr,rdaddr,dataout,pt_org,rdaddr1,e_d,d_d,ds,cipher_text);

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;   // 100MHz clock (10ns period)

    initial begin
        // Init signals
        rst = 1;
        wren = 0; rden = 0; ds = 0;
        pt = 5'd5;             // example plaintext = 15
        wraddr = 3'd0; rdaddr = 3'd0; rdaddr1 = 3'd0;

        // Reset
        #20 rst = 0;

        // ---- Write plaintext into RAM0 ----
        @(posedge clk);
        wren = 1;
        wraddr = 3'd0;          // write address 0
        @(posedge clk);
        wren = 0;
        
        // ---- Read plaintext from RAM0 (starts encryption) ----
        @(posedge clk);
        rden = 1; rdaddr = 3'd0;
        @(posedge clk);
        //rden = 0;

        // Wait for encryption to finish
        //wait (e_d == 1);
        //@(posedge clk);

        // ---- Trigger decryption (read ciphertext from RAM1) ----
        wait(e_d);
        ds = 1; rdaddr1 = 3'd0;
        @(posedge clk);
       // ds = 0;

        // Wait for decryption to finish
        wait (d_d == 1);
        @(posedge clk);

      

      //  $finish;
    end
endmodule
