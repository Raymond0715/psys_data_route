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

	output	reg [1279:0]						m_axis_g_tdata,
	output	reg									m_axis_g_tvalid,
	input										m_axis_g_tready,

	output	reg [255:0]							m_axis_h_tdata,
	output	reg									m_axis_h_tvalid,
	input										m_axis_h_tready
);


	wire	[1279:0]		data_g_0, data_g_1;
	wire	[255:0]			data_h_0, data_h_1, data_h_256_0, data_h_256_1;


	assign data_g_0 = s_axis_tvalid_0 ? s_axis_tdata_0[1535:256] : 0;
	assign data_g_1 = s_axis_tvalid_1 ? s_axis_tdata_1[1535:256] : 0;

	assign data_h_0 = s_axis_tvalid_0 ? s_axis_tdata_0[255:0] : 0;
	assign data_h_1 = s_axis_tvalid_1 ? s_axis_tdata_1[255:0] : 0;
	assign data_h_256_0 = s_axis_256_tvalid_0 ? s_axis_256_tdata_0[255:0] : 0;
	assign data_h_256_1 = s_axis_256_tvalid_1 ? s_axis_256_tdata_1[255:0] : 0;


	always @(posedge clk) begin
		if (~rst_n) begin
			m_axis_g_tdata <= 1280'd0;
			m_axis_h_tdata <= 256'd0;
		end
		else begin
			m_axis_g_tdata <= data_g_0 | data_g_1;
			m_axis_h_tdata <= data_h_0 | data_h_1 | data_h_256_0 | data_h_256_1;
			m_axis_g_tvalid <= s_axis_tvalid_0 | s_axis_tvalid_1;
			m_axis_h_tvalid <= s_axis_tvalid_0 | s_axis_tvalid_1
					  | s_axis_256_tvalid_0 | s_axis_256_tvalid_1;
		end
	end


	assign s_axis_tready_0 = m_axis_g_tready;
	assign s_axis_tready_1 = m_axis_g_tready;
	assign s_axis_256_tready_0 = m_axis_h_tready;
	assign s_axis_256_tready_1 = m_axis_h_tready;


endmodule
