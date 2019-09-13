#include <dynit.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include "malloc24.h"
#include "dcb.h"
#include "dcpsvc.h"
#include <signal.h>

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

static int allocDDName(OptInfo_T* optInfo, const char* type, char* ddName, char* dsName, __dyn_t* ip, int isExclusive, int isModify) {
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
	        fprintf(stderr, "Unable to open %s dataset %s\n", type, dsName);
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
		fprintf(stderr, "Unable to close dataset %s\n", dsName);
	}
	return rc;
}

static char* curstate = NULL;
static char* curds = NULL;

void openfailure(int val) {
	fprintf(stderr, "(ABEND 0x%x) Unable to open %s dataset %s\n", val, curstate, curds);
	exit(0);
}

int main(int argc, char* argv[]) {
	char getBuffer[65536];
	char putBuffer[65536];
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
	int shareBuffer;
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
	if (strchr(in, '(')) {
		fprintf(stderr, "No support for copy of PDS(E) member as source\n");
		return 4;
	}
	if (strchr(out, '(')) {
		fprintf(stderr, "No support for copy of PDS(E) member as target\n");
		return 4;
	}
	if (strchr(in, '/')) {
		fprintf(stderr, "No support for copy of HFS file as source\n");
		return 4;
	}
	if (strchr(out, '/')) {
		fprintf(stderr, "No support for copy of HFS file as target\n");
		return 4;
	}
	if (strlen(in) > 44) {
		fprintf(stderr, "Dataset maximum length is 44. Source name is too long\n");
		return 8;
	}
	if (strlen(out) > 44) {
		fprintf(stderr, "Dataset maximum length is 44. Target name is too long\n");
		return 8;
	}

	/*
	 * DCB must be 24-bit, but DCBE can be 31-bit, so DCB is 24-bit heap-allocated
	 * and DCBE is stack-allocated
	 */
	inDCB = malloc24(sizeof(DCB_T));
	outDCB = malloc24(sizeof(DCB_T));
	if (!inDCB || !outDCB) {
		fprintf(stderr, "Internal Error: unable to allocate storage below the line for I/O\n");
		return 16;
	}

	curstate = "source";
	curds = in;
	rc = allocDDName(&optInfo, curstate, ddIn, in, &inDDInfo, 0, 0);
	if (rc) {
		return rc;
	}
	dcbinit(&inDDInfo, inDCB, &inDCBE, MACFMT_READ);
#if 0
	if (signal(SIGABND, openfailure) == SIG_ERR) {
		perror("Internal Error: could not establish signal handler");
		abort();
	}
#endif
	rc = openDCB(ddInOpenType, &inDDInfo, inDCB);
	if (rc) {
		fprintf(stderr, "Unable to open source dataset %s\n", in);
		return rc;
	}

	curstate = "target";
	curds = out;
	rc = allocDDName(&optInfo, curstate, ddOut, out, &outDDInfo, 0, 0);
	if (rc) {
		return rc;
	}
	dcbinit(&outDDInfo, outDCB, &outDCBE, MACFMT_WRITE);
	rc = openDCB(ddOutOpenType, &outDDInfo, outDCB);
	if (rc) {
		fprintf(stderr, "Unable to open target dataset %s\n", in);
		return rc;
	}

	inDCBActive = (DCBActive_T*) inDCB;
	outDCBActive = (DCBActive_T*) outDCB;

	printf("input recfm: 0x%x lrecl: %d\n", inDCBActive->recfm, inDCBActive->lrecl);
	printf("output recfm: 0x%x lrecl: %d\n", outDCBActive->recfm, outDCBActive->lrecl);

	getparms.buffer = getBuffer;
	getparms.dcb = inDCBActive;
	getparms.iortn = (void*) inDCBActive->iortn;
	getparms.eodp = &eod;

	if (inDCBActive->recfm == outDCBActive->recfm && inDCBActive->lrecl == outDCBActive->lrecl) {
		putparms.buffer = getBuffer;
		shareBuffer = 1;
	} else {
		putparms.buffer = putBuffer;
		shareBuffer = 0;
	}
		
	putparms.dcb = outDCBActive;
	putparms.iortn = (void*) outDCBActive->iortn;
	putparms.flags = &flags;
	while (1) {
		GET(getparms);
		if (getparms.eodp->eod) {
			break;
		}
				
		if (!shareBuffer) {
			unsigned int bytesToWrite = outDCBActive->lrecl;
			unsigned int bytesRead; 
			char* inp;
			char* outp; 
			if ((inDCBActive->recfm & DCB_VB) == DCB_VB) {	
				bytesRead = *((unsigned short*) getBuffer);
printf("input is vb\n");
printf("record length: 0x%x\n", bytesRead);
				inp = &getBuffer[4];
				bytesRead -= 4;
			} else {
				inp = getBuffer;
				bytesRead = inDCBActive->lrecl;
			} 
			if ((outDCBActive->recfm & DCB_VB) == DCB_VB) {
printf("output is vb\n");
				if (bytesRead < bytesToWrite-4) {
					bytesToWrite = bytesRead+4;
				}
				outp = &putBuffer[4];
				*((unsigned int*) (putBuffer)) = 0;
				*((unsigned short*) (putBuffer)) = bytesToWrite;
				outDCBActive->lrecl = bytesToWrite;
				bytesToWrite -= 4;
			} else {
				outp = putBuffer;
				bytesToWrite = outDCBActive->lrecl;
			}
printf("bytes read:%d bytes-to-write:%d\n", bytesRead, bytesToWrite);
			if (bytesRead > bytesToWrite) {
printf("A) copy %d bytes\n", bytesToWrite);
				memcpy(outp, inp, bytesToWrite);
			} else if (bytesRead < bytesToWrite) {
printf("B) copy %d bytes\n", bytesRead);
				memcpy(outp, inp, bytesRead);
				memset(&outp[bytesRead], ' ', bytesToWrite-bytesRead);
			} else {
printf("C) copy %d bytes\n", bytesRead);
				memcpy(outp, inp, bytesRead);
			}
		}
		PUT(putparms);  
	}

	rc = closeDCB(ddInCloseType, inDCB);
	if (rc) {
		fprintf(stderr, "Unable to close source dataset %s after copy\n", in);
		return rc;
	}
	rc = closeDCB(ddOutCloseType, outDCB);
	if (rc) {
		fprintf(stderr, "Unable to close target dataset %s after copy\n", out);
		return rc;
	}

	rc = freeDDName(&optInfo, ddIn, in, &freeDDInfo);
	if (rc) {
		fprintf(stderr, "Unable to free source dataset %s after copy\n", in);
		return rc;
	}
	rc = freeDDName(&optInfo, ddOut, out, &freeDDInfo);
	if (rc) {
		fprintf(stderr, "Unable to free target dataset %s after copy\n", out);
		return rc;
	}

	free(inDCB);
	free(outDCB);
	
	return 0;
}
