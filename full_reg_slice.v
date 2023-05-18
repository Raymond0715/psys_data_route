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
	output	reg									s_in_tready,

	output		[DWIDTH-1:0]					m_out_tdata,
	output	reg									m_out_tvalid,
	input										m_out_tready
);


	localparam EMPTY = 2'b00;
	localparam RUN   = 2'b01;
	localparam FULL  = 2'b10;

	reg		[1:0]				c_state, n_state;

	reg		[DWIDTH-1:0]		in_tdata_reg_0, in_tdata_reg_1;
	reg							ctrl_reg_0, ctrl_reg_1, empty, full;


	always @(posedge clk) begin
		if (~rst_n) begin
			c_state <= EMPTY;
		end
		else begin
			c_state <= n_state;
		end
	end


	always @(*) begin
		if (~rst_n) begin
			n_state = EMPTY;
		end
		else begin
			case(c_state)
				EMPTY:
					begin
						if ((s_in_tvalid & s_in_tready) & ~(m_out_tvalid & m_out_tready)) begin
							n_state = RUN;
						end
						else begin
							n_state = EMPTY;
						end
					end

				RUN:
					begin
						if (~(s_in_tready & s_in_tvalid) & m_out_tready & m_out_tvalid) begin
							n_state = EMPTY;
						end
						else if (s_in_tready & s_in_tvalid & ~(m_out_tready & m_out_tvalid)) begin
							n_state = FULL;
						end
						else begin
							n_state = RUN;
						end
					end

				FULL:
					begin
						if (~(s_in_tready & s_in_tvalid) & m_out_tready & m_out_tvalid) begin
							n_state = RUN;
						end
						else begin
							n_state = FULL;
						end
					end
			endcase
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			ctrl_reg_0 <= 1'd0;
			ctrl_reg_1 <= 1'd0;
		end
		else begin
			if (c_state == RUN && n_state == FULL && (ctrl_reg_0 == ctrl_reg_1)) begin
				ctrl_reg_0 = ~ctrl_reg_0;
			end
			if (c_state == FULL && n_state == RUN) begin
				ctrl_reg_0 = ~ctrl_reg_0;
				ctrl_reg_1 = ~ctrl_reg_1;
			end
			if (c_state == RUN && (m_out_tready & m_out_tvalid) && (ctrl_reg_0 != ctrl_reg_1)) begin
				ctrl_reg_1 = ~ctrl_reg_1;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			empty <= 1'd1;
			full <= 1'd0;
		end
		else begin
			if (n_state == FULL) begin
				full <= 1'd1;
			end
			else begin
				full <= 1'd0;
			end
			if (n_state == EMPTY) begin
				empty <= 1'd1;
			end
			else begin
				empty <= 1'd0;
			end
		end

	end


	always @(posedge clk) begin
		if (~rst_n) begin
			s_in_tready <= 1'd0;
			m_out_tvalid <= 1'd0;
		end
		else begin
			if (n_state == FULL && ~(m_out_tready & m_out_tvalid)) begin
				s_in_tready <= 1'd0;
			end
			else begin
				s_in_tready <= 1'd1;
			end

			if (c_state == EMPTY && ~(s_in_tready & s_in_tvalid)) begin
				m_out_tvalid <= 1'd0;
			end
			else begin
				m_out_tvalid <= 1'd1;
			end
		end
	end


	always @(posedge clk) begin
		if (~rst_n) begin
			in_tdata_reg_0 <= 0;
			in_tdata_reg_1 <= 0;
		end
		else begin
			if (s_in_tvalid & s_in_tready) begin
				if (ctrl_reg_0) begin
					in_tdata_reg_0 <= s_in_tdata;
				end 
				else begin
					in_tdata_reg_1 <= s_in_tdata;
				end
			end
		end
	end


	assign m_out_tdata = ctrl_reg_1 ? in_tdata_reg_0 : in_tdata_reg_1;


endmodule
