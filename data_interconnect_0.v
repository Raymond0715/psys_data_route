/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/07/21
* Design Name:    poly_systolic_hw
* Module Name:    data_interconnect_0
* Project Name:   data_route
* Target Devices: ZCU 102
* Tool Versions:  Vivado 2021.2
* Description:
*
* Dependencies:
*
* Revision:
* Additional Comments:
*
*******************************************************************************/


module data_interconnect_0 (
	input										mode,

	input	[1535:0]							s_in_f_tdata,
	input										s_in_f_tvalid,
	output										s_in_f_tready,

	input	[1279:0]							s_in_g_tdata,
	input										s_in_g_tvalid,
	output										s_in_g_tready,

	input	[255:0]								s_in_h_tdata,
	input										s_in_h_tvalid,
	output										s_in_h_tready,

	output	[1535:0]							m_out_dic_a_tdata,
	output										m_out_dic_a_tvalid,
	input										m_out_dic_a_tready,

	output	[1535:0]							m_out_dic_b_tdata,
	output										m_out_dic_b_tvalid,
	input										m_out_dic_b_tready,

	output	[6143:0]							m_out_dic_c_tdata,
	output										m_out_dic_c_tvalid,
	input										m_out_dic_c_tready,

	output	[255:0]								m_out_dic_d_tdata,
	output										m_out_dic_d_tvalid,
	input										m_out_dic_d_tready
);


	wire 						out_dic_c_tvalid, out_dic_c_tready;


	in1536_out6144 out_dic_convert (
		.clk			( clk ),
		.rst_n			( rst_n ),
		.s_axis_tdata	( s_in_f_tdata ),
		.s_axis_tvalid	( out_dic_c_tvalid ),
		.s_axis_tready	( out_dic_c_tready),
		.m_axis_tdata	( m_out_dic_c_tdata ),
		.m_axis_tvalid	( m_out_dic_c_tvalid ),
		.m_axis_tready	( m_out_dic_c_tready )
	);


	assign m_out_dic_a_tdata = {s_in_g_tdata, s_in_h_tdata};
	assign m_out_dic_b_tdata = s_in_f_tdata;
	assign m_out_dic_d_tdata = s_in_h_tdata;

	assign m_out_dic_a_tvalid = ~mode ? s_in_h_tvalid : 0;
	assign m_out_dic_b_tvalid = ~mode ? s_in_f_tvalid : 0;
	assign out_dic_c_tvalid   = mode ? s_in_f_tvalid : 0;
	assign m_out_dic_d_tvalid = mode ? s_in_h_tvalid : 0;

	assign s_in_f_tready = mode ? out_dic_c_tready : m_out_dic_b_tready;
	assign s_in_h_tready = mode ? m_out_dic_d_tready : m_out_dic_a_tready;
	assign s_in_g_tready = ~mode & m_out_dic_a_tready;


endmodule
