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
        push    ebp                                     ; 0000 _ 55
        mov     ebp, esp                                ; 0001 _ 89. E5
        push    ebx                                     ; 0003 _ 53
        sub     esp, 20                                 ; 0004 _ 83. EC, 14
        call    init_palatte                            ; 0007 _ E8, FFFFFFFC(rel)
        mov     dword [ebp-14H], 655360                 ; 000C _ C7. 45, EC, 000A0000
        mov     dword [ebp-10H], 320                    ; 0013 _ C7. 45, F0, 00000140
        mov     dword [ebp-0CH], 200                    ; 001A _ C7. 45, F4, 000000C8
        mov     eax, dword [ebp-0CH]                    ; 0021 _ 8B. 45, F4
        lea     edx, [eax-1DH]                          ; 0024 _ 8D. 50, E3
        mov     eax, dword [ebp-10H]                    ; 0027 _ 8B. 45, F0
        sub     eax, 1                                  ; 002A _ 83. E8, 01
        sub     esp, 4                                  ; 002D _ 83. EC, 04
        push    edx                                     ; 0030 _ 52
        push    eax                                     ; 0031 _ 50
        push    0                                       ; 0032 _ 6A, 00
        push    0                                       ; 0034 _ 6A, 00
        push    14                                      ; 0036 _ 6A, 0E
        push    dword [ebp-10H]                         ; 0038 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 003B _ FF. 75, EC
        call    boxfill8                                ; 003E _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 0043 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0046 _ 8B. 45, F4
        lea     ecx, [eax-1CH]                          ; 0049 _ 8D. 48, E4
        mov     eax, dword [ebp-10H]                    ; 004C _ 8B. 45, F0
        lea     edx, [eax-1H]                           ; 004F _ 8D. 50, FF
        mov     eax, dword [ebp-0CH]                    ; 0052 _ 8B. 45, F4
        sub     eax, 28                                 ; 0055 _ 83. E8, 1C
        sub     esp, 4                                  ; 0058 _ 83. EC, 04
        push    ecx                                     ; 005B _ 51
        push    edx                                     ; 005C _ 52
        push    eax                                     ; 005D _ 50
        push    0                                       ; 005E _ 6A, 00
        push    8                                       ; 0060 _ 6A, 08
        push    dword [ebp-10H]                         ; 0062 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0065 _ FF. 75, EC
        call    boxfill8                                ; 0068 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 006D _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0070 _ 8B. 45, F4
        lea     ecx, [eax-1BH]                          ; 0073 _ 8D. 48, E5
        mov     eax, dword [ebp-10H]                    ; 0076 _ 8B. 45, F0
        lea     edx, [eax-1H]                           ; 0079 _ 8D. 50, FF
        mov     eax, dword [ebp-0CH]                    ; 007C _ 8B. 45, F4
        sub     eax, 27                                 ; 007F _ 83. E8, 1B
        sub     esp, 4                                  ; 0082 _ 83. EC, 04
        push    ecx                                     ; 0085 _ 51
        push    edx                                     ; 0086 _ 52
        push    eax                                     ; 0087 _ 50
        push    0                                       ; 0088 _ 6A, 00
        push    7                                       ; 008A _ 6A, 07
        push    dword [ebp-10H]                         ; 008C _ FF. 75, F0
        push    dword [ebp-14H]                         ; 008F _ FF. 75, EC
        call    boxfill8                                ; 0092 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 0097 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 009A _ 8B. 45, F4
        lea     ecx, [eax-1H]                           ; 009D _ 8D. 48, FF
        mov     eax, dword [ebp-10H]                    ; 00A0 _ 8B. 45, F0
        lea     edx, [eax-1H]                           ; 00A3 _ 8D. 50, FF
        mov     eax, dword [ebp-0CH]                    ; 00A6 _ 8B. 45, F4
        sub     eax, 26                                 ; 00A9 _ 83. E8, 1A
        sub     esp, 4                                  ; 00AC _ 83. EC, 04
        push    ecx                                     ; 00AF _ 51
        push    edx                                     ; 00B0 _ 52
        push    eax                                     ; 00B1 _ 50
        push    0                                       ; 00B2 _ 6A, 00
        push    8                                       ; 00B4 _ 6A, 08
        push    dword [ebp-10H]                         ; 00B6 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 00B9 _ FF. 75, EC
        call    boxfill8                                ; 00BC _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 00C1 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 00C4 _ 8B. 45, F4
        lea     edx, [eax-18H]                          ; 00C7 _ 8D. 50, E8
        mov     eax, dword [ebp-0CH]                    ; 00CA _ 8B. 45, F4
        sub     eax, 24                                 ; 00CD _ 83. E8, 18
        sub     esp, 4                                  ; 00D0 _ 83. EC, 04
        push    edx                                     ; 00D3 _ 52
        push    59                                      ; 00D4 _ 6A, 3B
        push    eax                                     ; 00D6 _ 50
        push    3                                       ; 00D7 _ 6A, 03
        push    7                                       ; 00D9 _ 6A, 07
        push    dword [ebp-10H]                         ; 00DB _ FF. 75, F0
        push    dword [ebp-14H]                         ; 00DE _ FF. 75, EC
        call    boxfill8                                ; 00E1 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 00E6 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 00E9 _ 8B. 45, F4
        lea     edx, [eax-4H]                           ; 00EC _ 8D. 50, FC
        mov     eax, dword [ebp-0CH]                    ; 00EF _ 8B. 45, F4
        sub     eax, 24                                 ; 00F2 _ 83. E8, 18
        sub     esp, 4                                  ; 00F5 _ 83. EC, 04
        push    edx                                     ; 00F8 _ 52
        push    2                                       ; 00F9 _ 6A, 02
        push    eax                                     ; 00FB _ 50
        push    2                                       ; 00FC _ 6A, 02
        push    7                                       ; 00FE _ 6A, 07
        push    dword [ebp-10H]                         ; 0100 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0103 _ FF. 75, EC
        call    boxfill8                                ; 0106 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 010B _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 010E _ 8B. 45, F4
        lea     edx, [eax-4H]                           ; 0111 _ 8D. 50, FC
        mov     eax, dword [ebp-0CH]                    ; 0114 _ 8B. 45, F4
        sub     eax, 4                                  ; 0117 _ 83. E8, 04
        sub     esp, 4                                  ; 011A _ 83. EC, 04
        push    edx                                     ; 011D _ 52
        push    59                                      ; 011E _ 6A, 3B
        push    eax                                     ; 0120 _ 50
        push    3                                       ; 0121 _ 6A, 03
        push    15                                      ; 0123 _ 6A, 0F
        push    dword [ebp-10H]                         ; 0125 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0128 _ FF. 75, EC
        call    boxfill8                                ; 012B _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 0130 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0133 _ 8B. 45, F4
        lea     edx, [eax-5H]                           ; 0136 _ 8D. 50, FB
        mov     eax, dword [ebp-0CH]                    ; 0139 _ 8B. 45, F4
        sub     eax, 23                                 ; 013C _ 83. E8, 17
        sub     esp, 4                                  ; 013F _ 83. EC, 04
        push    edx                                     ; 0142 _ 52
        push    59                                      ; 0143 _ 6A, 3B
        push    eax                                     ; 0145 _ 50
        push    59                                      ; 0146 _ 6A, 3B
        push    15                                      ; 0148 _ 6A, 0F
        push    dword [ebp-10H]                         ; 014A _ FF. 75, F0
        push    dword [ebp-14H]                         ; 014D _ FF. 75, EC
        call    boxfill8                                ; 0150 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 0155 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0158 _ 8B. 45, F4
        lea     edx, [eax-3H]                           ; 015B _ 8D. 50, FD
        mov     eax, dword [ebp-0CH]                    ; 015E _ 8B. 45, F4
        sub     eax, 3                                  ; 0161 _ 83. E8, 03
        sub     esp, 4                                  ; 0164 _ 83. EC, 04
        push    edx                                     ; 0167 _ 52
        push    59                                      ; 0168 _ 6A, 3B
        push    eax                                     ; 016A _ 50
        push    2                                       ; 016B _ 6A, 02
        push    0                                       ; 016D _ 6A, 00
        push    dword [ebp-10H]                         ; 016F _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0172 _ FF. 75, EC
        call    boxfill8                                ; 0175 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 017A _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 017D _ 8B. 45, F4
        lea     edx, [eax-3H]                           ; 0180 _ 8D. 50, FD
        mov     eax, dword [ebp-0CH]                    ; 0183 _ 8B. 45, F4
        sub     eax, 24                                 ; 0186 _ 83. E8, 18
        sub     esp, 4                                  ; 0189 _ 83. EC, 04
        push    edx                                     ; 018C _ 52
        push    60                                      ; 018D _ 6A, 3C
        push    eax                                     ; 018F _ 50
        push    60                                      ; 0190 _ 6A, 3C
        push    0                                       ; 0192 _ 6A, 00
        push    dword [ebp-10H]                         ; 0194 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0197 _ FF. 75, EC
        call    boxfill8                                ; 019A _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 019F _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 01A2 _ 8B. 45, F4
        lea     ebx, [eax-18H]                          ; 01A5 _ 8D. 58, E8
        mov     eax, dword [ebp-10H]                    ; 01A8 _ 8B. 45, F0
        lea     ecx, [eax-4H]                           ; 01AB _ 8D. 48, FC
        mov     eax, dword [ebp-0CH]                    ; 01AE _ 8B. 45, F4
        lea     edx, [eax-18H]                          ; 01B1 _ 8D. 50, E8
        mov     eax, dword [ebp-10H]                    ; 01B4 _ 8B. 45, F0
        sub     eax, 47                                 ; 01B7 _ 83. E8, 2F
        sub     esp, 4                                  ; 01BA _ 83. EC, 04
        push    ebx                                     ; 01BD _ 53
        push    ecx                                     ; 01BE _ 51
        push    edx                                     ; 01BF _ 52
        push    eax                                     ; 01C0 _ 50
        push    15                                      ; 01C1 _ 6A, 0F
        push    dword [ebp-10H]                         ; 01C3 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 01C6 _ FF. 75, EC
        call    boxfill8                                ; 01C9 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 01CE _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 01D1 _ 8B. 45, F4
        lea     ebx, [eax-4H]                           ; 01D4 _ 8D. 58, FC
        mov     eax, dword [ebp-10H]                    ; 01D7 _ 8B. 45, F0
        lea     ecx, [eax-2FH]                          ; 01DA _ 8D. 48, D1
        mov     eax, dword [ebp-0CH]                    ; 01DD _ 8B. 45, F4
        lea     edx, [eax-17H]                          ; 01E0 _ 8D. 50, E9
        mov     eax, dword [ebp-10H]                    ; 01E3 _ 8B. 45, F0
        sub     eax, 47                                 ; 01E6 _ 83. E8, 2F
        sub     esp, 4                                  ; 01E9 _ 83. EC, 04
        push    ebx                                     ; 01EC _ 53
        push    ecx                                     ; 01ED _ 51
        push    edx                                     ; 01EE _ 52
        push    eax                                     ; 01EF _ 50
        push    15                                      ; 01F0 _ 6A, 0F
        push    dword [ebp-10H]                         ; 01F2 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 01F5 _ FF. 75, EC
        call    boxfill8                                ; 01F8 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 01FD _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0200 _ 8B. 45, F4
        lea     ebx, [eax-3H]                           ; 0203 _ 8D. 58, FD
        mov     eax, dword [ebp-10H]                    ; 0206 _ 8B. 45, F0
        lea     ecx, [eax-4H]                           ; 0209 _ 8D. 48, FC
        mov     eax, dword [ebp-0CH]                    ; 020C _ 8B. 45, F4
        lea     edx, [eax-3H]                           ; 020F _ 8D. 50, FD
        mov     eax, dword [ebp-10H]                    ; 0212 _ 8B. 45, F0
        sub     eax, 47                                 ; 0215 _ 83. E8, 2F
        sub     esp, 4                                  ; 0218 _ 83. EC, 04
        push    ebx                                     ; 021B _ 53
        push    ecx                                     ; 021C _ 51
        push    edx                                     ; 021D _ 52
        push    eax                                     ; 021E _ 50
        push    7                                       ; 021F _ 6A, 07
        push    dword [ebp-10H]                         ; 0221 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0224 _ FF. 75, EC
        call    boxfill8                                ; 0227 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 022C _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 022F _ 8B. 45, F4
        lea     ebx, [eax-3H]                           ; 0232 _ 8D. 58, FD
        mov     eax, dword [ebp-10H]                    ; 0235 _ 8B. 45, F0
        lea     ecx, [eax-3H]                           ; 0238 _ 8D. 48, FD
        mov     eax, dword [ebp-0CH]                    ; 023B _ 8B. 45, F4
        lea     edx, [eax-18H]                          ; 023E _ 8D. 50, E8
        mov     eax, dword [ebp-10H]                    ; 0241 _ 8B. 45, F0
        sub     eax, 3                                  ; 0244 _ 83. E8, 03
        sub     esp, 4                                  ; 0247 _ 83. EC, 04
        push    ebx                                     ; 024A _ 53
        push    ecx                                     ; 024B _ 51
        push    edx                                     ; 024C _ 52
        push    eax                                     ; 024D _ 50
        push    7                                       ; 024E _ 6A, 07
        push    dword [ebp-10H]                         ; 0250 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0253 _ FF. 75, EC
        call    boxfill8                                ; 0256 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 025B _ 83. C4, 20
