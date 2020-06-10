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
        b = ord(monkey_troll_string[(rainbow-1) % (len(monkey_troll_string)-1)])
        x = (byte - (b + rainbow)) % 256 
        array.append(x)
        rainbow += 1

    return array

if __name__ == "__main__":
    flag = unmonkeyed(get_troll_string())
    zf = zipfile.ZipFile(io.BytesIO(flag), 'r', zipfile.ZIP_DEFLATED)
    with open("Flag.zip", "wb") as output:
        output.write(flag)
