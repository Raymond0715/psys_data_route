/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/05/12
* Design Name:    poly_systolic_hw
* Module Name:    in1536_out256_flex
* Project Name:   data_route
* Target Devices: ZCU 102
* Tool Versions:  Vivado 2021.2
* Description:
*
* Dependencies:
*
* Revision:
* Additional Comments:
* - shift_ctrl[2:0]: 3'b001  3'b010  3'b100
*
*******************************************************************************/


module in1536_out256_flex (
	input										clk,
	input										rst_n,

	input	[2:0]								shift_ctrl,
	input	[8:0]								shift_reg,

	input	[1535:0]							s_axis_tdata,
	input										s_axis_tvalid,
	output	reg									s_axis_tready,
	input	[23:0]								s_axis_tlast,

	output	[255:0]								m_axis_tdata,
	output	reg									m_axis_tvalid,
	input										m_axis_tready,
	output										m_axis_tlast
);


	reg		[1535:0]		in_reg;
	reg		[23:0]			tlast_reg;
	reg		[10:0]			count;
	reg						m_ready_reg;

	wire					m_ready;


	always @(posedge clk) begin
		if (~rst_n) begin
			m_ready_reg <= 1'b0;
		end
		else begin
			if (m_ready & ~s_axis_tvalid) begin
				m_ready_reg <= 1'b1;
			end
			else begin
				m_ready_reg <= 1'b0;
			end
		end
	end

	assign m_ready = m_ready_reg | m_axis_tready;


	always @(posedge clk) begin
		if (~rst_n) begin
			s_axis_tready <= 1;
			m_axis_tvalid <= 0;
		end
		else begin
			if (count > shift_reg) begin
				m_axis_tvalid <= 1;
				s_axis_tready <= 0;
			end
			else if (count == shift_reg) begin
				if (m_axis_tready) begin
					s_axis_tready <= 1;
				end
				else begin
					s_axis_tready <= 0;
				end

				if (~s_axis_tvalid & m_axis_tready) begin
					m_axis_tvalid <= 0;
				end
				else begin
					m_axis_tvalid <= 1;
				end
			end
			else begin
				if (s_axis_tvalid) begin
					m_axis_tvalid <= 1;
					s_axis_tready <= 0;
				end
				else begin
					m_axis_tvalid <= 0;
					s_axis_tready <= 1;
				end
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			count <= 11'd0;
		end
		else begin
			if (count == 11'd0 && s_axis_tvalid) begin
				count <= 11'd1536;
			end
			else if (m_axis_tready) begin
				if (count > shift_reg) begin
					count <= count - shift_reg;
				end
				else if (count == shift_reg) begin
					if (s_axis_tvalid) begin
						count <= 11'd1536;
					end
					else begin
						count <= count - shift_reg;
					end
				end
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			in_reg <= 1536'd0;
			tlast_reg <= 24'h0;
		end
		else begin
			if (m_axis_tlast) begin
				if (m_ready & s_axis_tlast) begin
					in_reg <= s_axis_tdata;
					tlast_reg <= s_axis_tlast;
				end
			end
			else if (m_axis_tready) begin
				if (count > shift_reg) begin
					in_reg <= in_reg >> shift_reg;
					tlast_reg <= tlast_reg >> shift_ctrl;
				end
				else if (s_axis_tvalid) begin
					in_reg <= s_axis_tdata;
					tlast_reg <= s_axis_tlast;
				end
			end
			else if (count == 11'd0 && s_axis_tvalid) begin
				in_reg <= s_axis_tdata;
				tlast_reg <= s_axis_tlast;
			end
		end
	end


	assign m_axis_tdata[63:0] = in_reg[63:0];
	assign m_axis_tdata[127:64] =
		(shift_ctrl[1] | shift_ctrl[2]) ? in_reg[127:64] : in_reg[63:0];
	assign m_axis_tdata[191:128] =
		(shift_ctrl[0] | shift_ctrl[1]) ? in_reg[63:0] : in_reg[191:128];
	assign m_axis_tdata[255:192] =
		shift_ctrl[2] ? in_reg[255:192] : shift_ctrl[1] ? in_reg[127:64] : in_reg[63:0];

	assign m_axis_tlast = shift_ctrl[0] ?
					   tlast_reg[0] :
					   shift_reg[1] ? tlast_reg[1] : tlast_reg[3];


endmodule
