connectedLeft = {2, 6, 9, 11, 12, 14, 15, 16}
connectedRight = {3, 6, 8, 10, 13, 14, 15, 16}
connectedTop = {4, 7, 10, 11, 12, 13, 14, 16}
connectedBottom = {5, 7, 8, 9, 12, 13, 15, 16}
universe = set(range(0, 17))


lcitc = connectedLeft.intersection(connectedTop)
nlcitc = (universe - connectedLeft).intersection(connectedTop)
lcintc = connectedLeft.intersection(universe - connectedTop)
nlcintc = (universe - connectedLeft).intersection(universe - connectedRight)


def test():
    print(lcitc)
    print(nlcitc)
    print(lcintc)
    print(nlcintc)


def generateBits(mySet, name="", opt=1):
    base = 0b000000000000000000
    for i in (mySet):
        base = base | 1 << i
    if opt == 1:
        print(f"int {name} = {bin(base)};")
    elif opt == 2:
        print(f"return {bin(base)};")


def main():
    generateBits(connectedRight, "rcl")
    generateBits(connectedBottom, "bcl")
    print("\n")
    print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=")
    print("\n")
    generateBits(lcitc, "", 2)
    generateBits(nlcitc, "", 2)
    generateBits(lcintc, "", 2)
    generateBits(nlcintc, "", 2)


if __name__ == "__main__":
    main()
