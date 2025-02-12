true : ;nasm -l nasm.list -Lmesp -Iasmlib/ -f bin -o print $0 && ls -l print && chmod +x print && objdas ./print && echo strace -i ./print foobar; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

;START equ _start - 3
%define START fff
%include "stdlib.mac"

;BASE	0x3d499000
BASE	0x10000000

ELF ff
ELF_PHDR jump
jmp fff
%include "regdump2.mac"

%if 0
push	1
mov	esi, edi
lea	esi, [edi]
imul	esi, edi, 1
push	2
lea	esi, [2*edi]
imul	esi, edi, 2
push	3
lea	esi, [3*edi]
imul	esi, edi, 3
push	4
ud2
imul	esi, edi, 4
push	5
lea	esi, [5*edi]
imul	esi, edi, 5
push	6
;lea	esi, [6*edi]
ud2
imul	esi, edi, 6
push	7
;lea	esi, [7*edi]
ud2
imul	esi, edi, 7
push	8
ud2
imul	esi, edi, 8
push	9
lea	esi, [9*edi]
imul	esi, edi, 9

times 12 nop

lea	esi, [edi+1]
lea	esi, [2*edi+1]
lea	esi, [3*edi+1]
ud2
lea	esi, [5*edi+1]
ud2
ud2
ud2
lea	esi, [9*edi+1]

times 12 nop

lea	esi, [eax+edi+1]
lea	esi, [eax+2*edi+1]
ud2
lea	esi, [eax+4*edi+1]
ud2
ud2
ud2
lea	esi, [eax+8*edi+1]
ud2

times 12 nop

lea	esi, [esp+1]
ud2
ud2
ud2
ud2
ud2
ud2
ud2
ud2

times 12 nop

lea	esi, [eax+esp+1]
ud2
ud2
ud2
ud2
ud2
ud2
ud2
ud2

; nasm -I asmlib/ -f elf32 foob.asm
; ld -m elf_i386 -z noseparate-code foob.o


shr	esi, 3
set	eax, 0
setfz	eax, 255
setfz	eax, 256
setfz	eax, 257
setfz	eax, 258
; lea m*x + c
; m = 1,2,3,5,9
; lea m*x + c + z (z being a register containing zero)
; m = 4,8
; mov m*x + 0
; m = 1
; imul m*x + 0
; m = 2,3,...
rwx

zero	eax
inc	eax
ror	eax, 1
dec	eax
dbg_regdump

zero	eax
inc	eax
ror	eax, 1
inc	eax
dbg_regdump

zero	eax
stc
rcr	eax, 1
dbg_regdump

zero	eax
inc	eax
ror	eax,1
sar	eax, 12
dbg_regdump

%endif

fff:
%if 0
	inc ebx

	zero	eax
	;inc	eax
	;dec	eax
	;dec	eax
	;mov	al,0x51
	mov	ah, bl
	bswap	eax
	;mov	al, 2

	;inc	al
	;dec	eax
	pusha
	mov	eax, ebx
	zero	ebx, edx, ecx
	printnum ':'
	popa
	reg
	crc32	eax, eax
	crc32	eax, eax
	crc32	eax, eax
	crc32	eax, eax
	crc32	eax, eax
	crc32	eax, eax
	crc32	eax, eax
	dbg_regdump
	;pusha
	;zero	ebx, edx, ecx
	;printnum
	;popa
	inc	ebx
	cmp	ebx, 255
	jbe fff
%endif

%if 0

zero	eax
dec	eax
das
; FFFFFF99 -103
int32 0xFFFFFF99
dbg_regdump


zero	eax
dec	eax
aas
; FFFFFE09 -503
int32 0xFFFFFE09
dbg_regdump

zero	eax
dec	eax
aaa
; FFFF0105 -65275
int32 0xFFFF0105
dbg_regdump

zero	eax
dec	eax
daa
; FFFFFF65 -155
int32 0xFFFFFF65
dbg_regdump

zero	eax
lahf
dbg_regdump

std
zero	eax
dec	ah
sahf
dbg_regdump

pushf
pop	eax
dbg_regdump


zero	eax
inc	eax
xchg	al,ah
dbg_regdump
%endif

%if 1

%macro XXXadd 2
%warning OVERLOAD %? %?? %1
%? %1,%2
taint %1
%endmacro
%define oa(x)	define (x) add
;%defalias and add
;%defalias or add
;%defalias mov add


