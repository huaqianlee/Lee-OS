;************************************
;Andy Lee @2021.08.11
;
;FILE: entry.asm
;
;1. Define the multi-boot protocol headers to compatible grub1 and grub2.
;2. Close interrupt, set cpu working mode.
;3. Initialize CPU and C runtime environment
;4. Data for CPU working mode
;************************************

MBT_HDR_FLAGS EQU 0x00010003
MBT_HDR_MAGIC EQU 0x1BADB002 ; The magic number of multi-boot protocol header
MBT_HDR2_MAGIC EQU 0xE85250D6 ; The second magic number of multi-boot protocol header
global _start ; Export _start symbol
extern main ; Import external main funciton symbol
[section .start.text] ; Define .start.text code section
[bits 32] ; Assembled as 32 bits code
_start:
jmp _entry
; The header that grub needed
ALIGN 8
mbt_hdr:
dd MBT_HDR_MAGIC
dd MBT_HDR_FLAGS
dd -(MBT_HDR_MAGIC+MBT_HDR_FLAGS)
dd mbt_hdr
dd _start
dd 0
dd 0
dd _entry

ALIGN 8
mbt2_hdr:
DD MBT_HDR2_MAGIC
DD 0
DD mbt2_hdr_end - mbt2_hdr
DD -(MBT_HDR2_MAGIC + 0 + (mbt2_hdr_end - mbt2_hdr))
DW 2, 0
DD 24
DD mbt2_hdr
DD _start
DD 0
DD 0
DW 3, 0
DD 12
DD _entry
DD 0
DD 0, 0
DD 8
mbt2_hdr_end:
ALIGN 8
_entry:
cli ; Close unblockable interrupt
in al, 0x70
or al, 0x80
out 0x70,al
; Reload GDT
lgdt [GDT_PTR]
jmp dword 0x8 :_32bits_mode
_32bits_mode:
; Initialize registers for C language
mov ax, 0x10
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax
xor eax,eax
xor ebx,ebx
xor ecx,ecx
xor edx,edx
xor edi,edi
xor esi,esi
xor ebp,ebp
xor esp,esp
; Initialize stack
mov esp,0x9000
call main
; Let CPU stop to execute instruction
halt_step:
halt
jmp halt_step
; What CPU working mode needs
GDT_START:
knull_dsc: dq 0
kcode_dsc: dq 0x00cf9e000000ffff
kdata_dsc: dq 0x00cf92000000ffff
k16cd_dsc: dq 0x00009e000000ffff
k16da_dsc: dq 0x000092000000ffff
GDT_END:
GDT_PTR:
GDTLEN dw GDT_END-GDT_START-1
GDTBASE dd GDT_START


