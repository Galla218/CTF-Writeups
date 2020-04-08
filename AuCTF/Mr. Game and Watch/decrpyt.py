import binascii

secret2 = [114, 118, 116, 114, 113, 114, 36, 37, 38, 38, 120, 121, 33, 36, 37, 113, 117, 118, 118, 113, 33, 117, 121, 37, 119, 34, 118, 115, 114, 120, 119, 114, 36, 120, 117, 120, 38, 114, 35, 118]
secret3 = [268, 348, 347, 347, 269, 256, 348, 269, 256, 256, 344, 271, 271, 264, 266, 348, 257, 266, 267, 348, 269, 266, 266, 344, 267, 270, 267, 267, 348, 349, 349, 265, 349, 267, 256, 269, 270, 349, 268, 271, 351, 349, 347, 269, 349, 271, 257, 269, 344, 351, 265, 351, 265, 271, 346, 271, 266, 264, 351, 349, 351, 271, 266, 266]

key2 = 64
key3 = 313

def decrypt_str(secret, key):
    decrypted = []
    for x in secret:
        decrypted.append(x ^ key)
    return decrypted

decrypt_key = bytes(decrypt_str(secret2, key2))
print(decrypt_key)

decrypt_key = bytes(decrypt_str(secret3, key3))
print(decrypt_key)
