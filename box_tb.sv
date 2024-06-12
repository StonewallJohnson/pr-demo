`include "axi_interfaces.sv"
`include "open_nic_shell_macros.vh"
`timescale 1ns/1ps
module box_tb ();
    /**
    TODO: 
    Make this take tx input from a file (for each cmac and adapter pair). Will
    likely require a master and slave (axil and axis) module that can facilitate that communication
    **/
    localparam int NUM_CMAC_PORT = 2;

    axil system_if ();
    axis #(.NUM_CMAC_PORT(NUM_CMAC_PORT)) adap_box ();
    axis #(.NUM_CMAC_PORT(NUM_CMAC_PORT)) box_adap ();
    axis #(.NUM_CMAC_PORT(NUM_CMAC_PORT)) cmac_box ();
    axis #(.NUM_CMAC_PORT(NUM_CMAC_PORT)) box_cmac ();

    logic mod_rstn;
    logic mod_rst_done;
    logic axil_aclk;
    logic [NUM_CMAC_PORT - 1 : 0] cmac_clk;

    p2p_322mhz #(.NUM_CMAC_PORT(NUM_CMAC_PORT)) dut (
        //system_if
        .s_axil_awvalid                 (system_if.s.awvalid),
        .s_axil_awaddr                  (system_if.s.awaddr),
        .s_axil_awready                 (system_if.s.awready),
        .s_axil_wvalid                  (system_if.s.wvalid),
        .s_axil_wdata                    (system_if.s.wdata),
        .s_axil_wready                  (system_if.s.wready),
        .s_axil_bvalid                  (system_if.s.bvalid),
        .s_axil_bresp                   (system_if.s.bresp),
        .s_axil_bready                  (system_if.s.bready),
        .s_axil_arvalid                 (system_if.s.arvalid),
        .s_axil_araddr                  (system_if.s.araddr),
        .s_axil_arready                 (system_if.s.arready),
        .s_axil_rvalid                  (system_if.s.rvalid),
        .s_axil_rdata                   (system_if.s.rdata),
        .s_axil_rresp                   (system_if.s.rresp),
        .s_axil_rready                  (system_if.s.rready),
        //adap_box
        .s_axis_adap_tx_322mhz_tvalid   (adap_box.s.tvalid),
        .s_axis_adap_tx_322mhz_tdata    (adap_box.s.tdata), 
        .s_axis_adap_tx_322mhz_tkeep    (adap_box.s.tkeep),
        .s_axis_adap_tx_322mhz_tlast    (adap_box.s.tlast),
        .s_axis_adap_tx_322mhz_tuser_err(adap_box.s.tuser_err),
        .s_axis_adap_tx_322mhz_tready   (adap_box.s.tready),
        //box_adap
        .m_axis_adap_rx_322mhz_tvalid   (box_adap.m.tvalid),
        .m_axis_adap_rx_322mhz_tdata    (box_adap.m.tdata),
        .m_axis_adap_rx_322mhz_tkeep    (box_adap.m.tkeep),
        .m_axis_adap_rx_322mhz_tlast    (box_adap.m.tlast),
        .m_axis_adap_rx_322mhz_tuser_err(box_adap.m.tuser_err),
        //box_cmac
        .m_axis_cmac_tx_tvalid           (box_cmac.m.tvalid),
        .m_axis_cmac_tx_tdata            (box_cmac.m.tdata),
        .m_axis_cmac_tx_tkeep            (box_cmac.m.tkeep),
        .m_axis_cmac_tx_tlast            (box_cmac.m.tlast),
        .m_axis_cmac_tx_tuser_err        (box_cmac.m.tuser_err),
        .m_axis_cmac_tx_tready           (box_cmac.m.tready),
        //cmac_box
        .s_axis_cmac_rx_tvalid           (cmac_box.s.tvalid),
        .s_axis_cmac_rx_tdata            (cmac_box.s.tdata), 
        .s_axis_cmac_rx_tkeep            (cmac_box.s.tkeep),
        .s_axis_cmac_rx_tlast            (cmac_box.s.tlast),
        .s_axis_cmac_rx_tuser_err        (cmac_box.s.tuser_err),

        .mod_rstn                       (mod_rstn),
        .mod_rst_done                   (mod_rst_done),

        .axil_aclk                      (axil_aclk),
        .cmac_clk                       (cmac_clk)
    );

    initial begin
        pass_through_test();
        $finish;
    end

    task automatic block_rx_test();
        mod_rstn = 1;
        mod_rst_done = 1;
        tick_axil_clk(axil_aclk);
        tick_cmac_clk(cmac_clk);
        /**
        just a normal rx
        **/
        cmac_box.m.tvalid[0] = 1;
        cmac_box.m.tvalid[1] = 1;
        cmac_box.m.tdata[`getvec(512, 0)] = 512'h1;
        cmac_box.m.tdata[`getvec(512, 1)] = 512'h2;
        cmac_box.m.tkeep[`getvec(64, 0)] = 64'hffffffffffffffff;
        cmac_box.m.tkeep[`getvec(64, 1)] = 64'hffffffffffffffff;
        cmac_box.m.tlast[0] = 1;
        cmac_box.m.tlast[1] = 1;
        cmac_box.m.tuser_err[0] = 0;
        cmac_box.m.tuser_err[1] = 0;

        tick_cmac_clk(cmac_clk);

        cmac_box.m.tvalid[0] = 0;
        cmac_box.m.tvalid[1] = 0;
        cmac_box.m.tdata[`getvec(512, 0)] = 0;
        cmac_box.m.tdata[`getvec(512, 1)] = 0;
        cmac_box.m.tkeep[`getvec(64, 0)] = 64'h0;
        cmac_box.m.tkeep[`getvec(64, 1)] = 64'h0;
        cmac_box.m.tlast[0] = 0;
        cmac_box.m.tlast[1] = 0;
        cmac_box.m.tuser_err[0] = 0;
        cmac_box.m.tuser_err[1] = 0;

        tick_cmac_clk(cmac_clk);
        tick_cmac_clk(cmac_clk);

        /**
        write to the block_rx register
        **/
        tick_axil_clk(axil_aclk);
        system_if.m.awvalid = 1;
        system_if.m.awaddr = 4;
        
        tick_axil_clk(axil_aclk);
        system_if.m.wvalid = 1;
        system_if.m.wdata = 1;
        system_if.m.wlast = 1;
        system_if.m.bready = 1;


        tick_axil_clk(axil_aclk);
        system_if.m.awvalid = 0;
        system_if.m.awaddr = 0;
        system_if.m.wvalid = 0;
        system_if.m.wdata = 0;
        system_if.m.wlast = 0;
        //should see bvalid == 1 and bresp == 0 at some point after this 
        
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        tick_axil_clk(axil_aclk);
        
        /**
        try another rx
        **/
        cmac_box.m.tvalid[0] = 1;
        cmac_box.m.tvalid[1] = 1;
        cmac_box.m.tdata[`getvec(512, 0)] = 512'h1;
        cmac_box.m.tdata[`getvec(512, 1)] = 512'h2;
        cmac_box.m.tkeep[`getvec(64, 0)] = 64'hffffffffffffffff;
        cmac_box.m.tkeep[`getvec(64, 1)] = 64'hffffffffffffffff;
        cmac_box.m.tlast[0] = 1;
        cmac_box.m.tlast[1] = 1;
        cmac_box.m.tuser_err[0] = 0;
        cmac_box.m.tuser_err[1] = 0;

        tick_cmac_clk(cmac_clk);

        cmac_box.m.tvalid[0] = 0;
        cmac_box.m.tvalid[1] = 0;
        cmac_box.m.tdata[`getvec(512, 0)] = 0;
        cmac_box.m.tdata[`getvec(512, 1)] = 0;
        cmac_box.m.tkeep[`getvec(64, 0)] = 64'h0;
        cmac_box.m.tkeep[`getvec(64, 1)] = 64'h0;
        cmac_box.m.tlast[0] = 0;
        cmac_box.m.tlast[1] = 0;
        cmac_box.m.tuser_err[0] = 0;
        cmac_box.m.tuser_err[1] = 0;

        tick_cmac_clk(cmac_clk);
        tick_cmac_clk(cmac_clk);
    endtask

    logic [511:0] data;
    logic [63:0] keep;
    task automatic pass_through_test();
        mod_rstn = 1;
        mod_rst_done = 1;
        tick_axil_clk(axil_aclk);
        tick_cmac_clk(cmac_clk);
        
        data[511:464] = 48'haaaaaaaaaaaa;
        data[463:416] = 48'hbbbbbbbbbbbb;
        data[415:0] = 0;
        rx_single_packet(data, 64'hffffffffffffffff);
        tx_single_packet(data, 64'hffffffffffffffff);

        write_reg(0, 1);

        rx_single_packet(data, 64'hffffffffffffffff);
        tx_single_packet(data, 64'hffffffffffffffff);
        tick_cmac_clk(cmac_clk);        
    endtask

    task automatic hairpin_test();
        mod_rstn = 1;
        mod_rst_done = 1;
        tick_axil_clk(axil_aclk);
        tick_cmac_clk(cmac_clk);
        
        data[511:464] = 48'haaaaaaaaaaaa;
        data[463:416] = 48'hbbbbbbbbbbbb;
        data[415:0] = 0;
        rx_single_packet(data, 64'hffffffffffffffff);
        //allow packet to tx
        box_cmac.s.tready = 3;
        tick_cmac_clk(cmac_clk);
        tick_cmac_clk(cmac_clk);

        write_reg(0, 1);

        rx_single_packet(data, 64'hffffffffffffffff);
        tick_cmac_clk(cmac_clk);
        tick_cmac_clk(cmac_clk);
    endtask

    task automatic loopback_test();
        mod_rstn = 1;
        mod_rst_done = 1;
        tick_axil_clk(axil_aclk);
        tick_cmac_clk(cmac_clk);

        //adapters can receive
        box_adap.s.tready = 3;
        
        data[511:464] = 48'haaaaaaaaaaaa;
        data[463:416] = 48'hbbbbbbbbbbbb;
        data[415:0] = 0;
        tx_single_packet(data, 64'hffffffffffffffff);
        tick_cmac_clk(cmac_clk);

        write_reg(0, 1);

        tx_single_packet(data, 64'hffffffffffffffff);
        tick_cmac_clk(cmac_clk);
    endtask

    task automatic tx_single_packet(input logic [511:0] data, input logic [63:0] keep);
        //put packet into box
        adap_box.m.tvalid[0] = 1;
        adap_box.m.tvalid[1] = 1;
        adap_box.m.tdata[`getvec(512, 0)] = data;
        adap_box.m.tdata[`getvec(512, 1)] = data;
        adap_box.m.tkeep[`getvec(64, 0)] = keep;
        adap_box.m.tkeep[`getvec(64, 1)] = keep;
        adap_box.m.tlast[0] = 1;
        adap_box.m.tlast[1] = 1;
        adap_box.m.tuser_err[0] = 0;
        adap_box.m.tuser_err[1] = 0;
        //able to receive on both macs
        box_cmac.s.tready = 3;

        tick_cmac_clk(cmac_clk);

        adap_box.m.tvalid[0] = 0;
        adap_box.m.tvalid[1] = 0;
        adap_box.m.tdata[`getvec(512, 0)] = 0;
        adap_box.m.tdata[`getvec(512, 1)] = 0;
        adap_box.m.tkeep[`getvec(64, 0)] = 0;
        adap_box.m.tkeep[`getvec(64, 1)] = 0;
        adap_box.m.tlast[0] = 0;
        adap_box.m.tlast[1] = 0;
        adap_box.m.tuser_err[0] = 0;
        adap_box.m.tuser_err[1] = 0;

        tick_cmac_clk(cmac_clk);
        tick_cmac_clk(cmac_clk);
    endtask

    task automatic rx_single_packet(input logic [511:0] data, input logic [63:0] keep);
        cmac_box.m.tvalid[0] = 1;
        cmac_box.m.tvalid[1] = 1;
        cmac_box.m.tdata[`getvec(512, 0)] = data;
        cmac_box.m.tdata[`getvec(512, 1)] = data;
        cmac_box.m.tkeep[`getvec(64, 0)] = keep;
        cmac_box.m.tkeep[`getvec(64, 1)] = keep;
        cmac_box.m.tlast[0] = 1;
        cmac_box.m.tlast[1] = 1;
        cmac_box.m.tuser_err[0] = 0;
        cmac_box.m.tuser_err[1] = 0;

        tick_cmac_clk(cmac_clk);

        cmac_box.m.tvalid[0] = 0;
        cmac_box.m.tvalid[1] = 0;
        cmac_box.m.tdata[`getvec(512, 0)] = 0;
        cmac_box.m.tdata[`getvec(512, 1)] = 0;
        cmac_box.m.tkeep[`getvec(64, 0)] = 64'h0;
        cmac_box.m.tkeep[`getvec(64, 1)] = 64'h0;
        cmac_box.m.tlast[0] = 0;
        cmac_box.m.tlast[1] = 0;
        cmac_box.m.tuser_err[0] = 0;
        cmac_box.m.tuser_err[1] = 0;

        tick_cmac_clk(cmac_clk);
    endtask

    int register_address;
    int reg_data;
    task automatic write_reg(input int register_address, input int data);
        system_if.m.awvalid = 1;
        system_if.m.awaddr = register_address;
        
        tick_axil_clk(axil_aclk);
        system_if.m.wvalid = 1;
        system_if.m.wdata = data;
        system_if.m.wlast = 1;
        system_if.m.bready = 1;

        tick_axil_clk(axil_aclk);
        system_if.m.awvalid = 0;
        system_if.m.awaddr = 0;
        system_if.m.wvalid = 0;
        system_if.m.wdata = 0;
        system_if.m.wlast = 0;
        tick_axil_clk(axil_aclk);
    endtask

    task automatic tick_cmac_clk(ref [1:0] cmac_clk);
        cmac_clk[0] = 1;
        cmac_clk[1] = 1;
        #1;
        cmac_clk[0] = 0;
        cmac_clk[1] = 0;
        #1;
    endtask

    task automatic tick_axil_clk(ref axil_aclk);
        axil_aclk = 1;
        #1;
        axil_aclk = 0;
        #1;
    endtask

endmodule