?_001:  call    io_hlt                                  ; 025E _ E8, FFFFFFFC(rel)
        jmp     ?_001                                   ; 0263 _ EB, F9
; HariMain End of function

boxfill8:; Function begin
        push    ebp                                     ; 007C _ 55
        mov     ebp, esp                                ; 007D _ 89. E5
        sub     esp, 20                                 ; 007F _ 83. EC, 14
        mov     eax, dword [ebp+10H]                    ; 0082 _ 8B. 45, 10
        mov     byte [ebp-14H], al                      ; 0085 _ 88. 45, EC
        mov     eax, dword [ebp+18H]                    ; 0088 _ 8B. 45, 18
        mov     dword [ebp-4H], eax                     ; 008B _ 89. 45, FC
        jmp     ?_005                                   ; 008E _ EB, 33

?_002:  mov     eax, dword [ebp+14H]                    ; 0090 _ 8B. 45, 14
        mov     dword [ebp-8H], eax                     ; 0093 _ 89. 45, F8
        jmp     ?_004                                   ; 0096 _ EB, 1F

?_003:  mov     eax, dword [ebp-4H]                     ; 0098 _ 8B. 45, FC
        imul    eax, dword [ebp+0CH]                    ; 009B _ 0F AF. 45, 0C
        mov     edx, eax                                ; 009F _ 89. C2
        mov     eax, dword [ebp-8H]                     ; 00A1 _ 8B. 45, F8
        add     eax, edx                                ; 00A4 _ 01. D0
        mov     edx, eax                                ; 00A6 _ 89. C2
        mov     eax, dword [ebp+8H]                     ; 00A8 _ 8B. 45, 08
        add     edx, eax                                ; 00AB _ 01. C2
        movzx   eax, byte [ebp-14H]                     ; 00AD _ 0F B6. 45, EC
        mov     byte [edx], al                          ; 00B1 _ 88. 02
        add     dword [ebp-8H], 1                       ; 00B3 _ 83. 45, F8, 01
