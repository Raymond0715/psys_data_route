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

	input	[DWIDTH-1:0]						s_axis_tdata_0,
	input										s_axis_tvalid_0,
	output										s_axis_tready_0,

	input	[DWIDTH-1:0]						s_axis_tdata_1,
	input										s_axis_tvalid_1,
	output										s_axis_tready_1,

	output	reg [DWIDTH-1:0]					m_axis_tdata,
	output	reg									m_axis_tvalid,
	input										m_axis_tready
);


	wire	[DWIDTH-1:0]		data_0, data_1;


	assign data_0 = s_axis_tvalid_0 ? s_axis_tdata_0 : 0;
	assign data_1 = s_axis_tvalid_1 ? s_axis_tdata_1 : 0;


	always @(posedge clk) begin
		if (~rst_n) begin
			m_axis_tdata <= 'd0;
			m_axis_tvalid <= 0;
		end
		else begin
			if ((s_axis_tvalid_0 & s_axis_tready_0) | (s_axis_tvalid_1 & s_axis_tready_1)) begin
				m_axis_tdata <= data_0 | data_1;
			end
			m_axis_tvalid <= s_axis_tvalid_0 | s_axis_tvalid_1;
		end
	end


	assign s_axis_tready_0 = m_axis_tready;
	assign s_axis_tready_1 = m_axis_tready;


endmodule
