#ifndef _MTR_DEBUG_INC_
#define _MTR_DEBUG_INC_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prints memory dump to screen
;
; Output format:
;
; 01 24 45 67 89 AB CD EF | ..eFt.!=
; 01 24 45 67 89 AB CD EF | ..eFt.!=
;
; [in] HL memory address
; [in] BC number of bytes
; [in] A bytes per line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_dbg_dump_mem
#define mtr_dbg_dump_mem __mtr_dbg_dump_mem

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; dumps registers info on screen
; [in] HL points to registers area of:
;
; IX
; IY
; AF'
; BC'
; DE'
; HL'
; AF
; BC
; DE
; HL
; IP
; SP
;
; Output example:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IX = 0123   IY = 4567
;
; HL'= 0123   DE'= 4567
; BC'= 89AB    A'= CD
;  F'= 8C (P,NZ,NC)
;
; HL = 0123   DE = 4567
; BC = 89AB    A = CD
;  F = 8C (P,NZ,NC)
; 
; IP = 2345
; 01 24 45 67 89 AB CD EF | ..eFt.!=
; 01 24 45 67 89 AB CD EF | ..eFt.!=
; 
; SP = 4567
; 01 24 45 67 89 AB CD EF | ..eFt.!=
; 01 24 45 67 89 AB CD EF | ..eFt.!=
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_dbg_dump
#define mtr_dbg_dump __mtr_dbg_dump

#endif