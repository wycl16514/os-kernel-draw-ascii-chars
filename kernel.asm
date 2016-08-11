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

CYLS       equ     0xff0
LEDS       equ     0xff1
VMODE      equ     0xff2
SCRNX      equ     0xff4
SCRNY      equ     0xff6
VRAM       equ     0x0ff8

[SECTION  .s16]
[BITS  16]
LABEL_BEGIN:
     mov   ax, cs
     mov   ds, ax
     mov   es, ax
     mov   ss, ax
     mov   sp, 0100h

     mov   al, 0x13   ;打开vram模式，执行此bios调用后，0xa0000开始的64k将作为显卡内存
     mov   ah, 0
     int   0x10

     ;将一些硬件参数存储到指定内存中
     mov   byte [VMODE], 8
     mov   word [SCRNX], 320
     mov   word [SCRNY], 200
     mov   dword [VRAM], 0x000a0000

     mov   ah, 0x02
     int   0x16    ;记录当前键盘信息
     mov   [LEDS],  al

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
        mov     dword [ebp-18H], 4080                   ; 000C _ C7. 45, E8, 00000FF0
        mov     eax, dword [ebp-18H]                    ; 0013 _ 8B. 45, E8
        mov     eax, dword [eax+8H]                     ; 0016 _ 8B. 40, 08
        mov     dword [ebp-14H], eax                    ; 0019 _ 89. 45, EC
        mov     eax, dword [ebp-18H]                    ; 001C _ 8B. 45, E8
        movzx   eax, word [eax+4H]                      ; 001F _ 0F B7. 40, 04
        cwde                                            ; 0023 _ 98
        mov     dword [ebp-10H], eax                    ; 0024 _ 89. 45, F0
        mov     eax, dword [ebp-18H]                    ; 0027 _ 8B. 45, E8
        movzx   eax, word [eax+6H]                      ; 002A _ 0F B7. 40, 06
        cwde                                            ; 002E _ 98
        mov     dword [ebp-0CH], eax                    ; 002F _ 89. 45, F4
        mov     eax, dword [ebp-0CH]                    ; 0032 _ 8B. 45, F4
        lea     edx, [eax-1DH]                          ; 0035 _ 8D. 50, E3
        mov     eax, dword [ebp-10H]                    ; 0038 _ 8B. 45, F0
        sub     eax, 1                                  ; 003B _ 83. E8, 01
        sub     esp, 4                                  ; 003E _ 83. EC, 04
        push    edx                                     ; 0041 _ 52
        push    eax                                     ; 0042 _ 50
        push    0                                       ; 0043 _ 6A, 00
        push    0                                       ; 0045 _ 6A, 00
        push    14                                      ; 0047 _ 6A, 0E
        push    dword [ebp-10H]                         ; 0049 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 004C _ FF. 75, EC
        call    boxfill8                                ; 004F _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 0054 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0057 _ 8B. 45, F4
        lea     ecx, [eax-1CH]                          ; 005A _ 8D. 48, E4
        mov     eax, dword [ebp-10H]                    ; 005D _ 8B. 45, F0
        lea     edx, [eax-1H]                           ; 0060 _ 8D. 50, FF
        mov     eax, dword [ebp-0CH]                    ; 0063 _ 8B. 45, F4
        sub     eax, 28                                 ; 0066 _ 83. E8, 1C
        sub     esp, 4                                  ; 0069 _ 83. EC, 04
        push    ecx                                     ; 006C _ 51
        push    edx                                     ; 006D _ 52
        push    eax                                     ; 006E _ 50
        push    0                                       ; 006F _ 6A, 00
        push    8                                       ; 0071 _ 6A, 08
        push    dword [ebp-10H]                         ; 0073 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0076 _ FF. 75, EC
        call    boxfill8                                ; 0079 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 007E _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0081 _ 8B. 45, F4
        lea     ecx, [eax-1BH]                          ; 0084 _ 8D. 48, E5
        mov     eax, dword [ebp-10H]                    ; 0087 _ 8B. 45, F0
        lea     edx, [eax-1H]                           ; 008A _ 8D. 50, FF
        mov     eax, dword [ebp-0CH]                    ; 008D _ 8B. 45, F4
        sub     eax, 27                                 ; 0090 _ 83. E8, 1B
        sub     esp, 4                                  ; 0093 _ 83. EC, 04
        push    ecx                                     ; 0096 _ 51
        push    edx                                     ; 0097 _ 52
        push    eax                                     ; 0098 _ 50
        push    0                                       ; 0099 _ 6A, 00
        push    7                                       ; 009B _ 6A, 07
        push    dword [ebp-10H]                         ; 009D _ FF. 75, F0
        push    dword [ebp-14H]                         ; 00A0 _ FF. 75, EC
        call    boxfill8                                ; 00A3 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 00A8 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 00AB _ 8B. 45, F4
        lea     ecx, [eax-1H]                           ; 00AE _ 8D. 48, FF
        mov     eax, dword [ebp-10H]                    ; 00B1 _ 8B. 45, F0
        lea     edx, [eax-1H]                           ; 00B4 _ 8D. 50, FF
        mov     eax, dword [ebp-0CH]                    ; 00B7 _ 8B. 45, F4
        sub     eax, 26                                 ; 00BA _ 83. E8, 1A
        sub     esp, 4                                  ; 00BD _ 83. EC, 04
        push    ecx                                     ; 00C0 _ 51
        push    edx                                     ; 00C1 _ 52
        push    eax                                     ; 00C2 _ 50
        push    0                                       ; 00C3 _ 6A, 00
        push    8                                       ; 00C5 _ 6A, 08
        push    dword [ebp-10H]                         ; 00C7 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 00CA _ FF. 75, EC
        call    boxfill8                                ; 00CD _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 00D2 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 00D5 _ 8B. 45, F4
        lea     edx, [eax-18H]                          ; 00D8 _ 8D. 50, E8
        mov     eax, dword [ebp-0CH]                    ; 00DB _ 8B. 45, F4
        sub     eax, 24                                 ; 00DE _ 83. E8, 18
        sub     esp, 4                                  ; 00E1 _ 83. EC, 04
        push    edx                                     ; 00E4 _ 52
        push    59                                      ; 00E5 _ 6A, 3B
        push    eax                                     ; 00E7 _ 50
        push    3                                       ; 00E8 _ 6A, 03
        push    7                                       ; 00EA _ 6A, 07
        push    dword [ebp-10H]                         ; 00EC _ FF. 75, F0
        push    dword [ebp-14H]                         ; 00EF _ FF. 75, EC
        call    boxfill8                                ; 00F2 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 00F7 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 00FA _ 8B. 45, F4
        lea     edx, [eax-4H]                           ; 00FD _ 8D. 50, FC
        mov     eax, dword [ebp-0CH]                    ; 0100 _ 8B. 45, F4
        sub     eax, 24                                 ; 0103 _ 83. E8, 18
        sub     esp, 4                                  ; 0106 _ 83. EC, 04
        push    edx                                     ; 0109 _ 52
        push    2                                       ; 010A _ 6A, 02
        push    eax                                     ; 010C _ 50
        push    2                                       ; 010D _ 6A, 02
        push    7                                       ; 010F _ 6A, 07
        push    dword [ebp-10H]                         ; 0111 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0114 _ FF. 75, EC
        call    boxfill8                                ; 0117 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 011C _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 011F _ 8B. 45, F4
        lea     edx, [eax-4H]                           ; 0122 _ 8D. 50, FC
        mov     eax, dword [ebp-0CH]                    ; 0125 _ 8B. 45, F4
        sub     eax, 4                                  ; 0128 _ 83. E8, 04
        sub     esp, 4                                  ; 012B _ 83. EC, 04
        push    edx                                     ; 012E _ 52
        push    59                                      ; 012F _ 6A, 3B
        push    eax                                     ; 0131 _ 50
        push    3                                       ; 0132 _ 6A, 03
        push    15                                      ; 0134 _ 6A, 0F
        push    dword [ebp-10H]                         ; 0136 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0139 _ FF. 75, EC
        call    boxfill8                                ; 013C _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 0141 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0144 _ 8B. 45, F4
        lea     edx, [eax-5H]                           ; 0147 _ 8D. 50, FB
        mov     eax, dword [ebp-0CH]                    ; 014A _ 8B. 45, F4
        sub     eax, 23                                 ; 014D _ 83. E8, 17
        sub     esp, 4                                  ; 0150 _ 83. EC, 04
        push    edx                                     ; 0153 _ 52
        push    59                                      ; 0154 _ 6A, 3B
        push    eax                                     ; 0156 _ 50
        push    59                                      ; 0157 _ 6A, 3B
        push    15                                      ; 0159 _ 6A, 0F
        push    dword [ebp-10H]                         ; 015B _ FF. 75, F0
        push    dword [ebp-14H]                         ; 015E _ FF. 75, EC
        call    boxfill8                                ; 0161 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 0166 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0169 _ 8B. 45, F4
        lea     edx, [eax-3H]                           ; 016C _ 8D. 50, FD
        mov     eax, dword [ebp-0CH]                    ; 016F _ 8B. 45, F4
        sub     eax, 3                                  ; 0172 _ 83. E8, 03
        sub     esp, 4                                  ; 0175 _ 83. EC, 04
        push    edx                                     ; 0178 _ 52
        push    59                                      ; 0179 _ 6A, 3B
        push    eax                                     ; 017B _ 50
        push    2                                       ; 017C _ 6A, 02
        push    0                                       ; 017E _ 6A, 00
        push    dword [ebp-10H]                         ; 0180 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0183 _ FF. 75, EC
        call    boxfill8                                ; 0186 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 018B _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 018E _ 8B. 45, F4
        lea     edx, [eax-3H]                           ; 0191 _ 8D. 50, FD
        mov     eax, dword [ebp-0CH]                    ; 0194 _ 8B. 45, F4
        sub     eax, 24                                 ; 0197 _ 83. E8, 18
        sub     esp, 4                                  ; 019A _ 83. EC, 04
        push    edx                                     ; 019D _ 52
        push    60                                      ; 019E _ 6A, 3C
        push    eax                                     ; 01A0 _ 50
        push    60                                      ; 01A1 _ 6A, 3C
        push    0                                       ; 01A3 _ 6A, 00
        push    dword [ebp-10H]                         ; 01A5 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 01A8 _ FF. 75, EC
        call    boxfill8                                ; 01AB _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 01B0 _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 01B3 _ 8B. 45, F4
        lea     ebx, [eax-18H]                          ; 01B6 _ 8D. 58, E8
        mov     eax, dword [ebp-10H]                    ; 01B9 _ 8B. 45, F0
        lea     ecx, [eax-4H]                           ; 01BC _ 8D. 48, FC
        mov     eax, dword [ebp-0CH]                    ; 01BF _ 8B. 45, F4
        lea     edx, [eax-18H]                          ; 01C2 _ 8D. 50, E8
        mov     eax, dword [ebp-10H]                    ; 01C5 _ 8B. 45, F0
        sub     eax, 47                                 ; 01C8 _ 83. E8, 2F
        sub     esp, 4                                  ; 01CB _ 83. EC, 04
        push    ebx                                     ; 01CE _ 53
        push    ecx                                     ; 01CF _ 51
        push    edx                                     ; 01D0 _ 52
        push    eax                                     ; 01D1 _ 50
        push    15                                      ; 01D2 _ 6A, 0F
        push    dword [ebp-10H]                         ; 01D4 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 01D7 _ FF. 75, EC
        call    boxfill8                                ; 01DA _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 01DF _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 01E2 _ 8B. 45, F4
        lea     ebx, [eax-4H]                           ; 01E5 _ 8D. 58, FC
        mov     eax, dword [ebp-10H]                    ; 01E8 _ 8B. 45, F0
        lea     ecx, [eax-2FH]                          ; 01EB _ 8D. 48, D1
        mov     eax, dword [ebp-0CH]                    ; 01EE _ 8B. 45, F4
        lea     edx, [eax-17H]                          ; 01F1 _ 8D. 50, E9
        mov     eax, dword [ebp-10H]                    ; 01F4 _ 8B. 45, F0
        sub     eax, 47                                 ; 01F7 _ 83. E8, 2F
        sub     esp, 4                                  ; 01FA _ 83. EC, 04
        push    ebx                                     ; 01FD _ 53
        push    ecx                                     ; 01FE _ 51
        push    edx                                     ; 01FF _ 52
        push    eax                                     ; 0200 _ 50
        push    15                                      ; 0201 _ 6A, 0F
        push    dword [ebp-10H]                         ; 0203 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0206 _ FF. 75, EC
        call    boxfill8                                ; 0209 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 020E _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0211 _ 8B. 45, F4
        lea     ebx, [eax-3H]                           ; 0214 _ 8D. 58, FD
        mov     eax, dword [ebp-10H]                    ; 0217 _ 8B. 45, F0
        lea     ecx, [eax-4H]                           ; 021A _ 8D. 48, FC
        mov     eax, dword [ebp-0CH]                    ; 021D _ 8B. 45, F4
        lea     edx, [eax-3H]                           ; 0220 _ 8D. 50, FD
        mov     eax, dword [ebp-10H]                    ; 0223 _ 8B. 45, F0
        sub     eax, 47                                 ; 0226 _ 83. E8, 2F
        sub     esp, 4                                  ; 0229 _ 83. EC, 04
        push    ebx                                     ; 022C _ 53
        push    ecx                                     ; 022D _ 51
        push    edx                                     ; 022E _ 52
        push    eax                                     ; 022F _ 50
        push    7                                       ; 0230 _ 6A, 07
        push    dword [ebp-10H]                         ; 0232 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0235 _ FF. 75, EC
        call    boxfill8                                ; 0238 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 023D _ 83. C4, 20
        mov     eax, dword [ebp-0CH]                    ; 0240 _ 8B. 45, F4
        lea     ebx, [eax-3H]                           ; 0243 _ 8D. 58, FD
        mov     eax, dword [ebp-10H]                    ; 0246 _ 8B. 45, F0
        lea     ecx, [eax-3H]                           ; 0249 _ 8D. 48, FD
        mov     eax, dword [ebp-0CH]                    ; 024C _ 8B. 45, F4
        lea     edx, [eax-18H]                          ; 024F _ 8D. 50, E8
        mov     eax, dword [ebp-10H]                    ; 0252 _ 8B. 45, F0
        sub     eax, 3                                  ; 0255 _ 83. E8, 03
        sub     esp, 4                                  ; 0258 _ 83. EC, 04
        push    ebx                                     ; 025B _ 53
        push    ecx                                     ; 025C _ 51
        push    edx                                     ; 025D _ 52
        push    eax                                     ; 025E _ 50
        push    7                                       ; 025F _ 6A, 07
        push    dword [ebp-10H]                         ; 0261 _ FF. 75, F0
        push    dword [ebp-14H]                         ; 0264 _ FF. 75, EC
        call    boxfill8                                ; 0267 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 026C _ 83. C4, 20
        mov     eax, dword [ebp-18H]                    ; 026F _ 8B. 45, E8
        movzx   eax, word [eax+4H]                      ; 0272 _ 0F B7. 40, 04
        movsx   edx, ax                                 ; 0276 _ 0F BF. D0
        mov     eax, dword [ebp-18H]                    ; 0279 _ 8B. 45, E8
        mov     eax, dword [eax+8H]                     ; 027C _ 8B. 40, 08
        sub     esp, 8                                  ; 027F _ 83. EC, 08
        push    systemFont+410H                         ; 0282 _ 68, 00000410(d)
        push    7                                       ; 0287 _ 6A, 07
        push    8                                       ; 0289 _ 6A, 08
        push    8                                       ; 028B _ 6A, 08
        push    edx                                     ; 028D _ 52
        push    eax                                     ; 028E _ 50
        call    putFont8                                ; 028F _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 0294 _ 83. C4, 20
        mov     eax, dword [ebp-18H]                    ; 0297 _ 8B. 45, E8
        movzx   eax, word [eax+4H]                      ; 029A _ 0F B7. 40, 04
        movsx   edx, ax                                 ; 029E _ 0F BF. D0
        mov     eax, dword [ebp-18H]                    ; 02A1 _ 8B. 45, E8
        mov     eax, dword [eax+8H]                     ; 02A4 _ 8B. 40, 08
        sub     esp, 8                                  ; 02A7 _ 83. EC, 08
        push    systemFont+420H                         ; 02AA _ 68, 00000420(d)
        push    7                                       ; 02AF _ 6A, 07
        push    8                                       ; 02B1 _ 6A, 08
        push    16                                      ; 02B3 _ 6A, 10
        push    edx                                     ; 02B5 _ 52
        push    eax                                     ; 02B6 _ 50
        call    putFont8                                ; 02B7 _ E8, FFFFFFFC(rel)
        add     esp, 32                                 ; 02BC _ 83. C4, 20
