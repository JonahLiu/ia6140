#include <stdio.h>
#include <stdlib.h>

void usage(void)
{
	fprintf(stderr, "genkey <key file> <input file> <output file>\n");
}

int main(int argc, char **argv)
{
	int i;
	FILE *fkey;
	FILE *fin;
	FILE *fout;
	unsigned char buf[8];
	unsigned char key[8];

	if(argc < 4)
	{
		usage();
		return -1;
	}

	fkey = fopen(argv[1], "rb");
	if(fkey==NULL)
	{
		fprintf(stderr, "Can not open %s\n", argv[1]);
	}

	fin = fopen(argv[2], "rb");
	if(fin==NULL)
	{
		fprintf(stderr, "Can not open %s\n", argv[2]);
	}

	fout = fopen(argv[3], "wb");
	if(fout==NULL)
	{
		fprintf(stderr, "Can not open %s\n", argv[3]);
	}

	fread(key, 1, 8, fkey);

	fread(buf, 1, 8, fin);

	for(i=0;i<8;i++)
	{
		buf[i] = buf[i]^key[i];
	}

	fwrite(buf, 1, 8, fout);

	return 0;
}
