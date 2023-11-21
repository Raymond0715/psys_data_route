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
* - ctrl { flex_shift_reg[18:10], flex_shift_ctrl[9:7],
*          switch_tvalid_out[6:3], switch_tvalid_in[2:0] }
*
*******************************************************************************/

`include "define_droute.vh"

module data_route (
	input										clk,
	input										rst_n,

	input	[18:0]								s_droute_switch_0,
	output										count_switch_0_tvalid,
	input	[18:0]								s_droute_switch_1,
	output										count_switch_1_tvalid,
	input	[18:0]								s_droute_switch_2,
	output										count_switch_2_tvalid,

	output	[5:0]								in_valid,

	input										dic_mode,

	input										pe_array_weight_data_switch,

	input	[127:0]								s_in_a_tdata,
	input										s_in_a_tvalid,
	output										s_in_a_tready,
	input	[15:0]								s_in_a_tkeep,
	input										s_in_a_tlast,
	output	[127:0]								m_out_a_tdata,
	output										m_out_a_tvalid,
	input										m_out_a_tready,
	output	reg [15:0]							m_out_a_tkeep = 16'hffff,
	output										m_out_a_tlast,

	input	[127:0]								s_in_b_tdata,
	input										s_in_b_tvalid,
	output										s_in_b_tready,
	input	[15:0]								s_in_b_tkeep,
	input										s_in_b_tlast,
	output	[127:0]								m_out_b_tdata,
	output										m_out_b_tvalid,
	input										m_out_b_tready,
	output	reg [15:0]							m_out_b_tkeep = 16'hffff,
	output	reg									m_out_b_tlast = 1'b0,

	input	[1535:0]							s_in_c_tdata,
	input										s_in_c_tvalid,
	output										s_in_c_tready,
	input	[15:0]								s_in_c_tkeep,
	input	[23:0]								s_in_c_tlast,
	output	[1535:0]							m_out_c_tdata,
	output										m_out_c_tvalid,
	input										m_out_c_tready,
	output	reg [15:0]							m_out_c_tkeep = 16'hffff,
	output	[11:0]								m_out_c_tlast,

	input	[1535:0]							s_in_d_tdata,
	input										s_in_d_tvalid,
	output										s_in_d_tready,
	input	[15:0]								s_in_d_tkeep,
	input	[23:0]								s_in_d_tlast,
	output	[1535:0]							m_out_d_tdata,
	output										m_out_d_tvalid,
	input										m_out_d_tready,
	output	reg [15:0]							m_out_d_tkeep = 16'hffff,
	output	[11:0]								m_out_d_tlast,

	input	[1535:0]							s_in_e_tdata,
	input										s_in_e_tvalid,
	output										s_in_e_tready,
	output	[1535:0]							m_out_e_tdata,
	output										m_out_e_tvalid,
	input										m_out_e_tready,

	output	[1535:0]							m_out_dic_a_tdata,
	output										m_out_dic_a_tvalid,
	input										m_out_dic_a_tready,

	output	[1535:0]							m_out_dic_b_tdata,
	output										m_out_dic_b_tvalid,
	input										m_out_dic_b_tready,

	output	[3071:0]							m_out_dic_c_tdata,
	output										m_out_dic_c_tvalid,
	input										m_out_dic_c_tready,
	output	reg [15:0]							m_out_dic_c_tkeep = 16'hffff,
	output	[3:0]								m_out_dic_c_tlast,
	output										out_dic_c_weight_switch,

	output	[255:0]								m_out_dic_d_tdata,
	output										m_out_dic_d_tvalid,
	input										m_out_dic_d_tready,
	output	reg [15:0]							m_out_dic_d_tkeep = 16'hffff,
	output										m_out_dic_d_tlast,
	output										out_dic_d_weight_switch,

	input	[1535:0]							s_in_i_tdata,
	input										s_in_i_tvalid,
	output										s_in_i_tready,
	output	[1535:0]							m_out_i_tdata,
	output										m_out_i_tvalid,
	input										m_out_i_tready

);


`ifdef SIM_BD
	wire	[127:0]			sim_in_a_tdata;
	wire					sim_in_a_tvalid, sim_in_a_tready, sim_in_a_tlast;

	data_gen # (
		.WIDTH					( 128	),
		.LENGTH					( 87048	),
		.DPATH 					( "/media/Projects/poly_systolic_unit/py-sim/dat/conv_256_56/input.txt"),
		.RAND					( 0 ),
		.RAND_CYC				( 1 )
	)
	in_gen_d (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.m_tdata				( sim_in_a_tdata ),
		.m_tvalid				( sim_in_a_tvalid ),
		.m_tlast				( sim_in_a_tlast ),
		.m_tready				( sim_in_a_tready )
	);

