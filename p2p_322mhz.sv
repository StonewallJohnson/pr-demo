// *************************************************************************
//
// Copyright 2020 Xilinx, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// *************************************************************************
`include "open_nic_shell_macros.vh"
`timescale 1ns/1ps
module p2p_322mhz #(
  parameter int NUM_CMAC_PORT = 1
) (
  input                          s_axil_awvalid,
  input                   [31:0] s_axil_awaddr,
  output                         s_axil_awready,
  input                          s_axil_wvalid,
  input                   [31:0] s_axil_wdata,
  output                         s_axil_wready,
  output                         s_axil_bvalid,
  output                   [1:0] s_axil_bresp,
  input                          s_axil_bready,
  input                          s_axil_arvalid,
  input                   [31:0] s_axil_araddr,
  output                         s_axil_arready,
  output                         s_axil_rvalid,
  output                  [31:0] s_axil_rdata,
  output                   [1:0] s_axil_rresp,
  input                          s_axil_rready,
  //adap_box
  (* MARK_DEBUG = "true" *)
  input      [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tvalid,
  (* MARK_DEBUG = "true" *)
  input  [512*NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tdata,
  input   [64*NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tkeep,
  input      [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tlast,
  input      [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tuser_err,
  output     [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tready,
  //box_adap
  output     [NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tvalid,
  output [512*NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tdata,
  output  [64*NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tkeep,
  output     [NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tlast,
  output     [NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tuser_err,
  //box_cmac
  output     [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tvalid,
  output [512*NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tdata,
  output  [64*NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tkeep,
  output     [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tlast,
  output     [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tuser_err,
  input      [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tready,
  //cmac_box
  (* MARK_DEBUG = "true" *)
  input      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tvalid,
  (* MARK_DEBUG = "true" *)
  input  [512*NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tdata,
  input   [64*NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tkeep,
  input      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tlast,
  input      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tuser_err,

  input                          mod_rstn,
  output                         mod_rst_done,

  input                          axil_aclk,
  input      [NUM_CMAC_PORT-1:0] cmac_clk
);

  wire                         axil_aresetn;
  wire     [NUM_CMAC_PORT-1:0] cmac_rstn;

  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tuser_err;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tready;

  wire     [NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tuser_err;

  generic_reset #(
    .NUM_INPUT_CLK  (1 + NUM_CMAC_PORT),
    .RESET_DURATION (100)
  ) reset_inst (
    .mod_rstn     (mod_rstn),
    .mod_rst_done (mod_rst_done),
    .clk          ({cmac_clk, axil_aclk}),
    .rstn         ({cmac_rstn, axil_aresetn})
  );
    
  localparam int NUM_REG = 12;
  localparam int REG_ADDR_WIDTH = $clog2(NUM_REG);
  localparam int REG_DATA_WIDTH = 32;
  //register file system interface
  wire system_reg_en;
  wire system_reg_we;
  wire [REG_ADDR_WIDTH - 1 : 0] system_reg_addr;
  wire [REG_DATA_WIDTH - 1 : 0] system_reg_din;
  wire [REG_DATA_WIDTH - 1 : 0] system_reg_dout;

  axi_lite_register #(
    .CLOCKING_MODE("common_clock"),
    .ADDR_W(REG_ADDR_WIDTH),
    .DATA_W(REG_DATA_WIDTH)
  ) system_config_reg_interface (
    .s_axil_awvalid (s_axil_awvalid),
    .s_axil_awaddr  (s_axil_awaddr),
    .s_axil_awready (s_axil_awready),
    .s_axil_wvalid  (s_axil_wvalid),
    .s_axil_wdata   (s_axil_wdata),
    .s_axil_wready  (s_axil_wready),
    .s_axil_bvalid  (s_axil_bvalid),
    .s_axil_bresp   (s_axil_bresp),
    .s_axil_bready  (s_axil_bready),
    .s_axil_arvalid (s_axil_arvalid),
    .s_axil_araddr  (s_axil_araddr),
    .s_axil_arready (s_axil_arready),
    .s_axil_rvalid  (s_axil_rvalid),
    .s_axil_rdata   (s_axil_rdata),
    .s_axil_rresp   (s_axil_rresp),
    .s_axil_rready  (s_axil_rready),

    .reg_en         (system_reg_en),
    .reg_we         (system_reg_we),
    .reg_addr       (system_reg_addr),
    .reg_din        (system_reg_din),
    .reg_dout       (system_reg_dout),

    .axil_aclk           (axil_aclk),
    .axil_aresetn        (axil_aresetn),
    .reg_clk        (axil_aclk),
    .reg_rstn       (axil_aresetn)
  );
  
  //check the register
  localparam int BLOCK_RX_REG = 4;
  localparam int DECOUPLED_REG = 0;

  logic [REG_DATA_WIDTH - 1 : 0] registers [NUM_REG];

  register_file #(
    .ENTRIES(NUM_REG),
    .DATA_WIDTH(REG_DATA_WIDTH)
  ) register_file_inst (
    .system_reg_en      (system_reg_en),
    .system_reg_we      (system_reg_we),
    .system_reg_addr    (system_reg_addr),
    .system_reg_din     (system_reg_din),
    .system_reg_dout    (system_reg_dout),

    .reg_values(registers)
  );

  generate for (genvar i = 0; i < NUM_CMAC_PORT; i++) begin  
    //adap_box
    wire middle_box_s_axis_adap_tvalid;
    wire [511:0] middle_box_s_axis_adap_tdata;
    wire [63:0] middle_box_s_axis_adap_tkeep;
    wire middle_box_s_axis_adap_tlast;
    wire middle_box_s_axis_adap_tuser_err;
    wire middle_box_s_axis_adap_tready;
    //box_cmac
    wire middle_box_m_axis_cmac_tvalid;
    wire [511:0] middle_box_m_axis_cmac_tdata;
    wire [63:0] middle_box_m_axis_cmac_tkeep;
    wire middle_box_m_axis_cmac_tlast;
    wire middle_box_m_axis_cmac_tuser_err;
    wire middle_box_m_axis_cmac_tready;
    //cmac_box
    wire middle_box_s_axis_cmac_tvalid;
    wire [511:0] middle_box_s_axis_cmac_tdata;
    wire [63:0] middle_box_s_axis_cmac_tkeep;
    wire middle_box_s_axis_cmac_tlast;
    wire middle_box_s_axis_cmac_tuser_err;
    wire middle_box_s_axis_cmac_tready;
    //box_adap
    wire middle_box_m_axis_adap_tvalid;
    wire [511:0] middle_box_m_axis_adap_tdata;
    wire [63:0] middle_box_m_axis_adap_tkeep;
    wire middle_box_m_axis_adap_tlast;
    wire middle_box_m_axis_adap_tuser_err;
    wire middle_box_m_axis_adap_tready;

    pass_through pass_through_inst (
      .s_axis_adap_tvalid     (middle_box_s_axis_adap_tvalid),
      .s_axis_adap_tdata      (middle_box_s_axis_adap_tdata),
      .s_axis_adap_tkeep      (middle_box_s_axis_adap_tkeep),
      .s_axis_adap_tlast      (middle_box_s_axis_adap_tlast),
      .s_axis_adap_tuser_err  (middle_box_s_axis_adap_tuser_err),
      .s_axis_adap_tready     (middle_box_s_axis_adap_tready),
      
      .m_axis_cmac_tvalid     (middle_box_m_axis_cmac_tvalid),
      .m_axis_cmac_tdata      (middle_box_m_axis_cmac_tdata),
      .m_axis_cmac_tkeep      (middle_box_m_axis_cmac_tkeep),
      .m_axis_cmac_tlast      (middle_box_m_axis_cmac_tlast),
      .m_axis_cmac_tuser_err  (middle_box_m_axis_cmac_tuser_err),
      .m_axis_cmac_tready     (middle_box_m_axis_cmac_tready),

      .s_axis_cmac_tvalid     (middle_box_s_axis_cmac_tvalid),
      .s_axis_cmac_tdata      (middle_box_s_axis_cmac_tdata),
      .s_axis_cmac_tkeep      (middle_box_s_axis_cmac_tkeep),
      .s_axis_cmac_tlast      (middle_box_s_axis_cmac_tlast),
      .s_axis_cmac_tuser_err  (middle_box_s_axis_cmac_tuser_err),
      .s_axis_cmac_tready     (middle_box_s_axis_cmac_tready),

      .m_axis_adap_tvalid     (middle_box_m_axis_adap_tvalid),
      .m_axis_adap_tdata      (middle_box_m_axis_adap_tdata),
      .m_axis_adap_tkeep      (middle_box_m_axis_adap_tkeep),
      .m_axis_adap_tlast      (middle_box_m_axis_adap_tlast),
      .m_axis_adap_tuser_err  (middle_box_m_axis_adap_tuser_err),
      .m_axis_adap_tready     (middle_box_m_axis_adap_tready),
      
      .cmac_clk               (cmac_clk[i]),
      .rstn                   (cmac_rstn[i])
    );

    
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_0_inst (
      .s_axis_tvalid (s_axis_adap_tx_322mhz_tvalid[i]),
      .s_axis_tdata  (s_axis_adap_tx_322mhz_tdata[`getvec(512, i)]),
      .s_axis_tkeep  (s_axis_adap_tx_322mhz_tkeep[`getvec(64, i)]),
      .s_axis_tlast  (s_axis_adap_tx_322mhz_tlast[i]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (s_axis_adap_tx_322mhz_tuser_err[i]),
      .s_axis_tready (s_axis_adap_tx_322mhz_tready[i]),

      .m_axis_tvalid (axis_adap_tx_322mhz_tvalid[i]),
      .m_axis_tdata  (axis_adap_tx_322mhz_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (axis_adap_tx_322mhz_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (axis_adap_tx_322mhz_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (axis_adap_tx_322mhz_tuser_err[i]),
      .m_axis_tready (axis_adap_tx_322mhz_tready[i]),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );
    
    dfx_decoupler_s_axis adap_box_decoupler (
      .s_axis_TVALID  (axis_adap_tx_322mhz_tvalid[i]),      
      .rp_axis_TVALID (middle_box_s_axis_adap_tvalid),    
      .s_axis_TREADY  (axis_adap_tx_322mhz_tready[i]),      
      .rp_axis_TREADY (middle_box_s_axis_adap_tready),    
      .s_axis_TDATA   (axis_adap_tx_322mhz_tdata[`getvec(512, i)]),        
      .rp_axis_TDATA  (middle_box_s_axis_adap_tdata),      
      .s_axis_TLAST   (axis_adap_tx_322mhz_tlast[i]),        
      .rp_axis_TLAST  (middle_box_s_axis_adap_tlast),      
      .s_axis_TKEEP   (axis_adap_tx_322mhz_tkeep[`getvec(64, i)]),        
      .rp_axis_TKEEP  (middle_box_s_axis_adap_tkeep),
      .s_axis_TUSER   (axis_adap_tx_322mhz_tuser_err[i]),        
      .rp_axis_TUSER  (middle_box_s_axis_adap_tuser_err),      
      .axis_aclk      (cmac_clk[i]),              
      .axis_arstn     (cmac_rstn[i]),            
      .decouple       (registers[DECOUPLED_REG]),                
      .decouple_status()  
    );

    wire decoupled_m_axis_cmac_tvalid;
    wire [511:0] decoupled_m_axis_cmac_tdata;
    wire [63:0] decoupled_m_axis_cmac_tkeep;
    wire decoupled_m_axis_cmac_tlast;
    wire decoupled_m_axis_cmac_tuser_err;
    wire decoupled_m_axis_cmac_tready;

    dfx_decoupler_m_axis box_cmac_decoupler (
      .s_axis_TVALID  (decoupled_m_axis_cmac_tvalid),     
      .rp_axis_TVALID (middle_box_m_axis_cmac_tvalid),   
      .s_axis_TREADY  (decoupled_m_axis_cmac_tready),    
      .rp_axis_TREADY (middle_box_m_axis_cmac_tready),   
      .s_axis_TDATA   (decoupled_m_axis_cmac_tdata),      
      .rp_axis_TDATA  (middle_box_m_axis_cmac_tdata),     
      .s_axis_TLAST   (decoupled_m_axis_cmac_tlast),     
      .rp_axis_TLAST  (middle_box_m_axis_cmac_tlast),     
      .s_axis_TKEEP   (decoupled_m_axis_cmac_tkeep),       
      .rp_axis_TKEEP  (middle_box_m_axis_cmac_tkeep),
      .s_axis_TUSER   (decoupled_m_axis_cmac_tuser_err),       
      .rp_axis_TUSER  (middle_box_m_axis_cmac_tuser_err),     
      .axis_aclk      (cmac_clk[i]),             
      .axis_arstn     (cmac_rstn[i]),           
      .decouple       (registers[DECOUPLED_REG]),               
      .decouple_status() 
    );

    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_1_inst (
      .s_axis_tvalid (decoupled_m_axis_cmac_tvalid),
      .s_axis_tdata  (decoupled_m_axis_cmac_tdata),
      .s_axis_tkeep  (decoupled_m_axis_cmac_tkeep),
      .s_axis_tlast  (decoupled_m_axis_cmac_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (decoupled_m_axis_cmac_tuser_err),
      .s_axis_tready (decoupled_m_axis_cmac_tready),

      .m_axis_tvalid (m_axis_cmac_tx_tvalid[i]),
      .m_axis_tdata  (m_axis_cmac_tx_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (m_axis_cmac_tx_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (m_axis_cmac_tx_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (m_axis_cmac_tx_tuser_err[i]),
      .m_axis_tready (m_axis_cmac_tx_tready[i]),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );

    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_0_inst (
      .s_axis_tvalid (s_axis_cmac_rx_tvalid[i] & ~registers[BLOCK_RX_REG]),
      .s_axis_tdata  (s_axis_cmac_rx_tdata[`getvec(512, i)]),
      .s_axis_tkeep  (s_axis_cmac_rx_tkeep[`getvec(64, i)]),
      .s_axis_tlast  (s_axis_cmac_rx_tlast[i]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (s_axis_cmac_rx_tuser_err[i]),
      .s_axis_tready (),

      .m_axis_tvalid (axis_adap_rx_322mhz_tvalid[i]),
      .m_axis_tdata  (axis_adap_rx_322mhz_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (axis_adap_rx_322mhz_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (axis_adap_rx_322mhz_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (axis_adap_rx_322mhz_tuser_err[i]),
      .m_axis_tready (1'b1),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );

    dfx_decoupler_s_axis cmac_box_decoupler (
      .s_axis_TVALID  (axis_adap_rx_322mhz_tvalid[i]),      
      .rp_axis_TVALID (middle_box_s_axis_cmac_tvalid),    
      .s_axis_TREADY  (1'b1),      
      .rp_axis_TREADY (middle_box_s_axis_cmac_tready),    
      .s_axis_TDATA   (axis_adap_rx_322mhz_tdata[`getvec(512, i)]),        
      .rp_axis_TDATA  (middle_box_s_axis_cmac_tdata),      
      .s_axis_TLAST   (axis_adap_rx_322mhz_tlast[i]),        
      .rp_axis_TLAST  (middle_box_s_axis_cmac_tlast),      
      .s_axis_TKEEP   (axis_adap_rx_322mhz_tkeep[`getvec(64, i)]),        
      .rp_axis_TKEEP  (middle_box_s_axis_cmac_tkeep),
      .s_axis_TUSER   (axis_adap_rx_322mhz_tuser_err[i]),        
      .rp_axis_TUSER  (middle_box_s_axis_cmac_tuser_err),      
      .axis_aclk      (cmac_clk[i]),              
      .axis_arstn     (cmac_rstn[i]),            
      .decouple       (registers[DECOUPLED_REG]),                
      .decouple_status()  
    );

    wire decoupled_m_axis_adap_tvalid;
    wire [511:0] decoupled_m_axis_adap_tdata;
    wire [63:0] decoupled_m_axis_adap_tkeep;
    wire decoupled_m_axis_adap_tlast;
    wire decoupled_m_axis_adap_tuser_err;
    wire decoupled_m_axis_adap_tready;

    dfx_decoupler_m_axis box_adap_decoupler (
      .s_axis_TVALID  (decoupled_m_axis_adap_tvalid),     
      .rp_axis_TVALID (middle_box_m_axis_adap_tvalid),   
      .s_axis_TREADY  (decoupled_m_axis_adap_tready),    
      .rp_axis_TREADY (middle_box_m_axis_adap_tready),   
      .s_axis_TDATA   (decoupled_m_axis_adap_tdata),      
      .rp_axis_TDATA  (middle_box_m_axis_adap_tdata),     
      .s_axis_TLAST   (decoupled_m_axis_adap_tlast),     
      .rp_axis_TLAST  (middle_box_m_axis_adap_tlast),     
      .s_axis_TKEEP   (decoupled_m_axis_adap_tkeep),       
      .rp_axis_TKEEP  (middle_box_m_axis_adap_tkeep),
      .s_axis_TUSER   (decoupled_m_axis_adap_tuser_err),       
      .rp_axis_TUSER  (middle_box_m_axis_adap_tuser_err),     
      .axis_aclk      (cmac_clk[i]),             
      .axis_arstn     (cmac_rstn[i]),           
      .decouple       (registers[DECOUPLED_REG]),               
      .decouple_status() 
    );

    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_1_inst (
      .s_axis_tvalid (decoupled_m_axis_adap_tvalid),
      .s_axis_tdata  (decoupled_m_axis_adap_tdata),
      .s_axis_tkeep  (decoupled_m_axis_adap_tkeep),
      .s_axis_tlast  (decoupled_m_axis_adap_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (decoupled_m_axis_adap_tuser_err),
      .s_axis_tready (decoupled_m_axis_adap_tready),

      .m_axis_tvalid (m_axis_adap_rx_322mhz_tvalid[i]),
      .m_axis_tdata  (m_axis_adap_rx_322mhz_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (m_axis_adap_rx_322mhz_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (m_axis_adap_rx_322mhz_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (m_axis_adap_rx_322mhz_tuser_err[i]),
      .m_axis_tready (1'b1),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );
  end
  endgenerate

endmodule: p2p_322mhz
