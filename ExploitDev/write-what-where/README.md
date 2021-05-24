# Write-What-Where
This writeup is for the purpose of my understanding of the write-what-where exploit abusing the lack of checks in the `unlink` function for earlier linux kernel versions 
using `dlmalloc`. This is performed with ASLR off.

## Dynamic Memory
When you call functions like `malloc` or `calloc`, you are dynamically creating chunks of memory on the heap. Standard function calls will utilize the stack because the variables
will only last within the scope of the function and can be torn down afterwards. Dynamically creating memory allows for the data to persist longer and allow the programmer or
garbage collector to free the memory when the program no longer requires it.

## dlmalloc()
Doug Lea's malloc is one such memory allocator and includes `malloc`, `calloc`, `realloc`, `free`, and other utility functions. The structure for a chunk of allocated memory is
diagramed below. An in-use chunk of memory contains a `Previous Size` field of 4 bytes and a `Size` field of 4 bytes. The `Prev_Size` field will contain the value 0 until the
adjacent chunk, lower in memory, is freed and no longer in use. The field will then contain the size of the adjacent chunk. The `Size` field will contain the size of the `Data` field. A free chunk will contain the `Prev_Size` and `Size` field along with a `Forward Pointer` and `Backward Pointer`. 

```
   Chunk in use                             Free chunk
------------------                       ------------------
:    Prev_Size   : 4 bytes               :   Prev_Size    : 4 bytes
:----------------:                       :----------------:
:      Size      : 4 bytes               :      Size      : 4 bytes
:----------------:                       :----------------:
:      Data      : variable in size      :     FD_Ptr     : 4 bytes
:                :                       :----------------:
:                :                       :     BK_Ptr     : 4 bytes
:                :                       :----------------:
:                :                       :    Old_Data    : variable in size
:                :                       :                :
------------------                       ------------------
```
Free chunks create a doubly linked list connecting all the free chunks together. When a chunk goes into use it unlinks itself from the list, or vice versa. More on this later.

`Size` will pad itself out to the next double word boundary so that it controlls the 3 least significant bits which will act as flags. The bit we are interested in is the least significant bit, which will contain the `Previous in Use` flag. When free is called on a chunk of memory, it will check the `P` flag for a 1 or a 0. If the bit is set to 1, it knows the adjacent chunk is in use. If 0, it knows the chunk is free. The heap does not allow two adjacent chunks to both be free. So if free is called on chunk1, it will see that chunk1's `P` bit is set and will merge chunk1 and chunk2 together. Keep in mind also that chunk1's `Prev_Size` field contains the size of chunk2 because chunk2
was freed and no longer in use.
```
                             Chunk 1                                                 Chunk 2 (Not in use)
-------------------------------------------------------------  -------------------------------------------------------------
:      Prev_Size      :   Size   |A|M|P|:       Data        :  : Prev_Size : Size |A|M|P|:  FD_Ptr  :  BK_Ptr  :  Old_Data :   
-------------------------------------------------------------  -------------------------------------------------------------
```
## What's the problem?
As mentioned earlier, when a chunk is freed from memory it gets put into a doubly linked list containing all the other free chunks. The chunks are inserted and removed from the linked list using `frontlink()` and `unlink()`. When `unlink()` is called it updates the adjacent free chunks forward pointer and backward pointer to update the linked list so that the chunks are no longer pointing to the chunk which just got put into use.
```
#define unlink(P, BK, FD) {
	FD = P->fd;
	BK = P->bk;
	FD->bk = BK;
	BK-fd = FD;
}

```
The issue is the last two lines where unlink goes to `FD` (forward adjacent chunk) and `BK` (backward adjacent chunk) and updates their pointers with `P`'s pointers. Unlink is not checking to make sure the pointers that `P` holds actually belong to `P`. What happens if you can overwrite a chunk which gets freed with your own forward and backward pointers?
## Exploit
Without looking at the source code of our vulnerable program, we can run `objdump -R` on it to see the functions from shared libraries that are loaded.
```
ubuntu@ubuntu:~$ objdump -R ./vuln

./vuln:     file format elf32-i386

DYNAMIC RELOCATION RECORDS
OFFSET   TYPE              VALUE 
080496d4 R_386_GLOB_DAT    __gmon_start__
080496b8 R_386_JUMP_SLOT   malloc@GLIBC_2.0
080496bc R_386_JUMP_SLOT   __libc_start_main@GLIBC_2.0
080496c0 R_386_JUMP_SLOT   printf@GLIBC_2.0
080496c4 R_386_JUMP_SLOT   exit@GLIBC_2.0
080496c8 R_386_JUMP_SLOT   free@GLIBC_2.0
080496cc R_386_JUMP_SLOT   memset@GLIBC_2.0
080496d0 R_386_JUMP_SLOT   strcpy@GLIBC_2.0
```
We can see that `malloc` and `strcpy` are both loaded. Running `ltrace` we can see the addresses of where `malloc` is being called and how large the allocations are. Keep in mind ASLR is turned off.
```
ubuntu@ubuntu:~$ ltrace 2>&1 ./vuln | grep malloc
malloc(300)                                      = 0x804a008
malloc(300)                                      = 0x804a138
malloc(300)                                      = 0x804a268
```
Let's run the program and see if we can get it to crash. We know the allocations are 300 bytes so lets try something larger than 300.
```
ubuntu@ubuntu:~$ ./vuln
Usage: ./vuln <Enter a string to copy into memory.>
ubuntu@ubuntu:~$ ./vuln AAAAAAAAAA
Thanks!
ubuntu@ubuntu:~$ ./vuln `python -c 'print("A" * 350)'`
Segmentation fault (core dumped)
```
Now that we know we can get the program to segfault, lets throw it into gdb and start debugging. 
