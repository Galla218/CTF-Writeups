# 0xDiablos
- Pwn
- 20 Points

## Solution
Being able to run the program was the first problem. Attempting to run returned this error

```Bash
bash: ./vuln: No such file or directory
```
Issue was because the file was 32 bit and I'm attempting to run it on a 64 bit machine. Fix was to install dependencies for 32 bit.
```Bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386
```
Running the program now opens a prompt expecting some input from us.
```Bash
ubuntu@ubuntu:~$ ./vuln
You know who are 0xDiablos:
 
```

Opening up the binary in ghidra we can quickly find the main function and within main the function `vuln` is called. Vuln simply gets user input and does a puts. We can easily see the vulnerability is a buffer overflow because there are no checks to make sure the buffer `local_bc` is not given an input larger than 180.

```C
void vuln(void)

{
  char local_bc [180];
  
  gets(local_bc);
  puts(local_bc);
  return;
}
```
There is another function called `flag` which will print out `flag.txt` if some parameters are set.
```C
void flag(int param_1,int param_2)

{
  char local_50 [64];
  FILE *local_10;
  
  local_10 = fopen("flag.txt","r");
  if (local_10 != (FILE *)0x0) {
    fgets(local_50,0x40,local_10);
    if ((param_1 == -0x21524111) && (param_2 == -0x3f212ff3)) {
      printf(local_50);
    }
    return;
  }
  puts("Hurry up and try in on server side.");
                    /* WARNING: Subroutine does not return */
  exit(0);
}
```

So we need to overwrite the buffer to change the execution flow to the flag function and then also change some parameters to the ones needed to print the file. I used [peda](https://github.com/longld/peda), a nice addon for gdb, to debug the program and test/create the framework for my exploit. First step was to validate the buffer overflow and make the program crash. In vuln it is expecting input no larger than 180 so lets start by inputing 190.

```Bash
ubuntu@ubuntu:~$ (python -c "print('A' * 190)") | ./vuln
You know who are 0xDiablos
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Segmentation fault (core dumped)
```

As expected the program crashed with a seg fault. Now lets begin debugging in gdb.
```Bash
ubuntu@ubuntu:~$ gdb ./vuln
