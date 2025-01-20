#include "mtr-task.inc"
#include "mtr-eidi.inc"
#include "mtr-sem.inc"

; Semaphore data:
; defw counter

SECTION code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_sem_acquire:
  PUSH HL
  CALL __mtr_di
__mtr_sem_acquire_check_ctr:
  LD C,(HL)
  INC HL
  LD B,(HL)
  DEC HL
  LD A,C
  OR B
  JR NZ,__mtr_sem_acquire_ready
  CALL __mtr_yield
  JR __mtr_sem_acquire_check_ctr
__mtr_sem_acquire_ready:
  DEC BC
; TODO: overflow assert
  LD (HL),C
  INC HL
  LD (HL),B
  POP HL
  CALL __mtr_ei
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Attempts to acquire semaphore.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_sem_try_acquire:
  PUSH HL
  CALL __mtr_di
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD A,C
  OR B
  JR NZ,__mtr_sem_try_acquire_01
  XOR A ; C:0, Z:1
  PUSH AF
  JR __mtr_sem_try_acquire_02
__mtr_sem_try_acquire_01:
  PUSH AF ; to save Z:0
  DEC HL
  DEC DE
; TODO: overflow assert
  LD (HL),C
  INC HL
  LD (HL),B
__mtr_sem_try_acquire_02:
  POP HL
  CALL __mtr_ei
  POP AF ; C:0, Z:0
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Releases semaphore.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_sem_release:
  PUSH HL
  CALL __mtr_di
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC BC
; TODO: overflow assert
  DEC HL
  LD (HL),C
  INC HL
  LD (HL),B
  POP HL
  CALL __mtr_ei
  XOR A
  RET
