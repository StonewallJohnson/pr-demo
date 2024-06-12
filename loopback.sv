module loopback (
    //adap_box
    input s_axis_adap_tvalid,
    input [511:0] s_axis_adap_tdata,
    input [63:0] s_axis_adap_tkeep,
    input s_axis_adap_tlast,
    input s_axis_adap_tuser_err,
    output s_axis_adap_tready,
    //box_cmac
    output logic m_axis_cmac_tvalid,
    output logic [511:0] m_axis_cmac_tdata,
    output logic [63:0] m_axis_cmac_tkeep,
    output logic m_axis_cmac_tlast,
    output logic m_axis_cmac_tuser_err,
    input m_axis_cmac_tready,
    //cmac_box
    input s_axis_cmac_tvalid,
    input [511:0] s_axis_cmac_tdata,
    input [63:0] s_axis_cmac_tkeep,
    input s_axis_cmac_tlast,
    input s_axis_cmac_tuser_err,
    output s_axis_cmac_tready,
    //box_adap
    output logic m_axis_adap_tvalid,
    output logic [511:0] m_axis_adap_tdata,
    output logic [63:0] m_axis_adap_tkeep,
    output logic m_axis_adap_tlast,
    output logic m_axis_adap_tuser_err,
    input m_axis_adap_tready,

    input cmac_clk,
    input rstn
);
    //tx -> rx 
    assign m_axis_adap_tvalid = s_axis_adap_tvalid;
    assign m_axis_adap_tdata = s_axis_adap_tdata;
    assign m_axis_adap_tkeep = s_axis_adap_tkeep;
    assign m_axis_adap_tlast = s_axis_adap_tlast;
    assign m_axis_adap_tuser_err = s_axis_adap_tuser_err;
    assign s_axis_adap_tready = m_axis_adap_tready;

    //no receive
endmodule: loopback