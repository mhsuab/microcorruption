4438 <main>
4438:  0441           mov	sp, r4
443a:  2453           incd	r4
443c:  3150 0cfe      add	#0xfe0c, sp
4440:  3012 da44      push	#0x44da "Enter your username below to authenticate.\n"
4444:  b012 c645      call	#0x45c6 <printf>
4448:  b140 0645 0000 mov	#0x4506 ">> ", 0x0(sp)
444e:  b012 c645      call	#0x45c6 <printf>
4452:  2153           incd	sp
4454:  3e40 f401      mov	#0x1f4, r14
4458:  3f40 0024      mov	#0x2400, r15
445c:  b012 8a45      call	#0x458a <getsn>     ; gets(0x2400, 0x1f4)
4460:  3e40 0024      mov	#0x2400, r14
4464:  0f44           mov	r4, r15             ; r15 = r4
4466:  3f50 0afe      add	#0xfe0a, r15        ; r15 = r4 - 502
446a:  b012 dc46      call	#0x46dc <strcpy>    ; strcpy(r15, 0x2400)
446e:  3f40 0afe      mov	#0xfe0a, r15        ; r15 = -502
4472:  0f54           add	r4, r15             ; r15 = r4 - 502
4474:  0f12           push	r15
4476:  b012 c645      call	#0x45c6 <printf>    ; printf(r15 = input)
447a:  2153           incd	sp                  ; sp += 2
447c:  3f40 0a00      mov	#0xa, r15
4480:  b012 4e45      call	#0x454e <putchar>   ; putchar(0xa), 0xa = '\n'
4484:  0f44           mov	r4, r15             ; r15 = r4
4486:  3f50 0afe      add	#0xfe0a, r15        ; r15 = r4 - 502 = input
448a:  b012 b044      call	#0x44b0 <conditional_unlock_door>
448e:  0f93           tst	r15
4490:  0324           jz	$+0x8 <main+0x60>
4492:  3012 0a45      push	#0x450a "Access Granted!"
4496:  023c           jmp	$+0x6 <main+0x64>
4498:  3012 1a45      push	#0x451a "That username is not valid."
449c:  b012 c645      call	#0x45c6 <printf>
44a0:  0f43           clr	r15
44a2:  3150 f601      add	#0x1f6, sp
44a6 <__stop_progExec__>
44a6:  32d0 f000      bis	#0xf0, sr
44aa:  fd3f           jmp	$-0x4 <__stop_progExec__+0x0>