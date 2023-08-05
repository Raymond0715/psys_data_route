/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/05/14
* Design Name:    poly_systolic_hw
* Module Name:    inter_switch
* Project Name:   data_route
* Target Devices: ZCU 102
* Tool Versions:  Vivado 2021.2
* Description:
*
* Dependencies:
*
* Revision:
* Additional Comments:
* 	- m_out_g_tvalid and m_out_g_tready represent 1536 output ctrl signal
* 	(out_g and out_h are combined as one signal).
* 	- m_out_h_tvalid and m_out_h_tready represent 256 output ctrl signal.
*
*******************************************************************************/


module inter_switch (
	input										clk,
	input										rst_n,

	input	[18:0]								ctrl,
	output										count_switch_tvalid,
	input										weight_switch,

	input	[1535:0]							s_in_a_tdata,
	input										s_in_a_tvalid,
	output										s_in_a_tready,
	input	[11:0]								s_in_a_tlast,

	input	[1535:0]							s_in_b_tdata,
	input										s_in_b_tvalid,
	output										s_in_b_tready,
	input	[11:0]								s_in_b_tlast,

	input	[1535:0]							s_in_c_tdata,
	input										s_in_c_tvalid,
	output										s_in_c_tready,
	input										s_in_c_tlast,

	input	[1535:0]							s_in_d_tdata,
	input										s_in_d_tvalid,
	output										s_in_d_tready,
	input										s_in_d_tlast,

	input	[1535:0]							s_in_e_tdata,
	input										s_in_e_tvalid,
	output										s_in_e_tready,

	input	[1535:0]							s_in_i_tdata,
	input										s_in_i_tvalid,
	output										s_in_i_tready,

	output	[1535:0]							m_out,
	output	[127:0]								m_out_128_a,
	output	[127:0]								m_out_128_b,
	output	[255:0]								m_out_256,

	output										m_out_a_tvalid,
	input										m_out_a_tready,
	output										m_out_a_tlast,

	output										m_out_b_tvalid,
	input										m_out_b_tready,

	output										m_out_c_tvalid,
	input										m_out_c_tready,

	output										m_out_d_tvalid,
	input										m_out_d_tready,

	output										m_out_e_tvalid,
	input										m_out_e_tready,

	output										m_out_f_tvalid,
	input										m_out_f_tready,
	output										m_out_f_tlast,

	output										m_out_g_tvalid,
	input										m_out_g_tready,
	output										m_out_g_tlast,

	output										m_out_h_tvalid,
	input										m_out_h_tready,
	output										m_out_h_tlast,

	output										m_out_i_tvalid,
	input										m_out_i_tready,

	output										m_inter_weight_switch
);



	reg		[18:0]			m_ctrl, m_ctrl_skid;
	wire	[5:0]			switch_in_en;
	wire	[8:0]			switch_out_en;

	// Input
	wire	[1535:0]		inter_tdata_ina, inter_tdata_inb, inter_tdata_inc,
							inter_tdata_ind, inter_tdata_ine, inter_tdata_ini;
	wire	[11:0]			in_a_tlast, in_b_tlast, in_c_tlast, in_d_tlast;
	wire					in_a_tvalid, in_b_tvalid, in_c_tvalid, in_d_tvalid,
							in_e_tvalid, in_i_tvalid;

	wire	[1535:0]		s_inter_tdata;
	wire	[11:0]			s_inter_tlast;
	wire					s_inter_tvalid, s_inter_tready;

	wire	[1548:0]		m_inter_tdata_bus;
	wire	[1535:0]		m_inter_tdata;
	wire	[11:0]			m_inter_tlast, m_inter_tlast_a;
	wire					m_inter_tvalid, m_inter_tready;


	assign in_a_tvalid = switch_in_en[0] & s_in_a_tvalid;
	assign in_b_tvalid = switch_in_en[1] & s_in_b_tvalid;
	assign in_c_tvalid = switch_in_en[2] & s_in_c_tvalid;
	assign in_d_tvalid = switch_in_en[3] & s_in_d_tvalid;
	assign in_e_tvalid = switch_in_en[4] & s_in_e_tvalid;
	assign in_i_tvalid = switch_in_en[5] & s_in_i_tvalid;

	assign in_a_tlast  = switch_in_en[0] ? s_in_a_tlast : 12'h0;
	assign in_b_tlast  = switch_in_en[1] ? s_in_b_tlast : 12'h0;
	assign in_c_tlast  = switch_in_en[2] ? {11'h0, s_in_c_tlast} : 12'h0;
	assign in_d_tlast  = switch_in_en[3] ? {11'h0, s_in_d_tlast} : 12'h0;

	assign inter_tdata_ina = in_a_tvalid ? s_in_a_tdata : 0;
	assign inter_tdata_inb = in_b_tvalid ? s_in_b_tdata : 0;
	assign inter_tdata_inc = in_c_tvalid ? s_in_c_tdata : 0;
	assign inter_tdata_ind = in_d_tvalid ? s_in_d_tdata : 0;
	assign inter_tdata_ine = in_e_tvalid ? s_in_e_tdata : 0;
	assign inter_tdata_ini = in_i_tvalid ? s_in_i_tdata : 0;

	assign s_inter_tdata = inter_tdata_ina | inter_tdata_inb | inter_tdata_inc
						| inter_tdata_ind | inter_tdata_ine | inter_tdata_ini; 

	assign s_inter_tvalid = in_a_tvalid | in_b_tvalid | in_c_tvalid
						 | in_d_tvalid | in_e_tvalid | in_i_tvalid;

	assign s_inter_tlast = in_a_tlast | in_b_tlast | in_c_tlast | in_d_tlast;
	

	axi_register_slice_v2_1_axic_register_slice # (
		.C_DATA_WIDTH			(1549),
		.C_REG_CONFIG			(1)
	)
	inter_reg_slice (
		.ACLK					( clk ),
		.ARESET					( ~rst_n ),
		.S_PAYLOAD_DATA			( {weight_switch, s_inter_tlast, s_inter_tdata} ),
		.S_VALID				( s_inter_tvalid ),
		.S_READY				( s_inter_tready ),
		.M_PAYLOAD_DATA			( m_inter_tdata_bus ),
		.M_VALID				( m_inter_tvalid ),
		.M_READY				( m_inter_tready )
	);


	assign m_inter_tdata = m_inter_tdata_bus[1535:0];
	assign m_inter_tlast = m_inter_tdata_bus[1547:1536];
	assign m_inter_weight_switch = m_inter_tdata_bus[1548];
	assign m_inter_tlast_a = switch_out_en[0] ? m_inter_tlast : 12'h0;
	assign m_out_f_tlast = switch_out_en[5] ? m_inter_tlast : 1'b0;
	assign m_out_g_tlast = switch_out_en[6] ? m_inter_tlast : 1'b0;
	assign m_out_h_tlast = switch_out_en[7] ? m_inter_tlast : 1'b0;
	assign count_switch_tvalid = s_inter_tvalid & s_inter_tready;


	assign s_in_a_tready = switch_in_en[0] & s_inter_tready;
	assign s_in_b_tready = switch_in_en[1] & s_inter_tready;
	assign s_in_c_tready = switch_in_en[2] & s_inter_tready;
	assign s_in_d_tready = switch_in_en[3] & s_inter_tready;
	assign s_in_e_tready = switch_in_en[4] & s_inter_tready;
	assign s_in_i_tready = switch_in_en[5] & s_inter_tready;


	assign switch_in_en[0] = ~ctrl[2] & ~ctrl[1] &  ctrl[0];
	assign switch_in_en[1] = ~ctrl[2] &  ctrl[1] & ~ctrl[0];
	assign switch_in_en[2] = ~ctrl[2] &  ctrl[1] &  ctrl[0];
	assign switch_in_en[3] =  ctrl[2] & ~ctrl[1] & ~ctrl[0];
	assign switch_in_en[4] =  ctrl[2] & ~ctrl[1] &  ctrl[0];
	assign switch_in_en[5] =  ctrl[2] &  ctrl[1] & ~ctrl[0];


	// Inter
	wire					out_c_tready, out_d_tready, out_e_tready, 
							out_f_tready, out_g_tready, out_i_tready;

	wire					inter_128_tready_a, inter_128_tready_b;

	wire					inter_tready_256_flex;

	assign m_inter_tready = out_c_tready | out_d_tready | out_e_tready
						 | out_f_tready | out_g_tready | out_i_tready
						 | (inter_128_tready_a & switch_out_en[0])
						 | (inter_128_tready_b & switch_out_en[1])
						 | (inter_tready_256_flex & switch_out_en[7]);

	assign out_c_tready = switch_out_en[2] & m_out_c_tready;
	assign out_d_tready = switch_out_en[3] & m_out_d_tready;
	assign out_e_tready = switch_out_en[4] & m_out_e_tready;
	assign out_f_tready = switch_out_en[5] & m_out_f_tready;
	assign out_g_tready = switch_out_en[6] & m_out_g_tready;
	assign out_i_tready = switch_out_en[8] & m_out_i_tready;


	// Output
	wire	[255:0]			out_inter_tdata_256_flex;
	wire	[127:0]			out_inter_128_tdata_a, out_inter_128_tdata_b;
	wire 					out_inter_128_tvalid_a, out_inter_128_tvalid_b,
							out_inter_tvalid_256_flex;


	assign m_out          = m_inter_tdata;
	assign m_out_128_a    = out_inter_128_tdata_a;
	assign m_out_128_b    = out_inter_128_tdata_b;
	assign m_out_256      = out_inter_tdata_256_flex;

	assign m_out_a_tvalid = out_inter_128_tvalid_a;
	assign m_out_b_tvalid = out_inter_128_tvalid_b;
	assign m_out_c_tvalid = switch_out_en[2] & m_inter_tvalid;
	assign m_out_d_tvalid = switch_out_en[3] & m_inter_tvalid;
	assign m_out_e_tvalid = switch_out_en[4] & m_inter_tvalid;
	assign m_out_f_tvalid = switch_out_en[5] & m_inter_tvalid;
	assign m_out_g_tvalid = switch_out_en[6] & m_inter_tvalid;
	assign m_out_h_tvalid = out_inter_tvalid_256_flex;
	assign m_out_i_tvalid = switch_out_en[8] & m_inter_tvalid;


	always @(posedge clk) begin
		if (~rst_n) begin
			m_ctrl <= 19'h10080;
			m_ctrl_skid <= 19'h10080;
		end
		else begin
			if (m_inter_tready | ~m_inter_tvalid) begin
				m_ctrl <= s_inter_tready ? ctrl : m_ctrl_skid;
			end

			if (s_inter_tready) begin
				m_ctrl_skid <= ctrl;
			end
		end
	end


	assign switch_out_en[0] =
		~m_ctrl[6] & ~m_ctrl[5] & ~m_ctrl[4] & ~m_ctrl[3] && m_ctrl[2:0] != 3'b0;
	assign switch_out_en[1] =
		~m_ctrl[6] & ~m_ctrl[5] & ~m_ctrl[4] &  m_ctrl[3] && m_ctrl[2:0] != 3'b0;
	assign switch_out_en[2] =
		~m_ctrl[6] & ~m_ctrl[5] &  m_ctrl[4] & ~m_ctrl[3] && m_ctrl[2:0] != 3'b0;
	assign switch_out_en[3] =
		~m_ctrl[6] & ~m_ctrl[5] &  m_ctrl[4] &  m_ctrl[3] && m_ctrl[2:0] != 3'b0;
	assign switch_out_en[4] =
		~m_ctrl[6] & m_ctrl[5] & ~m_ctrl[4] & ~m_ctrl[3] && m_ctrl[2:0] != 3'b0;
	assign switch_out_en[5] =
		~m_ctrl[6] &  m_ctrl[5] & ~m_ctrl[4] &  m_ctrl[3] && m_ctrl[2:0] != 3'b0;
	assign switch_out_en[6] =
		~m_ctrl[6] &  m_ctrl[5] &  m_ctrl[4] & ~m_ctrl[3] && m_ctrl[2:0] != 3'b0;
	assign switch_out_en[7] =
		~m_ctrl[6] &  m_ctrl[5] &  m_ctrl[4] &  m_ctrl[3] && m_ctrl[2:0] != 3'b0;
	assign switch_out_en[8] =
		 m_ctrl[6] & ~m_ctrl[5] & ~m_ctrl[4] & ~m_ctrl[3] && m_ctrl[2:0] != 3'b0;


	in1536_out128 dwidth_converter_out_a (
		.clk				( clk ),
		.rst_n				( rst_n ),
		.s_axis_tdata		( m_inter_tdata ),
		.s_axis_tvalid		( m_inter_tvalid & switch_out_en[0] ),
		.s_axis_tready		( inter_128_tready_a ),
		.s_axis_tlast		( m_inter_tlast_a ),
		.m_axis_tdata		( out_inter_128_tdata_a ),
		.m_axis_tvalid		( out_inter_128_tvalid_a ),
		.m_axis_tready		( m_out_a_tready ),
		.m_axis_tlast		( m_out_a_tlast )
	);


	in1536_out128 dwidth_converter_out_b (
		.clk				( clk ),
		.rst_n				( rst_n ),
		.s_axis_tdata		( m_inter_tdata ),
		.s_axis_tvalid		( m_inter_tvalid & switch_out_en[1] ),
		.s_axis_tready		( inter_128_tready_b ),
		.m_axis_tdata		( out_inter_128_tdata_b ),
		.m_axis_tvalid		( out_inter_128_tvalid_b ),
		.m_axis_tready		( m_out_b_tready )
	);


	in1536_out256_flex dwidth_converter_out_flex (
		.clk				( clk ),
		.rst_n				( rst_n ),
		.shift_ctrl			( m_ctrl[9:7] ),
		.shift_reg			( m_ctrl[18:10] ),
		.s_axis_tdata		( m_inter_tdata ),
		.s_axis_tvalid		( m_inter_tvalid & switch_out_en[7] ),
		.s_axis_tready		( inter_tready_256_flex ),
		.m_axis_tdata		( out_inter_tdata_256_flex ),
		.m_axis_tvalid		( out_inter_tvalid_256_flex ),
		.m_axis_tready		( m_out_h_tready )
	);


endmodule
