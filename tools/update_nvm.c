#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void usage(void)
{
	fprintf(stderr, "USAGE: update_nvm <input> [output]\n");
}

int main(int argc, char** argv)
{
	uint32_t word;
	uint16_t csum;
	int i;
	FILE *fin;
	FILE *fout=stdout;
	if(argc<2)
	{
		usage();
		return -1;
	}

	if(argc>2)
	{
		fout=fopen(argv[2],"w");
		if(fout==NULL)
		{
			fprintf(stderr, "Can not create file %s\n", argv[2]);
		}
	}

	if(argc>1)
	{
		fin=fopen(argv[1],"r");
		if(fin==NULL)
		{
			fprintf(stderr, "Can not create file %s\n", argv[1]);
		}
	}

	csum=0;
	while(fscanf(fin,"%x",&word)==1)
	{
		if(i==0x3f)
		{
			word = 0xBABA-csum;
		}
		else
		{
			csum+=word;
		}
		++i;

		fprintf(fout,"%04x\n", word);
	}
	fclose(fin);
	fclose(fout);
	return 0;
}
