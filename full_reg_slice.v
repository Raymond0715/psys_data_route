/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/05/17
* Design Name:    poly_systolic_hw
* Module Name:    full_reg_slice
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


module full_reg_slice # (
	parameter DWIDTH = 32
)
(
	input										clk,
	input										rst_n,

	input		[DWIDTH-1:0]					s_in_tdata,
	input										s_in_tvalid,
	output										s_in_tready,

	output		[DWIDTH-1:0]					m_out_tdata,
	output										m_out_tvalid,
	input										m_out_tready
);


	reg		[DWIDTH-1:0]		in_tdata_reg_0, in_tdata_reg_1;
	reg		[1:0]				count_reg;
	reg							ctrl_reg, s_in_tvalid_reg, m_out_tready_reg;

	wire						empty, full;


	always @(posedge clk) begin
		if (~rst_n) begin
			m_out_tready_reg <= 1'd0;
		end
		else begin
			m_out_tready_reg <= m_out_tready;
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			s_in_tvalid_reg <= 1'd0;
		end
		else begin
			s_in_tvalid_reg <= s_in_tvalid;
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			ctrl_reg <= 1'd0;
		end
		else begin
			if ((m_out_tvalid & m_out_tready) | (s_in_tvalid | s_in_tready)) begin
				ctrl_reg = ~ctrl_reg;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			count_reg <= 2'd0;
		end
		else begin
			if (~s_in_tvalid & m_out_tready & count_reg > 0) begin
				count_reg <= count_reg - 1;
			end
			if (s_in_tvalid & ~m_out_tready & count_reg < 2) begin
				count_reg <= count_reg + 1;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			in_tdata_reg_0 <= DWIDTH'd0;
			in_tdata_reg_1 <= DWIDTH'd0;
		end
		else begin
			if (s_in_tvalid & s_in_tready) begin
				if (ctrl_reg) begin
					in_tdata_reg_0 <= s_in_tdata;
				end 
				else begin
					in_tdata_reg_1 <= s_in_tdata;
				end
			end
		end
	end


	assign empty = ~count_reg[1] & ~count_reg[0];
	assign full = count_reg[1] & ~count_reg[0];
	assign m_out_tdata = ctrl_reg ? in_tdata_reg_1 : in_tdata_reg_0;
	assign m_out_tvalid = s_in_tvalid_reg | ~empty;
	assign s_in_tready = m_out_tready_reg | ~full;


endmodule
