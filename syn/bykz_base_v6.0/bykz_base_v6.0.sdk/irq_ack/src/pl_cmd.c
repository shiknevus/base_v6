// @file pl_cmd.c
// serial cmds: trigger A/B behaviors, set motion params (float x factor -> pulses)

#include "pl_cmd.h"
#include "pl_reg.h"
#include "pl_irq.h"
#include "util.h"

#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"
#include "xuartps_hw.h"
#include "xparameters.h"

#define EC_BASE   (PL_CFG_BASE + REG_BIAS_EC_PUL_AXIS)
#define EC1DO_BASE (PL_CFG_BASE + REG_BIAS_EC_1DO)
#define EC_S1DO_BASE (PL_CFG_BASE + REG_BIAS_EC_1DO_SLV)
#define EC_SRV_BASE (PL_CFG_BASE + REG_BIAS_EC_CAN_SERVO)
#define EC_SLV_BASE (PL_CFG_BASE + REG_BIAS_EC_SLV_PUL_AXIS)
#define INTC_BASE 0xA0000000U   // INTC #0

// motion params (mm units)
static float g_spd    = 20.0f;   // mm/s
static float g_acc    = 20.0f;   // mm/s2
static float g_dec    = 20.0f;   // mm/s2
static float g_target = 300.0f;  // mm
static float g_step   = 50.0f;   // mm
static u32   g_factor = 50000U;  // pulse/mm

// input mode
typedef enum { MODE_NORMAL, MODE_PARAM_SEL, MODE_PARAM_VAL } InputMode;
static InputMode g_mode = MODE_NORMAL;
static int  g_param_sel;
static char g_val_buf[24];
static int  g_val_len;

// pulse/mm factor, used by irq ack pos report
u32 CmdFactor(void)
{
    return g_factor;
}

// motion defaults -> PL
void CmdInit(void)
{
    u32 base = EC_BASE;
    float f  = (float)g_factor;

    Xil_Out32(base + PARAM1,  (u32)(int)(80.0f    * f)); // max spd
    Xil_Out32(base + PARAM2,  (u32)(int)(200.0f   * f)); // max acc
    Xil_Out32(base + PARAM3,  (u32)(int)(200.0f   * f)); // max dec
    Xil_Out32(base + PARAM5,  (u32)(int)(g_acc    * f)); // acc
    Xil_Out32(base + PARAM33, (u32)(int)(2.0f     * f)); // touch clamp spd
    Xil_Out32(base + PARAM34, (u32)(int)(g_dec    * f)); // dec
    Xil_Out32(base + PARAM35, (u32)(int)(g_spd    * f)); // spd
    Xil_Out32(base + PARAM36, (u32)(int)(g_target * f)); // target
    Xil_Out32(base + PARAM37, (u32)(int)(g_step   * f)); // step
    Xil_Out32(base + PARAM16, 0x00000001U);              // dir POS
    Xil_Out32(base + PARAM30, 0x00000001U);              // drive on

    // slv pulse axis defaults (same params as mst axis)
    base = EC_SLV_BASE;
    Xil_Out32(base + PARAM1,  (u32)(int)(80.0f    * f));  // max spd
    Xil_Out32(base + PARAM2,  (u32)(int)(200.0f   * f));  // max acc
    Xil_Out32(base + PARAM3,  (u32)(int)(200.0f   * f));  // max dec
    Xil_Out32(base + PARAM5,  (u32)(int)(g_acc    * f));  // acc
    Xil_Out32(base + PARAM33, (u32)(int)(2.0f     * f));  // touch clamp spd
    Xil_Out32(base + PARAM34, (u32)(int)(g_dec    * f));  // dec
    Xil_Out32(base + PARAM35, (u32)(int)(g_spd    * f));  // spd
    Xil_Out32(base + PARAM36, (u32)(int)(g_target * f));  // target
    Xil_Out32(base + PARAM37, (u32)(int)(g_step   * f));  // step
    Xil_Out32(base + PARAM16, 0x00000001U);               // dir POS
    Xil_Out32(base + PARAM30, 0x00000001U);               // drive on
}

static int PollKey(void)
{
    int c;
    if (!XUartPs_IsReceiveData(STDIN_BASEADDRESS))
        return 0;
    c = XUartPs_RecvByte(STDIN_BASEADDRESS);
    return (c == 0xFF) ? 0 : c;
}

