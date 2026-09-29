//16bit:PS测试模式；0bit：光纤传输使能
devmem 0xa0010030  32 0x00010001


//TX depot write
devmem 0xb0000000  32 0x00000004
devmem 0xb0000010  32 0x00000006
devmem 0xb0000020  32 0x00000008
devmem 0xb0000030  32 0x00000009

devmem 0xb0000000  32 0x00000004


devmem 0xb0000010  32 0x00000106


devmem 0xb0000020  32 0x00000108


devmem 0xb0000030  32 0x00000109


//TX req
devmem 0xa0010040  32 0x00000001
devmem 0xa0010040  32 0x00000000


//RX depot read
devmem 0xb0010000  32
devmem 0xb0010010  32
devmem 0xb0010020  32
devmem 0xb0010030  32

//读取中断数据
cat /proc/interrupts