?_001:  call    io_hlt                                  ; 02BF _ E8, FFFFFFFC(rel)
        jmp     ?_001            


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

putFont8:; Function begin
        push    ebp                                     ; 03B8 _ 55
        mov     ebp, esp                                ; 03B9 _ 89. E5
        sub     esp, 20                                 ; 03BB _ 83. EC, 14
        mov     eax, dword [ebp+18H]                    ; 03BE _ 8B. 45, 18
        mov     byte [ebp-14H], al                      ; 03C1 _ 88. 45, EC
        mov     dword [ebp-4H], 0                       ; 03C4 _ C7. 45, FC, 00000000
        jmp     ?_017                                   ; 03CB _ E9, 0000016C

?_008:  mov     edx, dword [ebp-4H]                     ; 03D0 _ 8B. 55, FC
        mov     eax, dword [ebp+1CH]                    ; 03D3 _ 8B. 45, 1C
        add     eax, edx                                ; 03D6 _ 01. D0
        movzx   eax, byte [eax]                         ; 03D8 _ 0F B6. 00
        mov     byte [ebp-5H], al                       ; 03DB _ 88. 45, FB
        cmp     byte [ebp-5H], 0                        ; 03DE _ 80. 7D, FB, 00
        jns     ?_009                                   ; 03E2 _ 79, 20
        mov     edx, dword [ebp+14H]                    ; 03E4 _ 8B. 55, 14
        mov     eax, dword [ebp-4H]                     ; 03E7 _ 8B. 45, FC
        add     eax, edx                                ; 03EA _ 01. D0
        imul    eax, dword [ebp+0CH]                    ; 03EC _ 0F AF. 45, 0C
        mov     edx, eax                                ; 03F0 _ 89. C2
        mov     eax, dword [ebp+10H]                    ; 03F2 _ 8B. 45, 10
        add     eax, edx                                ; 03F5 _ 01. D0
        mov     edx, eax                                ; 03F7 _ 89. C2
        mov     eax, dword [ebp+8H]                     ; 03F9 _ 8B. 45, 08
        add     edx, eax                                ; 03FC _ 01. C2
        movzx   eax, byte [ebp-14H]                     ; 03FE _ 0F B6. 45, EC
        mov     byte [edx], al                          ; 0402 _ 88. 02
