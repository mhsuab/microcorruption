0010 <__trap_interrupt>
0010:  3041           ret
4400 <__init_stack>
4400:  3140 0044      mov	#0x4400, sp
4404 <__low_level_init>
4404:  1542 5c01      mov	&0x015c, r5
4408:  75f3           and.b	#-0x1, r5
440a:  35d0 085a      bis	#0x5a08, r5
440e <__do_copy_data>
440e:  3f40 7c00      mov	#0x7c, r15
4412:  0f93           tst	r15
4414:  0724           jz	$+0x10 <__do_clear_bss+0x0>
4416:  8245 5c01      mov	r5, &0x015c
441a:  2f83           decd	r15
441c:  9f4f 3845 0024 mov	0x4538(r15), 0x2400(r15)
4422:  f923           jnz	$-0xc <__do_copy_data+0x8>
4424 <__do_clear_bss>
4424:  3f40 0001      mov	#0x100, r15
4428:  0f93           tst	r15
442a:  0624           jz	$+0xe <main+0x0>
442c:  8245 5c01      mov	r5, &0x015c
4430:  1f83           dec	r15
4432:  cf43 7c24      mov.b	#0x0, 0x247c(r15)
4436:  fa23           jnz	$-0xa <__do_clear_bss+0x8>
4438 <main>
4438:  3e40 2045      mov	#0x4520, r14
443c:  0f4e           mov	r14, r15
443e:  3e40 f800      mov	#0xf8, r14
4442:  3f40 0024      mov	#0x2400, r15
4446:  b012 8644      call	#0x4486 <enc>
444a:  b012 0024      call	#0x2400
444e:  0f43           clr	r15
4450 <__stop_progExec__>
4450:  32d0 f000      bis	#0xf0, sr
4454:  fd3f           jmp	$-0x4 <__stop_progExec__+0x0>
4456 <__ctors_end>
4456:  3040 3645      br	#0x4536 <_unexpected_>
445a <INT>
445a:  1e41 0200      mov	0x2(sp), r14
445e:  0212           push	sr
4460:  0f4e           mov	r14, r15
4462:  8f10           swpb	r15
4464:  024f           mov	r15, sr
4466:  32d0 0080      bis	#0x8000, sr
446a:  b012 1000      call	#0x10
446e:  3241           pop	sr
4470:  3041           ret
4472:  5468 6973      addc.b	0x7369(r8), r4
4476:  4973           sbc.b	r9
4478:  5365 6375      addc.b	0x7563(r5), 4
447a:  6375           subc.b	@r5, 4
447c:  7265           addc.b	@r5+, sr
447e:  5269 6768      addc.b	0x6867(r9), sr
4482:  743f           jmp	$-0x116 <__none__+0x436c>
4486 <enc>
4486:  0b12           push	r11
4488:  0a12           push	r10
448a:  0912           push	r9
448c:  0812           push	r8
448e:  0d43           clr	r13
4490:  cd4d 7c24      mov.b	r13, 0x247c(r13)
4494:  1d53           inc	r13
4496:  3d90 0001      cmp	#0x100, r13
449a:  fa23           jnz	$-0xa <enc+0xa>
449c:  3c40 7c24      mov	#0x247c, r12
44a0:  0d43           clr	r13
44a2:  0b4d           mov	r13, r11
44a4:  684c           mov.b	@r12, r8
44a6:  4a48           mov.b	r8, r10
44a8:  0d5a           add	r10, r13
44aa:  0a4b           mov	r11, r10
44ac:  3af0 0f00      and	#0xf, r10
44b0:  5a4a 7244      mov.b	0x4472(r10), r10
44b4:  8a11           sxt	r10
44b6:  0d5a           add	r10, r13
44b8:  3df0 ff00      and	#0xff, r13
44bc:  0a4d           mov	r13, r10
44be:  3a50 7c24      add	#0x247c, r10
44c2:  694a           mov.b	@r10, r9
44c4:  ca48 0000      mov.b	r8, 0x0(r10)
44c8:  cc49 0000      mov.b	r9, 0x0(r12)
44cc:  1b53           inc	r11
44ce:  1c53           inc	r12
44d0:  3b90 0001      cmp	#0x100, r11
44d4:  e723           jnz	$-0x30 <enc+0x1e>
44d6:  0b43           clr	r11
44d8:  0c4b           mov	r11, r12
44da:  183c           jmp	$+0x32 <enc+0x86>
44dc:  1c53           inc	r12
44de:  3cf0 ff00      and	#0xff, r12
44e2:  0a4c           mov	r12, r10
44e4:  3a50 7c24      add	#0x247c, r10
44e8:  684a           mov.b	@r10, r8
44ea:  4b58           add.b	r8, r11
44ec:  4b4b           mov.b	r11, r11
44ee:  0d4b           mov	r11, r13
44f0:  3d50 7c24      add	#0x247c, r13
44f4:  694d           mov.b	@r13, r9
44f6:  cd48 0000      mov.b	r8, 0x0(r13)
44fa:  ca49 0000      mov.b	r9, 0x0(r10)
44fe:  695d           add.b	@r13, r9
4500:  4d49           mov.b	r9, r13
4502:  dfed 7c24 0000 xor.b	0x247c(r13), 0x0(r15)
4508:  1f53           inc	r15
450a:  3e53           add	#-0x1, r14
450c:  0e93           tst	r14
450e:  e623           jnz	$-0x32 <enc+0x56>
4510:  3841           pop	r8
4512:  3941           pop	r9
4514:  3a41           pop	r10
4516:  3b41           pop	r11
4518:  3041           ret
451a <do_nothing>
451a:  0e4f           mov	r15, r14
451c:  0f4e           mov	r14, r15
451e:  3041           ret
4520:  7768           addc.b	@r8+, r7
4522:  6174           subc.b	@r4, sp
4524:  2773           subc	#0x2, r7
4526:  2074           subc	@r4, pc
4528:  6865           addc.b	@r5, r8
452a:  2070           subc	@pc, pc
452c:  6173           subc.b	#0x2, sp
452e:  7377           subc.b	@r7+, 4
4530:  6f72           subc.b	#0x4, r15
4532:  643f           jmp	$-0x136 <__none__+0x43fc>
4536 <_unexpected_>
4536:  0013           reti	pc
