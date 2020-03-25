# monKEYprito
- Crypto
- 492 Points (23 Solves)

## Solution
You were given ` monkey.zip ` and after unzipping revealed ` MoNkEy_CRYptor.py ` and ` you_was_monkeyd.enc `

At first glance, ` MoNkEy_CRYptor.py ` seemed relatively simple. There were only two functions, one of which, generated a string 
and the other encrypted ` monkey.zip ` using the generated string.

Taking a peak at the first function ` get_troll_string() ` we see that it is multiplying ` troll_string ` with the value of the first 
two bytes from ` monkey.zip ` (important later) and returning the newly generated string. 
```
def get_troll_string():
	troll_string = "MmMmMmMmoOoOoOOoOOonnnNnNNnkkKkKkKkKkkkekeekEKkekekEYyYyyYyyYYYYYYYYYY!!!!!!!!!!!!222@@@@@@2XDDDDDDDD"

	with open("Monkeyd_ziped.zip", 'rb') as file:
		run = 0
		for byte in file.read():
			if(run==2):
				break
			troll_string += troll_string*ord(byte)
			run+=1
	return troll_string
```
` monkeyd() ` takes the troll string as an argument, encrypts ` monkey.zip `, and returns the ` you_was_monkeyd.enc ` file. So we 
know that you_was_monkeyd is the file we are trying to decrypt into ` monkey.zip ` and should contain two files, one the flag and the 
other a PNG file.
```
def monkeyd(monkey_troll_string):
	array = []
	rainbow = 1
	with open("Monkeyd_ziped.zip", 'rb') as file:
		for byte in file.read():
			array.append(hex((ord(byte)+ord(monkey_troll_string[(rainbow-1)%(len(monkey_troll_string)-1)])+rainbow%256)%256))
			rainbow+=1

	with open('you_was_monkeyd.enc', 'wb') as output:
		output.write(bytearray(int(i, 16) for i in array))
```
It loops through each byte of the zip file and uses this line to encrypt:
``` 
array.append(hex((ord(byte)+ord(monkey_troll_string[(rainbow-1)%(len(monkey_troll_string)-1)])+rainbow%256)%256)) 
```
Breaking it out for easier reading:
```
hex(
  (ord(byte) +
  ord(monkey_troll_string)[ (rainbow-1) % (len(monkey_troll_string)-1)] +
  rainbow % 256) % 256
)
```
So, to complete the challenge I must take ` you_was_monkeyd.enc ` and do the reverse of this line on every byte. Easy! 

I began by first attempting to generate the same string which was originally used to encrypt. I basically just copied their function
but changed it to open ` you_was_monkeyd.enc ` instead (this was wrong and I will get into why). One variable down! 

Looking at ` rainbow ` it appeared to just be a counter variable but beginning at 1. ` you_was_monkeyd.enc ` and 
` monkey.zip ` would have the same number of bytes so ` rainbow ` can stay as it is. Now onto the tricky part...

Only variable left to figure out is ` byte `. First, I changed the formula into something easier to understand with simple variables:
```
(a + b + c % 256) % 256 = d #encrypted_byte
```
So now we just have to isolate ` a `. I wasn't sure how I was going to reverse the modulus so I started my search going to Google and 
quickly came across a helpful StackOverflow [question](https://stackoverflow.com/questions/10133194/reverse-modulus-operator). Simple
answer- you don't have to do anything!
```
a = (d - (b + c)) % 256
b = ord(monkey_troll_string[ (rainbow-1) % (len(monkey_troll_string)-1) ])
unencrypted_byte = (encrypted_byte - (b + rainbow)) % 256
```
So our decode script looks like this now:
```
with open("you_was_monkeyd.enc", "rb") as encrypt:
    data = encrypt.read()

def get_troll_string():
    troll_string = "MmMmMmMmoOoOoOOoOOonnnNnNNnkkKkKkKkKkkkekeekEKkekekEYyYyyYyyYYYYYYYYYY!!!!!!!!!!!!222@@@@@@2XDDDDDDDD"
    for x in range(2): #This is still wrong!
        troll_string += troll_string * ord(x)
    return troll_string

def unmonkeyed(monkey_troll_string):
    array = bytearray() 
    rainbow = 1
    for encrypted_byte in data:
        b = ord(monkey_troll_string[(rainbow-1) % (len(monkey_troll_string)-1)])
        decrypted_byte = (encrypted_byte - (b + rainbow)) % 256 
        array.append(decrypted_byte)
        rainbow += 1
        break

    return array
```
I did a quick hexdump of the first few decoded bytes to see if I was on the right track and was happy to see that the first bytes 
were the proper header of a zip file! Just had to decrypt the rest and write them to a file, or so I thought...

I tried outputting the decrypted bytes and unziping the file, but to my surprise, got an error saying my zip file was corrupt :(
After hours of frustration, I finally realized the problem was with my ` troll_string `. I was multiplying the string by the value of
the encrypted bytes. Easy fix because it was only the first two bytes and I knew they had to be the values of the zip file header ` PK `.

Final script:
```
#import binascii
import zipfile
import io
#from hexdump import hexdump

with open("you_was_monkeyd.enc", "rb") as encrypt:
    data = encrypt.read()

def get_troll_string():
    troll_string = "MmMmMmMmoOoOoOOoOOonnnNnNNnkkKkKkKkKkkkekeekEKkekekEYyYyyYyyYYYYYYYYYY!!!!!!!!!!!!222@@@@@@2XDDDDDDDD"
    for x in 'PK':
        troll_string += troll_string * ord(x)
    return troll_string

def unmonkeyed(monkey_troll_string):
    array = bytearray() 
    rainbow = 1
    for encrypted_byte in data:
        b = ord(monkey_troll_string[(rainbow-1) % (len(monkey_troll_string)-1)])
        decrypted_byte = (encrypted_byte - (b + rainbow)) % 256 
        array.append(decrypted_byte)
        rainbow += 1
        break

    return array

if __name__ == "__main__":
    flag = unmonkeyed(get_troll_string())
    #Test to see if it is a valid zip file
    zf = zipfile.ZipFile(io.BytesIO(flag), 'r', zipfile.ZIP_DEFLATED)

    with open("monkey.zip", "wb") as output:
        output.write(flag)
```
Flag:
```
F#{SPAM_THE_4w3s0m3_m0nk3y_EVERYWHERE}
```