?_009:  movsx   eax, byte [ebp-5H]                      ; 0404 _ 0F BE. 45, FB
        and     eax, 40H                                ; 0408 _ 83. E0, 40
        test    eax, eax                                ; 040B _ 85. C0
        jz      ?_010                                   ; 040D _ 74, 21
        mov     edx, dword [ebp+14H]                    ; 040F _ 8B. 55, 14
        mov     eax, dword [ebp-4H]                     ; 0412 _ 8B. 45, FC
        add     eax, edx                                ; 0415 _ 01. D0
        imul    eax, dword [ebp+0CH]                    ; 0417 _ 0F AF. 45, 0C
        mov     edx, eax                                ; 041B _ 89. C2
        mov     eax, dword [ebp+10H]                    ; 041D _ 8B. 45, 10
        add     eax, edx                                ; 0420 _ 01. D0
        lea     edx, [eax+1H]                           ; 0422 _ 8D. 50, 01
        mov     eax, dword [ebp+8H]                     ; 0425 _ 8B. 45, 08
        add     edx, eax                                ; 0428 _ 01. C2
        movzx   eax, byte [ebp-14H]                     ; 042A _ 0F B6. 45, EC
        mov     byte [edx], al                          ; 042E _ 88. 02
?_010:  movsx   eax, byte [ebp-5H]                      ; 0430 _ 0F BE. 45, FB
        and     eax, 20H                                ; 0434 _ 83. E0, 20
        test    eax, eax                                ; 0437 _ 85. C0
        jz      ?_011                                   ; 0439 _ 74, 21
        mov     edx, dword [ebp+14H]                    ; 043B _ 8B. 55, 14
        mov     eax, dword [ebp-4H]                     ; 043E _ 8B. 45, FC
        add     eax, edx                                ; 0441 _ 01. D0
        imul    eax, dword [ebp+0CH]                    ; 0443 _ 0F AF. 45, 0C
        mov     edx, eax                                ; 0447 _ 89. C2
        mov     eax, dword [ebp+10H]                    ; 0449 _ 8B. 45, 10
        add     eax, edx                                ; 044C _ 01. D0
        lea     edx, [eax+2H]                           ; 044E _ 8D. 50, 02
        mov     eax, dword [ebp+8H]                     ; 0451 _ 8B. 45, 08
        add     edx, eax                                ; 0454 _ 01. C2
        movzx   eax, byte [ebp-14H]                     ; 0456 _ 0F B6. 45, EC
        mov     byte [edx], al                          ; 045A _ 88. 02
