#include <dynit.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include "malloc24.h"
#include "dcb.h"
#include "dcpsvc.h"

typedef struct {
	int verbose:1;
} OptInfo_T;

static void dcbinit(__dyn_t* ddinfo, DCB_T* dcb, DCBE_T* dcbe, unsigned short macfmt) {
	DCBE_T localdcbe = { 
		DCBE_EYE, sizeof(DCBE_T), 0, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 
		{0}, &EOD, 0, 
		0, 0, 0
	};
	DCB_T localdcb = { 
		dcbe, {0}, 
		0, 0, ADDR_24_ODD, 0, DSORG_PS, ADDR_32_ODD, 
		DCBE_ON, ADDR_24_ODD, 0, ADDR_24_ODD, BLANKS, 
		OFLGS, 0, macfmt, 0, ADDR_24_ODD, ADDR_32_ODD, 0, 0,
		0, ADDR_32_ODD, ADDR_32_ODD, ADDR_32_ODD, 
		0, 0, 0, ADDR_24_ODD, 0, ADDR_32_ODD	
	};
	*dcb = localdcb;
	*dcbe = localdcbe;
	memcpy(&dcb->ddname, ddinfo->__ddname, 8);
}

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
	        fprintf(stderr, "Unable to allocate DDName %s for dataset %s. dynalloc failed with rc: 0x%x\n", ddName, dsName, rc);
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
	DCBE_T inDCBE;
	DCB_T* outDCB;
	DCBE_T outDCBE;
	GETPList_T getparms;	
	PUTPList_T putparms;	
	DCBActive_T* inDCBActive;
	DCBActive_T* outDCBActive;
	void* readFP;
	char* getp;
	char* putp;
	int rc;
	unsigned int bytesRead; 
	PUTFlags_T flags = {0};
	GETFlags_T eod   = {0};

	OptInfo_T optInfo = {0};
	OpenType_T ddInOpenType = { 1, Disp, OpenInput, 0 };
	OpenType_T ddOutOpenType = { 1, Disp, OpenOutput, 0 };
	CloseType_T ddInCloseType = { 1, Disp, 0 };
	CloseType_T ddOutCloseType = { 1, Disp, 0 };

	if (argc < 3) {
		fprintf(stderr, "syntax: dcp <in> <out>\n");
		return 16;
	}
	in = argv[1];
	out = argv[2];

	/*
	 * DCB must be 24-bit, but DCBE can be 31-bit, so DCB is 24-bit heap-allocated
	 * and DCBE is stack-allocated
	 */
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

	rc = allocDDName(&optInfo, ddOut, out, &outDDInfo, 0, 0);
	if (rc) {
		return rc;
	}


	dcbinit(&inDDInfo, inDCB, &inDCBE, MACFMT_READ);
	rc = openDCB(ddInOpenType, &inDDInfo, inDCB);
	if (rc) {
		fprintf(stderr, "openDCB (input) failed with rc:0x%x\n", rc);
		return rc;
	}
	dcbinit(&outDDInfo, outDCB, &outDCBE, MACFMT_WRITE);
	rc = openDCB(ddOutOpenType, &outDDInfo, outDCB);
	if (rc) {
		fprintf(stderr, "openDCB (output) failed with rc:0x%x\n", rc);
		return rc;
	}

	inDCBActive = (DCBActive_T*) inDCB;
	outDCBActive = (DCBActive_T*) outDCB;
	getparms.buffer = readBuffer;
	getparms.dcb = inDCBActive;
	getparms.iortn = (void*) inDCBActive->iortn;
	getparms.eodp = &eod;
	putparms.buffer = readBuffer;
	putparms.dcb = outDCBActive;
	putparms.iortn = (void*) outDCBActive->iortn;
	putparms.flags = &flags;
	while (1) {
		GET(getparms);
		if (getparms.eodp->eod) {
			break;
		}
		bytesRead = inDCB->lrecl;
		if (bytesRead > 0) {
			printf("GET: %d %.*s\n", bytesRead, bytesRead, getparms.buffer);
		}
		PUT(putparms);  
	}

	rc = closeDCB(ddInCloseType, inDCB);
	if (rc) {
		fprintf(stderr, "closeDB (input) failed with rc:0x%x\n", rc);
		return rc;
	}
	rc = closeDCB(ddOutCloseType, outDCB);
	if (rc) {
		fprintf(stderr, "closeDB (output) failed with rc:0x%x\n", rc);
		return rc;
	}

	rc = freeDDName(&optInfo, ddIn, in, &freeDDInfo);
	if (rc) {
		fprintf(stderr, "freeDDName (input) failed with rc:0x%x\n", rc);
		return rc;
	}
	rc = freeDDName(&optInfo, ddOut, out, &freeDDInfo);
	if (rc) {
		fprintf(stderr, "freeDDName (output) failed with rc:0x%x\n", rc);
		return rc;
	}

	free(inDCB);
	free(outDCB);
	
	return 0;
}
