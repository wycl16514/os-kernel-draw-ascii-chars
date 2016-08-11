#define  COL8_000000   0
#define  COL8_FF0000   1
#define  COL8_00FF00   2
#define  COL8_FFFF00   3
#define  COL8_0000FF   4
#define  COL8_FF00FF   5
#define  COL8_00FFFF   6
#define  COL8_FFFFFF   7
#define  COL8_C6C6C6   8
#define  COL8_840000   9
#define  COL8_008400   10
#define  COL8_848400   11
#define  COL8_000084   12
#define  COL8_840084   13
#define  COL8_008484   14
#define  COL8_848484   15

void io_htl(void);
void write_mem8(int addr, int data);
void io_cli(void);
void io_out8(int port, int data);
int  io_load_eflags(void);
void io_store_eflags(int eflags);
void init_palatte(void);
void set_palatte(int start, int end, unsigned char* rgb);
void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0,
  int x1, int y1);
void putFont8(char* vram, int xsize, int x, int y, char c, char* font);

struct BOOTINFO  {
    char cyls, leds, vmode, reserve;
    short scrnx, scrny;
    char  *vram;
};


void  HariMain(void) {
    char *vram;
    int  xsize, ysize;
    struct BOOTINFO *binfo;

    init_palatte();
    binfo = (struct BOOTINFO*) 0xff0;  
    vram = (*binfo).vram;
    xsize = (*binfo).scrnx;
    ysize = (*binfo).scrny;

    
    boxfill8(vram, xsize, COL8_008484, 0, 0,        xsize-1, ysize-29);
    boxfill8(vram, xsize, COL8_C6C6C6, 0, ysize-28, xsize-1, ysize-28);
    boxfill8(vram, xsize, COL8_FFFFFF, 0, ysize-27, xsize-1, ysize-27);
    boxfill8(vram, xsize, COL8_C6C6C6, 0, ysize-26, xsize-1, ysize-1);
 
    boxfill8(vram, xsize, COL8_FFFFFF, 3,  ysize-24, 59, ysize-24);
    boxfill8(vram, xsize, COL8_FFFFFF, 2,  ysize-24, 2,  ysize-4);
    boxfill8(vram, xsize, COL8_848484, 3,  ysize-4, 59,  ysize-4);
    boxfill8(vram, xsize, COL8_848484, 59, ysize-23,59,  ysize-5);
    boxfill8(vram, xsize, COL8_000000, 2,  ysize-3, 59,  ysize-3);
    boxfill8(vram, xsize, COL8_000000, 60, ysize-24,60,  ysize-3);

    boxfill8(vram, xsize, COL8_848484, xsize-47, ysize-24, xsize-4,  ysize-24);
    boxfill8(vram, xsize, COL8_848484, xsize-47, ysize-23, xsize-47, ysize-4);
    boxfill8(vram, xsize, COL8_FFFFFF, xsize-47, ysize-3,  xsize-4,  ysize-3);
    boxfill8(vram, xsize, COL8_FFFFFF, xsize-3,  ysize-24, xsize-3,  ysize-3);

    extern char systemFont[16]; 

    putFont8(binfo->vram, binfo->scrnx, 8, 8, COL8_FFFFFF, systemFont + 'A' * 16 );    

     putFont8(binfo->vram, binfo->scrnx, 16, 8, COL8_FFFFFF, systemFont + 'B' * 16);
    for(;;) {
        io_hlt();
    }

}


void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0,int x1, int y1) {
    int x, y;
    for (y = y0; y <= y1; y++) {
        for (x = x0; x <= x1; x++) {
            vram[y * xsize + x] = c;
        }
    }
 
}

void  init_palatte(void) {

    static unsigned char  table_rgb[16*3] = {
        0x00, 0x00, 0x00,
        0xff, 0x00, 0x00,
        0x00, 0xff, 0x00,
        0xff, 0xff, 0x00,
        0x00, 0x00, 0xff,
        0xff, 0x00, 0xff,
        0x00, 0xff, 0xff,
        0xff, 0xff, 0xff,
        0xc6, 0xc6, 0xc6,
        0x84, 0x00, 0x00,
        0x00, 0x84, 0x00,
        0x84, 0x84, 0x00,
        0x00, 0x00, 0x84,
        0x84, 0x00, 0x84,
        0x00, 0x84, 0x84,
        0x84, 0x84, 0x84
    };
  
    set_palatte(0, 15, table_rgb);
    return;
}

void  set_palatte(int start, int end, unsigned char* rgb) {
    int  i,  eflags;
    eflags = io_load_eflags();
    io_cli();
    io_out8(0x3c8, start);
    for (i = start; i <= end; i++) {
      io_out8(0x3c9, rgb[0] / 4);
      io_out8(0x3c9, rgb[1] / 4);
      io_out8(0x3c9, rgb[2] / 4);
      rgb += 3;
    } 

    io_store_eflags(eflags);
    return;
}

void putFont8(char* vram, int xsize, int x, int y, char c, char* font) {
    int  i ;
    char d;
    for (i = 0; i < 16; i++) {
        d = font[i];
        if ((d & 0x80) != 0)
          {vram[(y+i)*xsize + x + 0] = c;  }
        if ((d & 0x40) != 0)
          {vram[(y+i)*xsize + x + 1] = c;}
        if ((d & 0x20) != 0)
          {vram[(y+i)*xsize + x + 2] = c;}
        if ((d & 0x10) != 0)
          {vram[(y+i)*xsize + x + 3] = c;}
        if ((d & 0x08) != 0)
          {vram[(y+i)*xsize + x + 4] = c;}
        if ((d & 0x04) != 0)
          {vram[(y+i)*xsize + x + 5] = c;}
        if ((d & 0x02) != 0)
          {vram[(y+i)*xsize + x + 6] = c;}
        if ((d & 0x01) != 0x0)
          {vram[(y+i)*xsize + x + 7] = c;}
    }
}
 
