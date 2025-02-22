# Hanoi

## Reverse the Program
> full source code is [here](./dump.asm)

`login`
```asm
4520 <login>
4520:  c243 1024      mov.b	#0x0, &0x2410
4524:  3f40 7e44      mov	#0x447e "Enter the password to continue.", r15
4528:  b012 de45      call	#0x45de <puts>
452c:  3f40 9e44      mov	#0x449e "Remember: passwords are between 8 and 16 characters.", r15
4530:  b012 de45      call	#0x45de <puts>
4534:  3e40 1c00      mov	#0x1c, r14
4538:  3f40 0024      mov	#0x2400, r15                    ; r15 = 0x2400 = input
453c:  b012 ce45      call	#0x45ce <getsn>                 ; gets(0x2400, 0x1c)
4540:  3f40 0024      mov	#0x2400, r15
4544:  b012 5444      call	#0x4454 <test_password_valid>   ; test_password_valid(input)
4548:  0f93           tst	r15
454a:  0324           jz	$+0x8 <login+0x32>              ; if (test_password_valid(input) == 0) goto 0x4552
454c:  f240 5a00 1024 mov.b	#0x5a, &0x2410
4552:  3f40 d344      mov	#0x44d3 "Testing if password is valid.", r15
4556:  b012 de45      call	#0x45de <puts>
455a:  f290 fb00 1024 cmp.b	#0xfb, &0x2410                  ; input[0x10] == 0xfb
4560:  0720           jnz	$+0x10 <login+0x50>             ; if (input[0x10] != 0xfb) goto 4570
4562:  3f40 f144      mov	#0x44f1 "Access granted.", r15
4566:  b012 de45      call	#0x45de <puts>
456a:  b012 4844      call	#0x4448 <unlock_door>
456e:  3041           ret
4570:  3f40 0145      mov	#0x4501 "That password is not correct.", r15
4574:  b012 de45      call	#0x45de <puts>
4578:  3041           ret
```

Even though the program call `<test_password_valid>` to check if the password is valid, it only check for `input[0x10]` to determine whether it should call `<unlock_door>` or not. So we can just input 0x10 bytes of garbage and the last byte should be `0xfb`.

I/O Console for the input, `41414141414141414141414141414141fb`:
```text
Enter the password to continue.
Remember: passwords are between 8 and 16 characters.
Testing if password is valid.
Access granted.
```
**Access granted.** even though `<test_password_valid>` return `0x00` (false)

<!-- solution: {'level_id': 4, 'input': '41414141414141414141414141414141fb;'} -->
