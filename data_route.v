/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/05/09
* Design Name:    poly_systolic_hw
* Module Name:    data_route
* Project Name:   data_route
* Target Devices: ZCU 102
* Tool Versions:  Vivado 2021.2
* Description:
*
* Dependencies:
*
* Revision:
* Additional Comments:
* - ctrl { out_1_flex_reg[35:27], out_1_flex_ctrl[26:24],
*          switch_tvalid_out_1[23:21], switch_tvalid_in_1[20:18],
*          out_0_flex_reg[17:9], out_0_flex_ctrl[8:6], switch_tvalid_out_0[5:3],
*          switch_tvalid_in_0[2:0] }
*
*******************************************************************************/


module data_route (
	input										clk,
	input										rst_n,

	input	[35:0]								ctrl,

	input	[1535:0]							s_in_a_tdata,
	input										s_in_a_tvalid,
	output										s_in_a_tready,
	output	[1535:0]							m_out_a_tdata,
	output										m_out_a_tvalid,
	input										m_out_a_tready,

	input	[1535:0]							s_in_b_tdata,
	input										s_in_b_tvalid,
	output										s_in_b_tready,
	output	[1535:0]							m_out_b_tdata,
	output										m_out_b_tvalid,
	input										m_out_b_tready,

	input	[1535:0]							s_in_c_tdata,
	input										s_in_c_tvalid,
	output										s_in_c_tready,
	output	[1535:0]							m_out_c_tdata,
	output										m_out_c_tvalid,
	input										m_out_c_tready,

	input	[127:0]								s_in_d_tdata,
	input										s_in_d_tvalid,
	output										s_in_d_tready,
	output	[127:0]								m_out_d_tdata,
	output										m_out_d_tvalid,
	input										m_out_d_tready,

	input	[127:0]								s_in_e_tdata,
	input										s_in_e_tvalid,
	output										s_in_e_tready,
	output	[127:0]								m_out_e_tdata,
	output										m_out_e_tvalid,
	input										m_out_e_tready,

	output	[1535:0]							m_out_f_tdata,
	output										m_out_f_tvalid,
	input										m_out_f_tready,

	output	[1279:0]							m_out_g_tdata,
	output										m_out_g_tvalid,
	input										m_out_g_tready,

	output	[255:0]								m_out_h_tdata,
	output										m_out_h_tvalid,
	input										m_out_h_tready

);


	wire	[1535:0]		in_d_tdata, in_e_tdata;
	wire					in_d_tvalid, in_d_tready, in_e_tvalid, in_e_tready;

	wire	[1535:0]		switch_out_0, switch_out_1;
	wire	[255:0]			switch_out_0_256, switch_out_1_256;
	wire	[127:0]			switch_out_0_128, switch_out_1_128;


	wire	out_a_tvalid_0, out_a_tready_0, out_b_tvalid_0, out_b_tready_0,
			out_c_tvalid_0, out_c_tready_0, out_d_tvalid_0, out_d_tready_0,
			out_e_tvalid_0, out_e_tready_0, out_f_tvalid_0, out_f_tready_0,
			out_g_tvalid_0, out_g_tready_0, out_h_tvalid_0, out_h_tready_0;

	wire 	out_a_tvalid_1, out_a_tready_1, out_b_tvalid_1, out_b_tready_1,
			out_c_tvalid_1, out_c_tready_1, out_d_tvalid_1, out_d_tready_1,
			out_e_tvalid_1, out_e_tready_1, out_f_tvalid_1, out_f_tready_1,
			out_g_tvalid_1, out_g_tready_1, out_h_tvalid_1, out_h_tready_1;


	in128_out1536 dwidth_converter_ind (
		.aclk					( clk ),
		.aresetn				( rst_n ),
		.s_axis_tdata			( s_in_d_tdata ),
		.s_axis_tvalid			( s_in_d_tvalid ),
		.s_axis_tready			( s_in_d_tready ),
		.m_axis_tdata			( in_d_tdata ),
		.m_axis_tvalid			( in_d_tvalid ),
		.m_axis_tready			( in_d_tready )
	);


	in128_out1536 dwidth_converter_ine (
		.aclk					( clk ),
		.aresetn				( rst_n ),
		.s_axis_tdata			( s_in_e_tdata ),
		.s_axis_tvalid			( s_in_e_tvalid ),
		.s_axis_tready			( s_in_e_tready ),
		.m_axis_tdata			( in_e_tdata ),
		.m_axis_tvalid			( in_e_tvalid ),
		.m_axis_tready			( in_e_tready )
	);


	inter_switch inter_switch_0 (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.ctrl					( ctrl[17:0] ),

		.s_in_a_tdata			( s_in_a_tdata  ),
		.s_in_a_tvalid			( s_in_a_tvalid ),
		.s_in_a_tready			( s_in_a_tready ),
		.s_in_b_tdata			( s_in_b_tdata  ),
		.s_in_b_tvalid			( s_in_b_tvalid ),
		.s_in_b_tready			( s_in_b_tready ),
		.s_in_c_tdata			( s_in_c_tdata  ),
		.s_in_c_tvalid			( s_in_c_tvalid ),
		.s_in_c_tready			( s_in_c_tready ),
		.s_in_d_tdata			( in_d_tdata  ),
		.s_in_d_tvalid			( in_d_tvalid ),
		.s_in_d_tready			( in_d_tready ),
		.s_in_e_tdata			( in_e_tdata  ),
		.s_in_e_tvalid			( in_e_tvalid ),
		.s_in_e_tready			( in_e_tready ),

		.m_out					( switch_out_0 ),
		.m_out_256				( switch_out_0_256 ),
		.m_out_128				( switch_out_0_128 ),
		.m_out_a_tvalid			( out_a_tvalid_0 ),
		.m_out_a_tready			( out_a_tready_0 ),
		.m_out_b_tvalid			( out_b_tvalid_0 ),
		.m_out_b_tready			( out_b_tready_0 ),
		.m_out_c_tvalid			( out_c_tvalid_0 ),
		.m_out_c_tready			( out_c_tready_0 ),
		.m_out_d_tvalid			( out_d_tvalid_0 ),
		.m_out_d_tready			( out_d_tready_0 ),
		.m_out_e_tvalid			( out_e_tvalid_0 ),
		.m_out_e_tready			( out_e_tready_0 ),
		.m_out_f_tvalid			( out_f_tvalid_0 ),
		.m_out_f_tready			( out_f_tready_0 ),
		.m_out_g_tvalid			( out_g_tvalid_0 ),
		.m_out_g_tready			( out_g_tready_0 ),
		.m_out_h_tvalid			( out_h_tvalid_0 ),
		.m_out_h_tready			( out_h_tready_0 )
	);


	inter_switch inter_switch_1 (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.ctrl					( ctrl[35:18] ),

		.s_in_a_tdata			( s_in_a_tdata  ),
		.s_in_a_tvalid			( s_in_a_tvalid ),
		.s_in_a_tready			( s_in_a_tready ),
		.s_in_b_tdata			( s_in_b_tdata  ),
		.s_in_b_tvalid			( s_in_b_tvalid ),
		.s_in_b_tready			( s_in_b_tready ),
		.s_in_c_tdata			( s_in_c_tdata  ),
		.s_in_c_tvalid			( s_in_c_tvalid ),
		.s_in_c_tready			( s_in_c_tready ),
		.s_in_d_tdata			( in_d_tdata  ),
		.s_in_d_tvalid			( in_d_tvalid ),
		.s_in_d_tready			( in_d_tready ),
		.s_in_e_tdata			( in_e_tdata  ),
		.s_in_e_tvalid			( in_e_tvalid ),
		.s_in_e_tready			( in_e_tready ),

		.m_out					( switch_out_1 ),
		.m_out_256				( switch_out_1_256 ),
		.m_out_128				( switch_out_1_128 ),
		.m_out_a_tvalid			( out_a_tvalid_1 ),
		.m_out_a_tready			( out_a_tready_1 ),
		.m_out_b_tvalid			( out_b_tvalid_1 ),
		.m_out_b_tready			( out_b_tready_1 ),
		.m_out_c_tvalid			( out_c_tvalid_1 ),
		.m_out_c_tready			( out_c_tready_1 ),
		.m_out_d_tvalid			( out_d_tvalid_1 ),
		.m_out_d_tready			( out_d_tready_1 ),
		.m_out_e_tvalid			( out_e_tvalid_1 ),
		.m_out_e_tready			( out_e_tready_1 ),
		.m_out_f_tvalid			( out_f_tvalid_1 ),
		.m_out_f_tready			( out_f_tready_1 ),
		.m_out_g_tvalid			( out_g_tvalid_1 ),
		.m_out_g_tready			( out_g_tready_1 ),
		.m_out_h_tvalid			( out_h_tvalid_1 ),
		.m_out_h_tready			( out_h_tready_1 )
	);


	out_switch # (
		.DWIDTH (1536)
	)
	out_switch_c (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0_128 ),
		.s_axis_tvalid_0		( out_c_tvalid_0 ),
		.s_axis_tready_0		( out_c_tready_0 ),
		.s_axis_tdata_1			( switch_out_1_128 ),
		.s_axis_tvalid_1		( out_c_tvalid_1 ),
		.s_axis_tready_1		( out_c_tready_1 ),
		.m_axis_tdata			( m_out_c_tdata ),
		.m_axis_tvalid			( m_out_c_tvalid ),
		.m_axis_tready			( m_out_c_tready )
	);


	out_switch # (
		.DWIDTH (128)
	)
	out_switch_d (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0_128 ),
		.s_axis_tvalid_0		( out_d_tvalid_0 ),
		.s_axis_tready_0		( out_d_tready_0 ),
		.s_axis_tdata_1			( switch_out_1_128 ),
		.s_axis_tvalid_1		( out_d_tvalid_1 ),
		.s_axis_tready_1		( out_d_tready_1 ),
		.m_axis_tdata			( m_out_d_tdata ),
		.m_axis_tvalid			( m_out_d_tvalid ),
		.m_axis_tready			( m_out_d_tready )
	);


	out_switch # (
		.DWIDTH (128)
	)
	out_switch_e (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0_128 ),
		.s_axis_tvalid_0		( out_e_tvalid_0 ),
		.s_axis_tready_0		( out_e_tready_0 ),
		.s_axis_tdata_1			( switch_out_1_128 ),
		.s_axis_tvalid_1		( out_e_tvalid_1 ),
		.s_axis_tready_1		( out_e_tready_1 ),
		.m_axis_tdata			( m_out_e_tdata ),
		.m_axis_tvalid			( m_out_e_tvalid ),
		.m_axis_tready			( m_out_e_tready )
	);


	out_switch # (
		.DWIDTH (1536)
	)
	out_switch_f (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0_128 ),
		.s_axis_tvalid_0		( out_f_tvalid_0 ),
		.s_axis_tready_0		( out_f_tready_0 ),
		.s_axis_tdata_1			( switch_out_1_128 ),
		.s_axis_tvalid_1		( out_f_tvalid_1 ),
		.s_axis_tready_1		( out_f_tready_1 ),
		.m_axis_tdata			( m_out_f_tdata ),
		.m_axis_tvalid			( m_out_f_tvalid ),
		.m_axis_tready			( m_out_f_tready )
	);


	out_switch_flex out_switch_g_h(
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0 ),
		.s_axis_tvalid_0		( out_g_tvalid_0 ),
		.s_axis_tready_0		( out_g_tready_0 ),
		.s_axis_256_tdata_0		( switch_out_0_256 ),
		.s_axis_256_tvalid_0	( out_h_tvalid_0 ),
		.s_axis_256_tready_0	( out_h_tready_0 ),
		.s_axis_tdata_1			( switch_out_1 ),
		.s_axis_tvalid_1		( out_g_tvalid_1 ),
		.s_axis_tready_1		( out_g_tready_1 ),
		.s_axis_256_tdata_1		( switch_out_1_256 ),
		.s_axis_256_tvalid_1	( out_h_tvalid_1 ),
		.s_axis_256_tready_1	( out_h_tready_1 ),
		.m_axis_g_tdata			( m_out_g_tdata ),
		.m_axis_g_tvalid		( m_out_g_tvalid ),
		.m_axis_g_tready		( m_out_g_tready ),
		.m_axis_h_tdata			( m_out_h_tdata ),
		.m_axis_h_tvalid		( m_out_h_tvalid ),
		.m_axis_h_tready		( m_out_h_tready )
	);


endmodule