?_011:  movsx   eax, byte [ebp-5H]                      ; 045C _ 0F BE. 45, FB
        and     eax, 10H                                ; 0460 _ 83. E0, 10
        test    eax, eax                                ; 0463 _ 85. C0
        jz      ?_012                                   ; 0465 _ 74, 21
        mov     edx, dword [ebp+14H]                    ; 0467 _ 8B. 55, 14
        mov     eax, dword [ebp-4H]                     ; 046A _ 8B. 45, FC
        add     eax, edx                                ; 046D _ 01. D0
        imul    eax, dword [ebp+0CH]                    ; 046F _ 0F AF. 45, 0C
        mov     edx, eax                                ; 0473 _ 89. C2
        mov     eax, dword [ebp+10H]                    ; 0475 _ 8B. 45, 10
        add     eax, edx                                ; 0478 _ 01. D0
        lea     edx, [eax+3H]                           ; 047A _ 8D. 50, 03
        mov     eax, dword [ebp+8H]                     ; 047D _ 8B. 45, 08
        add     edx, eax                                ; 0480 _ 01. C2
        movzx   eax, byte [ebp-14H]                     ; 0482 _ 0F B6. 45, EC
        mov     byte [edx], al                          ; 0486 _ 88. 02
?_012:  movsx   eax, byte [ebp-5H]                      ; 0488 _ 0F BE. 45, FB
        and     eax, 08H                                ; 048C _ 83. E0, 08
        test    eax, eax                                ; 048F _ 85. C0
        jz      ?_013                                   ; 0491 _ 74, 21
        mov     edx, dword [ebp+14H]                    ; 0493 _ 8B. 55, 14
        mov     eax, dword [ebp-4H]                     ; 0496 _ 8B. 45, FC
        add     eax, edx                                ; 0499 _ 01. D0
        imul    eax, dword [ebp+0CH]                    ; 049B _ 0F AF. 45, 0C
        mov     edx, eax                                ; 049F _ 89. C2
        mov     eax, dword [ebp+10H]                    ; 04A1 _ 8B. 45, 10
        add     eax, edx                                ; 04A4 _ 01. D0
        lea     edx, [eax+4H]                           ; 04A6 _ 8D. 50, 04
        mov     eax, dword [ebp+8H]                     ; 04A9 _ 8B. 45, 08
        add     edx, eax                                ; 04AC _ 01. C2
        movzx   eax, byte [ebp-14H]                     ; 04AE _ 0F B6. 45, EC
        mov     byte [edx], al                          ; 04B2 _ 88. 02
