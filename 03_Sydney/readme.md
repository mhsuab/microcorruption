# Sydney

The program asks for password and unlocks the door if the password is correct.

`<main>` function use `<check_password>` to check the correctness of the password and depending on the result, it will either **unlock the door** or print "Invalid password; try again.".

## Dive into `<check_password>`

### Assembly

```asm
448a <check_password>
448a:  bf90 5525 0000 cmp	#0x2555, 0x0(r15)
4490:  0d20           jnz	$+0x1c <check_password+0x22>
4492:  bf90 2e4d 0200 cmp	#0x4d2e, 0x2(r15)
4498:  0920           jnz	$+0x14 <check_password+0x22>
449a:  bf90 5c73 0400 cmp	#0x735c, 0x4(r15)
44a0:  0520           jnz	$+0xc <check_password+0x22>
44a2:  1e43           mov	#0x1, r14
44a4:  bf90 6e63 0600 cmp	#0x636e, 0x6(r15)
44aa:  0124           jz	$+0x4 <check_password+0x24>
44ac:  0e43           clr	r14
44ae:  0f4e           mov	r14, r15
44b0:  3041           ret
```

### Analysis
Focus on the following instrctions in `<check_password>`:

```asm
448a:  bf90 5525 0000 cmp	#0x2555, 0x0(r15)
4492:  bf90 2e4d 0200 cmp	#0x4d2e, 0x2(r15)
449a:  bf90 5c73 0400 cmp	#0x735c, 0x4(r15)
44a4:  bf90 6e63 0600 cmp	#0x636e, 0x6(r15)
```

Register `r15` contains the pointer to the password and the password is checking 2 bytes at a time. The password is `0x2555 0x4d2e 0x735c 0x636e` in little endian.

<!-- solution: {'level_id': 3, 'input': '55252e4d5c736e63;'} -->
