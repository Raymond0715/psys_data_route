/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/07/23
* Design Name:    poly_systolic_hw
* Module Name:    in1536_out6144
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


module in1536_out6144 (
	input										clk,
	input										rst_n,

	input	[1535:0]							s_axis_tdata,
	input										s_axis_tvalid,
	output	reg									s_axis_tready,
	input										s_axis_tlast,
	input										weight_switch,

	output	reg [6143:0]						m_axis_tdata,
	output	reg									m_axis_tvalid,
	input										m_axis_tready,
	output	reg [3:0]							m_axis_tlast,
	output	reg [3:0]							weight_switch_out
);


	reg		[13:0]			count;


	always @(posedge clk) begin
		if (~rst_n) begin
			s_axis_tready <= 1'd1;
			m_axis_tvalid <= 1'd0;
		end
		else begin
			if (count < 14'd4608) begin
				s_axis_tready <= 1'd1;
				m_axis_tvalid <= 1'd0;
			end
			else if (count == 14'd4608) begin
				if (s_axis_tvalid) begin
					m_axis_tvalid <= 1'd1;
				end
				else begin
					m_axis_tvalid <= 1'd0;
				end

				if (s_axis_tvalid & ~m_axis_tready) begin
					s_axis_tready <= 1'd0;
				end
				else begin
					s_axis_tready <= 1'd1;
				end
			end
			else begin
				if (m_axis_tready) begin
					m_axis_tvalid <= 1'd0;
					s_axis_tready <= 1'd1;
				end
				else begin
					m_axis_tvalid <= 1'd1;
					s_axis_tready <= 1'd0;
				end
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			count <= 14'd0;
		end
		else begin
			if (s_axis_tvalid) begin
				if (count < 14'd4608) begin
					count <= count + 14'd1536;
				end
				else if (count == 14'd4608) begin
					if (m_axis_tready) begin
						count <= 14'd0;
					end
					else begin
						count <= count + 14'd1536;
					end
				end
			end
			if (count == 14'd6144 && m_axis_tready) begin
				count <= 14'd0;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			m_axis_tdata <= 6144'h0;
			m_axis_tlast <= 4'h0;
			weight_switch_out <= 4'h0;
		end
		else begin
			if (s_axis_tvalid & s_axis_tready && count < 14'd6144) begin
				m_axis_tdata <= m_axis_tdata >> 11'd1536;
				m_axis_tdata[6143:4608] <= s_axis_tdata;

				m_axis_tlast <= m_axis_tlast >> 1'b1;
				m_axis_tlast[3] <= s_axis_tlast;

				weight_switch_out <= weight_switch_out >> 1'b1;
				weight_switch_out[3] <= weight_switch;
			end
		end
	end


endmodule
