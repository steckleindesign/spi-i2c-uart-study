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
        sck <= 1'b1;
        #400
        repeat(34) begin
            #20 sck <= ~sck;
        end
    end
    
    // write
    initial begin
        cs   <= 1'b1;
        copi <= 1'b0;
        rd_data <= 8'b0;
        #400
        cs   <= 1'b0;
        #270
        copi <= 1'b1;
        #120
        copi <= 1'b0;
        #40
        copi <= 1'b1;
        #40
        copi <= 1'b0;
        #40
        copi <= 1'b1;
        #40
        copi <= 1'b0;
        #40
        copi <= 1'b1;
        #40
        copi <= 1'b0;
        #60
        cs   <= 1'b1;
    end
    
endmodule
