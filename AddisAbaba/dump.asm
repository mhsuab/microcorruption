4438 <main>
4438:  3150 eaff      add	#0xffea, sp
443c:  8143 0000      clr	0x0(sp)
4440:  3012 e644      push	#0x44e6 "Login with username:password below to authenticate.\n"
4444:  b012 c845      call	#0x45c8 <printf>    ; printf("Login with username:password below to authenticate.\n")
4448:  b140 1b45 0000 mov	#0x451b ">> ", 0x0(sp)
444e:  b012 c845      call	#0x45c8 <printf>    ; printf(">> ")
4452:  2153           incd	sp
4454:  3e40 1300      mov	#0x13, r14
4458:  3f40 0024      mov	#0x2400, r15
445c:  b012 8c45      call	#0x458c <getsn>     ; gets(0x2400, 0x13)
4460:  0b41           mov	sp, r11             ; r11 = sp
4462:  2b53           incd	r11                 ; r11 += 2
4464:  3e40 0024      mov	#0x2400, r14
4468:  0f4b           mov	r11, r15
446a:  b012 de46      call	#0x46de <strcpy>    ; strcpy(r11 = sp + 2, 0x2400)
446e:  3f40 0024      mov	#0x2400, r15
4472:  b012 b044      call	#0x44b0 <test_password_valid>   ; test_password_valid(0x2400)
4476:  814f 0000      mov	r15, 0x0(sp)
447a:  0b12           push	r11
447c:  b012 c845      call	#0x45c8 <printf>    ; printf(r11 = sp + 2 = [input])
4480:  2153           incd	sp                  ; sp += 2
4482:  3f40 0a00      mov	#0xa, r15
4486:  b012 5045      call	#0x4550 <putchar>
448a:  8193 0000      tst	0x0(sp)             ; if (test_password_valid(0x2400) == 0)
448e:  0324           jz	$+0x8 <main+0x5e>
4490:  b012 da44      call	#0x44da <unlock_door>
4494:  053c           jmp	$+0xc <main+0x68>
4496:  3012 1f45      push	#0x451f "That entry is not valid."  ; 448e jump to here if ZF == 1
449a:  b012 c845      call	#0x45c8 <printf>
449e:  2153           incd	sp
44a0:  0f43           clr	r15
44a2:  3150 1600      add	#0x16, sp
44a6 <__stop_progExec__>
44a6:  32d0 f000      bis	#0xf0, sr
44aa:  fd3f           jmp	$-0x4 <__stop_progExec__+0x0>
44ac <__ctors_end>
44ac:  3040 f246      br	#0x46f2 <_unexpected_>
44b0 <test_password_valid>
44b0:  0412           push	r4
44b2:  0441           mov	sp, r4
44b4:  2453           incd	r4
44b6:  2183           decd	sp
44b8:  c443 fcff      mov.b	#0x0, -0x4(r4)
44bc:  3e40 fcff      mov	#0xfffc, r14
44c0:  0e54           add	r4, r14
44c2:  0e12           push	r14
44c4:  0f12           push	r15
44c6:  3012 7d00      push	#0x7d
44ca:  b012 3845      call	#0x4538 <INT>
44ce:  5f44 fcff      mov.b	-0x4(r4), r15
44d2:  8f11           sxt	r15
44d4:  3152           add	#0x8, sp
44d6:  3441           pop	r4
44d8:  3041           ret
44da <unlock_door>
44da:  3012 7f00      push	#0x7f
44de:  b012 3845      call	#0x4538 <INT>
44e2:  2153           incd	sp
44e4:  3041           ret
