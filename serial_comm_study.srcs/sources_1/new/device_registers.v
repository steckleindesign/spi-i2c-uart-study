`timescale 1ns / 1ps

module device_registers
#(
    parameter [6:0] REG_EXTLED0_DCYCL_ADDR = 7'h03,
    parameter [6:0] REG_EXTLED0_DCYCH_ADDR = 7'h1C,
    parameter [6:0] REG_EXTLED1_DCYCL_ADDR = 7'h70,
    parameter [6:0] REG_EXTLED1_DCYCH_ADDR = 7'h79
)(
    // Device register block interface
    input  wire       CLK,
    input  wire       WR_REQ,
    input  wire       RD_REQ,
    input  wire [6:0] WR_ADDR,
    input  wire [6:0] RD_ADDR,
    input  wire [7:0] WR_DATA,
    output wire [7:0] RD_DATA,
    // Debug registers
    output wire [7:0] REG_EXTLED0_DCYCL,
    output wire [7:0] REG_EXTLED0_DCYCH,
    output wire [7:0] REG_EXTLED1_DCYCL,
    output wire [7:0] REG_EXTLED1_DCYCH
);

    // Crossing from SPI clock to Global clock
    // Use 2FF synchronizer to cross domains
    // !! Compare synthesis with shift register HDL !!
    reg wr_req_ff0       = 1'b0;
    reg wr_req_ff1       = 1'b0;
    reg wr_req_ff2       = 1'b0;
    reg rd_req_ff0       = 1'b0;
    reg rd_req_ff1       = 1'b0;
    reg rd_req_ff2       = 1'b0;
    
    // device registers interface signals
    reg       wr_en_r    = 1'b0;
    reg       rd_en_r    = 1'b0;
    reg [6:0] wr_addr_r  = 7'b0;
    reg [6:0] rd_addr_r  = 7'b0;
    reg [7:0] wr_data_r  = 8'b0;
    reg [7:0] rd_data_r  = 8'b0;
    
    // internal debug registers
    reg  [7:0] reg_extled0_dcycl_r = 8'd10;  // Hz
    reg  [7:0] reg_extled0_dcych_r = 8'd128; // (val / 256) * 100% = duty cycle
    reg  [7:0] reg_extled1_dcycl_r = 8'd5;   // Hz
    reg  [7:0] reg_extled1_dcych_r = 8'd196; // (val / 256) * 100% = duty cycle

    // Pass write request signal through 2FF synchronizer
    always @ (posedge CLK)
    begin
        // Generate write enable
        wr_en_r <= 1'b0;
        if (wr_req_ff2 == 1'b1 && wr_req_ff1 == 1'b0)
        begin
            wr_addr_r <= WR_ADDR;
            wr_data_r <= WR_DATA;
            wr_en_r   <= 1'b1;
        end
        wr_req_ff2 <= wr_req_ff1;
        wr_req_ff1 <= wr_req_ff0;
        wr_req_ff0 <= WR_REQ;
        
        // Generate read enable
        rd_en_r <= 1'b0;
        if (rd_req_ff2 == 1'b1 && rd_req_ff1 == 1'b0)
        begin
            rd_addr_r <= RD_ADDR;
            rd_en_r   <= 1'b1;
        end
        rd_req_ff2 <= rd_req_ff1;
        rd_req_ff1 <= rd_req_ff0;
        rd_req_ff0 <= RD_REQ;
    end

    // Register writes
    always @ (posedge CLK)
    begin
        if (wr_en_r == 1'b1)
        begin
            case (wr_addr_r)
                REG_EXTLED0_DCYCL_ADDR : reg_extled0_dcycl_r <= wr_data_r;
                REG_EXTLED0_DCYCH_ADDR : reg_extled0_dcych_r <= wr_data_r;
                REG_EXTLED1_DCYCL_ADDR : reg_extled1_dcycl_r <= wr_data_r;
                REG_EXTLED1_DCYCH_ADDR : reg_extled1_dcych_r <= wr_data_r;
            endcase
        end
    end
    
    // Register reads
    always @ (posedge CLK)
    begin
        if (rd_en_r == 1'b1)
        begin
            case (rd_addr_r)
                REG_EXTLED0_DCYCL_ADDR : rd_data_r <= reg_extled0_dcycl_r;
                REG_EXTLED0_DCYCH_ADDR : rd_data_r <= reg_extled0_dcych_r;
                REG_EXTLED1_DCYCL_ADDR : rd_data_r <= reg_extled1_dcycl_r;
                REG_EXTLED1_DCYCH_ADDR : rd_data_r <= reg_extled1_dcych_r;
            endcase
        end
    end
    // Read data connected to internal read data register
    assign RD_DATA     = rd_data_r;
    
    // Debug registers output to other modules
    assign REG_EXTLED0_DCYCL = reg_extled0_dcycl_r;
    assign REG_EXTLED0_DCYCH = reg_extled0_dcych_r;
    assign REG_EXTLED1_DCYCL = reg_extled1_dcycl_r;
    assign REG_EXTLED1_DCYCH = reg_extled1_dcych_r;
    
endmodule
