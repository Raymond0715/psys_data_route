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
	input										s_axis_tlast,

	output	reg [1535:0]						m_axis_tdata,
	output	reg									m_axis_tvalid,
	input										m_axis_tready,
	output	reg [11:0]							m_axis_tlast
);


	reg		[10:0]			count;
	reg		[3:0]			count_last;
	reg						last_reg;
	wire					last;


	always @(posedge clk) begin
		if (~rst_n) begin
			last_reg <= 1'b0;
		end
		else begin
			if (last & ~m_axis_tready) begin
				last_reg <= 1'b1;
			end
			else begin
				last_reg <= 1'b0;
			end
		end
	end

	assign last = last_reg | s_axis_tlast;


	always @(posedge clk) begin
		if (~rst_n) begin
			s_axis_tready <= 1'd1;
			m_axis_tvalid <= 1'd0;
		end
		else begin
			if (s_axis_tlast) begin
				m_axis_tvalid <= 1'b1;
				if (m_axis_tready) begin
					s_axis_tready <= 1'b1;
				end
				else begin
					s_axis_tready <= 1'b0;
				end
			end
			else if (count < 11'd1408) begin
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
			count_last <= 4'h0;
		end
		else begin
			if ((count == 11'd1536 || last) && m_axis_tready) begin
				count <= 11'd0;
				count_last <= 4'h0;
			end
			else if (s_axis_tvalid) begin
				if (count < 11'd1408) begin
					count <= count + 8'd128;
					count_last <= count_last + 4'h1;
				end
				else if (count == 11'd1408) begin
					if (m_axis_tready) begin
						count <= 11'd0;
						count_last <= 4'h0;
					end
					else begin
						count <= count + 8'd128;
						count_last <= count_last + 4'h1;
					end
				end
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			m_axis_tdata <= 1536'h0;
			m_axis_tlast <= 12'h0;
		end
		else begin
			//if (s_axis_tvalid & s_axis_tready && count < 11'd1535) begin
				//m_axis_tdata <= m_axis_tdata >> 8'd128;
				//m_axis_tdata[1535:1408] <= s_axis_tdata;

				//m_axis_tlast <= m_axis_tlast >> 1'b1;
				//m_axis_tlast[11] <= s_axis_tlast;
			//end
			if (s_axis_tvalid & s_axis_tready) begin
				if (count == 11'd0) begin
					m_axis_tdata <= {1408'h0, s_axis_tdata};
					m_axis_tlast <= {11'h0, s_axis_tlast};
				end
				else if (count < 11'd1535) begin
					m_axis_tdata <= m_axis_tdata | s_axis_tdata << count;
					m_axis_tlast <= m_axis_tlast | s_axis_tlast << count_last;
				end
			end
		end
	end


endmodule
