/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/05/16
* Design Name:    poly_systolic_hw
* Module Name:    out_switch_flex
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

module out_switch_flex (
	input										clk,
	input										rst_n,

	input	[1535:0]							s_axis_tdata_0,
	input										s_axis_tvalid_0,
	output										s_axis_tready_0,

	input	[255:0]								s_axis_256_tdata_0,
	input										s_axis_256_tvalid_0,
	output										s_axis_256_tready_0,

	input	[1535:0]							s_axis_tdata_1,
	input										s_axis_tvalid_1,
	output										s_axis_tready_1,

	input	[255:0]								s_axis_256_tdata_1,
	input										s_axis_256_tvalid_1,
	output										s_axis_256_tready_1,

	input	[1535:0]							s_axis_tdata_2,
	input										s_axis_tvalid_2,
	output										s_axis_tready_2,

	input	[255:0]								s_axis_256_tdata_2,
	input										s_axis_256_tvalid_2,
	output										s_axis_256_tready_2,

	output	[1279:0]							m_axis_g_tdata,
	output										m_axis_g_tvalid,
	input										m_axis_g_tready,

	output	[255:0]								m_axis_h_tdata,
	output										m_axis_h_tvalid,
	input										m_axis_h_tready
);


	wire	[1279:0]		data_g, data_g_0, data_g_1, data_g_2;
	wire	[255:0]			data_h, data_h_0, data_h_1, data_h_2, 
							data_h_256_0, data_h_256_1, data_h_256_2;
	wire					valid_g, valid_h, ready_g, ready_h;


	assign data_g_0 = s_axis_tvalid_0 ? s_axis_tdata_0[1535:256] : 0;
	assign data_g_1 = s_axis_tvalid_1 ? s_axis_tdata_1[1535:256] : 0;
	assign data_g_2 = s_axis_tvalid_2 ? s_axis_tdata_2[1535:256] : 0;

	assign data_h_0 = s_axis_tvalid_0 ? s_axis_tdata_0[255:0] : 0;
	assign data_h_1 = s_axis_tvalid_1 ? s_axis_tdata_1[255:0] : 0;
	assign data_h_2 = s_axis_tvalid_2 ? s_axis_tdata_2[255:0] : 0;

	assign data_h_256_0 = s_axis_256_tvalid_0 ? s_axis_256_tdata_0[255:0] : 0;
	assign data_h_256_1 = s_axis_256_tvalid_1 ? s_axis_256_tdata_1[255:0] : 0;
	assign data_h_256_2 = s_axis_256_tvalid_2 ? s_axis_256_tdata_2[255:0] : 0;


	assign data_g = data_g_0 | data_g_1 | data_g_2;
	assign data_h = data_h_0 | data_h_1 | data_h_2
				 | data_h_256_0 | data_h_256_1 | data_h_256_2;
	assign valid_g = s_axis_tvalid_0 | s_axis_tvalid_1 | s_axis_tvalid_2;
	assign valid_h = s_axis_tvalid_0 | s_axis_tvalid_1 | s_axis_tvalid_2
				  | s_axis_256_tvalid_0 | s_axis_256_tvalid_1
				  | s_axis_256_tvalid_2;


	axi_register_slice_v2_1_axic_register_slice # (
		.C_DATA_WIDTH		( 1280 ),
		.C_REG_CONFIG		( 2 )
	)
	fwd_slice_reg_g (
		.ACLK				( clk ),
		.ARESET				( ~rst_n ),
		.S_PAYLOAD_DATA		( data_g ),
		.S_VALID			( valid_g ),
		.S_READY			( ready_g ),
		.M_PAYLOAD_DATA		( m_axis_g_tdata ),
		.M_VALID			( m_axis_g_tvalid ),
		.M_READY			( m_axis_g_tready )
	);


	axi_register_slice_v2_1_axic_register_slice # (
		.C_DATA_WIDTH		( 256 ),
		.C_REG_CONFIG		( 2 )
	)
	fwd_slice_reg_h (
		.ACLK				( clk ),
		.ARESET				( ~rst_n ),
		.S_PAYLOAD_DATA		( data_h ),
		.S_VALID			( valid_h ),
		.S_READY			( ready_h ),
		.M_PAYLOAD_DATA		( m_axis_h_tdata ),
		.M_VALID			( m_axis_h_tvalid ),
		.M_READY			( m_axis_h_tready )
	);


	assign s_axis_tready_0 = ready_g;
	assign s_axis_tready_1 = ready_g;
	assign s_axis_256_tready_0 = ready_h;
	assign s_axis_256_tready_1 = ready_h;


endmodule
