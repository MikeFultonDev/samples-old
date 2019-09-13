#ifndef __DCB_H__
	#define __DCB_H__
/*
 * References: 
 * Underlying Open/Read/Write/Close assembler macros and corresponding data structures (control blocks)
 * http://tech.mikefulton.ca/QSAMOPEN
 * http://tech.mikefulton.ca/QSAMGET
 * http://tech.mikefulton.ca/QSAMPUT
 * http://tech.mikefulton.ca/QSAMCLOSE
 * http://tech.mikefulton.ca/QSAMDataControlBlock
 * http://tech.mikefulton.ca/QSAMDataControlBlockExtension 
 */

#include <dynit.h>

#pragma enum(small)
typedef enum {
	Disp=0,
	Reread=1, 
	Leave=3
} Action_T; 

typedef enum {
	OpenInput=0,
	OpenOutput=15,
	OpenUpdate=4
} OpenMode_T;

_Packed struct DCB_T;

typedef _Packed struct {
/* 0x00 */	char eye[4];          /* DCBE */
		unsigned short dcbelen;/* 0x0038 */
		unsigned short rsvr0; /* 0x0000 */
		_Packed struct DCB* dcb;/* 0x00000000 */
		unsigned int curmem;  /* 0x00000000 */
/* 0x10 */	char sysflags;        /* 0x00 */
		char usrflags0;       /* 0x00 */
		unsigned short stripes;/* 0x0000 */
		char usrflags1;       /* 0x00 */
		char flags;           /* 0x00 */
		unsigned short rsrv1; /* 0x0000 */
		unsigned int rsrv2;   /* 0x00000000 */
		unsigned int blksize; /* 0x00000000 */
/* 0x20 */	char rsrv3[8];        /* 0x0000000000000000 */
		void* eodadrtn;       /* 0x00000000 */
		void* ioerrrtn;       /* 0x00000000 */
/* 0x30 */	unsigned int rsv3;    /* 0x00000000 */
		unsigned short tapfl; /* 0x0000 */
		unsigned short mult;  /* 0x0000 */
} DCBE_T;

#define DCB_VB (0x50)
#define DCB_FB (0x90)

typedef _Packed struct {
/* 0x00 */	DCBE_T* dcbe;         /* 0x........ */
		char fdaddevtbl[0x0C];/* 0x000000000000000000000000 */
/* 0x10 */	unsigned int keylen;  /* 0x00000000 */
		char bufno;           /* 0x0 */
		unsigned int bufcb:24;/* 0x00001 */
		unsigned short bufl;  /* 0 */
		unsigned short dsorg; /* 0x4000 */
		unsigned int iobadrtn;/* 0x0000001 */
/* 0x20 */	char bftekdcbe;       /* 0x84 */
		unsigned int eodadrtn:24;/* 0x00000001 */
		char recfm;           /* 0x00 */
		unsigned int exitlst:24;/* 0x0 */
		char ddname[8];       /* blank padded on right */
/* 0x30 */	char openflags;       /* 0x02 */
		char iosflags;        /* 0x00 */
		unsigned short macfmt;/* 0x5000 for input */ /* 0x0050 for output */
		char optcd;           /* 00 */
		unsigned int checkrtn:24;/* 0x000001 */
		unsigned int synadrtn;/* 0x00000001 */
		unsigned short internalflags_1; /* 0x0000 */
		unsigned short blksize;/* 0x0000 */
/* 0x40 */	unsigned int internalflags_2; /* 0x00000000 */
		unsigned int internaluse;/* 0x00000001 */
		unsigned int eobadrtn;/* 0x00000001 */
		unsigned int recadrtn;/* 0x00000001 */
/* 0x50 */ 	unsigned short qswsflags;/* 0x0000 */	
		unsigned short lrecl; /* 0x0000 */
		char eropt;           /* 0x00 */
		unsigned int cntrlrtn:24;/* 0x000001 */
		unsigned int reserved;/* 0x00000000 */
		unsigned int eobrtn;  /* 0x00000001 */
} DCB_T;

typedef _Packed struct {
	char unk1[0x24];
	char recfm;
	char unk2[0xB];
/*0x30*/char hobunk;
	unsigned int iortn:24;
	char unk3[0x10];
/*0x44*/unsigned long* dcbioba;
	char unk4[0x8];
/*0x50*/char unk5[0x2];
	unsigned short lrecl;
} DCBActive_T;

#define ADDR_32_ODD (0x00000001)
#define ADDR_24_ODD (0x000001)

#define MACFMT_READ (0x5000)
#define MACFMT_WRITE (0x0050)
#define DCBE_ON (0x84)
#define OFLGS (0x2)
#define DSORG_PS (0x4000)
#define BLANKS "        "

#define DCBE_EYE "DCBE"

#endif
