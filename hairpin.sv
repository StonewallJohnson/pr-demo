module hairpin (
    //adap_box
    input s_axis_adap_tvalid,
    input [511:0] s_axis_adap_tdata,
    input [63:0] s_axis_adap_tkeep,
    input s_axis_adap_tlast,
    input s_axis_adap_tuser_err,
    output logic s_axis_adap_tready,
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
    output logic s_axis_cmac_tready,
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
    //axi stream tdata corresponds to Ethernet standard
    //most significant byte of packet is on the network first and arrives in tdata[7:0], bytes are network-endian (big);
    //least significant bit of first byte is tdata[0], most significant is tdata[7]      
    localparam int DST_ADDR_START = 0;
    localparam int DST_ADDR_END = 47;
    localparam int SRC_ADDR_START = 48;
    localparam int SRC_ADDR_END = 95;
    localparam int REST_START = 96;
    localparam int REST_END = 511;

    enum {
        SWAP,
        FORWARD
    } state;

    always_ff @(posedge cmac_clk) begin
        case (state)
            SWAP: begin
                if(s_axis_cmac_tvalid & ~s_axis_cmac_tlast) begin
                    //more data following
                    m_axis_cmac_tvalid <= s_axis_cmac_tvalid;
                    m_axis_cmac_tdata[REST_END:REST_START] <= s_axis_cmac_tdata[REST_END:REST_START];
                    //dst = src
                    m_axis_cmac_tdata[DST_ADDR_END:DST_ADDR_START] <= s_axis_cmac_tdata[SRC_ADDR_END:SRC_ADDR_START];
                    //src = dst
                    m_axis_cmac_tdata[SRC_ADDR_END:SRC_ADDR_START] <= s_axis_cmac_tdata[DST_ADDR_END:DST_ADDR_START];
                    m_axis_cmac_tkeep <= s_axis_cmac_tkeep;
                    m_axis_cmac_tlast <= s_axis_cmac_tlast;
                    m_axis_cmac_tuser_err <= s_axis_cmac_tuser_err;
                    s_axis_cmac_tready <= m_axis_cmac_tready; 
                    state <= FORWARD;
                end
                else if(s_axis_cmac_tvalid & s_axis_cmac_tlast) begin
                    //just this data
                    m_axis_cmac_tvalid <= s_axis_cmac_tvalid;
                    m_axis_cmac_tdata[REST_END:REST_START] <= s_axis_cmac_tdata[REST_END:REST_START];
                    //dst = src
                    m_axis_cmac_tdata[DST_ADDR_END:DST_ADDR_START] <= s_axis_cmac_tdata[SRC_ADDR_END:SRC_ADDR_START];
                    //src = dst
                    m_axis_cmac_tdata[SRC_ADDR_END:SRC_ADDR_START] <= s_axis_cmac_tdata[DST_ADDR_END:DST_ADDR_START];
                    m_axis_cmac_tkeep <= s_axis_cmac_tkeep;
                    m_axis_cmac_tlast <= s_axis_cmac_tlast;
                    m_axis_cmac_tuser_err <= s_axis_cmac_tuser_err;
                    s_axis_cmac_tready <= m_axis_cmac_tready;
                end
                else begin
                    //not sending data
                    m_axis_cmac_tvalid <= s_axis_cmac_tvalid;
                    m_axis_cmac_tdata <= s_axis_cmac_tdata;
                    m_axis_cmac_tkeep <= s_axis_cmac_tkeep;
                    m_axis_cmac_tlast <= s_axis_cmac_tlast;
                    m_axis_cmac_tuser_err <= s_axis_cmac_tuser_err;
                    s_axis_cmac_tready <= m_axis_cmac_tready;
                end
            end
            FORWARD: begin
                if(s_axis_cmac_tlast) begin
                    state <= SWAP;
                end
                m_axis_cmac_tvalid <= s_axis_cmac_tvalid;
                m_axis_cmac_tdata <= s_axis_cmac_tdata;
                m_axis_cmac_tkeep <= s_axis_cmac_tkeep;
                m_axis_cmac_tlast <= s_axis_cmac_tlast;
                m_axis_cmac_tuser_err <= s_axis_cmac_tuser_err;
                s_axis_cmac_tready <= m_axis_cmac_tready;
            end
            default: begin
                m_axis_cmac_tvalid <= s_axis_cmac_tvalid;
                m_axis_cmac_tdata <= s_axis_cmac_tdata;
                m_axis_cmac_tkeep <= s_axis_cmac_tkeep;
                m_axis_cmac_tlast <= s_axis_cmac_tlast;
                m_axis_cmac_tuser_err <= s_axis_cmac_tuser_err;
                s_axis_cmac_tready <= m_axis_cmac_tready;
                state <= SWAP;
            end 
        endcase
    end
endmodule: hairpin