`endif


	wire	[1535:0]		in_a_tdata, in_b_tdata;
	wire	[11:0]			in_a_tlast, in_b_tlast;
	wire					in_a_tvalid, in_b_tvalid;
	wire					in_a_tready_0, in_b_tready_0,
							in_a_tready_1, in_b_tready_1,
							in_a_tready_2, in_b_tready_2;

	wire	[1535:0]		in_f_tdata;
	wire	[1279:0]		in_g_tdata;
	wire	[255:0]			in_h_tdata;
	
	wire					in_f_tvalid, in_f_tready,
							in_g_tvalid, in_g_tready,
							in_h_tvalid, in_h_tready;

	wire	[1535:0]		switch_out_0, switch_out_1, switch_out_2;
	wire	[255:0]			switch_out_0_256, switch_out_1_256, switch_out_2_256;
	wire	[127:0]			switch_out_0_128_a, switch_out_0_128_b,
							switch_out_1_128_a, switch_out_1_128_b,
							switch_out_2_128_a, switch_out_2_128_b;

	wire		s_in_c_tready_0, s_in_d_tready_0, s_in_e_tready_0, s_in_i_tready_0;
	wire		s_in_c_tready_1, s_in_d_tready_1, s_in_e_tready_1, s_in_i_tready_1;
	wire		s_in_c_tready_2, s_in_d_tready_2, s_in_e_tready_2, s_in_i_tready_2;

	wire	out_a_tvalid_0, out_a_tready_0, out_b_tvalid_0, out_b_tready_0,
			out_c_tvalid_0, out_c_tready_0, out_d_tvalid_0, out_d_tready_0,
			out_e_tvalid_0, out_e_tready_0, out_f_tvalid_0, out_f_tready_0,
			out_g_tvalid_0, out_g_tready_0, out_h_tvalid_0, out_h_tready_0,
			out_i_tvalid_0, out_i_tready_0;

	wire 	out_a_tvalid_1, out_a_tready_1, out_b_tvalid_1, out_b_tready_1,
			out_c_tvalid_1, out_c_tready_1, out_d_tvalid_1, out_d_tready_1,
			out_e_tvalid_1, out_e_tready_1, out_f_tvalid_1, out_f_tready_1,
			out_g_tvalid_1, out_g_tready_1, out_h_tvalid_1, out_h_tready_1,
			out_i_tvalid_1, out_i_tready_1;

	wire	out_a_tvalid_2, out_a_tready_2, out_b_tvalid_2, out_b_tready_2,
			out_c_tvalid_2, out_c_tready_2, out_d_tvalid_2, out_d_tready_2,
			out_e_tvalid_2, out_e_tready_2, out_f_tvalid_2, out_f_tready_2,
			out_g_tvalid_2, out_g_tready_2, out_h_tvalid_2, out_h_tready_2,
			out_i_tvalid_2, out_i_tready_2;

	wire	out_f_tlast_0, out_f_tlast_1, out_f_tlast_2,
			out_g_tlast_0, out_g_tlast_1, out_g_tlast_2,
			out_h_tlast_0, out_h_tlast_1, out_h_tlast_2;
	wire	[11:0]		out_c_tlast_0, out_c_tlast_1, out_c_tlast_2,
						out_d_tlast_0, out_d_tlast_1, out_d_tlast_2;
	wire	in_f_tlast, in_g_tlast, in_h_tlast;
	wire	out_a_tlast_0, out_a_tlast_1, out_a_tlast_2;

	wire	out_weight_switch, out_weight_switch_0,
			out_weight_switch_1, out_weight_switch_2;

	wire	in_h_weight_switch, in_f_weight_switch;


	assign in_valid = {s_in_e_tvalid, s_in_d_tvalid, s_in_c_tvalid,
		in_b_tvalid, in_a_tvalid};
	//assign in_valid = {s_in_e_tvalid & s_in_e_tready,
		//s_in_d_tvalid & s_in_d_tready, s_in_c_tvalid & s_in_c_tready,
		//in_b_tvalid, in_a_tvalid};

	assign s_in_c_tready = s_in_c_tready_0 | s_in_c_tready_1 | s_in_c_tready_2;
	assign s_in_d_tready = s_in_d_tready_0 | s_in_d_tready_1 | s_in_d_tready_2;
	assign s_in_e_tready = s_in_e_tready_0 | s_in_e_tready_1 | s_in_e_tready_2;
	assign s_in_i_tready = s_in_i_tready_0 | s_in_i_tready_1 | s_in_i_tready_2;


	in128_out1536 dwidth_converter_ina (
		.clk					( clk ),
		.rst_n					( rst_n ),
`ifdef SIM_BD
		.s_axis_tdata			( sim_in_a_tdata ),
		.s_axis_tvalid			( sim_in_a_tvalid ),
		.s_axis_tready			( sim_in_a_tready ),
		.s_axis_tlast			( sim_in_a_tlast ),
