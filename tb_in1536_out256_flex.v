`timescale 1ns/1ps


module tb_in1536_out256_flex;


	// Clock and reset
	reg		clk = 1;
	reg		rst_n = 0;

	parameter PERIOD = 10;

	initial
	begin
		forever # (PERIOD/2) clk=~clk;
	end


	initial
	begin
		# (PERIOD * 5)	rst_n = 1;
	end


	// Logic
	wire	[1535:0]		in_tdata;
	wire	[255:0]			out_tdata;
	wire		in_tvalid, in_tready, out_tvalid;
	reg			en = 1;
	reg			out_tready = 1;

	initial
		begin
			# (PERIOD * 128)	en = 0;
			# (PERIOD * 5)		en = 1;
		end

	data_gen # (
		.Width					( 1536	),
		.CONFIG_LEN				( 10	),
		.FRAME_NUM				( 1		),
		.Data_Path 				( "/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/dwidth_convert_flex/input.txt")
	)
	in_gen(
		.i_sys_clk				( clk		),
		.i_sys_rst_n			( rst_n		),
		.i_start				( 1'b1		),
		.O_chan_cha1_ph_tdata	( in_tdata	),
		.O_chan_ph_tvalid		( in_tvalid	),
		.O_chan_ph_tlast		( ),
		.O_chan_ph_tready		( in_tready )
	);


	in1536_out256_flex in1536_out256_flex_inst (
		.clk				( clk ),
		.rst_n				( rst_n ),
		.shift_ctrl			( 3'b001 ),
		.shift_reg			( 9'h40 ),
		.s_axis_tdata		( in_tdata ),
		.s_axis_tvalid		( in_tvalid ),
		.s_axis_tready		( in_tready ),
		.m_axis_tdata		( out_tdata ),
		.m_axis_tvalid		( out_tvalid ),
		.m_axis_tready		( out_tready & en )
	);


endmodule
