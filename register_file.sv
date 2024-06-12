module register_file #(
    //I believe that the shell supports 4096 addresses for the 322mhz box 
    parameter int ENTRIES = 12,
    parameter int DATA_WIDTH =  32
) (
    //axi_lite_register interface (between system configuration)
    input wire system_reg_en,
    input wire system_reg_we,
    input wire [$clog2(ENTRIES) - 1 : 0] system_reg_addr,
    input wire [DATA_WIDTH - 1 : 0] system_reg_din,
    output logic [DATA_WIDTH - 1 : 0] system_reg_dout,

    output logic [DATA_WIDTH - 1 : 0] reg_values [ENTRIES]    
);
    /**
    TODO:
     - An initial block here that reads from a file (readmemb/h) to initialize
    the contents of the registers. Use a module parameter for the path to the
    file?
    **/
    initial begin
        for(int i = 0; i < ENTRIES; i++) begin
            reg_values[i] = 0;
        end        
    end

    always_comb begin
        if(~system_reg_en && system_reg_we) begin
            //write
            reg_values[system_reg_addr] = system_reg_din;
        end
        else if(system_reg_en && ~system_reg_we) begin
            //system register read
            system_reg_dout = reg_values[system_reg_addr];
        end
        else if(system_reg_en && system_reg_we) begin
            //write, read
            reg_values[system_reg_addr] = system_reg_din;
            system_reg_dout = reg_values[system_reg_addr];
        end
        else begin
            system_reg_dout = 0;
        end
    end
endmodule: register_file