`else
		.s_axis_tdata			( s_in_a_tdata ),
		.s_axis_tvalid			( s_in_a_tvalid ),
		.s_axis_tready			( s_in_a_tready ),
		.s_axis_tlast			( s_in_a_tlast ),
`endif
		.m_axis_tdata			( in_a_tdata ),
		.m_axis_tvalid			( in_a_tvalid ),
		.m_axis_tready			( in_a_tready_0 | in_a_tready_1 | in_a_tready_2 ),
		.m_axis_tlast			( in_a_tlast )
	);


	in128_out1536 dwidth_converter_inb (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata			( s_in_b_tdata ),
		.s_axis_tvalid			( s_in_b_tvalid ),
		.s_axis_tready			( s_in_b_tready ),
		.s_axis_tlast			( s_in_b_tlast ),
		.m_axis_tdata			( in_b_tdata ),
		.m_axis_tvalid			( in_b_tvalid ),
		.m_axis_tready			( in_b_tready_0 | in_b_tready_1 | in_b_tready_2 ),
		.m_axis_tlast			( in_b_tlast )
	);


	inter_switch inter_switch_0 (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.ctrl					( s_droute_switch_0 ),
		.count_switch_tvalid	( count_switch_0_tvalid ),
		.weight_switch			( pe_array_weight_data_switch ),

		.s_in_a_tdata			( in_a_tdata  ),
		.s_in_a_tvalid			( in_a_tvalid ),
		.s_in_a_tready			( in_a_tready_0 ),
		.s_in_a_tlast			( in_a_tlast ),
		.s_in_b_tdata			( in_b_tdata  ),
		.s_in_b_tvalid			( in_b_tvalid ),
		.s_in_b_tready			( in_b_tready_0 ),
		.s_in_b_tlast			( in_b_tlast ),
		.s_in_c_tdata			( s_in_c_tdata  ),
		.s_in_c_tvalid			( s_in_c_tvalid ),
		.s_in_c_tready			( s_in_c_tready_0 ),
		.s_in_c_tlast			( s_in_c_tlast ),
		.s_in_d_tdata			( s_in_d_tdata  ),
		.s_in_d_tvalid			( s_in_d_tvalid ),
		.s_in_d_tready			( s_in_d_tready_0 ),
		.s_in_d_tlast			( s_in_d_tlast ),
		.s_in_e_tdata			( s_in_e_tdata  ),
		.s_in_e_tvalid			( s_in_e_tvalid ),
		.s_in_e_tready			( s_in_e_tready_0 ),
		.s_in_i_tdata			( s_in_i_tdata  ),
		.s_in_i_tvalid			( s_in_i_tvalid ),
		.s_in_i_tready			( s_in_i_tready_0 ),

		.m_out					( switch_out_0 ),
		.m_out_256				( switch_out_0_256 ),
		.m_out_128_a			( switch_out_0_128_a ),
		.m_out_128_b			( switch_out_0_128_b ),
		.m_out_a_tvalid			( out_a_tvalid_0 ),
		.m_out_a_tready			( out_a_tready_0 ),
		.m_out_a_tlast			( out_a_tlast_0 ),
		.m_out_b_tvalid			( out_b_tvalid_0 ),
		.m_out_b_tready			( out_b_tready_0 ),
		.m_out_c_tvalid			( out_c_tvalid_0 ),
		.m_out_c_tready			( out_c_tready_0 ),
		.m_out_c_tlast			( out_c_tlast_0 ),
		.m_out_d_tvalid			( out_d_tvalid_0 ),
		.m_out_d_tready			( out_d_tready_0 ),
		.m_out_d_tlast			( out_d_tlast_0 ),
		.m_out_e_tvalid			( out_e_tvalid_0 ),
		.m_out_e_tready			( out_e_tready_0 ),
		.m_out_f_tvalid			( out_f_tvalid_0 ),
		.m_out_f_tready			( out_f_tready_0 ),
		.m_out_f_tlast			( out_f_tlast_0 ),
		.m_out_g_tvalid			( out_g_tvalid_0 ),
		.m_out_g_tready			( out_g_tready_0 ),
		.m_out_g_tlast			( out_g_tlast_0 ),
		.m_out_h_tvalid			( out_h_tvalid_0 ),
		.m_out_h_tready			( out_h_tready_0 ),
		.m_out_h_tlast			( out_h_tlast_0 ),
		.m_out_i_tvalid			( out_i_tvalid_0 ),
		.m_out_i_tready			( out_i_tready_0 ),
		.m_inter_weight_switch	( out_weight_switch_0 )
	);


	inter_switch inter_switch_1 (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.ctrl					( s_droute_switch_1 ),
		.count_switch_tvalid	( count_switch_1_tvalid ),
		.weight_switch			( pe_array_weight_data_switch ),

		.s_in_a_tdata			( in_a_tdata  ),
		.s_in_a_tvalid			( in_a_tvalid ),
		.s_in_a_tready			( in_a_tready_1 ),
		.s_in_a_tlast			( in_a_tlast ),
		.s_in_b_tdata			( in_b_tdata  ),
		.s_in_b_tvalid			( in_b_tvalid ),
		.s_in_b_tready			( in_b_tready_1 ),
		.s_in_b_tlast			( in_b_tlast ),
		.s_in_c_tdata			( s_in_c_tdata  ),
		.s_in_c_tvalid			( s_in_c_tvalid ),
		.s_in_c_tready			( s_in_c_tready_1 ),
		.s_in_c_tlast			( s_in_c_tlast ),
		.s_in_d_tdata			( s_in_d_tdata  ),
		.s_in_d_tvalid			( s_in_d_tvalid ),
		.s_in_d_tready			( s_in_d_tready_1 ),
		.s_in_d_tlast			( s_in_d_tlast ),
		.s_in_e_tdata			( s_in_e_tdata  ),
		.s_in_e_tvalid			( s_in_e_tvalid ),
		.s_in_e_tready			( s_in_e_tready_1 ),
		.s_in_i_tdata			( s_in_i_tdata  ),
		.s_in_i_tvalid			( s_in_i_tvalid ),
		.s_in_i_tready			( s_in_i_tready_1 ),

		.m_out					( switch_out_1 ),
		.m_out_256				( switch_out_1_256 ),
		.m_out_128_a			( switch_out_1_128_a ),
		.m_out_128_b			( switch_out_1_128_b ),
		.m_out_a_tvalid			( out_a_tvalid_1 ),
		.m_out_a_tready			( out_a_tready_1 ),
		.m_out_a_tlast			( out_a_tlast_1 ),
		.m_out_b_tvalid			( out_b_tvalid_1 ),
		.m_out_b_tready			( out_b_tready_1 ),
		.m_out_c_tvalid			( out_c_tvalid_1 ),
		.m_out_c_tready			( out_c_tready_1 ),
		.m_out_c_tlast			( out_c_tlast_1 ),
		.m_out_d_tvalid			( out_d_tvalid_1 ),
		.m_out_d_tready			( out_d_tready_1 ),
		.m_out_d_tlast			( out_d_tlast_1 ),
		.m_out_e_tvalid			( out_e_tvalid_1 ),
		.m_out_e_tready			( out_e_tready_1 ),
		.m_out_f_tvalid			( out_f_tvalid_1 ),
		.m_out_f_tready			( out_f_tready_1 ),
		.m_out_f_tlast			( out_f_tlast_1 ),
		.m_out_g_tvalid			( out_g_tvalid_1 ),
		.m_out_g_tready			( out_g_tready_1 ),
		.m_out_g_tlast			( out_g_tlast_1 ),
		.m_out_h_tvalid			( out_h_tvalid_1 ),
		.m_out_h_tready			( out_h_tready_1 ),
		.m_out_h_tlast			( out_h_tlast_1 ),
		.m_out_i_tvalid			( out_i_tvalid_1 ),
		.m_out_i_tready			( out_i_tready_1 ),
		.m_inter_weight_switch	( out_weight_switch_1 )
	);


	inter_switch inter_switch_2 (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.ctrl					( s_droute_switch_2 ),
		.count_switch_tvalid	( count_switch_2_tvalid ),
		.weight_switch			( pe_array_weight_data_switch ),

		.s_in_a_tdata			( in_a_tdata  ),
		.s_in_a_tvalid			( in_a_tvalid ),
		.s_in_a_tready			( in_a_tready_2 ),
		.s_in_a_tlast			( in_a_tlast ),
		.s_in_b_tdata			( in_b_tdata  ),
		.s_in_b_tvalid			( in_b_tvalid ),
		.s_in_b_tready			( in_b_tready_2 ),
		.s_in_b_tlast			( in_b_tlast ),
		.s_in_c_tdata			( s_in_c_tdata  ),
		.s_in_c_tvalid			( s_in_c_tvalid ),
		.s_in_c_tready			( s_in_c_tready_2 ),
		.s_in_c_tlast			( s_in_c_tlast ),
		.s_in_d_tdata			( s_in_d_tdata  ),
		.s_in_d_tvalid			( s_in_d_tvalid ),
		.s_in_d_tready			( s_in_d_tready_2 ),
		.s_in_d_tlast			( s_in_d_tlast ),
		.s_in_e_tdata			( s_in_e_tdata  ),
		.s_in_e_tvalid			( s_in_e_tvalid ),
		.s_in_e_tready			( s_in_e_tready_2 ),
		.s_in_i_tdata			( s_in_i_tdata  ),
		.s_in_i_tvalid			( s_in_i_tvalid ),
		.s_in_i_tready			( s_in_i_tready_2 ),

		.m_out					( switch_out_2 ),
		.m_out_256				( switch_out_2_256 ),
		.m_out_128_a			( switch_out_2_128_a ),
		.m_out_128_b			( switch_out_2_128_b ),
		.m_out_a_tvalid			( out_a_tvalid_2 ),
		.m_out_a_tready			( out_a_tready_2 ),
		.m_out_a_tlast			( out_a_tlast_2 ),
		.m_out_b_tvalid			( out_b_tvalid_2 ),
		.m_out_b_tready			( out_b_tready_2 ),
		.m_out_c_tvalid			( out_c_tvalid_2 ),
		.m_out_c_tready			( out_c_tready_2 ),
		.m_out_c_tlast			( out_c_tlast_2 ),
		.m_out_d_tvalid			( out_d_tvalid_2 ),
		.m_out_d_tready			( out_d_tready_2 ),
		.m_out_d_tlast			( out_d_tlast_2 ),
		.m_out_e_tvalid			( out_e_tvalid_2 ),
		.m_out_e_tready			( out_e_tready_2 ),
		.m_out_f_tvalid			( out_f_tvalid_2 ),
		.m_out_f_tready			( out_f_tready_2 ),
		.m_out_f_tlast			( out_f_tlast_2 ),
		.m_out_g_tvalid			( out_g_tvalid_2 ),
		.m_out_g_tready			( out_g_tready_2 ),
		.m_out_g_tlast			( out_g_tlast_2 ),
		.m_out_h_tvalid			( out_h_tvalid_2 ),
		.m_out_h_tready			( out_h_tready_2 ),
		.m_out_h_tlast			( out_h_tlast_2 ),
		.m_out_i_tvalid			( out_i_tvalid_2 ),
		.m_out_i_tready			( out_i_tready_2 ),
		.m_inter_weight_switch	( out_weight_switch_2 )
	);


	out_switch # (
		.DWIDTH (128)
		,.LASTW  (1)
	)
	out_switch_a (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0_128_a ),
		.s_axis_tvalid_0		( out_a_tvalid_0 ),
		.s_axis_tready_0		( out_a_tready_0 ),
		.s_axis_tlast_0			( out_a_tlast_0 ),
		.s_axis_tdata_1			( switch_out_1_128_a ),
		.s_axis_tvalid_1		( out_a_tvalid_1 ),
		.s_axis_tready_1		( out_a_tready_1 ),
		.s_axis_tlast_1			( out_a_tlast_1 ),
		.s_axis_tdata_2			( switch_out_2_128_a ),
		.s_axis_tvalid_2		( out_a_tvalid_2 ),
		.s_axis_tready_2		( out_a_tready_2 ),
		.s_axis_tlast_2			( out_a_tlast_2 ),
		.m_axis_tdata			( m_out_a_tdata ),
		.m_axis_tvalid			( m_out_a_tvalid ),
