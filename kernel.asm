%include "pm.inc"

org   0x9000

VRAM_ADDRESS  equ  0x000a0000

jmp   LABEL_BEGIN

[SECTION .gdt]
 ;                                  段基址          段界限                属性
LABEL_GDT:          Descriptor        0,            0,                   0  
LABEL_DESC_CODE32:  Descriptor        0,      SegCode32Len - 1,       DA_C + DA_32
LABEL_DESC_VIDEO:   Descriptor        0B8000h,         0ffffh,            DA_DRW
LABEL_DESC_VRAM:    Descriptor        0,         0ffffffffh,            DA_DRW
LABEL_DESC_STACK:   Descriptor        0,             TopOfStack,        DA_DRWA+DA_32

GdtLen     equ    $ - LABEL_GDT
GdtPtr     dw     GdtLen - 1
           dd     0

SelectorCode32    equ   LABEL_DESC_CODE32 -  LABEL_GDT
SelectorVideo     equ   LABEL_DESC_VIDEO  -  LABEL_GDT
SelectorStack     equ   LABEL_DESC_STACK  -  LABEL_GDT
SelectorVram      equ   LABEL_DESC_VRAM   -  LABEL_GDT


[SECTION  .s16]
[BITS  16]
LABEL_BEGIN:
     mov   ax, cs
     mov   ds, ax
     mov   es, ax
     mov   ss, ax
     mov   sp, 0100h

     mov   al, 0x13
     mov   ah, 0
     int   0x10

     xor   eax, eax
     mov   ax,  cs
     shl   eax, 4
     add   eax, LABEL_SEG_CODE32
     mov   word [LABEL_DESC_CODE32 + 2], ax
     shr   eax, 16
     mov   byte [LABEL_DESC_CODE32 + 4], al
     mov   byte [LABEL_DESC_CODE32 + 7], ah

     xor   eax, eax
     mov   ax, ds
     shl   eax, 4
     add   eax,  LABEL_GDT
     mov   dword  [GdtPtr + 2], eax

     lgdt  [GdtPtr]

     cli   ;关中断

     in    al,  92h
     or    al,  00000010b
     out   92h, al

     mov   eax, cr0
     or    eax , 1
     mov   cr0, eax

     jmp   dword  SelectorCode32: 0

     [SECTION .s32]
     [BITS  32]
     LABEL_SEG_CODE32:
     ;initialize stack for c code
     mov  ax, SelectorStack
     mov  ss, ax
     mov  esp, TopOfStack

     mov  ax, SelectorVram
     mov  ds,  ax

HariMain:; Function begin
        push    ebp                                     
        mov     ebp, esp                                
        sub     esp, 24  

        call    init_palatte

        mov     dword [ebp-0CH], 655360                
        jmp     ?_002                                   

?_001:  mov     eax, dword [ebp-0CH]                    
        and     eax, 0FH                                
        sub     esp, 8                                  
        push    eax                                    
        push    dword [ebp-0CH]                         
        call    write_mem8                              
        add     esp, 16                                
        add     dword [ebp-0CH], 1                     
?_002:  cmp     dword [ebp-0CH], 720895                
        jle     ?_001  
?_003:  call    io_hlt                                 
        jmp     ?_003

 write_mem8:   ;void write_mem8(int addr, int data)
        mov      ecx, [esp + 4]
        mov      al, [esp + 8]
        mov      [ecx], al
        ret

init_palatte:; Function begin
        push    ebp                                     ; 0038 _ 55
        mov     ebp, esp                                ; 0039 _ 89. E5
        sub     esp, 8                                  ; 003B _ 83. EC, 08
        sub     esp, 4                                  ; 003E _ 83. EC, 04
        push    table_rgb.1416                          ; 0041 _ 68, 00000000(d)
        push    15                                      ; 0046 _ 6A, 0F
        push    0                                       ; 0048 _ 6A, 00
        call    set_palatte                             ; 004A _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 004F _ 83. C4, 10
        nop                                             ; 0052 _ 90
        leave                                           ; 0053 _ C9
        ret                                             ; 0054 _ C3
; init_palatte End of function