mov eax, 1
;set	eax, -103
;set	eax, 0xFFFFFF99
;set	eax, -200
;set	eax, 200
rinit
rwx
time
printnum
%if 1
printnum
sleep 1
time
printnum
sleep 1
exit
%endif
%endif
set eax, -0
set eax, -1
set eax, -2
set eax, -3
set eax, -4
set eax, -5
set eax, -6
set eax, -7
set eax, -8
set eax, -9
set eax, -10
set eax, -11
set eax, -12
set eax, -13
set eax, -14
set eax, -15
set eax, -16
set eax, -17
set eax, -18
set eax, -19
set eax, -20
set eax, -21
set eax, -22
set eax, -23
set eax, -24
set eax, -25
set eax, -26
set eax, -27
set eax, -28
set eax, -29
set eax, -30
set eax, -31
set eax, -32
set eax, -33
set eax, -34
set eax, -35
set eax, -36
set eax, -37
set eax, -38
set eax, -39
set eax, -40
set eax, -41
set eax, -42
set eax, -43
set eax, -44
set eax, -45
set eax, -46
set eax, -47
set eax, -48
set eax, -49
set eax, -50
set eax, -51
set eax, -52
set eax, -53
set eax, -54
set eax, -55
set eax, -56
set eax, -57
set eax, -58
set eax, -59
set eax, -60
set eax, -61
set eax, -62
set eax, -63
set eax, -64
set eax, -65
set eax, -66
set eax, -67
set eax, -68
set eax, -69
set eax, -70
set eax, -71
set eax, -72
set eax, -73
set eax, -74
set eax, -75
set eax, -76
set eax, -77
set eax, -78
set eax, -79
set eax, -80
set eax, -81
set eax, -82
set eax, -83
set eax, -84
set eax, -85
set eax, -86
set eax, -87
set eax, -88
set eax, -89
set eax, -90
set eax, -91
set eax, -92
set eax, -93
set eax, -94
set eax, -95
set eax, -96
set eax, -97
set eax, -98
set eax, -99
set eax, -100
set eax, -101
set eax, -102
set eax, -103
set eax, -104
set eax, -105
set eax, -106
set eax, -107
set eax, -108
set eax, -109
set eax, -110
set eax, -111
set eax, -112
set eax, -113
set eax, -114
set eax, -115
set eax, -116
set eax, -117
set eax, -118
set eax, -119
set eax, -120
set eax, -121
set eax, -122
set eax, -123
set eax, -124
set eax, -125
set eax, -126
set eax, -127
set eax, -128
set eax, -129
set eax, -130
set eax, -131
set eax, -132
set eax, -133
set eax, -134
set eax, -135
set eax, -136
set eax, -137
set eax, -138
set eax, -139
set eax, -140
set eax, -141
set eax, -142
set eax, -143
set eax, -144
set eax, -145
set eax, -146
set eax, -147
set eax, -148
set eax, -149
set eax, -150
set eax, -151
set eax, -152
set eax, -153
set eax, -154
set eax, -155
set eax, -156
set eax, -157
set eax, -158
set eax, -159
set eax, -160
set eax, -161
set eax, -162
set eax, -163
set eax, -164
set eax, -165
set eax, -166
set eax, -167
set eax, -168
set eax, -169
set eax, -170
set eax, -171
set eax, -172
set eax, -173
set eax, -174
set eax, -175
set eax, -176
set eax, -177
set eax, -178
set eax, -179
set eax, -180
set eax, -181
set eax, -182
set eax, -183
set eax, -184
set eax, -185
set eax, -186
set eax, -187
set eax, -188
set eax, -189
set eax, -190
set eax, -191
set eax, -192
set eax, -193
set eax, -194
set eax, -195
set eax, -196
set eax, -197
set eax, -198
set eax, -199
set eax, -200
set eax, -201
set eax, -202
set eax, -203
set eax, -204
set eax, -205
set eax, -206
set eax, -207
set eax, -208
set eax, -209
set eax, -210
set eax, -211
set eax, -212
set eax, -213
set eax, -214
set eax, -215
set eax, -216
set eax, -217
set eax, -218
set eax, -219
set eax, -220
set eax, -221
set eax, -222
set eax, -223
set eax, -224
set eax, -225
set eax, -226
set eax, -227
set eax, -228
set eax, -229
set eax, -230
set eax, -231
set eax, -232
set eax, -233
set eax, -234
set eax, -235
set eax, -236
set eax, -237
set eax, -238
set eax, -239
set eax, -240
set eax, -241
set eax, -242
set eax, -243
set eax, -244
set eax, -245
set eax, -246
set eax, -247
set eax, -248
set eax, -249
set eax, -250
set eax, -251
set eax, -252
set eax, -253
set eax, -254
set eax, -255
set eax, -256
set eax, -257
set eax, -258
set eax, -259
set eax, -260
set eax, -261
set eax, -262
set eax, -263
set eax, -264
set eax, -265
set eax, -266
set eax, -267
set eax, -268
set eax, -269
set eax, -270
set eax, -271
set eax, -272
set eax, -273
set eax, -274
set eax, -275
set eax, -276
set eax, -277
set eax, -278
set eax, -279
set eax, -280
set eax, -281
set eax, -282
set eax, -283
set eax, -284
set eax, -285
set eax, -286
set eax, -287
set eax, -288
set eax, -289
set eax, -290
set eax, -291
set eax, -292
set eax, -293
set eax, -294
set eax, -295
set eax, -296
set eax, -297
set eax, -298
set eax, -299
set eax, -300
set eax, -301
set eax, -302
set eax, -303
set eax, -304
set eax, -305
set eax, -306
set eax, -307
set eax, -308
set eax, -309
set eax, -310
set eax, -311
set eax, -312
set eax, -313
set eax, -314
set eax, -315
set eax, -316
set eax, -317
set eax, -318
set eax, -319
set eax, -320
set eax, -321
set eax, -322
set eax, -323
set eax, -324
set eax, -325
set eax, -326
set eax, -327
set eax, -328
set eax, -329
set eax, -330
set eax, -331
set eax, -332
set eax, -333
set eax, -334
set eax, -335
set eax, -336
set eax, -337
set eax, -338
set eax, -339
set eax, -340
set eax, -341
set eax, -342
set eax, -343
set eax, -344
set eax, -345
set eax, -346
set eax, -347
set eax, -348
set eax, -349
set eax, -350
set eax, -351
set eax, -352
set eax, -353
set eax, -354
set eax, -355
set eax, -356
set eax, -357
set eax, -358
set eax, -359
set eax, -360
set eax, -361
set eax, -362
set eax, -363
set eax, -364
set eax, -365
set eax, -366
set eax, -367
set eax, -368
set eax, -369
set eax, -370
set eax, -371
set eax, -372
set eax, -373
set eax, -374
set eax, -375
set eax, -376
set eax, -377
set eax, -378
set eax, -379
set eax, -380
set eax, -381
set eax, -382
set eax, -383
set eax, -384
set eax, -385
set eax, -386
set eax, -387
set eax, -388
set eax, -389
set eax, -390
set eax, -391
set eax, -392
set eax, -393
set eax, -394
set eax, -395
set eax, -396
set eax, -397
set eax, -398
set eax, -399
set eax, -400
set eax, -401
set eax, -402
set eax, -403
set eax, -404
set eax, -405
set eax, -406
set eax, -407
set eax, -408
set eax, -409
set eax, -410
set eax, -411
set eax, -412
set eax, -413
set eax, -414
set eax, -415
set eax, -416
set eax, -417
set eax, -418
set eax, -419
set eax, -420
set eax, -421
set eax, -422
set eax, -423
set eax, -424
set eax, -425
set eax, -426
set eax, -427
set eax, -428
set eax, -429
set eax, -430
set eax, -431
set eax, -432
set eax, -433
set eax, -434
set eax, -435
set eax, -436
set eax, -437
set eax, -438
set eax, -439
set eax, -440
set eax, -441
set eax, -442
set eax, -443
set eax, -444
set eax, -445
set eax, -446
set eax, -447
set eax, -448
set eax, -449
set eax, -450
set eax, -451
set eax, -452
set eax, -453
set eax, -454
set eax, -455
set eax, -456
set eax, -457
set eax, -458
set eax, -459
set eax, -460
set eax, -461
set eax, -462
set eax, -463
set eax, -464
set eax, -465
set eax, -466
set eax, -467
set eax, -468
set eax, -469
set eax, -470
set eax, -471
set eax, -472
set eax, -473
set eax, -474
set eax, -475
set eax, -476
set eax, -477
set eax, -478
set eax, -479
set eax, -480
set eax, -481
set eax, -482
set eax, -483
set eax, -484
set eax, -485
set eax, -486
set eax, -487
set eax, -488
set eax, -489
set eax, -490
set eax, -491
set eax, -492
set eax, -493
set eax, -494
set eax, -495
set eax, -496
set eax, -497
set eax, -498
set eax, -499
set eax, -500
set eax, -501
set eax, -502
set eax, -503
set eax, -504
set eax, -505
set eax, -506
set eax, -507
set eax, -508
set eax, -509
set eax, -510
set eax, -511
set eax, -512
set eax, -513
set eax, -514
set eax, -515
set eax, -516
set eax, -517
set eax, -518
set eax, -519
set eax, -520
set eax, -521
set eax, -522
set eax, -523
set eax, -524
set eax, -525
set eax, -526
set eax, -527
set eax, -528
set eax, -529
set eax, -530
set eax, -531
set eax, -532
set eax, -533
set eax, -534
set eax, -535
set eax, -536
set eax, -537
set eax, -538
set eax, -539
set eax, -540
set eax, -541
set eax, -542
set eax, -543
set eax, -544
set eax, -545
set eax, -546
set eax, -547
set eax, -548
set eax, -549
set eax, -550
set eax, -551
set eax, -552
set eax, -553
set eax, -554
set eax, -555
set eax, -556
set eax, -557
set eax, -558
set eax, -559
set eax, -560
set eax, -561
set eax, -562
set eax, -563
set eax, -564
set eax, -565
set eax, -566
set eax, -567
set eax, -568
set eax, -569
set eax, -570
set eax, -571
set eax, -572
set eax, -573
set eax, -574
set eax, -575
set eax, -576
set eax, -577
set eax, -578
set eax, -579
set eax, -580
set eax, -581
set eax, -582
set eax, -583
set eax, -584
set eax, -585
set eax, -586
set eax, -587
set eax, -588
set eax, -589
set eax, -590
set eax, -591
set eax, -592
set eax, -593
set eax, -594
set eax, -595
set eax, -596
set eax, -597
set eax, -598
set eax, -599
set eax, -600
set eax, -601
set eax, -602
set eax, -603
set eax, -604
set eax, -605
set eax, -606
set eax, -607
set eax, -608
set eax, -609
set eax, -610
set eax, -611
set eax, -612
set eax, -613
set eax, -614
set eax, -615
set eax, -616
set eax, -617
set eax, -618
set eax, -619
set eax, -620
set eax, -621
set eax, -622
set eax, -623
set eax, -624
set eax, -625
set eax, -626
set eax, -627
set eax, -628
set eax, -629
set eax, -630
set eax, -631
set eax, -632
set eax, -633
set eax, -634
set eax, -635
set eax, -636
set eax, -637
set eax, -638
set eax, -639
set eax, -640
set eax, -641
set eax, -642
set eax, -643
set eax, -644
set eax, -645
set eax, -646
set eax, -647
set eax, -648
set eax, -649
set eax, -650
set eax, -651
set eax, -652
set eax, -653
set eax, -654
set eax, -655
set eax, -656
set eax, -657
set eax, -658
set eax, -659
set eax, -660
set eax, -661
set eax, -662
set eax, -663
set eax, -664
set eax, -665
set eax, -666
set eax, -667
set eax, -668
set eax, -669
set eax, -670
set eax, -671
set eax, -672
set eax, -673
set eax, -674
set eax, -675
set eax, -676
set eax, -677
set eax, -678
set eax, -679
set eax, -680
set eax, -681
set eax, -682
set eax, -683
set eax, -684
set eax, -685
set eax, -686
set eax, -687
set eax, -688
set eax, -689
set eax, -690
set eax, -691
set eax, -692
set eax, -693
set eax, -694
set eax, -695
set eax, -696
set eax, -697
set eax, -698
set eax, -699
set eax, -700
set eax, -701
set eax, -702
set eax, -703
set eax, -704
set eax, -705
set eax, -706
set eax, -707
set eax, -708
set eax, -709
set eax, -710
set eax, -711
set eax, -712
set eax, -713
set eax, -714
set eax, -715
set eax, -716
set eax, -717
set eax, -718
set eax, -719
set eax, -720
set eax, -721
set eax, -722
set eax, -723
set eax, -724
set eax, -725
set eax, -726
set eax, -727
set eax, -728
set eax, -729
set eax, -730
set eax, -731
set eax, -732
set eax, -733
set eax, -734
set eax, -735
set eax, -736
set eax, -737
set eax, -738
set eax, -739
set eax, -740
set eax, -741
set eax, -742
set eax, -743
set eax, -744
set eax, -745
set eax, -746
set eax, -747
set eax, -748
set eax, -749
set eax, -750
set eax, -751
set eax, -752
set eax, -753
set eax, -754
set eax, -755
set eax, -756
set eax, -757
set eax, -758
set eax, -759
set eax, -760
set eax, -761
set eax, -762
set eax, -763
set eax, -764
set eax, -765
set eax, -766
set eax, -767
set eax, -768
set eax, -769
set eax, -770
set eax, -771
set eax, -772
set eax, -773
set eax, -774
set eax, -775
set eax, -776
set eax, -777
set eax, -778
set eax, -779
set eax, -780
set eax, -781
set eax, -782
set eax, -783
set eax, -784
set eax, -785
set eax, -786
set eax, -787
set eax, -788
set eax, -789
set eax, -790
set eax, -791
set eax, -792
set eax, -793
set eax, -794
set eax, -795
set eax, -796
set eax, -797
set eax, -798
set eax, -799
set eax, -800
set eax, -801
set eax, -802
set eax, -803
set eax, -804
set eax, -805
set eax, -806
set eax, -807
set eax, -808
set eax, -809
set eax, -810
set eax, -811
set eax, -812
set eax, -813
set eax, -814
set eax, -815
set eax, -816
set eax, -817
set eax, -818
set eax, -819
set eax, -820
set eax, -821
set eax, -822
set eax, -823
set eax, -824
set eax, -825
set eax, -826
set eax, -827
set eax, -828
set eax, -829
set eax, -830
set eax, -831
set eax, -832
set eax, -833
set eax, -834
set eax, -835
set eax, -836
set eax, -837
set eax, -838
set eax, -839
set eax, -840
set eax, -841
set eax, -842
set eax, -843
set eax, -844
set eax, -845
set eax, -846
set eax, -847
set eax, -848
set eax, -849
set eax, -850
set eax, -851
set eax, -852
set eax, -853
set eax, -854
set eax, -855
set eax, -856
set eax, -857
set eax, -858
set eax, -859
set eax, -860
set eax, -861
set eax, -862
set eax, -863
set eax, -864
set eax, -865
set eax, -866
set eax, -867
set eax, -868
set eax, -869
set eax, -870
set eax, -871
set eax, -872
set eax, -873
set eax, -874
set eax, -875
set eax, -876
set eax, -877
set eax, -878
set eax, -879
set eax, -880
set eax, -881
set eax, -882
set eax, -883
set eax, -884
set eax, -885
set eax, -886
set eax, -887
set eax, -888
set eax, -889
set eax, -890
set eax, -891
set eax, -892
set eax, -893
set eax, -894
set eax, -895
set eax, -896
set eax, -897
set eax, -898
set eax, -899
set eax, -900
set eax, -901
set eax, -902
set eax, -903
set eax, -904
set eax, -905
set eax, -906
set eax, -907
set eax, -908
set eax, -909
set eax, -910
set eax, -911
set eax, -912
set eax, -913
set eax, -914
set eax, -915
set eax, -916
set eax, -917
set eax, -918
set eax, -919
set eax, -920
set eax, -921
set eax, -922
set eax, -923
set eax, -924
set eax, -925
set eax, -926
set eax, -927
set eax, -928
set eax, -929
set eax, -930
set eax, -931
set eax, -932
set eax, -933
set eax, -934
set eax, -935
set eax, -936
set eax, -937
set eax, -938
set eax, -939
set eax, -940
set eax, -941
set eax, -942
set eax, -943
set eax, -944
set eax, -945
set eax, -946
set eax, -947
set eax, -948
set eax, -949
set eax, -950
set eax, -951
set eax, -952
set eax, -953
set eax, -954
set eax, -955
set eax, -956
set eax, -957
set eax, -958
set eax, -959
set eax, -960
set eax, -961
set eax, -962
set eax, -963
set eax, -964
set eax, -965
set eax, -966
set eax, -967
set eax, -968
set eax, -969
set eax, -970
set eax, -971
set eax, -972
set eax, -973
set eax, -974
set eax, -975
set eax, -976
set eax, -977
set eax, -978
set eax, -979
set eax, -980
set eax, -981
set eax, -982
set eax, -983
set eax, -984
set eax, -985
set eax, -986
set eax, -987
set eax, -988
set eax, -989
set eax, -990
set eax, -991
set eax, -992
set eax, -993
set eax, -994
set eax, -995
set eax, -996
set eax, -997
set eax, -998
set eax, -999
set eax, -1000
set eax, -1001
set eax, -1002
set eax, -1003
set eax, -1004
set eax, -1005
set eax, -1006
set eax, -1007
set eax, -1008
set eax, -1009
set eax, -1010
set eax, -1011
set eax, -1012
set eax, -1013
set eax, -1014
set eax, -1015
set eax, -1016
set eax, -1017
set eax, -1018
set eax, -1019
set eax, -1020
set eax, -1021
set eax, -1022
set eax, -1023
set eax, -1024
