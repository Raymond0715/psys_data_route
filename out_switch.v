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


	wire	[DWIDTH-1:0]		tdata_0, tdata_1;


	assign tdata_0 = s_axis_tvalid_0 ? s_axis_tdata_0 : 0;
	assign tdata_1 = s_axis_tvalid_1 ? s_axis_tdata_1 : 0;


	always @(posedge clk) begin
		if (~rst_n) begin
			m_axis_tdata <= 0;
		end
		else begin
			if ((s_axis_tvalid_0 | s_axis_tvalid_1) & m_axis_tready) begin
				m_axis_tdata <= tdata_0 | tdata_1;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			m_axis_tvalid <= 1'b0;
		end
		else begin
			if ((s_axis_tvalid_0 | s_axis_tvalid_1) & m_axis_tready) begin
				m_axis_tvalid <= 1'b1;
			end
			if (~(s_axis_tvalid_0 | s_axis_tvalid_1) & m_axis_tready) begin
				m_axis_tvalid <= 1'b0;
			end
		end
	end


	assign s_axis_tready_0 = m_axis_tready;
	assign s_axis_tready_1 = m_axis_tready;


endmodule
