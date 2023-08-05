/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/05/12
* Design Name:    poly_systolic_hw
* Module Name:    out_switch
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

module out_switch # (
	parameter DWIDTH = 128
)
(
	input										clk,
	input										rst_n,

	input										weight_switch,

	input	[DWIDTH-1:0]						s_axis_tdata_0,
	input										s_axis_tvalid_0,
	output										s_axis_tready_0,
	input										s_axis_tlast_0,

	input	[DWIDTH-1:0]						s_axis_tdata_1,
	input										s_axis_tvalid_1,
	output										s_axis_tready_1,
	input										s_axis_tlast_1,

	input	[DWIDTH-1:0]						s_axis_tdata_2,
	input										s_axis_tvalid_2,
	output										s_axis_tready_2,
	input										s_axis_tlast_2,

	output	[DWIDTH-1:0]						m_axis_tdata,
	output										m_axis_tvalid,
	input										m_axis_tready,
	output										m_axis_tlast,

	output										weight_switch_out
);


	wire	[DWIDTH-1:0]		tdata, tdata_0, tdata_1, tdata_2;
	wire						tready, tvalid, tlast_0, tlast_1, tlast_2, tlast;
	wire	[DWIDTH+1:0]		m_out;

	reg							rstn_reg;


	assign tdata_0 = s_axis_tvalid_0 ? s_axis_tdata_0 : 0;
	assign tdata_1 = s_axis_tvalid_1 ? s_axis_tdata_1 : 0;
	assign tdata_2 = s_axis_tvalid_2 ? s_axis_tdata_2 : 0;
	assign tlast_0 = s_axis_tvalid_0 ? s_axis_tlast_0 : 0;
	assign tlast_1 = s_axis_tvalid_1 ? s_axis_tlast_1 : 0;
	assign tlast_2 = s_axis_tvalid_2 ? s_axis_tlast_2 : 0;

	assign tdata = tdata_0 | tdata_1 | tdata_2;
	assign tvalid = s_axis_tvalid_0 | s_axis_tvalid_1 | s_axis_tvalid_2;
	assign tlast = tlast_0 | tlast_1 | tlast_2;

	assign s_axis_tready_0 = tready;
	assign s_axis_tready_1 = tready;
	assign s_axis_tready_2 = tready;

	assign weight_switch_out = m_out[DWIDTH+1];
	assign m_axis_tdata = m_out[DWIDTH:1];
	assign m_axis_tlast = m_out[0];


	axi_register_slice_v2_1_axic_register_slice # (
		.C_DATA_WIDTH		( DWIDTH+2 ),
		.C_REG_CONFIG		( 2 )
	)
	fwd_slice_reg_g (
		.ACLK				( clk ),
		.ARESET				( ~rst_n ),
		.S_PAYLOAD_DATA		( {weight_switch, tdata, tlast} ),
		.S_VALID			( tvalid ),
		.S_READY			( tready ),
		.M_PAYLOAD_DATA		( m_out ),
		.M_VALID			( m_axis_tvalid ),
		.M_READY			( m_axis_tready )
	);


endmodule
