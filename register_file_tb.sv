`timescale 1ns/1ps
module register_file_tb;
    localparam int ENTRIES = 12;
    localparam int ADDR_WIDTH = $clog2(ENTRIES);
    localparam int DATA_WIDTH = 32;


    logic system_reg_en;
    logic system_reg_we;
    logic [ADDR_WIDTH - 1 : 0] system_reg_addr;
    logic [DATA_WIDTH - 1 : 0] system_reg_din;
    logic [DATA_WIDTH - 1 : 0] system_reg_dout;

    logic [DATA_WIDTH - 1 : 0] registers [ENTRIES];
    
    register_file #(.ENTRIES(ENTRIES), .DATA_WIDTH(DATA_WIDTH)) dut (
        .system_reg_en(system_reg_en),
        .system_reg_we(system_reg_we),
        .system_reg_addr(system_reg_addr),
        .system_reg_din(system_reg_din),
        .system_reg_dout(system_reg_dout),
        
        .reg_values(registers)
    );

    initial begin
        //system_read
        system_reg_en = 1;
        system_reg_addr = 4'd0;
        #1;

        //system write
        system_reg_we = 1;
        system_reg_din = 32'h00000bee;
        #1;
        system_reg_we = 0;
        system_reg_en = 0;
        system_reg_din = 0;

        //parallel reads
        system_reg_en = 1;
        system_reg_addr = 4'd0;
        #1;

        //write, then read
        system_reg_we = 1;
        system_reg_din = 32'hffffffff;
        #1;
        $finish;
    end

endmodule: register_file_tb