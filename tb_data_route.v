`timescale 1ns/1ps


module tb_data_route;


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
	wire	[1535:0]		in_tdata_a, in_tdata_b, in_tdata_c;
	wire	[127:0]			in_tdata_d, in_tdata_e;

	wire		in_tvalid_a, in_tvalid_b, in_tvalid_c, in_tvalid_d, in_tvalid_e;
	wire		in_tready_a, in_tready_b, in_tready_c, in_tready_d, in_tready_e;

	wire	[1535:0]		out_tdata_a, out_tdata_b, out_tdata_c, out_tdata_f;
	wire	[1279:0]		out_tdata_g;
	wire	[255:0]			out_tdata_h;
	wire	[127:0]			out_tdata_d, out_tdata_e;

	wire		out_tvalid_a, out_tvalid_b, out_tvalid_c, out_tvalid_d,
				out_tvalid_e, out_tvalid_f, out_tvalid_g, out_tvalid_h;

	reg			out_tready_a = 1;
	reg			out_tready_b = 1;
	reg			out_tready_c = 1;
	reg			out_tready_d = 1;
	reg			out_tready_e = 1;
	reg			out_tready_f = 1;
	reg			out_tready_g = 1;
	reg			out_tready_h = 1;


	// input a
	data_gen # (
		.Width					( 1536	),
		.CONFIG_LEN				( 10	),
		.FRAME_NUM				( 1		),
		.Data_Path 				( "/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/input_a.txt")
	)
	in_gen_a (
		.i_sys_clk				( clk		),
		.i_sys_rst_n			( rst_n		),
		.i_start				( 1'b1		),
		.O_chan_cha1_ph_tdata	( in_tdata_a ),
		.O_chan_ph_tvalid		( in_tvalid_a ),
		.O_chan_ph_tlast		( ),
		.O_chan_ph_tready		( in_tready_a )
	);

	// input b
	data_gen # (
		.Width					( 1536	),
		.CONFIG_LEN				( 10	),
		.FRAME_NUM				( 1		),
		.Data_Path 				( "/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/input_b.txt")
	)
	in_gen_b (
		.i_sys_clk				( clk		),
		.i_sys_rst_n			( rst_n		),
		.i_start				( 1'b1		),
		.O_chan_cha1_ph_tdata	( in_tdata_b ),
		.O_chan_ph_tvalid		( in_tvalid_b	),
		.O_chan_ph_tlast		( ),
		.O_chan_ph_tready		( in_tready_b )
	);

	// input c
	data_gen # (
		.Width					( 1536	),
		.CONFIG_LEN				( 10	),
		.FRAME_NUM				( 1		),
		.Data_Path 				( "/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/input_c.txt")
	)
	in_gen_c (
		.i_sys_clk				( clk		),
		.i_sys_rst_n			( rst_n		),
		.i_start				( 1'b1		),
		.O_chan_cha1_ph_tdata	( in_tdata_c ),
		.O_chan_ph_tvalid		( in_tvalid_c ),
		.O_chan_ph_tlast		( ),
		.O_chan_ph_tready		( in_tready_c )
	);

	// input d
	data_gen # (
		.Width					( 128	),
		.CONFIG_LEN				( 120	),
		.FRAME_NUM				( 1		),
		.Data_Path 				( "/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/input_d.txt")
	)
	in_gen_d (
		.i_sys_clk				( clk		),
		.i_sys_rst_n			( rst_n		),
		.i_start				( 1'b1		),
		.O_chan_cha1_ph_tdata	( in_tdata_d ),
		.O_chan_ph_tvalid		( in_tvalid_d ),
		.O_chan_ph_tlast		( ),
		.O_chan_ph_tready		( in_tready_d )
	);

	// input e
	data_gen # (
		.Width					( 128	),
		.CONFIG_LEN				( 120	),
		.FRAME_NUM				( 1		),
		.Data_Path 				( "/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/input_e.txt")
	)
	in_gen_e (
		.i_sys_clk				( clk		),
		.i_sys_rst_n			( rst_n		),
		.i_start				( 1'b1		),
		.O_chan_cha1_ph_tdata	( in_tdata_e ),
		.O_chan_ph_tvalid		( in_tvalid_e ),
		.O_chan_ph_tlast		( ),
		.O_chan_ph_tready		( in_tready_e )
	);


	data_route data_route_inst (
		.clk					( clk ),
		.rst_n					( rst_n ),
		.ctrl					( 36'h201e48043 ),

		.s_in_a_tdata			( in_tdata_a  ),
		.s_in_a_tvalid			( in_tvalid_a ),
		.s_in_a_tready			( in_tready_a ),
		.m_out_a_tdata			( out_tdata_a ),
		.m_out_a_tvalid			( out_tvalid_a ),
		.m_out_a_tready			( out_tready_a ),

		.s_in_b_tdata			( in_tdata_b  ),
		.s_in_b_tvalid			( in_tvalid_b ),
		.s_in_b_tready			( in_tready_b ),
		.m_out_b_tdata			( out_tdata_b ),
		.m_out_b_tvalid			( out_tvalid_b ),
		.m_out_b_tready			( out_tready_b ),

		.s_in_c_tdata			( in_tdata_c  ),
		.s_in_c_tvalid			( in_tvalid_c ),
		.s_in_c_tready			( in_tready_c ),
		.m_out_c_tdata			( out_tdata_c ),
		.m_out_c_tvalid			( out_tvalid_c ),
		.m_out_c_tready			( out_tready_c ),

		.s_in_d_tdata			( in_tdata_d  ),
		.s_in_d_tvalid			( in_tvalid_d ),
		.s_in_d_tready			( in_tready_d ),
		.m_out_d_tdata			( out_tdata_d ),
		.m_out_d_tvalid			( out_tvalid_d ),
		.m_out_d_tready			( out_tready_d ),

		.s_in_e_tdata			( in_tdata_e  ),
		.s_in_e_tvalid			( in_tvalid_e ),
		.s_in_e_tready			( in_tready_e ),
		.m_out_e_tdata			( out_tdata_e ),
		.m_out_e_tvalid			( out_tvalid_e ),
		.m_out_e_tready			( out_tready_e ),

		.m_out_f_tdata			( out_tdata_f  ),
		.m_out_f_tvalid			( out_tvalid_f ),
		.m_out_f_tready			( out_tready_f ),

		.m_out_g_tdata			( out_tdata_g  ),
		.m_out_g_tvalid			( out_tvalid_g ),
		.m_out_g_tready			( out_tready_g ),

		.m_out_h_tdata			( out_tdata_h  ),
		.m_out_h_tvalid			( out_tvalid_h ),
		.m_out_h_tready			( out_tready_h )
	);


	integer handle0 ;
	initial handle0=$fopen("/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/out_a_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_a & out_tready_a) begin
				$fdisplay(handle0,"%h",out_tdata_a);
			end
		end
	end


	integer handle1 ;
	initial handle1=$fopen("/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/out_b_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_b & out_tready_b) begin
				$fdisplay(handle1,"%h",out_tdata_b);
			end
		end
	end


	integer handle2 ;
	initial handle2=$fopen("/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/out_c_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_c & out_tready_c) begin
				$fdisplay(handle2,"%h",out_tdata_c);
			end
		end
	end


	integer handle3 ;
	initial handle3=$fopen("/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/out_d_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_d & out_tready_d) begin
				$fdisplay(handle2,"%h",out_tdata_d);
			end
		end
	end


	integer handle4 ;
	initial handle4=$fopen("/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/out_e_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_e & out_tready_e) begin
				$fdisplay(handle2,"%h",out_tdata_e);
			end
		end
	end


	integer handle5 ;
	initial handle5=$fopen("/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/out_f_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_f & out_tready_f) begin
				$fdisplay(handle2,"%h",out_tdata_f);
			end
		end
	end


	integer handle6 ;
	initial handle6=$fopen("/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/out_g_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_g & out_tready_g) begin
				$fdisplay(handle2,"%h",out_tdata_g);
			end
		end
	end


	integer handle7 ;
	initial handle7=$fopen("/media/raymond_2t_101/1_projects/poly_systolic_unit/py-sim/dat/data_route/out_h_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_h & out_tready_h) begin
				$fdisplay(handle2,"%h",out_tdata_h);
			end
		end
	end


endmodule

