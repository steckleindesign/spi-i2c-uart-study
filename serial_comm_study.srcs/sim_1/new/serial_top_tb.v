`timescale 1ns / 1ps

module serial_top_tb();

    reg        CLK;
    
    reg        SCK;
    reg        CS;
    reg        COPI;
    
    wire       CIPO;
    
    wire       PWM_OUT0, PWM_OUT1;
    
    wire       LED0_R, LED0_G, LED0_B;
                           
    wire [7:0] DEBUG_REG_EXTLED0_DCYCL;
    wire [7:0] DEBUG_REG_EXTLED0_DCYCH;
    wire [7:0] DEBUG_REG_EXTLED1_DCYCL;
    wire [7:0] DEBUG_REG_EXTLED1_DCYCH;
    
    serial_top UUT (.CLK(CLK),
                    .SCK(SCK),
                    .CS(CS),
                    .COPI(COPI),
                    .CIPO(CIPO),
                    .PWM_OUT0(PWM_OUT0),
                    .PWM_OUT1(PWM_OUT1),
                    .LED0_R(LED0_R),
                    .LED0_G(LED0_G),
                    .LED0_B(LED0_B),
                    .DEBUG_REG_EXTLED0_DCYCL(DEBUG_REG_EXTLED0_DCYCL),
                    .DEBUG_REG_EXTLED0_DCYCH(DEBUG_REG_EXTLED0_DCYCH),
                    .DEBUG_REG_EXTLED1_DCYCL(DEBUG_REG_EXTLED1_DCYCL),
                    .DEBUG_REG_EXTLED1_DCYCH(DEBUG_REG_EXTLED1_DCYCH));
                    
    always
    begin
        CLK = 1'b0;
        #4;
        CLK = 1'b1;
        #4;
    end
    
    initial
    begin
        SCK  = 1'b1;
        CS   = 1'b1;
        COPI = 1'b0;
        #10;
        CS   = 1'b0;
        #20;
        SCK  = 1'b0;
        COPI = 1'b0;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b0;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b0;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b0;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b0;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b0;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b1;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b1;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b0;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b1;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b0;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b1;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b0;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b1;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b0;
        #10;
        SCK  = 1'b1;
        #10;
        SCK  = 1'b0;
        COPI = 1'b1;
        #10;
        SCK  = 1'b1;
        #10
        COPI = 1'b0;
        #10
        CS   = 1'b1;
        #100;
    end
    
endmodule
