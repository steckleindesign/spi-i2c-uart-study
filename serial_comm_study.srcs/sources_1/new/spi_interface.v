`timescale 1ns / 1ps

// Reads look ok, need to be careful with writes,
// When data byte is sent, if CS goes high too soon,
// then the data byte might not get to the device register module
// Consider a null byte at the end of a write for now

module spi_interface(
    // SPI lines
    input  wire       SCK,
    input  wire       CS,
    input  wire       COPI,
    output wire       CIPO,
    // Device registers interface
    output wire       WR_REQ,
    output wire       RD_REQ,
    output wire [6:0] WR_ADDR,
    output wire [6:0] RD_ADDR,
    output wire [7:0] WR_DATA,
    input  wire [7:0] RD_DATA
);
        
    // curr bit in transaction, MSB first
    reg  [2:0] curr_bit_r         = 3'd7;
    
    // Register incoming read data before read cycle
    reg        register_rd_data_r = 1'b0;
    
    // Data-In/Out shift register
    // DIN SR is of pingpong fashion, 2 8-bits shift registers
    reg  [7:0] din_sr[1:0];
    reg  [7:0] dout_sr            = 8'b0;
    
    // Addresses of device registers
    // R/W separate so we can implement full duplex later
    reg  [6:0] wr_addr_r          = 7'b0;
    reg  [6:0] rd_addr_r          = 7'b0;
    
    // read and write requests, adds a cycle of latency
    reg        wr_req_r           = 1'b0;
    reg        rd_req_r           = 1'b0;
    
    // Type of byte being transferred
    reg        cmd_byte_r         = 1'b1; // Determines read/write and register address
    reg        null_byte_r        = 1'b0; // 0's
    reg        data_byte_r        = 1'b0; // Write data byte
    reg        rd_byte_r          = 1'b0;
    
    // Side of the pingpong shift register which is being written by MCU
    reg        pp_side_r          = 1'b0;
        
    // R/W request wires tied to R/W internal registers
    assign WR_REQ  = wr_req_r;
    assign RD_REQ  = rd_req_r;
    
    // Address signals to device register module
    assign WR_ADDR = wr_addr_r;
    assign RD_ADDR = rd_addr_r;
    
    // Write data byte sent to device register module
    assign WR_DATA = din_sr[pp_side_r];
    
    // Shift out data on CIPO via 8-bit wide SR
    assign CIPO    = dout_sr[7];
    
    // Falling edge to meet setup/hold time (MCU is controller, FPGA is peripheral)
    always @ (negedge SCK)
    begin        
        // Need to hold incoming data from device registers module
        dout_sr <= register_rd_data_r == 1'b1 ? RD_DATA                :
        // Drive CIPO line via data-out shift register
                            rd_byte_r == 1'b1 ? { dout_sr[6:0], 1'b0 } :
        // CIPO idles low outside of a read cycle
                                                8'b0;
    end
    
    // CS acts as asynchronous reset
    // Need to study implementation closely
    always @ (posedge SCK or posedge CS)
    begin
        if (CS == 1'b1)
        begin
            curr_bit_r  <= 3'b111;
            wr_req_r    <= 1'b0;
            rd_req_r    <= 1'b0;
            din_sr[0]   <= 8'b0;
            din_sr[1]   <= 8'b0;
            cmd_byte_r  <= 1'b1; // First cycle after reset is command byte
            null_byte_r <= 1'b0;
            data_byte_r <= 1'b0;
            rd_byte_r   <= 1'b0;
        end
        else
        begin
            // Default values, can be overwritten
            register_rd_data_r <= 1'b0;
            wr_req_r           <= 1'b0;
            rd_req_r           <= 1'b0;
            
            // Each cycle process COPI bit
            din_sr[pp_side_r] <= { din_sr[pp_side_r][6:0], COPI };
            
            // First bit of byte transfer
            case (curr_bit_r)
                3'd7:
                begin
                    // Reads and writes only execute if R/W request is driven high,
                    // so we can always register both read and write addresses
                    wr_addr_r <= din_sr[pp_side_r][6:0];
                    rd_addr_r <= din_sr[pp_side_r][6:0];
                    // Drive read request signal high right away in a null byte
                    // In this design, null byte only occurs when a read is to occur
                    rd_req_r  <= null_byte_r;
                end
                3'd1:
                    register_rd_data_r <= null_byte_r;
                // Logic during last bit of each byte transfer
                3'd0:
                begin
                    // Default byte states to 0, override if necessary
                    cmd_byte_r  <= 1'b0;
                    null_byte_r <= 1'b0;
                    data_byte_r <= 1'b0;
                    rd_byte_r   <= 1'b0;
                    
                    // After command byte, flip pp write side
                    pp_side_r   <= cmd_byte_r ? pp_side_r : ~pp_side_r;
                    
                    // During last bit of command byte
                    // Check Read/Write bit to determine next byte state
                    null_byte_r <= cmd_byte_r &  din_sr[pp_side_r][6];
                    data_byte_r <= cmd_byte_r & ~din_sr[pp_side_r][6];
                    
                    // Read byte follows null byte
                    rd_byte_r   <= null_byte_r;
                    
                    // At end of data byte, set write request strobe
                    // Wait 1 byte transer duration for write to go through
                    // Allows time to cross clock domains between the register module
                    wr_req_r    <= data_byte_r;
                end
            endcase
            curr_bit_r = curr_bit_r - 1'b1;
        end
    end

endmodule