?_013:  movsx   eax, byte [ebp-5H]                      ; 04B4 _ 0F BE. 45, FB
        and     eax, 04H                                ; 04B8 _ 83. E0, 04
        test    eax, eax                                ; 04BB _ 85. C0
        jz      ?_014                                   ; 04BD _ 74, 21
        mov     edx, dword [ebp+14H]                    ; 04BF _ 8B. 55, 14
        mov     eax, dword [ebp-4H]                     ; 04C2 _ 8B. 45, FC
        add     eax, edx                                ; 04C5 _ 01. D0
        imul    eax, dword [ebp+0CH]                    ; 04C7 _ 0F AF. 45, 0C
        mov     edx, eax                                ; 04CB _ 89. C2
        mov     eax, dword [ebp+10H]                    ; 04CD _ 8B. 45, 10
        add     eax, edx                                ; 04D0 _ 01. D0
        lea     edx, [eax+5H]                           ; 04D2 _ 8D. 50, 05
        mov     eax, dword [ebp+8H]                     ; 04D5 _ 8B. 45, 08
        add     edx, eax                                ; 04D8 _ 01. C2
        movzx   eax, byte [ebp-14H]                     ; 04DA _ 0F B6. 45, EC
        mov     byte [edx], al                          ; 04DE _ 88. 02
