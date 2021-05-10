#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

int main(int argc, char** argv)

{
   char *buf1;
   char *buf2;
   char *buf3;  

   buf1=(char*)malloc(292);
   memset(buf1, 0, 292);
   buf2=(char*)malloc(292);
   memset(buf2, 0, 292);               /*Created four buffers at 512 bytes each and memset the mem...*/
   buf3=(char*)malloc(292);
   memset(buf3, 0, 292);

   if (argc !=2){
     printf("Usage: ./heap3 <Enter a string to copy into memory.>\n");
     exit(1);}

   strcpy(buf1,argv[1]);
   printf("Thanks!");
   free(buf2);
   exit(0);
}
