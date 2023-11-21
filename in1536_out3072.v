/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/07/23
* Design Name:    poly_systolic_hw
* Module Name:    in1536_out3072
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


module in1536_out3072 (
	input										clk,
	input										rst_n,

	input	[1535:0]							s_axis_tdata,
	input										s_axis_tvalid,
	output	reg									s_axis_tready,
	input										s_axis_tlast,
	input										weight_switch,

	output	reg [3071:0]						m_axis_tdata,
	output	reg									m_axis_tvalid,
	input										m_axis_tready,
	output	reg [2:0]							m_axis_tlast,
	output	reg									weight_switch_out
);


	reg		[13:0]			count;
	reg		[1:0]			weight_switch_reg;
	wire					m_axis_tlast_reduce;


	always @(posedge clk) begin
		if (~rst_n) begin
			s_axis_tready <= 1'd1;
			m_axis_tvalid <= 1'd0;
		end
		else begin
			if (count < 14'd1536) begin
				s_axis_tready <= 1'd1;
				m_axis_tvalid <= 1'd0;
			end
			else if (count == 14'd1536) begin
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
				if (count < 14'd1536) begin
					count <= count + 14'd1536;
				end
				else if (count == 14'd1536) begin
					if (m_axis_tready) begin
						count <= 14'd0;
					end
					else begin
						count <= count + 14'd1536;
					end
				end
			end
			if (count == 14'd3072 && m_axis_tready) begin
				count <= 14'd0;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			m_axis_tdata <= 3072'h0;
			m_axis_tlast <= 2'h0;
			weight_switch_reg <= 2'h0;
		end
		else begin
			if (m_axis_tvalid & m_axis_tready & m_axis_tlast[0]) begin
				m_axis_tlast <= 2'h0;
				weight_switch_reg <= 2'h0;
			end
			else if (s_axis_tvalid & s_axis_tready && count < 14'3072) begin
				m_axis_tdata <= m_axis_tdata >> 11'd1536;
				m_axis_tdata[3071:1536] <= s_axis_tdata;

				m_axis_tlast <= m_axis_tlast >> 1'b1;
				m_axis_tlast[1] <= s_axis_tlast;

				weight_switch_reg <= weight_switch_reg >> 1'b1;
				weight_switch_reg[1] <= weight_switch;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			weight_switch_out <= 1'b0;
		end
		else if (m_axis_tvalid & m_axis_tready & m_axis_tlast_reduce
				& weight_switch_reg[0]) begin
			weight_switch_out <= 1'b1;
		end
		else begin
			weight_switch_out <= 1'b0;
		end
	end

	assign m_axis_tlast_reduce = |m_axis_tlast;


endmodule
