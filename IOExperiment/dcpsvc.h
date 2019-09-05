#ifndef __IO_SVC__
	#define __IO_SVC__

extern int EOD;
#pragma variable(EOD, NORENT)

typedef _Packed struct {
	unsigned int last:1;
	unsigned int action:3;
	unsigned int mode:4;
	unsigned int pad:24;
} OpenType_T;

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
	unsigned int eod:1;
	unsigned int reserved:31;
} READFlags_T;

typedef _Packed struct {
	char* buffer;
	void* dcb;
	void* iortn;
	READFlags_T* eodp;
} READPList_T;	

int SVC19(SVC19PList_T r0);
int SVC20(SVC20PList_T r0);
void READ(READPList_T plist);

#endif
