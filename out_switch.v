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

	input										en,

	input	[DWIDTH-1:0]						s_axis_tdata_0,
	input										s_axis_tvalid_0,
	output										s_axis_tready_0,

	input	[DWIDTH-1:0]						s_axis_tdata_1,
	input										s_axis_tvalid_1,
	output										s_axis_tready_1,

	output	[DWIDTH-1:0]						m_axis_tdata,
	output										m_axis_tvalid,
	input										m_axis_tready
);


	reg 						m_axis_tvalid_reg;

	reg		[DWIDTH-1:0]		data_0, data_1;

	always @(posedge clk) begin
		if (~rst_n) begin
			data_0 <= 'd0;
			data_1 <= 'd0;
		end
		else begin
			if (s_axis_tready_0 & s_axis_tvalid_0 & en) begin
				data_0 <= s_axis_tdata_0;
			end
			else begin
				data_0 <= 0;
			end

			if (s_axis_tready_1 & s_axis_tvalid_1 & en) begin
				data_1 <= s_axis_tdata_1;
			end
			else begin
				data_1 <= 0;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			m_axis_tvalid_reg <= 0;
		end
		else begin
			if (s_axis_tvalid_0 | s_axis_tvalid_1) begin
				m_axis_tvalid_reg <= 1;
			end
			else begin
				m_axis_tvalid_reg <= 0;
			end
		end
	end


	assign m_axis_tvalid = en & m_axis_tvalid_reg;
	assign s_axis_tready_0 = m_axis_tready;
	assign s_axis_tready_1 = m_axis_tready;
	assign m_axis_tdata = data_0 | data_1;


endmodule