`ifdef SIM_BD
		.m_axis_tready			( 1'b1 ),
`else
		.m_axis_tready			( m_out_a_tready ),
`endif
		.m_axis_tlast			( m_out_a_tlast )
	);


	out_switch # (
		.DWIDTH (128)
		,.LASTW  (1)
	)
	out_switch_b (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0_128_b ),
		.s_axis_tvalid_0		( out_b_tvalid_0 ),
		.s_axis_tready_0		( out_b_tready_0 ),
		.s_axis_tlast_0			( out_b_tlast_0 ),
		.s_axis_tdata_1			( switch_out_1_128_b ),
		.s_axis_tvalid_1		( out_b_tvalid_1 ),
		.s_axis_tready_1		( out_b_tready_1 ),
		.s_axis_tlast_1			( out_b_tlast_1 ),
		.s_axis_tdata_2			( switch_out_2_128_b ),
		.s_axis_tvalid_2		( out_b_tvalid_2 ),
		.s_axis_tready_2		( out_b_tready_2 ),
		.s_axis_tlast_2			( out_b_tlast_2 ),
		.m_axis_tdata			( m_out_b_tdata ),
		.m_axis_tvalid			( m_out_b_tvalid ),
		.m_axis_tready			( m_out_b_tready )
	);


	out_switch # (
		.DWIDTH (1536)
		,.LASTW  (12)
	)
	out_switch_c (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0 ),
		.s_axis_tvalid_0		( out_c_tvalid_0 ),
		.s_axis_tready_0		( out_c_tready_0 ),
		.s_axis_tlast_0			( out_c_tlast_0 ),
		.s_axis_tdata_1			( switch_out_1 ),
		.s_axis_tvalid_1		( out_c_tvalid_1 ),
		.s_axis_tready_1		( out_c_tready_1 ),
		.s_axis_tlast_1			( out_c_tlast_1 ),
		.s_axis_tdata_2			( switch_out_2 ),
		.s_axis_tvalid_2		( out_c_tvalid_2 ),
		.s_axis_tready_2		( out_c_tready_2 ),
		.s_axis_tlast_2			( out_c_tlast_2 ),
		.m_axis_tdata			( m_out_c_tdata ),
		.m_axis_tvalid			( m_out_c_tvalid ),
		.m_axis_tready			( m_out_c_tready ),
		.m_axis_tlast			( m_out_c_tlast )
	);


	out_switch # (
		.DWIDTH (1536)
		,.LASTW  (12)
	)
	out_switch_d (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0 ),
		.s_axis_tvalid_0		( out_d_tvalid_0 ),
		.s_axis_tready_0		( out_d_tready_0 ),
		.s_axis_tlast_0			( out_d_tlast_0 ),
		.s_axis_tdata_1			( switch_out_1 ),
		.s_axis_tvalid_1		( out_d_tvalid_1 ),
		.s_axis_tready_1		( out_d_tready_1 ),
		.s_axis_tlast_1			( out_d_tlast_1 ),
		.s_axis_tdata_2			( switch_out_2 ),
		.s_axis_tvalid_2		( out_d_tvalid_2 ),
		.s_axis_tready_2		( out_d_tready_2 ),
		.s_axis_tlast_2			( out_d_tlast_2 ),
		.m_axis_tdata			( m_out_d_tdata ),
		.m_axis_tvalid			( m_out_d_tvalid ),
		.m_axis_tready			( m_out_d_tready ),
		.m_axis_tlast			( m_out_d_tlast )
	);


	out_switch # (
		.DWIDTH (1536)
	)
	out_switch_e (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0 ),
		.s_axis_tvalid_0		( out_e_tvalid_0 ),
		.s_axis_tready_0		( out_e_tready_0 ),
		.s_axis_tdata_1			( switch_out_1 ),
		.s_axis_tvalid_1		( out_e_tvalid_1 ),
		.s_axis_tready_1		( out_e_tready_1 ),
		.s_axis_tdata_2			( switch_out_2 ),
		.s_axis_tvalid_2		( out_e_tvalid_2 ),
		.s_axis_tready_2		( out_e_tready_2 ),
		.m_axis_tdata			( m_out_e_tdata ),
		.m_axis_tvalid			( m_out_e_tvalid ),
		.m_axis_tready			( m_out_e_tready )
	);


	assign out_weight_switch =
		out_weight_switch_0 | out_weight_switch_1 | out_weight_switch_2;


	out_switch # (
		.DWIDTH (1536)
		,.LASTW  (1)
	)
	out_switch_f (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.weight_switch			( out_weight_switch ),
		.s_axis_tdata_0			( switch_out_0 ),
		.s_axis_tvalid_0		( out_f_tvalid_0 ),
		.s_axis_tready_0		( out_f_tready_0 ),
		.s_axis_tlast_0			( out_f_tlast_0 ),
		.s_axis_tdata_1			( switch_out_1 ),
		.s_axis_tvalid_1		( out_f_tvalid_1 ),
		.s_axis_tready_1		( out_f_tready_1 ),
		.s_axis_tlast_1			( out_f_tlast_1 ),
		.s_axis_tdata_2			( switch_out_2 ),
		.s_axis_tvalid_2		( out_f_tvalid_2 ),
		.s_axis_tready_2		( out_f_tready_2 ),
		.s_axis_tlast_2			( out_f_tlast_2 ),
		.m_axis_tdata			( in_f_tdata ),
		.m_axis_tvalid			( in_f_tvalid ),
		.m_axis_tready			( in_f_tready ),
		.m_axis_tlast			( in_f_tlast ),
		.weight_switch_out		( in_f_weight_switch )
	);


	out_switch_flex out_switch_g_h (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.weight_switch			( out_weight_switch ),
		.s_axis_tdata_0			( switch_out_0 ),
		.s_axis_tvalid_0		( out_g_tvalid_0 ),
		.s_axis_tready_0		( out_g_tready_0 ),
		.s_axis_tlast_0			( out_g_tlast_0 ),
		.s_axis_256_tdata_0		( switch_out_0_256 ),
		.s_axis_256_tvalid_0	( out_h_tvalid_0 ),
		.s_axis_256_tready_0	( out_h_tready_0 ),
		.s_axis_256_tlast_0		( out_h_tlast_0 ),

		.s_axis_tdata_1			( switch_out_1 ),
		.s_axis_tvalid_1		( out_g_tvalid_1 ),
		.s_axis_tready_1		( out_g_tready_1 ),
		.s_axis_tlast_1			( out_g_tlast_1 ),
		.s_axis_256_tdata_1		( switch_out_1_256 ),
		.s_axis_256_tvalid_1	( out_h_tvalid_1 ),
		.s_axis_256_tready_1	( out_h_tready_1 ),
		.s_axis_256_tlast_1		( out_h_tlast_1 ),

		.s_axis_tdata_2			( switch_out_2 ),
		.s_axis_tvalid_2		( out_g_tvalid_2 ),
		.s_axis_tready_2		( out_g_tready_2 ),
		.s_axis_tlast_2			( out_g_tlast_2 ),
		.s_axis_256_tdata_2		( switch_out_2_256 ),
		.s_axis_256_tvalid_2	( out_h_tvalid_2 ),
		.s_axis_256_tready_2	( out_h_tready_2 ),
		.s_axis_256_tlast_2		( out_h_tlast_2 ),

		.m_axis_g_tdata			( in_g_tdata ),
		.m_axis_g_tvalid		( in_g_tvalid ),
		.m_axis_g_tready		( in_g_tready ),
		.m_axis_g_tlast			( in_g_tlast ),
		.m_axis_h_tdata			( in_h_tdata ),
		.m_axis_h_tvalid		( in_h_tvalid ),
		.m_axis_h_tready		( in_h_tready ),
		.m_axis_h_tlast			( in_h_tlast ),
		.weight_switch_h		( in_h_weight_switch )
	);


	out_switch # (
		.DWIDTH (1536)
	)
	out_switch_i (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.s_axis_tdata_0			( switch_out_0 ),
		.s_axis_tvalid_0		( out_i_tvalid_0 ),
		.s_axis_tready_0		( out_i_tready_0 ),
		.s_axis_tdata_1			( switch_out_1 ),
		.s_axis_tvalid_1		( out_i_tvalid_1 ),
		.s_axis_tready_1		( out_i_tready_1 ),
		.s_axis_tdata_2			( switch_out_2 ),
		.s_axis_tvalid_2		( out_i_tvalid_2 ),
		.s_axis_tready_2		( out_i_tready_2 ),
		.m_axis_tdata			( m_out_i_tdata ),
		.m_axis_tvalid			( m_out_i_tvalid ),
		.m_axis_tready			( m_out_i_tready )
	);

	data_interconnect_0 data_interconnect_0_inst (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.mode					( dic_mode ),

		.s_in_f_tdata			( in_f_tdata  ),
		.s_in_f_tvalid			( in_f_tvalid ),
		.s_in_f_tready			( in_f_tready ),
		.s_in_f_tlast			( in_f_tlast ),
		.f_weight_switch		( in_f_weight_switch ),
		.s_in_g_tdata			( in_g_tdata  ),
		.s_in_g_tvalid			( in_g_tvalid ),
		.s_in_g_tready			( in_g_tready ),
		.s_in_g_tlast			( in_g_tlast ),
		.s_in_h_tdata			( in_h_tdata  ),
		.s_in_h_tvalid			( in_h_tvalid ),
		.s_in_h_tready			( in_h_tready ),
		.s_in_h_tlast			( in_h_tlast ),
		.h_weight_switch		( in_h_weight_switch ),

		.m_out_dic_a_tdata		( m_out_dic_a_tdata  ),
		.m_out_dic_a_tvalid		( m_out_dic_a_tvalid ),
		.m_out_dic_a_tready		( m_out_dic_a_tready ),
		.m_out_dic_b_tdata		( m_out_dic_b_tdata  ),
		.m_out_dic_b_tvalid		( m_out_dic_b_tvalid ),
		.m_out_dic_b_tready		( m_out_dic_b_tready ),
		.m_out_dic_c_tdata		( m_out_dic_c_tdata  ),
		.m_out_dic_c_tvalid		( m_out_dic_c_tvalid ),
		.m_out_dic_c_tready		( m_out_dic_c_tready ),
		.m_out_dic_c_tlast		( m_out_dic_c_tlast ),
		.out_dic_c_weight_switch	( out_dic_c_weight_switch ),
		.m_out_dic_d_tdata		( m_out_dic_d_tdata  ),
		.m_out_dic_d_tvalid		( m_out_dic_d_tvalid ),
		.m_out_dic_d_tready		( m_out_dic_d_tready ),
		.m_out_dic_d_tlast		( m_out_dic_d_tlast ),
		.out_dic_d_weight_switch	( out_dic_d_weight_switch )
	);


`ifdef SIM_BD
	integer handle0 ;
	initial handle0=$fopen("/media/Projects/poly_systolic_unit/py-sim/dat/poly_systolic/out_b_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (m_out_b_tvalid & m_out_b_tready) begin
				$fdisplay(handle0,"%h",m_out_b_tdata);
			end
		end
	end
`endif


endmodule
