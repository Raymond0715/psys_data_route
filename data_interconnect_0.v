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
	input										clk,
	input										rst_n,

	input										mode,

	input	[1535:0]							s_in_f_tdata,
	input										s_in_f_tvalid,
	output										s_in_f_tready,
	input										s_in_f_tlast,
	input										f_weight_switch,

	input	[1279:0]							s_in_g_tdata,
	input										s_in_g_tvalid,
	output										s_in_g_tready,
	input										s_in_g_tlast,

	input	[255:0]								s_in_h_tdata,
	input										s_in_h_tvalid,
	output										s_in_h_tready,
	input										s_in_h_tlast,
	input										h_weight_switch,

	output	[1535:0]							m_out_dic_a_tdata,
	output										m_out_dic_a_tvalid,
	input										m_out_dic_a_tready,

	output	[1535:0]							m_out_dic_b_tdata,
	output										m_out_dic_b_tvalid,
	input										m_out_dic_b_tready,

	output	[6143:0]							m_out_dic_c_tdata,
	output										m_out_dic_c_tvalid,
	input										m_out_dic_c_tready,
	output	[3:0]								m_out_dic_c_tlast,
	output	[3:0]								out_dic_c_weight_switch,

	output	[255:0]								m_out_dic_d_tdata,
	output										m_out_dic_d_tvalid,
	input										m_out_dic_d_tready,
	output										m_out_dic_d_tlast,
	output										out_dic_d_weight_switch
);


	wire 						out_dic_c_tvalid, out_dic_c_tready,
								out_dic_c_tlast, out_dic_c_weight_switch_pre;


	in1536_out6144 out_dic_convert (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata			( s_in_f_tdata ),
		.s_axis_tvalid			( out_dic_c_tvalid ),
		.s_axis_tready			( out_dic_c_tready),
		.s_axis_tlast			( out_dic_c_tlast),
		.weight_switch			( out_dic_c_weight_switch_pre ),
		.m_axis_tdata			( m_out_dic_c_tdata ),
		.m_axis_tvalid			( m_out_dic_c_tvalid ),
		.m_axis_tready			( m_out_dic_c_tready ),
		.m_axis_tlast			( m_out_dic_c_tlast ),
		.weight_switch_out		( out_dic_c_weight_switch )
	);


	assign m_out_dic_a_tdata = {s_in_g_tdata, s_in_h_tdata};
	assign m_out_dic_b_tdata = s_in_f_tdata;
	assign m_out_dic_d_tdata = s_in_h_tdata;

	assign m_out_dic_a_tvalid = ~mode ? s_in_h_tvalid : 0;
	assign m_out_dic_b_tvalid = ~mode ? s_in_f_tvalid : 0;

	assign out_dic_c_tvalid   = mode ? s_in_f_tvalid : 0;
	assign out_dic_c_tlast    = mode ? s_in_f_tlast : 0;
	assign out_dic_c_weight_switch_pre = mode ? f_weight_switch : 0;

	assign m_out_dic_d_tvalid = mode ? s_in_h_tvalid : 0;
	assign m_out_dic_d_tlast  = mode ? s_in_h_tlast : 0;
	assign out_dic_d_weight_switch = mode ? h_weight_switch : 0;

	assign s_in_f_tready = mode ? out_dic_c_tready : m_out_dic_d_tready;
	assign s_in_h_tready = mode ? m_out_dic_d_tready : m_out_dic_a_tready;
	assign s_in_g_tready = ~mode & m_out_dic_a_tready;


endmodule
