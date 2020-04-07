
secret = "aQLpavpKQcCVpfcg"
decrypted = ""
for y in secret:
    #for x in "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890":
    for x in range(127):
        c = ((x * 8) + 19) % 61 + 65
        if chr(c) == y:
            decrypted += chr(x)
            break

print(decrypted)