void PrintMenu(void)
{
    xil_printf("\r\n");
    xil_printf("-------------------------------------------\r\n");
    xil_printf(" ec_1do + ec_pul_axis + ec_slv_pul_axis  m: menu\r\n");
    xil_printf("-------------------------------------------\r\n");
    xil_printf(" A: 1/2/3/4/5/6 = home/jog/move/jog/move/getpos\r\n");
    xil_printf(" B: x/v/k/e/f/d = pause/resume/stop/son/soff/reset \r\n");
    xil_printf(" 1DO: 7/8/9=do on/off/st   t/y/u=slv on/off/st \r\n");
    xil_printf(" SRV: h/z/p=home/zero/pos  b/c=stop/read  o=st \r\n");
    xil_printf(" SLV: a/j/l=home/jog/move  i=st  n/q/U=pause/resume/stop\r\n");
    xil_printf("      D/E/F=reset/son/soff\r\n");
    xil_printf(" w: set params   r: regs   s: ch status   \r\n");
    xil_printf("-------------------------------------------\r\n");
}

static void PrintParamMenu(void)
{
    xil_printf("\r\n--- Set param ---\r\n");
    xil_printf(" 1: spd    (mm/s)  = ");
    PrintFp(g_spd);
    xil_printf(" (PARAM35)\r\n");
    xil_printf(" 2: acc    (mm/s2) = ");
    PrintFp(g_acc);
    xil_printf(" (PARAM5)\r\n");
    xil_printf(" 3: dec    (mm/s2) = ");
    PrintFp(g_dec);
    xil_printf(" (PARAM34)\r\n");
    xil_printf(" 4: target (mm)    = ");
    PrintFp(g_target);
    xil_printf(" (PARAM36)\r\n");
    xil_printf(" 5: step   (mm)    = ");
    PrintFp(g_step);
    xil_printf(" (PARAM37)\r\n");
    xil_printf(" 6: factor (pulse/mm) = %u \r\n", (unsigned)g_factor);
    xil_printf("Select (1~6, q cancel): ");
}

// A ch trigger: write A_BHV_ID, RTL pulses a_bhv_vld
static void TrigBhv(u8 id)
{
    if (Xil_In32(EC_BASE + EC_CHA_ST))
        xil_printf("[A] busy, bhv %u ignored\r\n", (unsigned)id);
    else {
        Xil_Out32(EC_BASE + A_BHV_ID, (u32)id);
        xil_printf("A bhv %u\r\n", (unsigned)id);
    }
}

// B ch triggers: rctrl bits (pre_sta in RTL), auto-cleared by b_clr_*
static void TrigPause(void)
{
    Xil_Out32(EC_BASE + PARAM26, 1U);
    xil_printf("B pause(100)\r\n");
}
static void TrigResume(void)
{
    Xil_Out32(EC_BASE + PARAM28, 1U);   // P28 first
    Xil_Out32(EC_BASE + PARAM26, 1U);
    xil_printf("B resume(101)\r\n");
}
static void TrigStop(void)
{
    Xil_Out32(EC_BASE + PARAM27, 1U);   // P27 first
    Xil_Out32(EC_BASE + PARAM26, 1U);
    xil_printf("B stop(103)\r\n");
}
static void TrigReset(void)
{
    Xil_Out32(EC_BASE + PARAM29, 1U);   // pulse
    usleep(10000);
    Xil_Out32(EC_BASE + PARAM29, 0U);
    xil_printf("B reset(102)\r\n");
}
static void TrigSon(void)
{
    Xil_Out32(EC_BASE + PARAM30, 1U);
    xil_printf("B son(104)\r\n");
}
static void TrigSoff(void)
{
    Xil_Out32(EC_BASE + PARAM30, 0U);
    xil_printf("B soff(105)\r\n");
}

// --- slv pulse axis A ch ---
static void TrigSlvBhv(u8 id)
{
    if (Xil_In32(EC_SLV_BASE + EC_CHA_ST))
        xil_printf("[SLV_A] busy, bhv %u ignored\r\n", (unsigned)id);
    else {
        Xil_Out32(EC_SLV_BASE + A_BHV_ID, (u32)id);
        xil_printf("SLV A bhv %u\r\n", (unsigned)id);
    }
}

