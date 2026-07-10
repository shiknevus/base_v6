/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Huaye Zhang
// Creat Date:    
// Design Name:   
// Module Name:   
// Project Name:  
// Target Devices:
// Tool versions:
//                
// Dependencies:
//    
//
//Description:
//
/////////////////////////////////////////////////////////////////
module com_io_top
#(
     parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
)
(
     input                              clk
    ,input                              reset

    ,input  wire                        driver_cfg_wea
    ,input  wire    [RAM_AWIDTH-1:0]    driver_cfg_addra
    ,input  wire    [RAM_DWIDTH-1:0]    driver_cfg_dina
    
    ,input  wire                        rd_msg_addr_en
    ,input  wire    [RAM_AWIDTH-1:0]    rd_msg_addr
    ,output reg     [RAM_DWIDTH-1:0]    do_status
    ,output reg     [RAM_DWIDTH-1:0]    di_status
//    ,output reg     [RAM_DWIDTH-1:0]    ao_status
    ,output reg     [RAM_DWIDTH-1:0]    ai_status
);
    reg     [RAM_DWIDTH-1:0]    do_status_1st;
    reg     [RAM_DWIDTH-1:0]    do_status_2nd;
    reg     [RAM_DWIDTH-1:0]    di_status_1st;
    reg     [RAM_DWIDTH-1:0]    di_status_2nd;
    reg     [RAM_DWIDTH-1:0]    di_status_3rd;
//    reg     [RAM_DWIDTH-1:0]    ao_status_1st;
    reg     [RAM_DWIDTH-1:0]    ai_status_1st;
    reg     [RAM_DWIDTH-1:0]    do_status_reg;
    reg     [RAM_DWIDTH-1:0]    di_status_reg;
//    reg     [RAM_DWIDTH-1:0]    ao_status_reg;
    reg     [RAM_DWIDTH-1:0]    ai_status_reg;

//do
    always @(posedge clk)begin
        if(reset)begin
            do_status_1st   <=  'd0;
        end else if (driver_cfg_wea & (driver_cfg_addra == (`DEPOT_BIAS_DO))) begin
            do_status_1st   <=  driver_cfg_dina;
        end else begin
            do_status_1st   <=  do_status_1st;
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            do_status_2nd   <=  'd0;
        end else if (driver_cfg_wea & (driver_cfg_addra == (`DEPOT_BIAS_DO + 1))) begin
            do_status_2nd   <=  driver_cfg_dina;
        end else begin
            do_status_2nd   <=  do_status_2nd;
        end
    end
//di
    always @(posedge clk)begin
        if(reset)begin
            di_status_1st   <=  'd0;
        end else if (driver_cfg_wea & (driver_cfg_addra == (`DEPOT_BIAS_DI))) begin
            di_status_1st   <=  driver_cfg_dina;
        end else begin
            di_status_1st   <=  di_status_1st;
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            di_status_2nd   <=  'd0;
        end else if (driver_cfg_wea & (driver_cfg_addra == (`DEPOT_BIAS_DI + 1))) begin
            di_status_2nd   <=  driver_cfg_dina;
        end else begin
            di_status_2nd   <=  di_status_2nd;
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            di_status_3rd   <=  'd0;
        end else if (driver_cfg_wea & (driver_cfg_addra == (`DEPOT_BIAS_DI + 2))) begin
            di_status_3rd   <=  driver_cfg_dina;
        end else begin
            di_status_3rd   <=  di_status_3rd;
        end
    end

////ao
//    always @(posedge clk)begin
//        if(reset)begin
//            ao_status_1st   <=  'd0;
//        end else if (driver_cfg_wea & (driver_cfg_addra == (`DEPOT_BIAS_AO))) begin
//            ao_status_1st   <=  driver_cfg_dina;
//        end else begin
//            ao_status_1st   <=  ao_status_1st;
//        end
//    end

//ai
    always @(posedge clk)begin
        if(reset)begin
            ai_status_1st   <=  'd0;
        end else if (driver_cfg_wea & (driver_cfg_addra == (`DEPOT_BIAS_AI))) begin
            ai_status_1st   <=  driver_cfg_dina;
        end else begin
            ai_status_1st   <=  ai_status_1st;
        end
    end

//read port
    always @(posedge clk)begin
        if(reset)begin
            do_status_reg   <=  'd0;
        end else if (rd_msg_addr_en & (rd_msg_addr == (`DEPOT_BIAS_DO))) begin
            do_status_reg   <=  do_status_1st;
        end else if (rd_msg_addr_en & (rd_msg_addr == (`DEPOT_BIAS_DO + 1))) begin
            do_status_reg   <=  do_status_2nd;
        end else begin
            do_status_reg   <=  do_status_reg;
        end
    end

    always @(posedge clk)begin
        do_status   <=  do_status_reg;
    end

    always @(posedge clk)begin
        if(reset)begin
            di_status_reg   <=  'd0;
        end else if (rd_msg_addr_en & (rd_msg_addr == (`DEPOT_BIAS_DI))) begin
            di_status_reg   <=  di_status_1st;
        end else if (rd_msg_addr_en & (rd_msg_addr == (`DEPOT_BIAS_DI + 1))) begin
            di_status_reg   <=  di_status_2nd;
        end else if (rd_msg_addr_en & (rd_msg_addr == (`DEPOT_BIAS_DI + 2))) begin
            di_status_reg   <=  di_status_3rd;
        end else begin
            di_status_reg   <=  di_status_reg;
        end
    end

    always @(posedge clk)begin
        di_status   <=  di_status_reg;
    end

//   always @(posedge clk)begin
//        if(reset)begin
//            ao_status_reg   <=  'd0;
//        end else if (rd_msg_addr_en & (rd_msg_addr == (`DEPOT_BIAS_AO))) begin
//            ao_status_reg   <=  ao_status_1st;
//        end else begin
//            ao_status_reg   <=  ao_status_reg;
//        end
//    end

//    always @(posedge clk)begin
//        ao_status   <=  ao_status_reg;
//    end

    always @(posedge clk)begin
        if(reset)begin
            ai_status_reg   <=  'd0;
        end else if (rd_msg_addr_en & (rd_msg_addr == (`DEPOT_BIAS_AI))) begin
            ai_status_reg   <=  ai_status_1st;
        end else begin
            ai_status_reg   <=  ai_status_reg;
        end
    end
    always @(posedge clk)begin
        ai_status   <=  ai_status_reg;
    end


endmodule

