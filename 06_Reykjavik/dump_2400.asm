2400
0b12           push	r11
0412           push	r4
0441           mov	sp, r4                  ; r4 = sp
2452           add	#0x4, r4                ; r4 = sp + 4
3150 e0ff      add	#0xffe0, sp
3b40 2045      mov	#0x4520 "what's the password?", r11
073c           jmp	$+0x10
1b53           inc	r11
8f11           sxt	r15
0f12           push	r15
0312           push	#0x0
b012 6424      call	#0x2464 <INT>           ; putchar | print ("what's the password?")
2152           add	#0x4, sp
6f4b           mov.b	@r11, r15
4f93           tst.b	r15
f623           jnz	$-0x12
3012 0a00      push	#0xa
0312           push	#0x0
b012 6424      call	#0x2464 <INT>           ; putchar | print ("\n")
2152           add	#0x4, sp
3012 1f00      push	#0x1f
3f40 dcff      mov	#0xffdc (-36), r15
0f54           add	r4, r15                 ; r15 = sp - 36
0f12           push	r15
2312           push	#0x2
b012 6424      call	#0x2464 <INT>           ; gets(r15, 0x1f)
3150 0600      add	#0x6, sp
b490 7fb5 dcff cmp	#0xb57f, -0x24(r4)      ; if (strcmp(r4 - 0x24, "b57f") == 0), r4 - 0x24 = r15
0520           jnz	$+0xc                   ; jump to instruction after trigger unlock if not equal
3012 7f00      push	#0x7f
b012 6424      call	#0x2464 <INT>           ; trigger unlock
2153           incd	sp
3150 2000      add	#0x20, sp
3441           pop	r4
3b41           pop	r11
3041           ret

2464 <INT>:
1e41 0200      mov	0x2(sp), r14
0212           push	sr
0f4e           mov	r14, r15
8f10           swpb	r15
024f           mov	r15, sr
32d0 0080      bis	#0x8000, sr
b012 1000      call	#0x10
3241           pop	sr
3041           ret
