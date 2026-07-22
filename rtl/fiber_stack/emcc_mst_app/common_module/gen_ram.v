/////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// Creat Date:
// Design Name
// Module Name
// Project Name
// Target Devices
// Tool versions:
//
// Dependencies:
//
//
// Revision:  ram has 2 latency
/////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps

module gen_ram
#(
     parameter  RAM_DWIDTH  = 32
    ,parameter  RAM_DEPTH   = 1024
    ,parameter  TYPE        = "TRUE"
    ,parameter  RAM_AWIDTH  = $clog2(RAM_DEPTH)
    ,parameter  EN_WIDTH    =(RAM_DWIDTH/8)
)
(
     input                      clka
    ,input                      ena
    ,input  [EN_WIDTH-1:0]      wea
    ,input  [RAM_AWIDTH-1:0]    addra
    ,input  [RAM_DWIDTH-1:0]    dina
    ,output [RAM_DWIDTH-1:0]    douta
    ,input                      clkb
    ,input                      enb
    ,input  [EN_WIDTH-1:0]      web
    ,input  [RAM_AWIDTH-1:0]    addrb
    ,input  [RAM_DWIDTH-1:0]    dinb
    ,output [RAM_DWIDTH-1:0]    doutb
);
    wire    [RAM_DWIDTH-1:0]    data_a;
    wire    [RAM_DWIDTH-1:0]    data_b;
    wire    [RAM_DWIDTH-1:0]    q_a;
    wire    [RAM_DWIDTH-1:0]    q_b;
    generate
        if(TYPE ==  "TRUE") begin:TRUE
            if(RAM_DEPTH == 1024) begin:DEPTH_1024
                if(RAM_DWIDTH == 32) begin:WIDTH_32
                    SDPBRAM_1024x32b SDPBRAM_1024x32b_u (
                         .clka      (clka   )   // input wire clka
                        ,.ena       (ena    )   // input wire ena
                        ,.wea       (wea    )   // input wire [3 : 0] wea
                        ,.addra     (addra  )   // input wire [9 : 0] addra
                        ,.dina      (dina   )   // input wire [31 : 0] dina
                        ,.clkb      (clkb   )   // input wire clkb
                        ,.enb       (enb    )   // input wire enb
                        ,.addrb     (addrb  )   // input wire [9 : 0] addrb
                        ,.doutb     (doutb  )   // output wire [31 : 0] doutb
                    );
                end
            end else if(RAM_DEPTH == 16384) begin:DEPTH_16384
                if(RAM_DWIDTH == 32) begin:WIDTH_32
                    TDPBRAM_16384x32b TDPBRAM_16384x32b_u (
                         .clka      (clka   )   // input wire clka
                        ,.ena       (ena    )   // input wire ena
                        ,.wea       (wea    )   // input wire [3 : 0] wea
                        ,.addra     (addra  )   // input wire [11 : 0] addra
                        ,.dina      (dina   )   // input wire [31 : 0] dina
                        ,.douta     (douta  )   // output wire [31 : 0] douta
                        ,.clkb      (clkb   )   // input wire clkb
                        ,.enb       (enb    )   // input wire enb
                        ,.web       (web    )   // input wire [3 : 0] web
                        ,.addrb     (addrb  )   // input wire [11 : 0] addrb
                        ,.dinb      (dinb   )   // input wire [31 : 0] dinb
                        ,.doutb     (doutb  )   // output wire [31 : 0] doutb
                    );
                end
            end else if(RAM_DEPTH == 2048) begin:DEPTH_2048
                if(RAM_DWIDTH == 32) begin:WIDTH_32
                    SDPBRAM_2048x32b SDPBRAM_2048x32b_u (
                         .clka      (clka   )
                        ,.ena       (ena    )
                        ,.wea       (wea    )
                        ,.addra     (addra  )
                        ,.dina      (dina   )
                        ,.clkb      (clkb   )
                        ,.enb       (enb    )
                        ,.addrb     (addrb  )
                        ,.doutb     (doutb  )
                    );
                end
            end else if(RAM_DEPTH == 512) begin:DEPTH_512
                if(RAM_DWIDTH == 32) begin:WIDTH_32
                    TDPBRAM_512x32b TDPBRAM_512x32b_u (
                         .clka      (clka   )   // input wire clka
                        ,.ena       (ena    )   // input wire ena
                        ,.wea       (wea    )   // input wire [3 : 0] wea
                        ,.addra     (addra  )   // input wire [11 : 0] addra
                        ,.dina      (dina   )   // input wire [31 : 0] dina
                        ,.douta     (douta  )   // output wire [31 : 0] douta
                        ,.clkb      (clkb   )   // input wire clkb
                        ,.enb       (enb    )   // input wire enb
                        ,.web       (web    )   // input wire [3 : 0] web
                        ,.addrb     (addrb  )   // input wire [11 : 0] addrb
                        ,.dinb      (dinb   )   // input wire [31 : 0] dinb
                        ,.doutb     (doutb  )   // output wire [31 : 0] doutb
                    );
                end
            end else if(RAM_DEPTH == 4096) begin:DEPTH_4096
                if(RAM_DWIDTH == 32) begin:WIDTH_32
                    TDPBRAM_4096x32b TDPBRAM_4096x32b_u (
                         .clka      (clka   )   // input wire clka
                        ,.ena       (ena    )   // input wire ena
                        ,.wea       (wea    )   // input wire [3 : 0] wea
                        ,.addra     (addra  )   // input wire [11 : 0] addra
                        ,.dina      (dina   )   // input wire [31 : 0] dina
                        ,.douta     (douta  )   // output wire [31 : 0] douta
                        ,.clkb      (clkb   )   // input wire clkb
                        ,.enb       (enb    )   // input wire enb
                        ,.web       (web    )   // input wire [3 : 0] web
                        ,.addrb     (addrb  )   // input wire [11 : 0] addrb
                        ,.dinb      (dinb   )   // input wire [31 : 0] dinb
                        ,.doutb     (doutb  )   // output wire [31 : 0] doutb
                    );
                end
            end
        end else if (TYPE == "ULTRA")begin:ULTRA
            xilinx_ultraram_true_dual_port
            #(
                 .AWIDTH(RAM_AWIDTH)
                ,.DWIDTH(RAM_DWIDTH)
                ,.NBPIPE(1)
            )
                ultra_ram_u
                (
                     .clk       (clka   )
                    ,.rsta      (0      )
                    ,.wea       (wea    )
                    ,.regcea    (1      )
                    ,.mem_ena   (1      )
                    ,.dina      (dina   )
                    ,.addra     (addra  )
                    ,.douta     (douta  )
                    ,.rstb      (0      )
                    ,.web       (web    )
                    ,.regceb    (1      )
                    ,.mem_enb   (1      )
                    ,.dinb      (dinb   )
                    ,.addrb     (addrb  )
                    ,.doutb     (doutb  )
                );
        end else if (TYPE == "BLOCK_SDP")begin:BLOCK
            xilinx_simple_dual_port_2_clock_ram
            #(
                 .RAM_WIDTH         (RAM_DWIDTH         )                      // Specify RAM data width
                ,.RAM_DEPTH         (RAM_DEPTH          )                    // Specify RAM depth (number of entries)
                ,.RAM_PERFORMANCE   ("HIGH_PERFORMANCE" )// Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
                ,.INIT_FILE         (""                 )                        // Specify name/location of RAM initialization file if using one (leave blank if not)
            )
                sdp_2_clk_ram_u (
                     .clka      (clka   )   // Write clock
                    ,.wea       (wea    )   // Write enable
                    ,.addra     (addra  )   // Write address bus, width determined from RAM_DEPTH
                    ,.dina      (dina   )   // RAM input data, width determined from RAM_WIDTH
                    ,.clkb      (clkb   )   // Read clock
                    ,.rstb      (0      )   // Output reset (does not affect memory contents)
                    ,.regceb    (1      )   // Output register enable
                    ,.enb       (enb    )   // Read Enable, for additional power savings, disable when not in use
                    ,.addrb     (addrb  )   // Read address bus, width determined from RAM_DEPTH
                    ,.doutb     (doutb  )   // RAM output data, width determined from RAM_WIDTH
                );
        end else if (TYPE == "BLOCK")begin:BLOCK
            xilinx_true_dual_port_read_first_2_clock_ram #(
               .RAM_WIDTH       (RAM_DWIDTH )                    // Specify RAM data width
              ,.RAM_DEPTH       (RAM_DEPTH  )                    // Specify RAM depth (number of entries)
            )
                block_ram_u
                (
                     .clka          (clka)                           // Port A clock
                    ,.rsta          (0)                           // Port A output reset (does not affect memory contents)
                    ,.ena           (ena)                            // Port A RAM Enable, for additional power savings, disable port when not in use
                    ,.wea           (wea)                            // Port A write enable
                    ,.regcea        (1      )                         // Port A output register enable
                    ,.addra         (addra)  // Port A address bus, width determined from RAM_DEPTH
                    ,.dina          (dina)           // Port A RAM input data
                    ,.douta         (douta)         // Port A RAM output data
                    ,.clkb          (clkb)                           // Port B clock
                    ,.rstb          (0)                           // Port B output reset (does not affect memory contents)
                    ,.web           (web)                            // Port B write enable
                    ,.enb           (enb)                            // Port B RAM Enable, for additional power savings, disable port when not in use
                    ,.regceb        (1)                         // Port B output register enable
                    ,.addrb         (addrb)  // Port B address bus, width determined from RAM_DEPTH
                    ,.dinb          (dinb)           // Port B RAM input data
                    ,.doutb         (doutb)        // Port B RAM output data
                );
        end
    endgenerate
endmodule
