* Bring up order, including PLD code  
  * 68000 cross-compiler under macOS \- docker command \- but your Ubuntu is in a moving box  
  * GLUE bitfile supporting ROM, RAM, CF, IO  
  * Debug CLK  
  * Debug RESET and HALT  
  * Test DTACK, ROM\_SELECT, LDS, UDS, AS, A1-A16, D0-D15  
  * Make routine for bitbang serial out over DEBUG\_OUT  
  * Test RAM\_BANK\_1\_SELECT  
  * Emulator for 68000  
    - [ ] Detect debug-in and debug-out bitbang?  
  * Software \- get to interactive prompt and disk, which would   
    - [ ] About 2 sec of boot loop cycling debug\_out, 2Hz (“blinka blinka” every second)  
    - [ ] Test DEBUG\_OUT with flashy  
    - [ ] Switch to serial out over DEBUG\_OUT  
          * DEBUG\_OUT serial char out disables interrupts  
    - [ ] **At this point, ROM, GLUE, CPU, CLK, RESET, interrupts, and DEBUG\_OUT all work.**  
    - [ ] Test serial polling on DEBUG\_IN  
    - [ ] Add bootloader code to receive and run a binary over serial  
          * Need a toolchain to emit “loadable” binary  
    - [ ] Check and configure RAM size, print to serial  
    - [ ] Check and configure CF card first block, print to serial  
    - [ ] **At this point, storage works**  
          * **Could actually run CP/M-68K**  
    - [ ] Write MCU serial I/O and timer interrupts and protocol  
    - [ ] Do negotiation with MCU \- probably need an “OK” status  
    - [ ] Switch to serial over MCU  
    - [ ] Install ISR that flashies at 2Hz and updates time and date  
    - [ ] **At this point, serial I/O and timers and the MCU protocol work**  
    - [ ] Write boot code to query the time and date  
    - [ ] Rest of monitor  
  * BIOS looks like this:  
    - [ ] Tier 1 — Boot and run CP/M-68K with nothing else:  
          * Serial console (polled): init, putchar, getchar, status  
          * Block device: read sector, write sector, select, geometry query  
          * Boot: cold start, warm start  
          * Memory sizing / map query  
    - [ ] Tier 2 — Make it a useful standalone monitor/ROM environment:  
          * Simple memory read/write/fill/dump commands (monitor)  
          * S-record or Intel HEX loader over serial  
          * Basic trap dispatch (so user code calls ROM services via TRAP \#n rather than hardcoded addresses)  
    - [ ] Tier 3 \- Timer hardware  
          * Timer ISR with a tick counter  
          * GET\_TIME / SET\_TIME (calendar time, seeded at boot or via serial command)  
          * Optional delay/sleep primitive  
    - [ ] Tier 4  
          * Video console driver (when your video hardware is working)  
          * Mouse and keyboard input  
  * Monitor looks like:  
    - [ ] Print hello and revision and date  
    - [ ] Print RAM size  
    - [ ] Wait for two seconds for interrupt to monitor \- commands:  
          * Dir CF card FAT boot partition  
          * Load and boot from boot partition  
          * Receive and boot from serial  
          * (later) Flash MCU from boot partition file  
            * Disable interrupts,  
            * Drop back to DEBUG\_IN serial output for duration  
    - [ ] Check CF card boot partition for boot kernel name or information and boot it  
* Software path  
  * GLUE CPLD for ROM, RAM, IO, CF card  
  * Bitbang serial  
  * IO code for serial port  
  * Boot monitor  
    - [ ] Serial port  
* USB-C power with switch inline between supply and USB-C port  
  * “two 5.1k pull-downs on both CC pins of your connector” \- check for 1A delivery, test this  
* RC reset/halt trigger \- short RC to discharge with reset button  
* CPUCLK \- 12MHz clock or 20 MHz from TTL oscillator, okay to change and reflash GLUE bitfile if clock is changed  
* 68000P12, upgradeable to 68EC000-20 or 68010@10 or any 68K in 64-DIP format  
  * Redo board to slot in a 68030 at some later date if desired  
* RTC \- completely forgot from the beginning.  
  * Full up on pins in GLUE and in IO MCU, so not easy to add now and board space may not be available  
  * Add a revision later, use the BQ3285 and a coin cell to be somewhat period-appropriate  
* Address map  
  * 0x0 through 0xBFFFFF \- RAM addressing but only sockets for 4MB on v1  
    * 0b0000\_xxxx\_xxxx\_xxxx\_xxxx\_xxx, 0x0X\_XXXX is bank 1  
    * 0b0001\_xxxx\_xxxx\_xxxx\_xxxx\_xxx, 0x1X\_XXXX is bank 2  
    * 0b0010\_xxxx\_xxxx\_xxxx\_xxxx\_xxx, 0x2X\_XXXX  is bank 3  
    * 0b0011\_xxxx\_xxxx\_xxxx\_xxxx\_xxx, 0x3X\_XXXX  is bank 4  
    * Fill them in sequentially  
    * DTACK responds whether RAM is populated, D will be repeating within partially populated, floating/junk for not-populated  
    * ROM shadowed over RAM bank 1 until first write to RAM space or access to GLUE IO as described elsewhere  
  * 0xC0\_0000 \- 0xCF\_FFFF: 128K ROM, repeating  
  * 0xD0\_0000-0xDF\_FFFF \= 1MB Video expansion card area (640\*480\*8bpp is only 300K, have room for double buffering, sprites, etc)  
  * 0xE0\_0000 \- 0xEF\_FFFF : on-board video “OBVID” config, repeating  
  * 0xF0\_0000-0xFF\_FFFF \- IO area  
    * 0xF0\_XXXX \- GLUE config and I/O  
    * 0xF1\_XXXX \- compact flash, 8-bit access (odd addresses)  
    * 0xF2\_XXXX \- IO MCU, 8-bit access (odd addresses)  
    * 0xF3\_XXXX \- audio DAC latch, 8-bit access (all odd addresses)  
* 128K ROM from 2x 64K  
  * Simple bootloader  
  * Simple shell  
  * No video config in ROM  
  * Load and run from CF  
  * Receive and run over serial  
  * Maybe even stick BASIC in there  
  * DTACK follows AS by a clock for 12MHz CPU clock or two clocks if 16MHz or 20MHz CPU  
* Initially 256KByte from 2x 128K KM681000BLP-7 SRAM  
  * Allow upgrade to 4M by populating eight 512KByte SRAM parts (e.g. [AS6C4008-55PCN Alliance Memory, Inc. | Integrated Circuits (ICs) | DigiKey](https://www.digikey.com/en/products/detail/alliance-memory-inc/AS6C4008-55PCN/4234586) ) \- x8 is going to be $60  
  * A20,A21 select between 4 banks of SRAMs  
  * Can have incomplete banks but all lower banks must be populated or RAM will be sparse  
  * DTACK follows AS by a clock for 12MHz CPU clock or two clocks if 16MHz or 20MHz CPU  
* GLUE logic is dedicated ATF1508 CPLD for:  
  * Address decode: ROM\_SELECT, RAM\_BANK\_{n}\_SELECT, IO\_SELECT, OBVID\_SELECT, CF\_SELECT, AUDIO\_SELECT, ENGINE\_SELECT  
  * ROM initially shadowed at 0x0X\_XXXX, RAM bank 1 not selected  
  * First-write-to-RAM unshadows ROM from 0x0X\_XXXX RAM bank 1 selected  
  * DTACK generation logic  
    * Count off for RAM and ROM, hard-coded for crystal populated on board  
    * OR with ENGINE\_DTACK, IO\_DTACK to stall until video expansion or io releases bus  
    * AND result with OBVID\_STALL on data access so any DTACK is blocked until 16-bit OBVID shift register in CPLD is ready to be loaded  
  * ROM shadowing mechanism and unshadow trigger  
  * BERR after some number of cycles if DTACK not asserted.  Have one timeout counter for BERR for everything else, like 8 cycles, and then crazy long BERR like 256 for IO\_DTACK  
  * Would like BERR for user space (FC2 \== 0\) outside a range of memory in glue logic on 64K boundaries if desired to make things read-only or as rudimentary process isolation, but that requires more address lines and GLUE is probably out.  
  * IRQ-to-IPL and IACK management for IO\_IRQ, ENGINE\_IRQ, OBVID\_IRQ  
  * GLUE config register memory map:

| Offset from base | Width | Functionality                    |
| :--------------- | :---- | :------------------------------- |
| 0x01             | 8-bit | Bit 0: Debug out                 |
| 0x03             | 8     | Bit 0: Debug in                  |
| 0x07             | 8     | write: un-shadow ROM             |
| 0x09             | 8     | WRITE\_RANGE\_BASE (64K blocks)  |
| 0x0B             | 8     | WRITE\_RANGE\_COUNT (64K blocks) |
| 0x0D             | 8     | Bit 0: video expansion present   |

    * Debug out  
      * sets or clears debug LED and test point output (clip an FTDI, bitbang serial for diagnostics)  
      * Reads a test point input  
      * Can bit-bang serial output to debug IO board  
    * Debug in  
      * Can bit-bang serial input if there’s a reason  

* On-board video (“OBVID”) NTSC, VGA \- second ATF1508  
  * CPLD 16-bit shift register clocks out 1 bit, expands to R3G3B2 through internal pair of palette registers  
  * Count off hsync and vsync to provide HSYNC and VSYNC signals and exit-VBLANK interrupt (through GLUE)  
  * Default for all config registers is 0, video disabled  
  * Some config registers can be “changed any time” but CPU is likely to be busy in tight loop for visible pixels so practically will only change in hblank or vblank.  
  * Config registers are noted by address from base address  
  * Config register 0x1.b: OBVID\_MODE  
    * D2..D0 : OBVID\_MODE\_CLOCK  
      * 000 \= disable video \- disable oscillator clocks, Hi-Z VGA and CPST outputs, reset OBVID\_STALL  
      * 100 \= 14.318 MHz (may decide later that this Hi-Z’s the 8 pins to VGA DACs and HSYNC and VSYNC)  
      * 101 \= 25.2 MHz (may decide later that this Hi-Z’s the PIXEL and SYNC signals to composite video circuit)  
    * D3: OBVID\_MODE\_PALETTE \- 0 \= “slow palette”  mode, 1 \= “fast palette” mode  
    * D4: OBVID\_MODE\_FORMAT \- 0 \= progressive, 1 \= interlaced  
    * D5: OBVID\_MODE\_ENBVINT \- 0 \= disable frame interrupt, 1 \= enable frame interrupt  
    * D6: OBVID\_MODE\_ENBSNP \- 0 \= disable blocking snoop, 1 \= enable blocking snoop  
    * D7: OBVID\_MODE\_CBURST \- 0 \= no colorburst cycles, 1 \= enable colorburst cycles  
    * CPU is expected to transition between modes by waiting until end of a visible pixel ISR. disabling frame interrupt (write 0 byte), then wait at least 50 milliseconds for settling, then configure counter and palette registers as desired with frame interrupt disabled, then set mode and optional interrupt enable.  
  * Config register 0x3.b: OBVID\_MODE2  
    * D0: OBVID\_MODE2\_PPC \- 0 \= pixel per clock, 1 \= pixel per 2 clocks  
      * Realistically, I’ll need to upgrade to a 68EC000@20 to get 640\*480  
    * D1: OBVID\_MODE\_ENBLINT \- 0 \= disable line interrupt outside visible region, 1 \- enable  
    * Can be changed at any time  
  * Config register 0x5.b: OBVID\_WORDS\_START  
    * Set number of words (in words, so every 16 pixels) to start visible pixel processing after end of hblank.  That is to say, when CPU writes to 0x12.w, causing OBVID\_STALL, when is OBVID\_STALL released?  
    * Can be changed in hblank  
  * Config register 0x9.b: OBVID\_BORDER\_PIXEL  
    * bit 0 is border pixel bit used outside of visible pixel word range  
    * Can be changed any time  
  * Config register 0xB.b: OBVID\_LINES\_START  
    * set start of visible lines after end of vblank, when first read from memory for OBVID CPLD snoop is unblocked after vsync  
  * Config register 0xD.b: OBVID\_LINES\_COUNT  
    * set start of visible lines after end of vblank, when first read from memory for OBVID CPLD snoop is unblocked after vsync  
  * Config register 0xE.w : OBVID\_PALETTE  
    * Loads palette register immediately  
    * 2 R3G3B2 palette entries, 0 in LSB, 1 in MSB  
    * Can be changed any time  
    * Is it worth exposing this?  
  * Config register 0x10.w : OBVID\_NEXT\_PALETTE  
    * Load color palette buffer  
    * 2 R3G3B2 palette entries, 0 in LSB, 1 in MSB  
    * Can be changed any time  
  * Operation register 0x12.w \- write to this location arms blocking snoop, aka OBVID\_STALL signal to GLUE logic after CPU releases \~AS  
    * Snooped bus user data (FC2:FC0 \== 101\) in “slow palette” mode expects 16bits of pixel data (16 pixels) repeated through visible pixels  
    * Snooped bus data in “fast palette” mode expects 16 bits of palette (2x R3G3B2) and then 16bits of pixel data (16 pixels) repeated through visible pixels and then one more 16-bits palette  
      * Would need something like looped or unrolled “move.l (A0)+, D0”, transfer two 16-bit words in 12 cycles. \- works for 68000 @ 12MHz\!  
      * Palette data loaded into “next palette”  
      * Next palette loaded into palette when shift register is loaded  
      * If there is no waiting pixel data, shift register and palette are loaded from border pixel and next palette.  
    * CPLD holds OBVID\_STALL until shift register is empty  
      * Latches 16 bit shift register from data lines on PIXEL\_CLOCK signal  
      * Releases OBVID\_STALL on next CPU\_CLOCK cycle so GLUE \~DTACK is asserted, then asserts OBVID\_STALL when CPU releases \~AS  
    * If OBVID\_STALL is disabled, CPU is responsible for managing timing, or maybe framebuffer is used as visual debugger  
    * Must be written once per visible line  
    * Notes  
      * For VGA only, "slow palette" is the palette is updated at most once per line, or perhaps as slow as set once and never set again.  "Fast palette" is the palette is updated every 16 pixels. For composite, the pixels are just 0 and 1 and I might add a colorburst mode so I can get artifact colors.  
      * 16-bit "pixel shift register", "palette register", "next 16 pixels" register, and "next palette" register. The LSBit of the pixel shift register is the current pixel, and selects from the two 8-bit values in the palette register for VGA.  Or it is black or white voltage for composite video.  Every pixel clock the pixel shift register shifts right.  On the starting pixel clock (multiple of 16\) and every 16 clocks through the end of visible pixels, the pixel shift register would be loaded from the "next 16 pixels" and the palette register would be loaded from "next palette".  After the visible pixels range, every 16 clocks until visible pixels starts again, the shift would be filled with border pixel (maybe set or cleared) and the palette register would be loaded from OBVID\_BORDER\_PALETTE. The implication is that all lines will be multiples of 16 and I'm okay with that.  
      * in "slow palette" mode, stall the next bus access (expecting a CPU read from framebuffer) until the pixel shift register is loaded from the previous "next 16 pixels", at which point the "next 16 pixels" are loaded from the snoop, the bus D lines are loaded into "next 16 pixels" and STALL is released.  Thus a line of "slow palette" can optionally set the "next" palette register to set border colors for the line, write 0x12, then just read N words. Next palette register isn't set during the line so it can still get loaded into "palette register" every 16 clocks.  
      * In "fast palette" the snoops also set the "next palette register" first, so a line of "fast palette" writes 0x12, then reads N\*2 words made of a palette read and a pixel read, likely a move.l which will then perform two word reads. The first load will not stall but will be immediately loaded into "next palette". The second read will stall until the shift is loaded from the "next 16 pixels", the bus D lines are loaded into "next 16 pixels" and STALL is released.  
  * Operation register 0x14.w, write to disarm blocking snoop  
  * Just before beginning of frame OBVID interrupts CPU so that CPU enters “framebuffer” ISR, doing N (e.g. 200, 240, 400, 480\) tight loops to write rows and then check IO MCU, etc in HBLANK, exits ISR at end of visible rows   
    * Tight loop writes out 16 bits at a time, MOVE.W (An+), D0  
    * CPU does busy wait on vblank todo per frame processing  
    * CPU ISR sets some word in memory at vblank  
    * CPU out-of-ISR loop waits on that word, then clears it, then does vblank processing  
  * In HBLANK / HSYNC:  
    * Maybe check UART/PS2, dequeue byte \- but what if IO MCU is in an ISR of its own, that could take 10s to 100s of 68000 cycles to finish…  Probably just have long queues in the MC and let vblank processing drain queues.  
* Compact Flash interface  
  * Only do 8-bit access to ease routing, D0-D7 so only odd addresses  
  * Entirely True IDE PIO mode, no interrupts  
  * GLUE manages DTACK, will need to hard-code wait states as necessary (7@12MHz, 12@20MHz)  
  * IO addresses as offsets from base address:  
    * 0x1 \- Data Register: (16-bit/8-bit) Data to/from the CF card.  
    * 0x3 \- Error (Read) / Features (Write): Valid after a command error or for enabling features.  
    * 0x5 \- Sector Count: Number of sectors to read/write.  
    * 0x7 \- Sector Number (LBA 7-0): Starting sector address.  
    * 0x9 \- Cylinder Low (LBA 15-8): Cylinder address low byte.  
    * 0xB \- Cylinder High (LBA 23-16): Cylinder address high byte.  
    * 0xD \- Drive/Head (LBA 27-24): Drive/Head register.  
    * 0xF \- Status (Read) / Command (Write): Used to check device status or issue commands.   
* IO through 8051-compatible AT89S52  
  * [AT89S52-24PU Microchip Technology | Integrated Circuits (ICs) | DigiKey](https://www.digikey.com/en/products/detail/microchip-technology/AT89S52-24PU/1008597)  
  * 5V UART, just TX, RX  
  * 2 PS2  
  * AT89S52 Continuously polls IO\_SELECT from GLUE chip: if detected, disable interrupts, do 68000 bus cycle including putting data on data bus, lowering DTACK, then waiting for AS to rise and releasing DTACK, enable interrupts  
  * Probably need fifo for all inputs so CPU doesn't need to do anything during visible row scanout ISR  
  * IO addresses as offsets from base address:  
    * 0x1: UART Config  
    * 0x3: UART R/W  
    * 0x5: KBD data  
    * 0x7: mouse data  
    * 0x9: status…?  
  * Program either in jig or by GLUE control signals  
* Application-specific engine \- third ATF1508  
  * A, D signals  
  * ENGINE\_{DTACK,SELECT,IRQ,IACK} to and from GLUE for control as a peripheral  
  * ENGINE\_{TMS,TCK,TDI,TDO} from GLUE for bitfile loading  
  * CPU signals for memory-mapped access (low 20 bits) and bus mastering (all 24 bits): R/W, AS, LDS, UDS, DTACK  
  * E.g. application comes with bitfile that is bitbanged through the GLUE.  Bitfile is loaded with e.g. fread and passed off to a system call  
  * Possibilities include:  
    * Drive bus snooping for video generation at a higher rate with corresponding spin of OBVID, e.g. 320\*480@8bpp or 640\*480@4bpp  
    * Rudimentary fixed-point ray-box intersection  
    * Mandelbrot accelerator  
* Latched 8-bit audio  
  * CPU needs to update it in VBLANK ISR per line and per-blanking-line ISR  
  * 8-bit R2R  
  * [LM358](https://www.digikey.com/en/products/detail/texas-instruments/LM358P/277042) op-amp  
  * Will need to see how much noise and distortion is caused by timing variation.  Maybe I can add blocking DTACK on a timer tick or something

On board video

* 912 samples \* 262 @ 59.9 is 14.318MHz.  
  * 1 bpp \= 14.318 Mb/sec \=  .89 MT/sec  
* 400 \* 525 (320 \* 480\) is 12.6MHz, repeat lines and double pixels to 640 \* 480  
  * 1 bpp  \= 12.6 Mb/sec \= 787 KT/sec  
  * 4 bpp \= 50.4 Mb/sec  \= 3.15 MT/sec, tight and need \>= 16MHz 68010 probably  
  * 8 bpp \= \= 6.3 MT/sec \- not possible  
* 800 \* 525 @ 60 (640 \* 480\) is 25.2MHz,  
  * 1 bpp  \= 25.2 Mb/sec \= 1.574 MT/sec  
  * 4 bpp \= 100.8 Mb/sec  \= 6.3 MT/sec, not possible  
  * 8 bpp \= \= 12.6 MT/sec \- not possible  
* ~~16-entry 8-bit (R3G3B2) palette \- how to write?~~  
  * ~~4 address bits, 8 data bits through CPLD gated on palette address space~~  
  * ~~16-entry VGA palette RAM is at 0x20-0x2f~~  
    * ~~Address lines into palette RAM are out of CPLD, normally part of shift register, but also enabled by writes to 0x20-0x2f~~  
    * ~~Palette RAM 8-bit data lines will be wired to the data lines out of the CPLD and to the DAC, so must only update the palette RAM during sync when the VGA monitor is not looking at RGB~~  
    * ~~The smallest cheapest sram is 8k…  Might have enough CPLD pins for a “palette selector” index on higher palette SRAM address pins.~~

GLUE CPLD 

* Need to know IRQ-to-IPL mapping and compare with A1-A3 on IACK (FC0-FC2 is 1\) in order to supply the right peripheral IACK \- this will be in the CPLD \- probably hardcode, like composite is 0, video expansion is 1, serial is 2  
* Receive RESET \- assert HALT while RESET is asserted  
  * After RESET, read HALT as input and do something if asserted, like flash LED

AT89S52

* ISR for UART, PS2, Audio  
  * Audio ISR at pri 0  
* Got that old PS/2 software from PIC for Alice 2  
* Could you get one, put it on a breadboard, and test it using a couple PS/2 breakouts?  Either drive it with Pico or just print the keycodes on the UART?
