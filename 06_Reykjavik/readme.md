# Reykjavik
> source code is [here](./dump.asm)

## Analysis

### Stage 1
Focus on the function `<main>`
```asm
4438:  3e40 2045      mov	#0x4520, r14
443c:  0f4e           mov	r14, r15
443e:  3e40 f800      mov	#0xf8, r14
4442:  3f40 0024      mov	#0x2400, r15
4446:  b012 8644      call	#0x4486 <enc>
444a:  b012 0024      call	#0x2400
444e:  0f43           clr	r15
```

`<main>` function calls `<enc>` function with `0x2400` as first argument and observe the memory at `0x2400` after `<enc>` function returns.

- before
  ```
  2400: 4c85 1bc5 80df e9bf 3864 2bc6 4277 62b8   L.......8d+.Bwb.
  2410: c3ca d965 a40a c1a3 bbd1 a6ea b3eb 180f   ...e............
  2420: 78af ea7e 5c8e c695 cb6f b8e9 333c 5aa1   x..~\....o..3<Z.
  2430: 5cee 906b d1aa a1c3 a986 8d14 08a5 a22c   \..k...........,
  2440: baa5 1957 192d abe1 66b9 185b 4a08 e95c   ...W.-..f..[J..\
  2450: d919 8069 07a5 ef01 caa2 a30d f344 815e   ...i.........D.^
  2460: 3e10 e765 2bc8 2837 abad ab3f 8cfa 754d   >..e+.(7...?..uM
  ```
- after
  ```
  2400: 0b12 0412 0441 2452 3150 e0ff 3b40 2045   .....A$R1P..;@ E
  2410: 073c 1b53 8f11 0f12 0312 b012 6424 2152   .<.S........d$!R
  2420: 6f4b 4f93 f623 3012 0a00 0312 b012 6424   oKO..#0.......d$
  2430: 2152 3012 1f00 3f40 dcff 0f54 0f12 2312   !R0...?@...T..#.
  2440: b012 6424 3150 0600 b490 7fb5 dcff 0520   ..d$1P........ 
  2450: 3012 7f00 b012 6424 2153 3150 2000 3441   0....d$!S1P .4A
  2460: 3b41 3041 1e41 0200 0212 0f4e 8f10 024f   ;A0A.A.....N...O
  ```

Then, after the call, dump the [memory](./memory.bin) and use the [online tool](https://microcorruption.com/assembler) to disassemble the code at `0x2400`, result in [dump_2400.asm](./dump_2400.asm).

That is, this program is a loader that loads the code in function `<enc>` to region `0x2400` and then call `0x2400`.

### Stage 2
Focus on the function @ `0x2400`, source code is [here](./dump_2400.asm)

From the source code, we can find that there are multiple calls to `0x2464`:
```asm
2464
       1e41 0200      mov	0x2(sp), r14
       0212           push	sr
       0f4e           mov	r14, r15
       8f10           swpb	r15
       024f           mov	r15, sr
       32d0 0080      bis	#0x8000, sr
       b012 1000      call	#0x10
       3241           pop	sr
       3041           ret
```
Observe and compare the code from previous problems, we can find that this is the code for function `<INT> (void INT(int arg, ...))`. With the help of the [Lockitail Manual](https://microcorruption.com/public/manual.pdf), we can identify what all the interrupts are doing.

Important segment in fucntion @ `0x2400`:
```asm
...
       3012 1f00      push	#0x1f
       3f40 dcff      mov	#0xffdc, r15
       0f54           add	r4, r15                 ; r15 = sp - 36
       0f12           push	r15
       2312           push	#0x2
       b012 6424      call	#0x2464 <INT>           ; gets(r15, 0x1f), INT 0x2 ~> gets
       3150 0600      add	#0x6, sp
       b490 7fb5 dcff cmp	#0xb57f, -0x24(r4)      ; r4 - 0x24 = r15
       0520           jnz	$+0xc                   ; if ([r4 - 0x24] != 0xb57f), jump to $+0xc
       3012 7f00      push	#0x7f
       b012 6424      call	#0x2464 <INT>           ; trigger unlock, INT 0x7f ~> unlock
       2153           incd	sp
       3150 2000      add	#0x20, sp
       3441           pop	r4
       3b41           pop	r11
       3041           ret
```

Program gets the input from to the buffer `r15` pointed to and compare the **first 2 bytes of the input with `0xb57f`**.
If the comparison is true, it will trigger the unlock function.

Therefore, any input that starts with `[hex] 7f b5` will unlock the door.

<!-- solution: {'level_id': 6, 'input': '7fb5;'} -->
