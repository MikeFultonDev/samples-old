#include <dynit.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include "malloc24.h"

typedef struct {  
	int verbose:1;
} OptInfo_T;

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

typedef _Packed struct {
	unsigned int last:1;
	unsigned int action:3;
	unsigned int mode:4;	
	unsigned int pad:24;
} OpenType_T;

typedef _Packed struct {
/* 0x00 */	char intro[0x10];     /* 0x00000000000000000000000000000000 */
/* 0x10 */	unsigned int keylen;  /* 0x00000000 */
		char bufno;           /* 0x0 */
		unsigned int bufcb:24;/* 0x00001 */
		unsigned short bufl;  /* 0 */
		unsigned short dsorg; /* 0x4000 */
		unsigned int iobadrtn;/* 0x0000001 */
/* 0x20 */	char bftek;           /* 0x0 */
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
	char unk[0x30];
	char hobunk;
	unsigned int iortn:24;
} DCBActive_T;

#define ADDR_32_ODD (0x00000001)
#define ADDR_24_ODD (0x000001)

#define MACFMT_READ (0x5000)
#define MACFMT_WRITE (0x0050)
#define OFLGS (0x2)
#define DSORG_PS (0x4000)
#define BLANKS "        "

static void dcbinit(__dyn_t* ddinfo, DCB_T* dcb, unsigned short macfmt) {
	DCB_T localdcb = { 
		{0}, 
		0, 0, ADDR_24_ODD, 0, DSORG_PS, ADDR_32_ODD, 
		0, ADDR_24_ODD, 0, ADDR_24_ODD, BLANKS, 
		OFLGS, 0, macfmt, 0, ADDR_24_ODD, ADDR_32_ODD, 0, 0,
		0, ADDR_32_ODD, ADDR_32_ODD, ADDR_32_ODD, 
		0, 0, 0, ADDR_24_ODD, 0, ADDR_32_ODD	
	};
	*dcb = localdcb;
	memcpy(&dcb->ddname, ddinfo->__ddname, 8);
}

typedef _Packed struct {
	unsigned int last:1;
	unsigned int action:3;
	unsigned int pad:28;	
} CloseType_T;

typedef _Packed struct {
	OpenType_T type;
	unsigned int zero:8;
	unsigned int dcb:24;
} SVC19PList_T;

typedef _Packed struct {
	CloseType_T type;
	unsigned int zero:8;
	unsigned int dcb:24;
} SVC20PList_T;

typedef _Packed struct {
	char* buffer;
	DCBActive_T* dcb;
	void* iortn;
} READPList_T;	

int SVC19(SVC19PList_T r0);
int SVC20(SVC20PList_T r0);
void READ(READPList_T plist);

static int openDCB( OpenType_T type, __dyn_t* ddInfo, DCB_T* dcb) {
	unsigned int dcb24 = (((unsigned int) dcb) & 0xFFFFFF);
	
	SVC19PList_T R0 = { type, 0, dcb24 };         
	return SVC19(R0); 
}

static int closeDCB(CloseType_T type, DCB_T* dcb) {
	unsigned int dcb24 = (((unsigned int) dcb) & 0xFFFFFF);
	
	SVC20PList_T R0 = { type, 0, dcb24 };         
	return SVC20(R0); 
}

static int allocDDName(OptInfo_T* optInfo, char* ddName, char* dsName, __dyn_t* ip, int isExclusive, int isModify) {
        int rc;         
                
	dyninit(ip);
                        
        ip->__ddname = ddName;
 	ip->__dsname = dsName;
      	        
        if (isExclusive) {
	        ip->__status = __DISP_OLD;
	} else if (isModify) {
 	        ip->__status = __DISP_MOD;
        } else {
                ip->__status = __DISP_SHR;
        }               
	           		
	errno = 0;
	rc = dynalloc(ip);
        if (rc) {
		perror("dynalloc");
	        fprintf(stderr, "dynalloc failed with rc: 0x%x\n", rc);
        }
	return rc;
}

static int freeDDName(OptInfo_T* optInfo, char* ddName, char* dsName, __dyn_t* ip) {
        int rc;
        	
	dyninit(ip);

	ip->__ddname = ddName;
	ip->__dsname = dsName;

	errno = 0;
	rc = dynfree(ip);
	if (rc) {
		perror("dynfree");
		fprintf(stderr, "dynfree failed with rc: 0x%x\n", rc);
	}
	return rc;
}

int main(int argc, char* argv[]) {
	char readBuffer[65536];
	char* in;
	char* out;
	char ddIn[] = {"DDIN    "};
	char ddOut[]= {"DDOUT   "};
	__dyn_t inDDInfo;
	__dyn_t outDDInfo;
	__dyn_t freeDDInfo;
	DCB_T* inDCB;
	DCB_T* outDCB;
	READPList_T readparms;	
	DCBActive_T* inDCBActive;
	void* readFP;
	int rc;

	OptInfo_T optInfo = {0};
	OpenType_T ddInOpenType = { 1, Disp, OpenInput, 0 };
	CloseType_T ddInCloseType = { 1, Disp, 0 };

	if (argc < 3) {
		fprintf(stderr, "syntax: dcp <in> <out>\n");
		return 16;
	}
	in = argv[1];
	out = argv[2];

	inDCB = malloc24(sizeof(DCB_T));
	outDCB = malloc24(sizeof(DCB_T));
	if (!inDCB || !outDCB) {
		fprintf(stderr, "unable to allocate storage below the line for I/O\n");
		return 16;
	}
	
	rc = allocDDName(&optInfo, ddIn, in, &inDDInfo, 0, 0);

	if (rc) {
		return rc;
	}

	dcbinit(&inDDInfo, inDCB, MACFMT_READ);
	rc = openDCB(ddInOpenType, &inDDInfo, inDCB);
	if (rc) {
		fprintf(stderr, "openDCB failed with rc:0x%x\n", rc);
		return rc;
	}
	inDCBActive = (DCBActive_T*) inDCB;
	readparms.buffer = readBuffer;
	readparms.dcb = inDCBActive;
	readparms.iortn = (void*) inDCBActive->iortn;
	printf("lrecl:%d\n", inDCB->lrecl);
	READ(readparms);
	printf("%.*s\n", inDCB->lrecl, readparms.buffer);

	rc = closeDCB(ddInCloseType, inDCB);
	if (rc) {
		fprintf(stderr, "closeDB failed with rc:0x%x\n", rc);
		return rc;
	}

	rc = freeDDName(&optInfo, ddIn, in, &freeDDInfo);

	if (rc) {
		fprintf(stderr, "freeDDName failed with rc:0x%x\n", rc);
		return rc;
	}

	free(inDCB);
	free(outDCB);
	
	return 0;
}