?_004:  mov     eax, dword [ebp-8H]                     ; 00B7 _ 8B. 45, F8
        cmp     eax, dword [ebp+1CH]                    ; 00BA _ 3B. 45, 1C
        jle     ?_003                                   ; 00BD _ 7E, D9
        add     dword [ebp-4H], 1                       ; 00BF _ 83. 45, FC, 01
?_005:  mov     eax, dword [ebp-4H]                     ; 00C3 _ 8B. 45, FC
        cmp     eax, dword [ebp+20H]                    ; 00C6 _ 3B. 45, 20
        jle     ?_002                                   ; 00C9 _ 7E, C5
        leave                                           ; 00CB _ C9
        ret                                             ; 00CC _ C3
; boxfill8 End of function



init_palatte:; Function begin
        push    ebp                                     ; 00CD _ 55
        mov     ebp, esp                                ; 00CE _ 89. E5
        sub     esp, 8                                  ; 00D0 _ 83. EC, 08
        sub     esp, 4                                  ; 00D3 _ 83. EC, 04
        push    table_rgb.1444                          ; 00D6 _ 68, 00000000(d)
        push    15                                      ; 00DB _ 6A, 0F
        push    0                                       ; 00DD _ 6A, 00
        call    set_palatte                             ; 00DF _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 00E4 _ 83. C4, 10
        nop                                             ; 00E7 _ 90
        leave                                           ; 00E8 _ C9
        ret                                             ; 00E9 _ C3
