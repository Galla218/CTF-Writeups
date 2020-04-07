# Sora
- Reversing

This obnoxious kid with spiky hair keeps telling me his key can open all doors. Can you generate a key to open this 
program before he does?

## Solution
Loaded the file into Ghidra and began inspecting `main`. The disassembly looked like so:
```Ruby
ulong main(void)

{
  int extraout_EAX;
  int __edflag;
  long in_FS_OFFSET;
  char local_38 [40];
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  setvbuf(stdout,(char *)0x0,2,0);
  puts("Give me a key!");
  __edflag = 0x1e;
  fgets(local_38,0x1e,stdin);
  encrypt(local_38,__edflag);
  if (extraout_EAX == 0) {
    puts("That\'s not it!");
  }
  else {
    print_flag();
  }
  if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return (ulong)(extraout_EAX == 0);
}
```
We can see that it first retrieves a string from the user and then calls `encrypt` on the given input and if the encrypt function does not return `0` it will print the flag. 

Looking into `encrypt`, it was a while loop which would do some character comparisons with characters from a variable called `secret`.
```Ruby
void encrypt(char *__block,int __edflag)

{
  size_t sVar1;
  int local_20;
  
  local_20 = 0;
  while ((sVar1 = strlen(secret), (ulong)(long)local_20 < sVar1 &&
         (((int)__block[local_20] * 8 + 0x13) % 0x3d + 0x41 == (int)(char)secret[local_20]))) {
    local_20 = local_20 + 1;
  }
  return;
}
```
`secret` was equal to `aQLpavpKQcCVpfcg`

We can simply brute force finding a key by iterating through each character of `secret` and applying the same mathematical operations of `encrypt` to a random ascii character and seeing if it matches the current character from `secret`. I created a simple loop in Python which looked like the following
```Ruby
secret = "aQLpavpKQcCVpfcg"
decrypted = ""
for y in secret:
    for x in range(128):  #ascii character range 0-127
        c = ((x * 8) + 19) % 61 + 65
        if chr(c) == y:
            decrypted += chr(x)
            break

print(decrypted)
```
Our key is `75<"72"%5($."0(` and after giving it to the program we get the flag `auctf{that_w@s_2_ezy_29302}`. Interesting to note if you set the loop to only check human readable characters then the key would come out to `try_to_break_meG`

## Flag
`auctf{that_w@s_2_ezy_29302}`
