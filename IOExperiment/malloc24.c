#include "malloc24.h"

#define AMODE 31


#if AMODE==31
	#include <leawi.h>
	#include <memory.h>

	static int malloc24heapid=0;

	#ifndef _FBCHECK
		#define _FBCHECK(fc, token) \
			 ( memcmp(&(fc).tok_msgno, &((token)[2]),2) \
				&& memcmp((fc).tok_facid, &((token)[5]),3))
		#define    CEE000      "\x00\x00\x00\x00\x00\x00\x00\x00"
	#endif

	void* malloc24_from31bit(_INT4* heap_id, _INT4 size) {
		_INT4 increment = 0;
		_INT4 options = 73; /* below the line heap */
		_FEEDBACK fc;
		_POINTER stg;

		if (*heap_id == 0) {
			CEECRHP(heap_id, &size, &increment, &options, &fc);
			if (_FBCHECK(fc, CEE000) != 0) {
				return NULL;
			}
		}

		CEEGTST(heap_id, &size, &stg, &fc);
		if (_FBCHECK(fc, CEE000) != 0) {
			return NULL;
		}

		return stg;
	}

	void free24_from31bit(_POINTER ptr) {
		_FEEDBACK fc;
		CEEFRST(&ptr, &fc);
		if (_FBCHECK(fc, CEE000) != 0) {
			; /* internal error */
		}
	}
	void* malloc24(size_t bytes) {
		return malloc24_from31bit(&malloc24heapid, bytes);
	}
	int free24(void* ptr) {
		return 0;
	}
#else 
	void* malloc24(size_t bytes) {
		return __malloc24(bytes);
	}
	int free24(void* ptr) {
		return free(ptr);
	}
#endif