; init_palatte End of function

set_palatte:; Function begin
        push    ebp                                     ; 00EA _ 55
        mov     ebp, esp                                ; 00EB _ 89. E5
        sub     esp, 24                                 ; 00ED _ 83. EC, 18
        call    io_load_eflags                          ; 00F0 _ E8, FFFFFFFC(rel)
        mov     dword [ebp-0CH], eax                    ; 00F5 _ 89. 45, F4
        call    io_cli                                  ; 00F8 _ E8, FFFFFFFC(rel)
        sub     esp, 8                                  ; 00FD _ 83. EC, 08
        push    dword [ebp+8H]                          ; 0100 _ FF. 75, 08
        push    968                                     ; 0103 _ 68, 000003C8
        call    io_out8                                 ; 0108 _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 010D _ 83. C4, 10
        mov     eax, dword [ebp+8H]                     ; 0110 _ 8B. 45, 08
        mov     dword [ebp-10H], eax                    ; 0113 _ 89. 45, F0
        jmp     ?_007                                   ; 0116 _ EB, 65

?_006:  mov     eax, dword [ebp+10H]                    ; 0118 _ 8B. 45, 10
        movzx   eax, byte [eax]                         ; 011B _ 0F B6. 00
        shr     al, 2                                   ; 011E _ C0. E8, 02
        movzx   eax, al                                 ; 0121 _ 0F B6. C0
        sub     esp, 8                                  ; 0124 _ 83. EC, 08
        push    eax                                     ; 0127 _ 50
        push    969                                     ; 0128 _ 68, 000003C9
        call    io_out8                                 ; 012D _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 0132 _ 83. C4, 10
        mov     eax, dword [ebp+10H]                    ; 0135 _ 8B. 45, 10
        add     eax, 1                                  ; 0138 _ 83. C0, 01
        movzx   eax, byte [eax]                         ; 013B _ 0F B6. 00
        shr     al, 2                                   ; 013E _ C0. E8, 02
        movzx   eax, al                                 ; 0141 _ 0F B6. C0
        sub     esp, 8                                  ; 0144 _ 83. EC, 08
        push    eax                                     ; 0147 _ 50
        push    969                                     ; 0148 _ 68, 000003C9
        call    io_out8                                 ; 014D _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 0152 _ 83. C4, 10
        mov     eax, dword [ebp+10H]                    ; 0155 _ 8B. 45, 10
        add     eax, 2                                  ; 0158 _ 83. C0, 02
        movzx   eax, byte [eax]                         ; 015B _ 0F B6. 00
        shr     al, 2                                   ; 015E _ C0. E8, 02
        movzx   eax, al                                 ; 0161 _ 0F B6. C0
        sub     esp, 8                                  ; 0164 _ 83. EC, 08
        push    eax                                     ; 0167 _ 50
        push    969                                     ; 0168 _ 68, 000003C9
        call    io_out8                                 ; 016D _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 0172 _ 83. C4, 10
        add     dword [ebp+10H], 3                      ; 0175 _ 83. 45, 10, 03
        add     dword [ebp-10H], 1                      ; 0179 _ 83. 45, F0, 01
