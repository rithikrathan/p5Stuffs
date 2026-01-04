rcl = [3, 6, 9, 10, 13, 14, 15, 16]
bcl = [5, 7, 8, 9, 12, 13, 15, 16]
not_rc_u_bc = [5, 7, 8, 12]
rc_u_not_bc = [3, 6, 10, 14]
rc_u_bc = [9, 13, 15, 16]
not_rc_u_not_bc = [0, 1, 2, 4, 11]

connectedLeft = {2, 6, 9, 11, 13, 14, 15, 16}
connectedTop = {4, 7, 10, 11, 12, 13, 15, 16}
universe = set(range(0, 17))

lc_U_tc = list(connectedLeft.intersection(connectedTop))
nolc_U_tc = list((universe - connectedLeft).intersection(connectedTop))
lc_U_notc = list(connectedLeft.intersection((universe - connectedTop)))
nolc_U_notc = list(
    (universe - connectedLeft).intersection((universe - connectedTop)))


def test():
    print(lc_U_tc)
    print(nolc_U_tc)
    print(lc_U_notc)
    print(nolc_U_notc)


def list2bin(list, name):
    binary = 0b00000000000000000
    for i in list:
        binary = binary | 1 << i
    print(f"int {name} = {bin(binary)};")


if __name__ == "__main__":
    test()
    list2bin(rcl, "rcl")
    list2bin(bcl, "bcl")
    list2bin(not_rc_u_bc, "not_rc_u_bc")
    list2bin(rc_u_not_bc, "rc_u_not_bc")
    list2bin(rc_u_bc, "rc_u_bc")
    list2bin(not_rc_u_not_bc, "not_rc_u_not_bc")
    print("\n")
    list2bin(lc_U_tc, "lc_U_tc")
    list2bin(nolc_U_tc, "nolc_U_tc")
    list2bin(lc_U_notc, "lc_U_notc")
    list2bin(nolc_U_notc, "nolc_U_notc")
