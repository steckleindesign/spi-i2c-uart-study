`timescale 1ns / 1ps

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
    // DIN SR is pp
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
    reg        cmd_byte_r         = 1'b1;
    reg        null_byte_r        = 1'b0;
    reg        data_byte_r        = 1'b0;
    reg        rd_byte_r          = 1'b0;
    
    // PP buffer write side
    reg        pp_side_r          = 1'b0;
        
    // R/W request wires tied to R/W internal registers
    assign WR_REQ    = wr_req_r;
    assign RD_REQ    = rd_req_r;
    
    // Connect device register addr inputs to internal addr registers
    assign WR_ADDR   = wr_addr_r;
    assign RD_ADDR   = rd_addr_r;
    
    // Connect device register data line input to internal data reg
    assign WR_DATA   = din_sr[~pp_side_r];
    
    // Shift out data on CIPO via 8-bit wide SR
    assign CIPO      = dout_sr[7];
    
    // Falling edge to meet setup/hold time
    always @ (negedge SCK)
    begin
        // Need to register incoming data from device registers
        // Drive CIPO line via data-out shift register
        // CIPO idles low outside of a read cycle
        dout_sr <= register_rd_data_r == 1'b1 ? RD_DATA                :
                            rd_byte_r == 1'b1 ? { dout_sr[6:0], 1'b0 } :
                                                8'b0;
    end
    
    always @ (posedge SCK or posedge CS)
    begin
        if (CS == 1'b1)
        begin
            curr_bit_r   <= 3'b111;
            wr_req_r     <= 1'b0;
            rd_req_r     <= 1'b0;
            din_sr[0]    <= 8'b0;
            din_sr[1]    <= 8'b0;
            // First cycle after reset is command byte
            cmd_byte_r   <= 1'b1;
            null_byte_r  <= 1'b0;
            data_byte_r  <= 1'b0;
            rd_byte_r    <= 1'b0;
        end
        else
        begin
            // Default values, can be overwritten
            register_rd_data_r      <= 1'b0;
            wr_req_r                <= 1'b0;
            rd_req_r                <= 1'b0;
            
            // Each cycle process COPI bit
            din_sr[pp_side_r] <= { din_sr[pp_side_r][6:0], COPI };
            
            // Logic during first bit of each byte transfer
            case (curr_bit_r)
                3'd7:
                begin
                    // We can always register both read and write addresses
                    // Reads and writes only execute if R/W request is driven high
                    wr_addr_r <= din_sr[pp_side_r][6:0];
                    rd_addr_r <= din_sr[pp_side_r][6:0];
                    // Drive read request signal high right after command byte
                    rd_req_r  <= null_byte_r;
                end
                3'd1:
                    register_rd_data_r <= null_byte_r;
                // Logic during last bit of each byte transfer
                3'd0:
                begin
                    // Default byte states to 0, override if necessary
                    cmd_byte_r      <= 1'b0;
                    null_byte_r     <= 1'b0;
                    data_byte_r     <= 1'b0;
                    rd_byte_r       <= 1'b0;
                    
                    // After command byte, flip pp write side
                    pp_side_r <= cmd_byte_r == 1'b1 ? pp_side_r : ~pp_side_r;
                    
                    // During last bit of command byte
                    // Check Read/Write bit to determine next byte state
                    null_byte_r     <= cmd_byte_r &  din_sr[pp_side_r][6];
                    data_byte_r     <= cmd_byte_r & ~din_sr[pp_side_r][6];
                    
                    // Read byte follows null byte
                    rd_byte_r       <= null_byte_r;
                    
                    // At end of data byte, set write request strobe
                    // Wait 1 byte transer duration for write to go through
                    // Allows time to cross clock domains between the register module
                    wr_req_r        <= data_byte_r;
                end
            endcase
            curr_bit_r = curr_bit_r - 1'b1;
        end
    end

endmodule