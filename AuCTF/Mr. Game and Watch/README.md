# Mr. Game and Watch
- Reversing

My friend is learning some wacky new interpreted language and different hashing algorithms. He's hidden a flag inside this program 
but I cant find it... He told me to connect to challenges.auctf.com 30001 once I figured it out though.

## Solution
Given a Java class file, I loaded it into jd-gui to get a decompilation. The main function printed a few lines and then called
`crackme` and if the function returned true it would print the flag. Inspecting `crackme`, I noticed it called three separate check functions.

### crack_1
```Java
private static boolean crack_1(Scanner paramScanner) {
  System.out.println("Let's try some hash cracking!! I'll go easy on you the first time. The first hash we are checking is this");

  System.out.println("\t" + secret_1);
  System.out.print("Think you can crack it? If so give me the value that hashes to that!\n\t");

  String str1 = paramScanner.nextLine();

  String str2 = hash(str1, "MD5");

  return (str2.compareTo(secret_1) == 0);
}
```
`secret_1 = "d5c67e2fc5f5f155dff8da4bdc914f41";`

The function first prints `secret_1`, which is the MD5 hash of the answer, obtains the user's input, hashes it, and then checks
it against `secret_1`. Plugging `secret_1` into an online hash cracker ([crackstation.com](https://crackstation.net/)), we get `masterchief` as the answer.

### crack_2
```Java
private static boolean crack_2(Scanner paramScanner) {
  System.out.println("Nice work! One down, two to go ...");

  System.out.print("This next one you don't get to see, if you aren't already digging into the class file you may wanna try that out!\n\t");

  String str = paramScanner.nextLine();
  return (hash(str, "SHA1").compareTo(decrypt(secret_2, key_2)) == 0);
}
```
This function is hashing the user input with SHA1 and then comparing it to the decryption of `secret_2` with `key_2`. `secret_2` is an
array of bytes and `key_2` is equal to 64. Looking at the decrypt function, it appears that the decompilation of it is off because all
it does is return an empty string.
```Java
private static String decrypt(int[] paramArrayOfInt, int paramInt) {
  String str = "";
  for (byte b = 0; b < paramArrayOfInt.length; b++) {
    str = str + str;
  }
  return str;
}
```
I'm assuming since `crack_2` is calling `decrypt` that it must've used their `encrypt` function to create the hash in the first place.
Looking at `encrypt`, all it does is xor every byte with the `paramInt` which is the key. Since we know the key, we can decrypt
using the same method of xoring every byte with the key.
```Java
private static int[] encrypt(String paramString, int paramInt) {
  int[] arrayOfInt = new int[paramString.length()];

  for (byte b = 0; b < paramString.length(); b++) {
    arrayOfInt[b] = paramString.charAt(b) ^ paramInt;
}
 ```
 After doing this to `secret_2` we get `264212deff89ade15661a59e7b632872d858f2c6` and plugging the hash into an online hash cracker
 we get `princesspeach`.
 
 ### crack_3
 ```Java
 private static boolean crack_3(Scanner paramScanner) {
  System.out.print("Nice work! Here's the last one...\n\t");
  String str1 = paramScanner.nextLine();

  String str2 = hash(str1, "SHA-256");
  int[] arrayOfInt = encrypt(str2, key_3);
  return Arrays.equals(arrayOfInt, secret_3);
}
```
Here the function is taking the user's string and using their `encrypt` function on it with `key_3` and checking it against `secret_3`.
We know that `secret_3` is the hash of the correct input string encrypted with `key_3`; because of this we can use the same method from `crack_2` 
to obtain the hash. The decrypted `secret_3` is equal to `5ebb49e499a6613e832e433a2722edd0d2947d56fdb4d684af0f06c631fdf633` and the hash
is equal to `solidsnake`.

## Flag
`auctf{If_u_h8_JAVA_and_@SM_try_c_sharp_2922}`
