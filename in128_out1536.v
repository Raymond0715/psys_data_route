/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/0518
* Design Name:    poly_systolic_hw
* Module Name:    in128_out1536
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


module in128_out1536 (
	input										clk,
	input										rst_n,

	input	[127:0]								s_axis_tdata,
	input										s_axis_tvalid,
	output	reg									s_axis_tready,

	output	[1535:0]							m_axis_tdata,
	output	reg									m_axis_tvalid,
	input										m_axis_tready
);


	reg		[1535:0]		in_reg;
	reg		[10:0]			count;


	always @(posedge clk) begin
		if (~rst_n) begin
			s_axis_tready <= 1'd1;
			m_axis_tvalid <= 1'd0;
		end
		else begin
			if (count < 11'd1408) begin
				s_axis_tready <= 1'd1;
				m_axis_tvalid <= 1'd0;
			end
			else if (count == 11'd1408) begin
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
			count <= 11'd0;
		end
		else begin
			if (s_axis_tvalid) begin
				if (count < 11'd1408) begin
					count <= count + 8'd128;
				end
				else if (count == 11'd1408) begin
					if (m_axis_tready) begin
						count <= 11'd0;
					end
					else begin
						count <= count + 8'd128;
					end
				end
			end
			if (count == 11'd1536 && m_axis_tready) begin
				count <= 11'd0;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			in_reg <= 1536'd0;
		end
		else begin
			if (s_axis_tvalid & s_axis_tready && count < 11'd1535) begin
				in_reg <= in_reg >> 8'd128;
				in_reg[1535:1408] <= s_axis_tdata;
			end
		end
	end


	assign m_axis_tdata = in_reg;


endmodule
