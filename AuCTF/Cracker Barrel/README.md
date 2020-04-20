# Cracker Barrel
- Reversing

I found a USB drive under the checkers board at cracker barrel. My friends told me not to plug it in but surely nothing bad is on it?
I found this file, but I can't seem to unlock it's secrets. Can you help me out?
Also.. once you think you've got it I think you should try to connect to challenges.auctf.com at port 30000 not sure what that means, but it written on the flash drive..

## Solution
Loading the program up in Ghidra, I see main calls a function `check` and inside there it will call `check_1`, `check_2`, and `check_3`. If
all checks pass it will print the flag.

### Check_1
```C++
undefined8 check_1(char *param_1)

{
  int iVar1;
  undefined8 uVar2;
  
  iVar1 = strcmp(param_1,"starwars");
  if (iVar1 == 0) {
    iVar1 = strcmp(param_1,"startrek");
    if (iVar1 == 0) {
      uVar2 = 0;
    }
    else {
      uVar2 = 1;
    }
  }
  else {
    uVar2 = 0;
  }
  return uVar2;
}
```
We can see that it compares the argument string with starwars. So, starwars is the answer to the first check.

### Check_2
```C++
ulong check_2(char *param_1)

{
  int iVar1;
  size_t sVar2;
  char *__s1;
  int counter;
  
  sVar2 = strlen(param_1);
  iVar1 = (int)sVar2;
  __s1 = (char *)malloc((long)(iVar1 + 1) << 3);
  counter = 0;
  while (counter < iVar1) {
    __s1[counter] = "si siht egassem terces"[(iVar1 + -1) - counter];
    counter = counter + 1;
  }
  iVar1 = strcmp(__s1,param_1);
  return (ulong)(iVar1 == 0);
}
```
Check_2 is reversing `"si siht egassem terces"` which comes out to `secret message this is`, but we can skip this check entirely.
The variable `__s1` is begin allocated to the length determined by the length of the argument string supplied. If we supplied an empty string
`__s1` would equal an empty string and we would skip the while loop. The comparison would pass because `__s1` was never modified by the loop.

### Check_3
```C++
ulong check_3(char *param_1)

{
  bool bVar1;
  size_t sVar2;
  void *pvVar3;
  long in_FS_OFFSET;
  int local_5c;
  int local_54;
  int local_48 [4];
  undefined4 local_38;
  undefined4 local_34;
  undefined4 local_30;
  undefined4 local_2c;
  undefined4 local_28;
  undefined4 local_24;
  long local_20;
  
  local_20 = *(long *)(in_FS_OFFSET + 0x28);
  local_48[0] = 0x7a;
  local_48[1] = 0x21;
  local_48[2] = 0x21;
  local_48[3] = 0x62;
  local_38 = 0x36;
  local_34 = 0x7e;
  local_30 = 0x77;
  local_2c = 0x6e;
  local_28 = 0x26;
  local_24 = 0x60;
  sVar2 = strlen(param_1);
  pvVar3 = malloc(sVar2 << 2);
  local_5c = 0;
  while (sVar2 = strlen(param_1), (ulong)(long)local_5c < sVar2) {
    *(uint *)((long)pvVar3 + (long)local_5c * 4) = (int)param_1[local_5c] + 2U ^ 0x14;
    local_5c = local_5c + 1;
  }
  bVar1 = false;
  local_54 = 0;
  while (sVar2 = strlen(param_1), (ulong)(long)local_54 < sVar2) {
    if (*(int *)((long)pvVar3 + (long)local_54 * 4) != local_48[local_54]) {
      bVar1 = true;
    }
    local_54 = local_54 + 1;
  }
  if (local_20 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return (ulong)!bVar1;
}
```
Looking at this check, we can see it makes the same mistake and allocates memory for the string based off the length of the argument string.
Our answer for both `check_2` and `check_3` is `\n`.

## Flag
`auctf{w3lc0m3_to_R3_1021}`
