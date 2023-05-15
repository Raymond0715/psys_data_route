/**
*
* Company:        Zhejiang University
* Engineer:       Raymond
*
* Create Date:    2023/05/11
* Design Name:    poly_systolic_hw
* Module Name:    decoder_3_8
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


module decoder_3_8 (
	input	[2:0]								in,
	output	[7:0]								out
);

	assign out[0] = ~in[2] & ~in[1] & ~in[0];
	assign out[1] =  in[2] & ~in[1] & ~in[0];
	assign out[2] = ~in[2] &  in[1] & ~in[0];
	assign out[3] =  in[2] &  in[1] & ~in[0];
	assign out[4] = ~in[2] & ~in[1] &  in[0];
	assign out[5] =  in[2] & ~in[1] &  in[0];
	assign out[6] = ~in[2] &  in[1] &  in[0];
	assign out[7] =  in[2] &  in[1] &  in[0];

endmodule