set_palatte:; Function begin
        push    ebp                                     ; 0055 _ 55
        mov     ebp, esp                                ; 0056 _ 89. E5
        sub     esp, 24                                 ; 0058 _ 83. EC, 18
        call    io_load_eflags                          ; 005B _ E8, FFFFFFFC(rel)
        mov     dword [ebp-0CH], eax                    ; 0060 _ 89. 45, F4
        call    io_cli                                  ; 0063 _ E8, FFFFFFFC(rel)
        sub     esp, 8                                  ; 0068 _ 83. EC, 08
        push    dword [ebp+8H]                          ; 006B _ FF. 75, 08
        push    968                                     ; 006E _ 68, 000003C8
        call    io_out8                                 ; 0073 _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 0078 _ 83. C4, 10
        mov     eax, dword [ebp+8H]                     ; 007B _ 8B. 45, 08
        mov     dword [ebp-10H], eax                    ; 007E _ 89. 45, F0
        jmp     ?_005   
 ?_004:  mov     eax, dword [ebp+10H]                    ; 0083 _ 8B. 45, 10
        movzx   eax, byte [eax]                         ; 0086 _ 0F B6. 00
        shr     al, 2                                   ; 0089 _ C0. E8, 02
        movzx   eax, al                                 ; 008C _ 0F B6. C0
        sub     esp, 8                                  ; 008F _ 83. EC, 08
        push    eax                                     ; 0092 _ 50
        push    969                                     ; 0093 _ 68, 000003C9
        call    io_out8                                 ; 0098 _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 009D _ 83. C4, 10
        mov     eax, dword [ebp+10H]                    ; 00A0 _ 8B. 45, 10
        add     eax, 1                                  ; 00A3 _ 83. C0, 01
        movzx   eax, byte [eax]                         ; 00A6 _ 0F B6. 00
        shr     al, 2                                   ; 00A9 _ C0. E8, 02
        movzx   eax, al                                 ; 00AC _ 0F B6. C0
        sub     esp, 8                                  ; 00AF _ 83. EC, 08
        push    eax                                     ; 00B2 _ 50
        push    969                                     ; 00B3 _ 68, 000003C9
        call    io_out8
        add     esp, 16                                 ; 00BD _ 83. C4, 10
        mov     eax, dword [ebp+10H]                    ; 00C0 _ 8B. 45, 10
        add     eax, 2                                  ; 00C3 _ 83. C0, 02
        movzx   eax, byte [eax]                         ; 00C6 _ 0F B6. 00
        shr     al, 2                                   ; 00C9 _ C0. E8, 02
        movzx   eax, al                                 ; 00CC _ 0F B6. C0
        sub     esp, 8                                  ; 00CF _ 83. EC, 08
        push    eax                                     ; 00D2 _ 50
        push    969                                     ; 00D3 _ 68, 000003C9
        call    io_out8                                 ; 00D8 _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 00DD _ 83. C4, 10
        add     dword [ebp+10H], 3                      ; 00E0 _ 83. 45, 10, 03
        add     dword [ebp-10H], 1 
?_005:  mov     eax, dword [ebp-10H]                    ; 00E8 _ 8B. 45, F0
        cmp     eax, dword [ebp+0CH]                    ; 00EB _ 3B. 45, 0C
        jle     ?_004                                   ; 00EE _ 7E, 93
        sub     esp, 12                                 ; 00F0 _ 83. EC, 0C
        push    dword [ebp-0CH]                         ; 00F3 _ FF. 75, F4
        call    io_store_eflags                         ; 00F6 _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 00FB _ 83. C4, 10
        nop                                             ; 00FE _ 90
        leave                                           ; 00FF _ C9
        ret  


    io_hlt:  ;void io_hlt(void);
      HLT
      RET

    io_cli:
      CLI
      RET
    
    io_sti:
      STI
      RET
    io_stihlt:
      STI
      HLT
      RET
    io_in8:
      mov  edx, [esp + 4]
      mov  eax, 0
      in   al, dx

    io_in16:
      mov  edx, [esp + 4]
      mov  eax, 0
      in   ax, dx

    io_in32:
      mov edx, [esp + 4]
      in  eax, dx
      ret

    io_out8:
       mov edx, [esp + 4]
       mov al, [esp + 8]
       out dx, al
       ret

    io_out16:
       mov edx, [esp + 4]
       mov eax, [esp + 8]
       out dx, ax
       ret

    io_out32:
        mov edx, [esp + 4]
        mov eax, [esp + 8]
        out dx, eax
        ret

    io_load_eflags:
        pushfd
        pop  eax
        ret

    io_store_eflags:
        mov eax, [esp + 4]
        push eax
        popfd
        ret

table_rgb.1416:                                         ; byte
        db 00H, 00H, 00H, 0FFH, 00H, 00H, 00H, 0FFH     ; 0000 _ ........
        db 00H, 0FFH, 0FFH, 00H, 00H, 00H, 0FFH, 0FFH   ; 0008 _ ........
        db 00H, 0FFH, 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH ; 0010 _ ........
        db 0C6H, 0C6H, 0C6H, 84H, 00H, 00H, 00H, 84H    ; 0018 _ ........
        db 00H, 84H, 84H, 00H, 00H, 00H, 84H, 84H       ; 0020 _ ........
        db 00H, 84H, 00H, 84H, 84H, 84H, 84H, 84H

SegCode32Len   equ  $ - LABEL_SEG_CODE32

[SECTION .gs]
ALIGN 32
[BITS 32]
LABEL_STACK:
times 512  db 0
TopOfStack  equ  $ - LABEL_STACK

