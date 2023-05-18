/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/05/18
* Design Name:    poly_systolic_hw
* Module Name:    forward_reg_slice
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


module forward_reg_slice # (
	parameter DWIDTH = 32
)
(
	input										clk,
	input										rst_n,

	input		[DWIDTH-1:0]					s_in_tdata,
	input										s_in_tvalid,
	output										s_in_tready,

	output	reg	[DWIDTH-1:0]					m_out_tdata,
	output	reg									m_out_tvalid,
	input										m_out_tready
);


	always @(posedge clk) begin
		if (~rst_n) begin
			m_out_tdata <= 0;
		end
		else begin
			if (s_in_tvalid & m_out_tready) begin
				m_out_tdata <= s_in_tdata;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			m_out_tvalid <= 1'b0;
		end
		else if (s_in_tvalid) begin
			m_out_tvalid = 1'b1;
		end
		else if (m_out_tready) begin
			m_out_tvalid = 1'b0;
		end
	end

	assign s_in_tready = m_out_tready;


endmodule