?_014:  movsx   eax, byte [ebp-5H]                      ; 04E0 _ 0F BE. 45, FB
        and     eax, 02H                                ; 04E4 _ 83. E0, 02
        test    eax, eax                                ; 04E7 _ 85. C0
        jz      ?_015                                   ; 04E9 _ 74, 21
        mov     edx, dword [ebp+14H]                    ; 04EB _ 8B. 55, 14
        mov     eax, dword [ebp-4H]                     ; 04EE _ 8B. 45, FC
        add     eax, edx                                ; 04F1 _ 01. D0
        imul    eax, dword [ebp+0CH]                    ; 04F3 _ 0F AF. 45, 0C
        mov     edx, eax                                ; 04F7 _ 89. C2
        mov     eax, dword [ebp+10H]                    ; 04F9 _ 8B. 45, 10
        add     eax, edx                                ; 04FC _ 01. D0
        lea     edx, [eax+6H]                           ; 04FE _ 8D. 50, 06
        mov     eax, dword [ebp+8H]                     ; 0501 _ 8B. 45, 08
        add     edx, eax                                ; 0504 _ 01. C2
        movzx   eax, byte [ebp-14H]                     ; 0506 _ 0F B6. 45, EC
        mov     byte [edx], al                          ; 050A _ 88. 02
