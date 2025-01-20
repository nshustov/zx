#include "mtr-utils-regs.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Saves all registers on the stack
;
; Order of registers stored on stack:
; IX  ; SP+0
; IY  ; SP+2
; AF' ; SP+4
; BC' ; SP+6
; DE' ; SP+8
; HL' ; SP+10
; AF  ; SP+12
; BC  ; SP+14
; DE  ; SP+16
; HL  ; SP+18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_save_all_regs:
  EX (SP),HL
  PUSH DE
  JR __mtr_save_regs_after_de

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Saves registers on the stack, all but HL.
; HL is not preserved.
;
; Order of registers stored on stack:
; IX  ; SP+0
; IY  ; SP+2
; AF' ; SP+4
; BC' ; SP+6
; DE' ; SP+8
; HL' ; SP+10
; AF  ; SP+12
; BC  ; SP+14
; DE  ; SP+16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_save_regs:
  EX DE,HL ; HL in DE, DE in HL
  EX (SP),HL ; SP+22 DE on stack, return address in HL
__mtr_save_regs_after_de:
  PUSH BC ; SP+20
  PUSH AF ; SP+18
  EXX
  EX AF,AF'
  PUSH HL ; SP+16
  PUSH DE ; SP+14
  PUSH BC ; SP+12
  PUSH AF ; SP+10
  PUSH IY ; SP+8
  PUSH IX ; SP+6
  EXX
  EX AF,AF'
  PUSH HL ; SP+4 return address on stack
  EX DE,HL ; HL restored
; restore DE
  PUSH IX ; SP+2
  PUSH AF ; SP+0
  LD IX,22 ; offset to DE value on stack
  ADD IX,SP
  LD E,(IX+0)
  LD D,(IX+1)
  POP AF
  POP IX
  RET

; Saves registers at address placed on stack before CALL __mtr_save_regs_at invoked.
; For restoring the registers, caller can use __mtr_restore_all_regs_from
; or set SP to the address returned in HL and call __mtr_restore_all_regs
; [out] HL address of last stored register data
__mtr_save_all_regs_at:
  CALL __mtr_save_all_regs ; all registers are on stack
  LD HL,__MTR_SAVE_ALL_REGS_SIZE+4 ; offset to memory address
  ADD HL,SP
  PUSH HL
; load to DE the address where to store the registers
  LD E,(HL)
  INC HL
  LD D,(HL) ; DE has the address where to store the registers
; copy the registers data from stack to address in DE
  DEC HL
  LD BC,__MTR_SAVE_ALL_REGS_SIZE
  LDDR
  CALL __mtr_restore_all_regs
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restores all registers from the stack, as saved by
; __mtr_save_all_regs.
;
; Order of registers stored on stack (below PC return address):
; IX  ; SP+0
; IY  ; SP+2
; AF' ; SP+4
; BC' ; SP+6
; DE' ; SP+8
; HL' ; SP+10
; AF  ; SP+12
; BC  ; SP+14
; DE  ; SP+16
; HL  ; SP+18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_restore_all_regs:
  POP HL ; return address
  CALL __mtr_restore_regs
  EX (SP),HL
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restores all registers from the stack, as saved by
; __mtr_save_regs.
;
; Order of registers stored on stack (below PC return address):
; IX  ; SP+0
; IY  ; SP+2
; AF' ; SP+4
; BC' ; SP+6
; DE' ; SP+8
; HL' ; SP+10
; AF  ; SP+12
; BC  ; SP+14
; DE  ; SP+16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_restore_regs:
; restore DE from stack and put there HL instead
; we have to do it this way as opposite with manipulating with SP
; to be safe from interrupts tainting the stack memory
  LD IX,__MTR_SAVE_REGS_SIZE ; PC is on top of stack, so we point to DE
  ADD IX,SP
  LD E,(IX+0)
  LD D,(IX+1)
  LD (IX+0),L
  LD (IX+1),H
; DE restored, HL is in place of DE on stack
  POP HL ; HL now has return address
  POP IX
  POP IY
  EXX
  EX AF,AF'
  POP AF
  POP BC
  POP DE
  POP HL
  EXX
  EX AF,AF'
  POP AF
  POP BC
; HL has the return address and stack has its value stored in the beginning
  EX (SP),HL
  RET

; Restores all registers from save by address in HL.
__mtr_restore_all_regs_from:
; reserve space on stack for registers data
  EX DE,HL
  LD HL,0
  ADD HL,SP
  LD BC,__MTR_SAVE_ALL_REGS_SIZE
  OR A
  SBC HL,BC
  LD SP,HL
; Load reserved space on stack with registers data
  EX DE,HL
  LDDR
; restore registers and return
  CALL __mtr_restore_all_regs
  RET
