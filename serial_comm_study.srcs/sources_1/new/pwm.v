`timescale 1ns / 1ps

module pwm
#(
    localparam  [7:0] c_PWM_INC = 8'd180
)(
    input  wire       CLK,        // 12 MHz
    input  wire [7:0] DUTY_CYCLE_L,
    input  wire [7:0] DUTY_CYCLE_H,
    output wire       PWM_OUT
);
    
    reg  [24:0] cnt_r = 1'b0;
    reg  [24:0] pwm_out_r = 1'b0;
    
    wire [15:0] dcyc_w;
    wire [24:0] compare_w;
    
    always @ (posedge CLK)
    begin
        pwm_out_r <= cnt_r == 1'b0 ? 1'b1 : cnt_r == compare_w ? 1'b0 : pwm_out_r;
        cnt_r <= cnt_r == 24'd11999999 ? 1'b0 : cnt_r + 1;
    end
    
    assign dcyc_w  = { DUTY_CYCLE_H, DUTY_CYCLE_L };
    assign compare_w = c_PWM_INC * dcyc_w;
    
    assign PWM_OUT = pwm_out_r;
    
endmodule
