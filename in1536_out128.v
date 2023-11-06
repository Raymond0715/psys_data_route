/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/0518
* Design Name:    poly_systolic_hw
* Module Name:    in1536_out128
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


module in1536_out128 (
	input										clk,
	input										rst_n,

	input	[1535:0]							s_axis_tdata,
	input										s_axis_tvalid,
	output	reg									s_axis_tready,
	input	[11:0]								s_axis_tlast,

	output	[127:0]								m_axis_tdata,
	output	reg									m_axis_tvalid,
	input										m_axis_tready,
	output										m_axis_tlast
);


	reg		[1535:0]		in_reg;
	reg		[11:0]			tlast_reg;
	reg		[10:0]			count;

	reg						m_ready_reg;
	wire					m_ready;

	//reg						in_last_reg;
	//wire					in_last;


	//always @(posedge clk) begin
		//if (~rst_n) begin
			//in_last_reg <= 1'b0;
		//end
		//else begin
			//if (in_last & ~m_axis_tready) begin
				//in_last_reg <= 1'b1;
			//end
			//else begin
				//in_last_reg <= 1'b0;
			//end
		//end
	//end

	//assign in_last = in_last_reg | (|s_axis_tlast);


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
			s_axis_tready <= 1'd1;
			m_axis_tvalid <= 1'd0;
		end
		else begin
			if (count == 11'd128 || m_axis_tlast) begin
				if (m_axis_tready) begin
					s_axis_tready <= 1'd1;
				end
				else begin
					s_axis_tready <= 1'd0;
				end

				if (~s_axis_tvalid & m_axis_tready) begin
					m_axis_tvalid <= 1'd0;
				end
				else begin
					m_axis_tvalid <= 1'd1;
				end
			end
			else if (count > 11'd128) begin
				m_axis_tvalid <= 1'd1;
				s_axis_tready <= 1'd0;
			end
			else begin
				if (s_axis_tvalid) begin
					m_axis_tvalid <= 1'd1;
					s_axis_tready <= 1'd0;
				end
				else begin
					m_axis_tvalid <= 1'd0;
					s_axis_tready <= 1'd1;
				end
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			count <= 11'd0;
		end
		else begin
			if (m_axis_tlast & s_axis_tvalid) begin
				count <= 11'd1536;
			end
			else if (m_axis_tlast & ~s_axis_tvalid) begin
				count <= 11'd0;
			end
			else if (count > 11'd128 && m_axis_tready) begin
				count <= count - 11'd128;
			end
			else if ((count == 11'd128) && m_axis_tready && s_axis_tvalid) begin
				count <= 11'd1536;
			end
			else if (count == 11'd128 && m_axis_tready) begin
				count <= count - 11'd128;
			end
			else if (count == 11'd0 && s_axis_tvalid) begin
				count <= 11'd1536;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			in_reg <= 1536'd0;
			tlast_reg <= 12'd0;
		end
		else begin
			if (m_axis_tlast) begin
				if (m_ready & s_axis_tvalid) begin
					in_reg <= s_axis_tdata;
					tlast_reg <= s_axis_tlast;
				end
			end
			else if (count > 8'd128 && m_axis_tready) begin
				in_reg <= in_reg >> 8'd128;
				tlast_reg <= tlast_reg >> 1'd1;
			end
			else if (count == 8'd128 && m_axis_tready && s_axis_tvalid) begin
				in_reg <= s_axis_tdata;
				tlast_reg <= s_axis_tlast;
			end
			else if (count == 8'd0 && s_axis_tvalid) begin
				in_reg <= s_axis_tdata;
				tlast_reg <= s_axis_tlast;
			end
		end
	end


	assign m_axis_tdata = in_reg[127:0];
	assign m_axis_tlast = tlast_reg[0];


endmodule