// --- slv pulse axis B ch ---
static void TrigSlvPause(void)
{
    Xil_Out32(EC_SLV_BASE + PARAM26, 1U);
    xil_printf("SLV B pause(100)\r\n");
}
static void TrigSlvResume(void)
{
    Xil_Out32(EC_SLV_BASE + PARAM28, 1U);
    Xil_Out32(EC_SLV_BASE + PARAM26, 1U);
    xil_printf("SLV B resume(101)\r\n");
}
static void TrigSlvStop(void)
{
    Xil_Out32(EC_SLV_BASE + PARAM27, 1U);
    Xil_Out32(EC_SLV_BASE + PARAM26, 1U);
    xil_printf("SLV B stop(103)\r\n");
}
static void TrigSlvReset(void)
{
    Xil_Out32(EC_SLV_BASE + PARAM29, 1U);
    usleep(10000);
    Xil_Out32(EC_SLV_BASE + PARAM29, 0U);
    xil_printf("SLV B reset(102)\r\n");
}
static void TrigSlvSon(void)
{
    Xil_Out32(EC_SLV_BASE + PARAM30, 1U);
    xil_printf("SLV B son(104)\r\n");
}
static void TrigSlvSoff(void)
{
    Xil_Out32(EC_SLV_BASE + PARAM30, 0U);
    xil_printf("SLV B soff(105)\r\n");
}

// 1do A ch trigger: bhv 1=do on, 2=do off
static void TrigDoAt(u32 base, u8 id)
{
    if (Xil_In32(base + EC_CHA_ST))
        xil_printf("[1DO] busy, bhv %u ignored\r\n", (unsigned)id);
    else {
        Xil_Out32(base + A_BHV_ID, (u32)id);
        xil_printf("1DO bhv %u\r\n", (unsigned)id);
    }
}
static void TrigDo(u8 id)    { TrigDoAt(EC1DO_BASE, id); }
static void TrigDoS(u8 id)   { TrigDoAt(EC_S1DO_BASE, id); }

// 1do status + do level (PARAM66)
static void Read1DoStAt(u32 base)
{
    xil_printf("1DO: busy=%u tx=%u alm=%u fsm=0x%08x do=%u\r\n",
        (unsigned)Xil_In32(base + EC_CHA_ST), (unsigned)Xil_In32(base + A_TX_ID),
        (unsigned)Xil_In32(base + A_ALM_NUM), (unsigned)Xil_In32(base + DEBUG_REG1),
        (unsigned)Xil_In32(base + PARAM66));
}
static void Read1DoSt(void)  { Read1DoStAt(EC1DO_BASE); }
static void Read1DoStS(void) { Read1DoStAt(EC_S1DO_BASE); }

// can servo A ch trigger (bhv: 1home 2zero 3pos 7vstop 8vread)
static void TrigSrvBhv(u8 id)
{
    if (Xil_In32(EC_SRV_BASE + EC_CHA_ST))
        xil_printf("[SRV] busy, bhv %u ignored\r\n", (unsigned)id);
    else {
        Xil_Out32(EC_SRV_BASE + A_BHV_ID, (u32)id);
        xil_printf("SRV bhv %u\r\n", (unsigned)id);
    }
}

static void ReadSrvSt(void)
{
    u32 base = EC_SRV_BASE;
    xil_printf("SRV: busy=%u tx=%u bhv=%u alm=%u fsm=0x%08x\r\n",
        (unsigned)Xil_In32(base + EC_CHA_ST), (unsigned)Xil_In32(base + A_TX_ID),
        (unsigned)Xil_In32(base + A_BHV_ID), (unsigned)Xil_In32(base + A_ALM_NUM),
        (unsigned)Xil_In32(base + DEBUG_REG1));
}

static void ReadSlvChSt(void)
{
    u32 base = EC_SLV_BASE;
    xil_printf("SLV A: busy=%u tx=%u bhv=%u alm=%u fsm=0x%08x\r\n",
        (unsigned)Xil_In32(base + EC_CHA_ST), (unsigned)Xil_In32(base + A_TX_ID),
        (unsigned)Xil_In32(base + A_BHV_ID), (unsigned)Xil_In32(base + A_ALM_NUM),
        (unsigned)Xil_In32(base + DEBUG_REG1));
    xil_printf("SLV B: busy=%u tx=%u bhv=%u alm=%u fsm=0x%08x\r\n",
        (unsigned)Xil_In32(base + EC_CHB_ST), (unsigned)Xil_In32(base + B_TX_ID),
        (unsigned)Xil_In32(base + B_BHV_ID), (unsigned)Xil_In32(base + B_ALM_NUM),
        (unsigned)Xil_In32(base + DEBUG_REG2));
    xil_printf("SLV C: busy=%u tx=%u bhv=%u alm=%u fsm=0x%08x\r\n",
        (unsigned)Xil_In32(base + EC_CHC_ST), (unsigned)Xil_In32(base + C_TX_ID),
        (unsigned)Xil_In32(base + C_BHV_ID), (unsigned)Xil_In32(base + C_ALM_NUM),
        (unsigned)Xil_In32(base + DEBUG_REG3));
}

