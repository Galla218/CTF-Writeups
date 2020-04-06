def func1():
    var1 = 25
    var2 = 0

    while(var2 <= 9):
        var1 += (((var2 + 10) << 2) + (var2 + 10)) + ((((var2 + 10) << 2) + (var2 + 10)) * 4) 
        var1 = var1 & 0xff
        var2 += 1
    return var1

def func2():
    return 207

def func3(x, y):
    var1 = x | y
    var2 = x & y
    var3 = x ^ y
    
    var4 = 0
    var5 = 0
    while(var5 < var3):
        var4 += var1 + (var2 - var5)
        var5 += 1

    return var4


if __name__ == "__main__":
    x = func1()
    y = func2()
    z = func3(x, y)
    print(z)
