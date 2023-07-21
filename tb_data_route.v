`timescale 1ns/1ps


module tb_data_route;


	// Clock and reset
	reg		clk = 1;
	reg		rst_n = 0;

	parameter PERIOD = 5;

	initial
	begin
		forever # (PERIOD/2) clk=~clk;
	end


	initial
	begin
		# (PERIOD * 5)	rst_n = 1;
	end


	// Logic
	wire	[1535:0]		in_tdata_c, in_tdata_d, in_tdata_e, in_tdata_i;
	wire	[127:0]			in_tdata_a, in_tdata_b;

	wire	[5:0]			in_valid;

	wire		in_tvalid_a, in_tvalid_b, in_tvalid_c, in_tvalid_d, in_tvalid_e;
	wire		in_tready_a, in_tready_b, in_tready_c, in_tready_d, in_tready_e;
	wire		count_switch_0_tvalid, count_switch_1_tvalid, count_switch_2_tvalid;

	wire	[1535:0]		out_tdata_c, out_tdata_d, out_tdata_e, out_tdata_f, out_tdata_i;
	wire	[1279:0]		out_tdata_g;
	wire	[255:0]			out_tdata_h;
	wire	[127:0]			out_tdata_a, out_tdata_b;

	wire		out_tvalid_a, out_tvalid_b, out_tvalid_c, out_tvalid_d,
				out_tvalid_e, out_tvalid_f, out_tvalid_g, out_tvalid_h,
				out_tvalid_i;

	reg			out_tready_b = 1;
	reg			out_tready_c = 1;
	reg			out_tready_d = 1;
	reg			out_tready_e = 1;
	reg			out_tready_f = 1;
	reg			out_tready_g = 1;
	reg			out_tready_h = 1;
	reg			out_tready_i = 1;


	// input a
	data_gen # (
		.WIDTH					( 128	),
		.LENGTH					( 120	),
		.DPATH 					( "/media/Projects/poly_systolic_unit/py-sim/dat/data_route/input_a.txt")
	)
	in_gen_a (
		.clk					( clk		),
		.rst_n					( rst_n		),
		.m_tdata				( in_tdata_a ),
		.m_tvalid				( in_tvalid_a ),
		.m_tlast				( ),
		.m_tready				( in_tready_a )
	);

	// input b
	data_gen # (
		.WIDTH					( 128	),
		.LENGTH					( 768	),
		.DPATH 					( "/media/Projects/poly_systolic_unit/py-sim/dat/data_route/input_b.txt")
	)
	in_gen_b (
		.clk					( clk		),
		.rst_n					( rst_n		),
		.m_tdata				( in_tdata_b ),
		.m_tvalid				( in_tvalid_b	),
		.m_tlast				( ),
		.m_tready				( in_tready_b )
	);

	// input c
	data_gen # (
		.WIDTH					( 1536	),
		.LENGTH					( 10	),
		.DPATH 					( "/media/Projects/poly_systolic_unit/py-sim/dat/data_route/input_c.txt")
	)
	in_gen_c (
		.clk					( clk		),
		.rst_n					( rst_n		),
		.m_tdata				( in_tdata_c ),
		.m_tvalid				( in_tvalid_c ),
		.m_tlast				( ),
		.m_tready				( in_tready_c )
	);

	// input d
	data_gen # (
		.WIDTH					( 1536	),
		.LENGTH					( 10	),
		.DPATH 					( "/media/Projects/poly_systolic_unit/py-sim/dat/data_route/input_d.txt")
	)
	in_gen_d (
		.clk					( clk		),
		.rst_n					( rst_n		),
		.m_tdata				( in_tdata_d ),
		.m_tvalid				( in_tvalid_d ),
		.m_tlast				( ),
		.m_tready				( in_tready_d )
	);

	// input e
	data_gen # (
		.WIDTH					( 1536	),
		.LENGTH					( 10	),
		.DPATH 					( "/media/Projects/poly_systolic_unit/py-sim/dat/data_route/input_e.txt")
	)
	in_gen_e (
		.clk					( clk		),
		.rst_n					( rst_n		),
		.m_tdata				( in_tdata_e ),
		.m_tvalid				( in_tvalid_e ),
		.m_tlast				( ),
		.m_tready				( in_tready_e )
	);

	// input i
	data_gen # (
		.WIDTH					( 1536	),
		.LENGTH					( 10	),
		.DPATH 					( "/media/Projects/poly_systolic_unit/py-sim/dat/data_route/input_i.txt")
	)
	in_gen_i (
		.clk					( clk		),
		.rst_n					( rst_n		),
		.m_tdata				( in_tdata_i ),
		.m_tvalid				( in_tvalid_i ),
		.m_tlast				( ),
		.m_tready				( in_tready_i )
	);


	reg sim_out_a_tready_reg=0;
	reg sim_out_a_tready_reg_pad;
	wire out_tready_a;

	assign out_tready_a = sim_out_a_tready_reg_pad;

	integer delay1, delay2, k;
	initial
		begin
			for (k = 0; k < 100; k = k+1)
				begin
					delay1 = 10 * ( {$random} % 60 );
					delay2 = 10 * ( {$random} % 60 );
					# delay1 sim_out_a_tready_reg = 1;
					# delay2 sim_out_a_tready_reg = 0;
				end
		end

	always @(posedge clk) begin
		sim_out_a_tready_reg_pad <= sim_out_a_tready_reg;
	end


	data_route data_route_inst (
		.clk					( clk ),
		.rst_n					( rst_n ),

		.s_droute_switch_0		( 19'h100c1 ),
		.count_switch_0_tvalid	( count_switch_0_tvalid ),
		.s_droute_switch_1		( 19'h2013a ),
		.count_switch_1_tvalid	( count_switch_1_tvalid ),
		.s_droute_switch_2		( 19'h10083 ),
		.count_switch_2_tvalid	( count_switch_2_tvalid ),
		.in_valid				( in_valid ),

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
		.m_out_h_tready			( out_tready_h ),

		.s_in_i_tdata			( in_tdata_i  ),
		.s_in_i_tvalid			( in_tvalid_i ),
		.s_in_i_tready			( in_tready_i ),
		.m_out_i_tdata			( out_tdata_i ),
		.m_out_i_tvalid			( out_tvalid_i ),
		.m_out_i_tready			( out_tready_i )
	);


	integer handle0 ;
	initial handle0=$fopen("/media/Projects/poly_systolic_unit/py-sim/dat/data_route/out_a_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_a & out_tready_a) begin
				$fdisplay(handle0,"%h",out_tdata_a);
			end
		end
	end


	integer handle1 ;
	initial handle1=$fopen("/media/Projects/poly_systolic_unit/py-sim/dat/data_route/out_b_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_b & out_tready_b) begin
				$fdisplay(handle1,"%h",out_tdata_b);
			end
		end
	end


	integer handle2 ;
	initial handle2=$fopen("/media/Projects/poly_systolic_unit/py-sim/dat/data_route/out_c_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_c & out_tready_c) begin
				$fdisplay(handle2,"%h",out_tdata_c);
			end
		end
	end


	integer handle3 ;
	initial handle3=$fopen("/media/Projects/poly_systolic_unit/py-sim/dat/data_route/out_d_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_d & out_tready_d) begin
				$fdisplay(handle3,"%h",out_tdata_d);
			end
		end
	end


	integer handle4 ;
	initial handle4=$fopen("/media/Projects/poly_systolic_unit/py-sim/dat/data_route/out_e_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_e & out_tready_e) begin
				$fdisplay(handle4,"%h",out_tdata_e);
			end
		end
	end


	integer handle5 ;
	initial handle5=$fopen("/media/Projects/poly_systolic_unit/py-sim/dat/data_route/out_f_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_f & out_tready_f) begin
				$fdisplay(handle5,"%h",out_tdata_f);
			end
		end
	end


	integer handle6 ;
	initial handle6=$fopen("/media/Projects/poly_systolic_unit/py-sim/dat/data_route/out_g_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_g & out_tready_g) begin
				$fdisplay(handle6,"%h",out_tdata_g);
			end
		end
	end


	integer handle7 ;
	initial handle7=$fopen("/media/Projects/poly_systolic_unit/py-sim/dat/data_route/out_h_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_h & out_tready_h) begin
				$fdisplay(handle7,"%h",out_tdata_h);
			end
		end
	end


	integer handle8 ;
	initial handle8=$fopen("/media/Projects/poly_systolic_unit/py-sim/dat/data_route/out_i_sim.txt");
	always @ (posedge clk) begin
		if (rst_n) begin
			if (out_tvalid_i & out_tready_i) begin
				$fdisplay(handle8,"%h",out_tdata_i);
			end
		end
	end


endmodule