?_007:  mov     eax, dword [ebp-10H]                    ; 017D _ 8B. 45, F0
        cmp     eax, dword [ebp+0CH]                    ; 0180 _ 3B. 45, 0C
        jle     ?_006                                   ; 0183 _ 7E, 93
        sub     esp, 12                                 ; 0185 _ 83. EC, 0C
        push    dword [ebp-0CH]                         ; 0188 _ FF. 75, F4
        call    io_store_eflags                         ; 018B _ E8, FFFFFFFC(rel)
        add     esp, 16                                 ; 0190 _ 83. C4, 10
        nop                                             ; 0193 _ 90
        leave                                           ; 0194 _ C9
        ret                                             ; 0195 _ C3
; set_palatte End of function


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

table_rgb.1444:                                         ; byte
        db 00H, 00H, 00H, 0FFH, 00H, 00H, 00H, 0FFH     ; 0000 _ ........
        db 00H, 0FFH, 0FFH, 00H, 00H, 00H, 0FFH, 0FFH   ; 0008 _ ........
        db 00H, 0FFH, 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH ; 0010 _ ........
        db 0C6H, 0C6H, 0C6H, 84H, 00H, 00H, 00H, 84H    ; 0018 _ ........
        db 00H, 84H, 84H, 00H, 00H, 00H, 84H, 84H       ; 0020 _ ........
        db 00H, 84H, 00H, 84H, 84H, 84H, 84H, 84H       ; 0028 _ ........



SegCode32Len   equ  $ - LABEL_SEG_CODE32

[SECTION .gs]
ALIGN 32
[BITS 32]
LABEL_STACK:
times 512  db 0
TopOfStack  equ  $ - LABEL_STACK

