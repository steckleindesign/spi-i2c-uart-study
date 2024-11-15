`timescale 1ns / 1ps

module spi_interface_tb ();
    // inputs
    reg        sck;
    reg        cs;
    reg        copi;
    reg  [7:0] rd_data;
    // outputs
    wire       cipo;
    wire       wr_req;
    wire       rd_req;
    wire [6:0] wr_addr;
    wire [6:0] rd_addr;
    wire [7:0] wr_data;
    
    // Data for test
    reg  [7:0] addr;
    reg  [7:0] data;

    spi_interface DUT (.SCK(sck),
                       .CS(cs),
                       .COPI(copi),
                       .CIPO(cipo),
                       .WR_REQ(wr_req),
                       .RD_REQ(rd_req),
                       .WR_ADDR(wr_addr),
                       .RD_ADDR(rd_addr),
                       .WR_DATA(wr_data),
                       .RD_DATA(rd_data));
                       
    // SPI clk
    initial begin
        cs      = 1'b1;
        sck     = 1'b1;
        copi    = 1'b0;
        rd_data = 8'b0; // not used here, comes from register module
        #50;
        addr = 8'h70 | 8'h80; // 0x80 sets bit 7 to 1, for a read operation
        data = 8'h0;
        transfer_byte(addr, 1, 0); // Command byte
        transfer_byte(data, 0, 0); // Null byte, send 0's, receive 0's
        transfer_byte(data, 0, 1); // Read byte, send 0's, receive read data
        #50;
        
    end
    
    task transfer_byte(input [7:0] byte, input integer first, last);
        integer i;
        begin
            if (first)
            begin
                cs  = 1'b0;
                #20;
            end
            sck = 1'b0;
            for (i = 7; i >= 0; i = i - 1)
            begin
                sck  = 1'b0;
                copi = byte[i];
                #10;
                sck  = 1'b1;
                #10;
            end
            if (last)
            begin
                sck = 1'b1;
                #10
                cs  = 1'b1;
            end
        end
    endtask
    
endmodule
