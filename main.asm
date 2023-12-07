; -----------------------------------------------------------
; Mikrokontroller alapu rendszerek hazi feladat
; Keszitette: Kiss Ferenc Andras
; Feladat leirasa:
;		32 bites szamban az 1-esek szamanak megallapitasa.
;		Bemenet: a szam (4 regiszterben).
;		Kimenet: az egyesek szama (1 regiszterben).
; -----------------------------------------------------------

$NOMOD51 ; a sztenderd 8051 regiszter definiciok nem szuksegesek

$INCLUDE (SI_EFM8BB3_Defs.inc) ; regiszter es SFR definiciok

; Ugrotabla letrehozasa
	CSEG AT 0
	SJMP Main

myprog SEGMENT CODE			;sajat kodszegmens letrehozasa
RSEG myprog 				;sajat kodszegmens kivalasztasa

; ------------------------------------------------------------
; Foprogram
; ------------------------------------------------------------
; Feladata: a szukseges inicializacios lepesek elvegzese es a
;			feladatot megvalosito szubrutin(ok) meghivasa
; ------------------------------------------------------------
Main:
	CLR IE_EA ; interruptok tiltasa a watchdog tiltas idejere
	MOV WDTCN,#0DEh ; watchdog timer tiltasa
	MOV WDTCN,#0ADh
	SETB IE_EA ; interruptok engedelyezese

	; paraméterek elokeszitese a szubrutinhivashoz

	MOV R0, #0x04
	MOV R5, #0x08
	MOV R6, #0x00

	MOV R1, #0x03	; 32 bites szam (4 x 8bit)
	MOV R2, #0x02
	MOV R3, #0xDC
	MOV R4, #0x03

	CALL CountOnes	; a feladat elvegzese, az eredmeny az R6 regiszterben lathato
	JMP $			; vegtelen ciklusban varunk

; -----------------------------------------------------------
; CountOnes szubrutin
; -----------------------------------------------------------
; Funkció:	Az 1-esek szamanak megallapitasa az R1-R4 regiszterekben
; Bementek:	R0 - pointer (R1-R4 regiszterekre), egyben a hatralevo regiszterek szama
;			R1-R4 - 32-bites szam (4x8 biten)
;			R5 - a vizsgalt bit sorszáma az ACC-ban (8:MSB->1:LSB)
; Regisztereket modositja:
;			A, R0, R5, R6
; Kimenet:	R6 - 1-esek szama
; -----------------------------------------------------------

CountOnes:
	MOV A, @R0	; az RLC muvelet csak az ACC erteken vegezheto el
				; betoltjuk az ACC-ba az R0-ban tarolt cimen talalhato erteket

Loop:
	RLC A		; a kovetkezo vizsgalando bitet betoltjuk a CY-be
	JNC Skip	; ha a vizsgalt bit 0, atugorjuk a kovetkezo utasitast
	INC R6		; ha a bit 1, megnoveljuk az egyesek szamat

Skip:
	DJNZ R5, Loop		; ha nem vizsgaltuk meg az adott regiszter osszes bitjet, megnezzuk a kovetkezot
	MOV R5, #0x08		; ha a regiszter osszes bitjet megvizsgaltuk, alaphelyzetbe allitjuk a bitszamlalot
	DJNZ R0, CountOnes	; ha van olyan regiszter, amit meg nem vizsgaltunk meg
	RET					; vissszaterunk a foprogramba

END
