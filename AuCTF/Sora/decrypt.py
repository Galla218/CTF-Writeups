
secret = "aQLpavpKQcCVpfcg"
decrypted = ""
for y in secret:
    for x in "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890":
    #for x in range(128):
        c = ((ord(x) * 8) + 19) % 61 + 65
        if chr(c) == y:
            decrypted += x
            break

print(decrypted)