?_015:  movsx   eax, byte [ebp-5H]                      ; 050C _ 0F BE. 45, FB
        and     eax, 01H                                ; 0510 _ 83. E0, 01
        test    eax, eax                                ; 0513 _ 85. C0
        jz      ?_016                                   ; 0515 _ 74, 21
        mov     edx, dword [ebp+14H]                    ; 0517 _ 8B. 55, 14
        mov     eax, dword [ebp-4H]                     ; 051A _ 8B. 45, FC
        add     eax, edx                                ; 051D _ 01. D0
        imul    eax, dword [ebp+0CH]                    ; 051F _ 0F AF. 45, 0C
        mov     edx, eax                                ; 0523 _ 89. C2
        mov     eax, dword [ebp+10H]                    ; 0525 _ 8B. 45, 10
        add     eax, edx                                ; 0528 _ 01. D0
        lea     edx, [eax+7H]                           ; 052A _ 8D. 50, 07
        mov     eax, dword [ebp+8H]                     ; 052D _ 8B. 45, 08
        add     edx, eax                                ; 0530 _ 01. C2
        movzx   eax, byte [ebp-14H]                     ; 0532 _ 0F B6. 45, EC
        mov     byte [edx], al                          ; 0536 _ 88. 02
?_016:  add     dword [ebp-4H], 1                       ; 0538 _ 83. 45, FC, 01
?_017:  cmp     dword [ebp-4H], 15                      ; 053C _ 83. 7D, FC, 0F
        jle     ?_008                                   ; 0540 _ 0F 8E, FFFFFE8A
        leave                                           ; 0546 _ C9
        ret                                             ; 0547 _ C3
; putFont8 End of function



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


font_A:                                                 ; oword
        db 00H, 18H, 18H, 18H, 18H, 24H, 24H, 24H       ; 0000 _ .....$$$
        db 24H, 7EH, 42H, 42H, 42H, 0E7H, 00H, 00H      ; 0008 _ $~BBB...
        db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H       ; 0010 _ ........
        db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H       ; 0018 _ ........


table_rgb.1444:                                         ; byte
        db 00H, 00H, 00H, 0FFH, 00H, 00H, 00H, 0FFH     ; 0000 _ ........
        db 00H, 0FFH, 0FFH, 00H, 00H, 00H, 0FFH, 0FFH   ; 0008 _ ........
        db 00H, 0FFH, 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH ; 0010 _ ........
        db 0C6H, 0C6H, 0C6H, 84H, 00H, 00H, 00H, 84H    ; 0018 _ ........
        db 00H, 84H, 84H, 00H, 00H, 00H, 84H, 84H       ; 0020 _ ........
        db 00H, 84H, 00H, 84H, 84H, 84H, 84H, 84H       ; 0028 _ ........

%include "fontData.inc"

SegCode32Len   equ  $ - LABEL_SEG_CODE32

[SECTION .gs]
ALIGN 32
[BITS 32]
LABEL_STACK:
times 512  db 0
TopOfStack  equ  $ - LABEL_STACK

