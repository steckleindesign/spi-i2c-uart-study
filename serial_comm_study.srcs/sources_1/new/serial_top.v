`timescale 1ns / 1ps

module serial_top(
    // Global clock - 12 MHz
    input  wire CLK,
    // SPI interface
    input  wire SCK,
    input  wire CS,
    input  wire COPI,
    output wire CIPO,
    // PWM Outputs
    output wire PWM_OUT0,
    output wire PWM_OUT1,
    // Debug
    input  wire TEST, // MCU timer output
    output reg  LED0_R,
    output reg  LED0_G,
    output reg  LED0_B,
    // Debugging SPI interface
    output wire [7:0] DEBUG_REG_EXTLED0_DCYCL,
    output wire [7:0] DEBUG_REG_EXTLED0_DCYCH,
    output wire [7:0] DEBUG_REG_EXTLED1_DCYCL,
    output wire [7:0] DEBUG_REG_EXTLED1_DCYCH,
    
    output wire       debug_pingpong,
    output wire       debug_wr_req,
    output wire [6:0] debug_wr_addr,
    output wire [7:0] debug_wr_data
);

    wire       wr_req_w;
    wire       rd_req_w;
    wire [6:0] wr_addr_w;
    wire [6:0] rd_addr_w;
    wire [7:0] wr_data_w;
    wire [7:0] rd_data_w;
    
    // Device Registers
    wire [7:0] reg_extled0_dcycl_w;
    wire [7:0] reg_extled0_dcych_w;
    wire [7:0] reg_extled1_dcycl_w;
    wire [7:0] reg_extled1_dcych_w;
    
    spi_interface    spi0 (.SCK(SCK),
                           .CS(CS),
                           .COPI(COPI),
                           .CIPO(CIPO),
                           .WR_REQ(wr_req_w),
                           .RD_REQ(rd_req_w),
                           .WR_ADDR(wr_addr_w),
                           .RD_ADDR(rd_addr_w),
                           .WR_DATA(wr_data_w),
                           .RD_DATA(rd_data_w),
                           .pingpong(debug_pingpong));
                        
    device_registers reg0 (.CLK(CLK),
                           .WR_REQ(wr_req_w),
                           .RD_REQ(rd_req_w),
                           .WR_ADDR(wr_addr_w),
                           .RD_ADDR(rd_addr_w),
                           .WR_DATA(wr_data_w),
                           .RD_DATA(rd_data_w),
                           .REG_EXTLED0_DCYCL(reg_extled0_dcycl_w),
                           .REG_EXTLED0_DCYCH(reg_extled0_dcych_w),
                           .REG_EXTLED1_DCYCL(reg_extled1_dcycl_w),
                           .REG_EXTLED1_DCYCH(reg_extled1_dcych_w));
    
    pwm              pwm0 (.CLK(CLK),
                           .DUTY_CYCLE_L(reg_extled0_dcycl_w),
                           .DUTY_CYCLE_H(reg_extled0_dcych_w),
                           .PWM_OUT(PWM_OUT0));
                           
    pwm              pwm1 (.CLK(CLK),
                           .DUTY_CYCLE_L(reg_extled1_dcycl_w),
                           .DUTY_CYCLE_H(reg_extled1_dcych_w),
                           .PWM_OUT(PWM_OUT1));
    
    // Debug logic
    always @ (posedge CLK)
    begin
        LED0_B <= TEST;
        LED0_R <= 1'b0;
        LED0_G <= ~TEST;
    end
    
    assign DEBUG_REG_EXTLED0_DCYCL = reg_extled0_dcycl_w;
    assign DEBUG_REG_EXTLED0_DCYCH = reg_extled0_dcych_w;
    assign DEBUG_REG_EXTLED1_DCYCL = reg_extled1_dcycl_w;
    assign DEBUG_REG_EXTLED1_DCYCH = reg_extled1_dcych_w;
    
    assign debug_wr_req  = wr_req_w;
    assign debug_wr_addr = wr_addr_w;
    assign debug_wr_data = wr_data_w;

endmodule
