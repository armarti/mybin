#!/usr/bin/env python3
import sys


def base64(word):
    binlist = []
    for letter in word:
        _ord = ord(letter)
        _bin = bin(_ord)
        s_bin = str(_bin).replace('0b', '')
        sp_bin = '{0}{1}'.format('0' * (8 % len(s_bin)), s_bin)
        binlist += [sp_bin]
    null_padlen = 0
    while (8 * len(binlist) + null_padlen) % 6 != 0:
        null_padlen += 1
    if null_padlen > 0:
        binlist += ['0' * null_padlen]
    print(binlist)
    binlist_flat = ''.join(binlist)
    b6_binlist = [binlist_flat[seg:seg + 6] for seg in range(0, len(binlist_flat), 6)]
    print(b6_binlist)
    b64_list = [int('0b' + _bin, 2) for _bin in b6_binlist]
    print(b64_list)
    ascii_list = []
    for dec in b64_list:
        ascii_adj = 0
        if 0 <= dec <= 25:     # A-Z
            ascii_adj = 65
        elif 26 <= dec <= 51:  # A-Z
            ascii_adj = 71
        elif 52 <= dec <= 61:  # a-z
            ascii_adj = -4
        elif dec == 62:        # +
            ascii_adj = -19
        elif dec == 63:        # /
            ascii_adj = -16
        else:
            print(ascii_list)
            print("Something went wrong.")
            exit(1)
        ascii_list += [dec + ascii_adj]
    print(ascii_list)
    ascii_list = [chr(_ascii) for _ascii in ascii_list]
    ascii_str = ''.join(ascii_list)
    print(ascii_list)
    print(ascii_str)
    eq_padlen = 0
    while (len(ascii_str) + eq_padlen) % 4 != 0:
        eq_padlen += 1
    ascii_str += '=' * eq_padlen
    print(ascii_str)


if __name__ == '__main__':
#    base64("green")


#else:
    print(base64(sys.argv[1]))