// float -> pulses by factor, write to PL
static void ParamApply(void)
{
    u32 off, p;
    float v;
    int sel = g_param_sel;

    if (sel == 6) {   // factor: integer, pulse/mm
        g_factor = ParseUint(g_val_buf);
        xil_printf("factor %u pulse/mm \r\n", (unsigned)g_factor);
        return;
    }

    v = ParseFloat(g_val_buf);
    switch (sel) {
    case 1: g_spd = v;    off = PARAM35; break;
    case 2: g_acc = v;    off = PARAM5;  break;
    case 3: g_dec = v;    off = PARAM34; break;
    case 4: g_target = v; off = PARAM36; break;
    default: g_step = v;  off = PARAM37; break;   // sel 5
    }
    p = (u32)(int)(v * (float)g_factor);
    Xil_Out32(EC_BASE + off, p);
    xil_printf("PARAM%u = %u pulses\r\n",
               (unsigned)(sel == 1 ? 35 : sel == 2 ? 5 : sel == 3 ? 34 : sel == 4 ? 36 : 37),
               (unsigned)p);
}

// pulses -> mm
static void PrintMm(u32 pulses)
{
    PrintFp((float)(int)pulses / (float)g_factor);
}

// A/B/C channel status + FSM state (DEBUG_REG1/2/3)
static void ReadChSt(void)
{
    u32 base = EC_BASE;
    xil_printf("A: busy=%u tx=%u bhv=%u alm=%u fsm=0x%08x\r\n",
        (unsigned)Xil_In32(base + EC_CHA_ST), (unsigned)Xil_In32(base + A_TX_ID),
        (unsigned)Xil_In32(base + A_BHV_ID), (unsigned)Xil_In32(base + A_ALM_NUM),
        (unsigned)Xil_In32(base + DEBUG_REG1));
    xil_printf("B: busy=%u tx=%u bhv=%u alm=%u fsm=0x%08x\r\n",
        (unsigned)Xil_In32(base + EC_CHB_ST), (unsigned)Xil_In32(base + B_TX_ID),
        (unsigned)Xil_In32(base + B_BHV_ID), (unsigned)Xil_In32(base + B_ALM_NUM),
        (unsigned)Xil_In32(base + DEBUG_REG2));
    xil_printf("C: busy=%u tx=%u bhv=%u alm=%u fsm=0x%08x\r\n",
        (unsigned)Xil_In32(base + EC_CHC_ST), (unsigned)Xil_In32(base + C_TX_ID),
        (unsigned)Xil_In32(base + C_BHV_ID), (unsigned)Xil_In32(base + C_ALM_NUM),
        (unsigned)Xil_In32(base + DEBUG_REG3));
}

// test view
static void ReadRegs(void)
{
    u32 base = EC_BASE;
    xil_printf("spd=");
    PrintMm(Xil_In32(base + PARAM35));
    xil_printf(" acc=");
    PrintMm(Xil_In32(base + PARAM5));
    xil_printf(" dec=");
    PrintMm(Xil_In32(base + PARAM34));
    xil_printf(" target=");
    PrintMm(Xil_In32(base + PARAM36));
    xil_printf(" step=");
    PrintMm(Xil_In32(base + PARAM37));
    xil_printf("\r\n");
    xil_printf("pause=%u stop=%u resume=%u drv_rst=%u drv_on=%u\r\n",
        (unsigned)Xil_In32(base + PARAM26),
        (unsigned)Xil_In32(base + PARAM27),
        (unsigned)Xil_In32(base + PARAM28),
        (unsigned)Xil_In32(base + PARAM29),
        (unsigned)Xil_In32(base + PARAM30));
}

