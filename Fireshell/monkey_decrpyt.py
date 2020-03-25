import binascii
import zipfile
import io
from hexdump import hexdump

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
    for byte in data:
        print(byte)
        b = ord(monkey_troll_string[(rainbow-1) % (len(monkey_troll_string)-1)])
        x = (byte - (b + rainbow)) % 256 
        array.append(x)
        rainbow += 1
        break

    return array

png_magic = binascii.unhexlify("89504E470D0A1A0A")
png_end = binascii.unhexlify("49454E44AE426082")
png_idat = binascii.unhexlify("49444154")

flag = unmonkeyed(get_troll_string())

#with open("Flag.zip", "wb") as output:
#    output.write(flag)

'''loc_start = flag.find(png_magic)
loc_idat = flag.find(png_idat)
loc_end = flag.find(png_end)
print(loc_start, loc_idat, loc_end)
print("Done!")'''

#zf = zipfile.ZipFile(io.BytesIO(flag), 'r', zipfile.ZIP_DEFLATED)
