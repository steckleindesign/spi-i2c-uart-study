`timescale 1ns / 1ps

module pwm_tb ();
    
    reg        clk;
    reg  [7:0] duty_cycle_l;
    reg  [7:0] duty_cycle_h;
    wire       pwm_out;
    
    pwm DUT (.CLK(clk),
             .DUTY_CYCLE_L(duty_cycle_l),
             .DUTY_CYCLE_H(duty_cycle_h),
             .PWM_OUT(pwm_out));
             
    initial
    begin
        duty_cycle_l <= 8'd255;
        duty_cycle_h <= 8'd255;
    end
    
    initial begin
        clk <= 1'b0;
        forever begin
            #80 clk <= ~clk;
        end
    end
    
endmodule
