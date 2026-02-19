ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 512K
    RAM (rwx) : ORIGIN = 0x00100000, LENGTH = 512K
}

SECTIONS
{
    .vectors : { *(.vectors) } > ROM
    .text    : { *(.text*) } > ROM
    .rodata  : { *(.rodata*) } > ROM

    .data : {
        _data_start = .;
        *(.data*)
        _data_end = .;
    } > RAM AT > ROM
    _data_load = LOADADDR(.data);

    .bss : {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    } > RAM

    _stack_top = ORIGIN(RAM) + LENGTH(RAM);

    .init_array : {
        _init_array_start = .;
        KEEP(*(.init_array*))
        KEEP(*(SORT(.init_array.*)))
        _init_array_end = .;
    } > ROM

    .fini_array : {
        _fini_array_start = .;
        KEEP(*(.fini_array*))
        KEEP(*(SORT(.fini_array.*)))
        _fini_array_end = .;
    } > ROM
}