// irq path diag
static void ReadIrqDbg(void)
{
    xil_printf("IRQ_REG1=0x%08x IRQ_REG2=0x%08x INTC_ISR=0x%08x IER=0x%08x isr=%u\r\n",
        (unsigned)Xil_In32(EC_BASE + IRQ_REG1),
        (unsigned)Xil_In32(EC_BASE + IRQ_REG2),
        (unsigned)Xil_In32(INTC_BASE + 0x00U),
        (unsigned)Xil_In32(INTC_BASE + 0x08U),
        (unsigned)IrqIsrCount());
}

static void HandleKey(char key)
{
    // param value input
    if (g_mode == MODE_PARAM_VAL) {
        if ((key >= '0' && key <= '9') || key == '.' || key == '-') {
            if (g_val_len < (int)sizeof(g_val_buf) - 1) {
                g_val_buf[g_val_len++] = key;
                g_val_buf[g_val_len] = 0;
                xil_printf("%c", key);
            }
        } else if (key == '\r' || key == '\n') {
            xil_printf("\r\n");
            if (g_val_len > 0)
                ParamApply();
            else
                xil_printf("empty, ignored\r\n");
            g_val_len = 0;
            g_val_buf[0] = 0;
            g_mode = MODE_NORMAL;
        } else if (key == 0x7F || key == 0x08) {   // backspace
            if (g_val_len > 0) {
                g_val_len--;
                g_val_buf[g_val_len] = 0;
                xil_printf("\b \b");
            }
        } else if (key == 0x1B) {                  // ESC
            xil_printf("\r\ncancelled\r\n");
            g_val_len = 0;
            g_val_buf[0] = 0;
            g_mode = MODE_NORMAL;
        }
        return;
    }

    // param select
    if (g_mode == MODE_PARAM_SEL) {
        if (key >= '1' && key <= '6') {
            g_param_sel = (int)(key - '0');
            g_val_len = 0;
            g_val_buf[0] = 0;
            g_mode = MODE_PARAM_VAL;
            xil_printf("%c\r\nenter value: ", key);
        } else if (key == 0x1B || key == 'q' || key == 'Q') {
            xil_printf("\r\ncancelled\r\n");
            g_mode = MODE_NORMAL;
        }
        return;
    }

    switch (key) {
    case '1': TrigBhv(1);  break;
    case '2': TrigBhv(2);  break;
    case '3': TrigBhv(3);  break;
    case '4': TrigBhv(20); break;
    case '5': TrigBhv(21); break;
    case '6': TrigBhv(30); break;
    case '7': TrigDo(1); break;
    case '8': TrigDo(2); break;
    case '9': Read1DoSt(); break;
    case 't': TrigDoS(1); break;
    case 'y': TrigDoS(2); break;
    case 'u': Read1DoStS(); break;
    case 'h': TrigSrvBhv(1); break;   // home
    case 'z': TrigSrvBhv(2); break;   // zero
    case 'p': TrigSrvBhv(3); break;   // pos
    case 'b': TrigSrvBhv(7); break;   // vstop
    case 'c': TrigSrvBhv(8); break;   // vread
    case 'o': ReadSrvSt(); break;
    case 'a': TrigSlvBhv(1); break;   // home
    case 'j': TrigSlvBhv(2); break;   // jog
    case 'l': TrigSlvBhv(3); break;   // move
    case 'i': ReadSlvChSt(); break;
    case 'n': TrigSlvPause(); break;
    case 'q': TrigSlvResume(); break;
    case 'U': TrigSlvStop(); break;
    case 'D': TrigSlvReset(); break;
    case 'E': TrigSlvSon(); break;
    case 'F': TrigSlvSoff(); break;
    case 'x': TrigPause();  break;
    case 'v': TrigResume(); break;
    case 'k': TrigStop();   break;
    case 'e': TrigSon();    break;
    case 'f': TrigSoff();   break;
    case 'd': TrigReset();  break;
    case 'w': case 'W':
        g_mode = MODE_PARAM_SEL;
        PrintParamMenu();
        break;
    case 'r': case 'R': ReadRegs(); break;
    case 's': case 'S': ReadChSt(); break;
    case 'g': case 'G': ReadIrqDbg(); break;
    case 'm': case 'M': PrintMenu(); break;
    default:
        if (key >= 32 && key < 127)
            xil_printf("[?] '%c' - press m for menu\r\n", key);
    }
}

void CmdPoll(void)
{
    int key = PollKey();
    if (key)
        HandleKey((char)key);
}
