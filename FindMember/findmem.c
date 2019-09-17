#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
int findMember(char* ddname, char* member) {
	FILE* fp;
	fldata_t fld;
	char dsname[44+3+1];
	char fmem[8+8+5+1];
	int rc;

	if (strlen(ddname) > 8) {
		fprintf(stderr, "DDName %s is invalid\n", ddname);
		return 4;
	}
	if (strlen(member) > 8) {
		fprintf(stderr, "Member %s is invalid\n", member);
		return 4;
	}
	sprintf(fmem, "dd:%s(%s)", ddname, member);
	fp = fopen(fmem, "rb");
	if (!fp) {
		return 4;
	}
	rc = fldata(fp, dsname, &fld); 
	if (rc) {
		return rc;
	}
	rc = fclose(fp);
	if (rc) {
		return rc;
	}
	printf("%s\n", fld.__dsname);
	return 0;
}

int main(int argc, char* argv[]) {
	char ddname[] = "PDSCONC";
	char* member;
	char* cds;
	int rc;

	if (argc != 2) {
		fprintf(stderr, "syntax: findmem <member>\n");
		return 4;
	}
	member = argv[1];
	rc = findMember(ddname, member);
	if (rc) {
		fprintf(stderr, "Unable to find member %s in concatentated dataset list for %s\n", member, ddname);
		return rc;
	}
	return 0;
}
