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
    
    // Data for test
    reg  [7:0] addr;
    reg  [7:0] data;
    
    
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
        #4 CLK = ~CLK;
    end
    
    initial
    begin
        CLK  = 1'b0;
        SCK  = 1'b1;
        CS   = 1'b1;
        COPI = 1'b0;
        addr = 8'h00;
        data = 8'h00;
        #100;
        addr = 8'h03;
        data = 8'h78;
        transfer_byte(addr);
        transfer_byte(data);
        #100;
    end
    
    task transfer_byte(input [7:0] byte);
        integer i;
        begin
            CS  = 1'b0;
            #20
            SCK = 1'b0;
            for (i = 7; i >= 0; i = i - 1)
            begin
                SCK  = 1'b0;
                COPI = byte[i];
                #10;
                SCK  = 1'b1;
                #10;
            end
            SCK = 1'b1;
            #10
            CS  = 1'b1;
        end
    endtask
    
endmodule
