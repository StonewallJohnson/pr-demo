interface axil ();
    logic awvalid;
    logic [31:0] awaddr;
    logic awready;
    logic wvalid;
    logic [31:0] wdata;
    logic wlast;
    logic wready;
    logic bvalid;
    logic [1:0] bresp;
    logic bready;
    logic arvalid;
    logic [31:0] araddr;
    logic arready;
    logic rvalid;
    logic [31:0] rdata;
    logic [1:0] rresp;
    logic rready;

    modport s (
        input awvalid,
        input awaddr,
        output awready,
        input wvalid,
        input wdata,
        input wlast,
        output wready,
        output bvalid,
        output bresp,
        input bready,
        input arvalid,
        input araddr,
        output arready,
        output rvalid,
        output rdata,
        output rresp,
        input rready
    );

    modport m (
        output awvalid,
        output awaddr,
        input awready, 
        output wvalid,
        output wdata,
        output wlast,
        input wready, 
        input bvalid, 
        input bresp, 
        output bready,
        output arvalid,
        output araddr,
        input arready, 
        input rvalid, 
        input rdata, 
        input rresp, 
        output rready
    );
endinterface

interface axis #(parameter int NUM_CMAC_PORT = 1) ();
    logic [NUM_CMAC_PORT-1:0] tvalid;
    logic [512*NUM_CMAC_PORT-1:0] tdata;
    logic [64*NUM_CMAC_PORT-1:0] tkeep;
    logic [NUM_CMAC_PORT-1:0] tlast;
    logic [NUM_CMAC_PORT-1:0] tuser_err;
    logic [NUM_CMAC_PORT-1:0] tready;

    modport s (
        input tvalid,
        input tdata,
        input tkeep,
        input tlast,
        input tuser_err,
        output tready
    );

    modport m (
        output tvalid,
        output tdata,
        output tkeep,
        output tlast,
        output tuser_err,
        input tready
    );
endinterface