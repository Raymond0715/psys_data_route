/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/05/14
* Design Name:    poly_systolic_hw
* Module Name:    inter_switch
* Project Name:   data_route
* Target Devices: ZCU 102
* Tool Versions:  Vivado 2021.2
* Description:
*
* Dependencies:
*
* Revision:
* Additional Comments:
* 	- m_out_g_tvalid and m_out_g_tready represent 1536 output ctrl signal
* 	(out_g and out_h are combined as one signal).
* 	- m_out_h_tvalid and m_out_h_tready represent 256 output ctrl signal.
*
*******************************************************************************/


module inter_switch (
	input										clk,
	input										rst_n,

	input	[17:0]								ctrl,

	input	[1535:0]							s_in_a_tdata,
	input										s_in_a_tvalid,
	output	reg									s_in_a_tready,

	input	[1535:0]							s_in_b_tdata,
	input										s_in_b_tvalid,
	output	reg									s_in_b_tready,

	input	[1535:0]							s_in_c_tdata,
	input										s_in_c_tvalid,
	output	reg									s_in_c_tready,

	input	[1535:0]							s_in_d_tdata,
	input										s_in_d_tvalid,
	output	reg									s_in_d_tready,

	input	[1535:0]							s_in_e_tdata,
	input										s_in_e_tvalid,
	output	reg									s_in_e_tready,

	output	reg	[1535:0]						m_out,
	output	reg [255:0]							m_out_256,
	output	reg [127:0]							m_out_128,

	output	reg									m_out_a_tvalid,
	input										m_out_a_tready,

	output	reg									m_out_b_tvalid,
	input										m_out_b_tready,

	output	reg									m_out_c_tvalid,
	input										m_out_c_tready,

	output	reg									m_out_d_tvalid,
	input										m_out_d_tready,

	output	reg									m_out_e_tvalid,
	input										m_out_e_tready,

	output	reg									m_out_f_tvalid,
	input										m_out_f_tready,

	output	reg									m_out_g_tvalid,
	input										m_out_g_tready,

	output	reg									m_out_h_tvalid,
	input										m_out_h_tready
);




	// Input
	wire	[1535:0]		inter_tdata_ina, inter_tdata_inb, inter_tdata_inc,
							inter_tdata_ind, inter_tdata_ine;
	wire					in_a_tvalid, in_b_tvalid, in_c_tvalid, in_d_tvalid,
							in_e_tvalid;

	wire	[1535:0]		inter_tdata;
	wire					inter_tvalid, inter_tready;

	reg		[1535:0]		inter_tdata_reg;
	reg						inter_tvalid_reg, inter_tready_reg,
							inter_tready_128_reg;

	wire	[7:0]			switch_in_en;

	assign in_a_tvalid      = switch_in_en[4] & s_in_a_tvalid;
	assign in_b_tvalid      = switch_in_en[3] & s_in_b_tvalid;
	assign in_c_tvalid      = switch_in_en[2] & s_in_c_tvalid;
	assign in_d_tvalid      = switch_in_en[1] & s_in_d_tvalid;
	assign in_e_tvalid      = switch_in_en[0] & s_in_e_tvalid;

	assign inter_tdata_ina     = in_a_tvalid ? s_in_a_tdata : 0;
	assign inter_tdata_inb     = in_b_tvalid ? s_in_b_tdata : 0;
	assign inter_tdata_inc     = in_c_tvalid ? s_in_c_tdata : 0;
	assign inter_tdata_ind     = in_d_tvalid ? s_in_d_tdata : 0;
	assign inter_tdata_ine     = in_e_tvalid ? s_in_e_tdata : 0;

	assign inter_tdata = inter_tdata_ina | inter_tdata_inb | inter_tdata_inc
					| inter_tdata_ind | inter_tdata_ine; 

	assign inter_tvalid = in_a_tvalid | in_b_tvalid | in_c_tvalid | in_d_tvalid
					| in_e_tvalid;

	always @(posedge clk) begin
		if (~rst_n) begin
			inter_tdata_reg <= 1'b0;
			inter_tvalid_reg <= 1'b0;
			s_in_a_tready <= 1'b0;
			s_in_b_tready <= 1'b0;
			s_in_c_tready <= 1'b0;
			s_in_d_tready <= 1'b0;
			s_in_e_tready <= 1'b0;
		end
		else begin
			inter_tdata_reg <= inter_tdata;
			inter_tvalid_reg <= inter_tvalid;
			s_in_a_tready <= switch_in_en[4] & inter_tready;
			s_in_b_tready <= switch_in_en[3] & inter_tready;
			s_in_c_tready <= switch_in_en[2] & inter_tready;
			s_in_d_tready <= switch_in_en[1] & inter_tready;
			s_in_e_tready <= switch_in_en[0] & inter_tready;
		end
	end


	decoder_3_8 switch_in (
		.in					( ctrl[2:0] ),
		.out				( switch_in_en )
	);


	// Inter
	wire					out_a_tready, out_b_tready, out_c_tready,
							out_d_tready, out_e_tready, out_f_tready,
							out_g_tready, out_h_tready;

	wire					inter_128_tready;

	wire					inter_tready_256_flex;

	assign inter_tready = out_a_tready | out_b_tready | out_c_tready
					   | inter_128_tready | out_f_tready | out_g_tready
					   | inter_tready_256_flex;

	assign out_a_tready = switch_out_en[7] & m_out_a_tready;
	assign out_b_tready = switch_out_en[6] & m_out_b_tready;
	assign out_c_tready = switch_out_en[5] & m_out_c_tready;
	assign out_d_tready = switch_out_en[4] & m_out_d_tready;
	assign out_e_tready = switch_out_en[3] & m_out_e_tready;
	assign out_f_tready = switch_out_en[2] & m_out_f_tready;
	assign out_g_tready = switch_out_en[1] & m_out_g_tready;
	assign out_h_tready = switch_out_en[0] & m_out_h_tready;


	// Output
	wire	[1535:0]		out_inter_128_tdata, out_inter_tdata_256_flex;
	wire 					out_inter_128_tvalid, out_inter_tvalid_256_flex;

	wire	[7:0]			switch_out_en;


	always @(posedge clk) begin
		if (~rst_n) begin
			m_out <= 1536'd0;
			m_out_128 <= 128'd0;
			m_out_256 <= 256'd0;
			m_out_a_tvalid <= 1'd0;
			m_out_b_tvalid <= 1'd0;
			m_out_c_tvalid <= 1'd0;
			m_out_d_tvalid <= 1'd0;
			m_out_e_tvalid <= 1'd0;
			m_out_f_tvalid <= 1'd0;
			m_out_g_tvalid <= 1'd0;
			m_out_g_tvalid <= 1'd0;
		end
		else begin
			m_out <= inter_tdata_reg;
			m_out_128 <= out_inter_128_tdata;
			m_out_256 <= out_inter_tdata_256_flex;
			m_out_a_tvalid <= switch_out_en[7] & inter_tvalid_reg;
			m_out_b_tvalid <= switch_out_en[6] & inter_tvalid_reg;
			m_out_c_tvalid <= switch_out_en[5] & inter_tvalid_reg;
			m_out_d_tvalid <= switch_out_en[4] & out_inter_128_tvalid;
			m_out_e_tvalid <= switch_out_en[3] & out_inter_128_tvalid;
			m_out_f_tvalid <= switch_out_en[2] & inter_tvalid_reg;
			m_out_g_tvalid <= switch_out_en[1] & inter_tvalid_reg;
			m_out_h_tvalid <= switch_out_en[0] & out_inter_tvalid_256_flex;
			
		end
	end


	decoder_3_8 switch_out (
		.in					( ctrl[5:3] ),
		.out				( switch_out_en )
	);


	in1536_out128 dwidth_converter_out (
		.aclk				( clk ),
		.aresetn			( rst_n ),
		.s_axis_tdata		( inter_tdata_reg ),
		.s_axis_tvalid		( inter_tvalid_reg ),
		.s_axis_tready		( inter_128_tready ),
		.m_axis_tdata		( out_inter_128_tdata ),
		.m_axis_tvalid		( out_inter_128_tvalid ),
		.m_axis_tready		( out_d_tready | out_e_tready )
	);


	in1536_out256_flex dwidth_converter_out_flex (
		.clk				( clk ),
		.rst_n				( rst_n ),
		.shift_ctrl			( ctrl[8:6] ),
		.shift_reg			( ctrl[17:9] ),
		.s_axis_tdata		( inter_tdata_reg ),
		.s_axis_tvalid		( inter_tvalid_reg ),
		.s_axis_tready		( inter_tready_256_flex ),
		.m_axis_tdata		( out_inter_tdata_256_flex ),
		.m_axis_tvalid		( out_inter_tvalid_256_flex ),
		.m_axis_tready		( out_h_tready )
	);


endmodule
