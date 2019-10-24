#include "conv.h"
#include <stdio.h>

int main() {
	int c;
	while ((c = getchar()) >= 0) {	
		putchar(ebcdic[c]);
	}
}
