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
* - ctrl { out_flex[14:12], switch_tvalid_out_1[11:9], switch_tvalid_in_1[8:6],
*          switch_tvalid_out_0[5:3], switch_tvalid_in_0[2:0] }
* - ctrl == 0  ->  disable
* - OUT_G & OUT_H ctrl signal need one more bit.
*
*******************************************************************************/


module data_route (
	input										clk,
	input										rst_n,

	input	[14:0]								ctrl,

	output	[13:0]								addra,
	input	[1535:0]							dina,
	output	[1535:0]							douta,
	output										ena,
	output										wea,

	output	[13:0]								addrb,
	input	[1535:0]							dinb,
	output	[1535:0]							doutb,
	output										enb,
	output										web,

	input	[1535:0]							in_c_tdata,
	output	[1535:0]							out_c_tdata,

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

	output	[1535:0]							out_f_tdata,
	output										out_f_valid,
	input										out_f_ready,

	output	[1279:0]							out_g_tdata,
	output										out_g_valid,
	input										out_g_ready,

	output	[255:0]								out_h_tdata,
	output										out_h_valid,
	input										out_h_ready

);


	wire	[1535:0]		in_d_tdata_1536, in_e_tdata_1536;
	wire					in_d_tvalid, in_e_tvalid;


	// Switch 0, 1536 & 128


	// Switch 1, 1536 & 128
	

	// output
	//reg		[7:0]			switch_out_tvalid_reg;

	//always @(posedge clk) begin
		//if (~rst_n) begin
			//switch_out_tvalid_reg <= 'd0;
		//end
		//else begin
			//switch_out_tvalid_reg <= switch_0_out_tvalid | switch_1_out_tvalid;
		//end
	//end

	// Instance output
	wire		s_out_d_tvalid_0;
	out_switch # (
		.DWIDTH (128)
	)
	out_switch_d (
		.clk				( clk ),
		.rst_n				( rst_n ),
		.en					( switch_out_tvalid_reg[4] ),
		.s_axis_tdata_0		( inter_0_128_reg ),
		.s_axis_tvalid_0	( ),
		.s_axis_tready_0	( ),
		.s_axis_tdata_1		( inter_1_128_reg ),
		.s_axis_tvalid_1	( ),
		.s_axis_tready_1	( ),
		.m_axis_tdata		( m_out_d_tdata ),
		.m_axis_tvalid		( m_out_d_tvalid ),
		.m_axis_tready		( m_out_d_tready )
	);


	// Instance data width convert
	in128_out1536 dwidth_converter_ind (
		.aclk				( clk ),
		.aresetn			( rst_n ),
		.s_axis_tdata		( s_in_d_tdata ),
		.s_axis_tvalid		( s_in_d_tvalid ),
		.s_axis_tready		( s_in_d_tready ),
		.m_axis_tdata		( in_d_tdata_1536 ),
		.m_axis_tvalid		( in_d_tvalid ),
		.m_axis_tready		( )
	);


	in128_out1536 dwidth_converter_ine (
		.aclk				( clk ),
		.aresetn			( rst_n ),
		.s_axis_tdata		( s_in_e_tdata ),
		.s_axis_tvalid		( s_in_e_tvalid ),
		.s_axis_tready		( s_in_e_tready ),
		.m_axis_tdata		( in_e_tdata_1536 ),
		.m_axis_tvalid		( ),
		.m_axis_tready		( )
	);


endmodule
