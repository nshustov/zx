#include "mtr-task.inc"
#include "mtr-eidi.inc"
#include "mtr-control.inc"

SECTION code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_exit_if_cooperative:
  LD A,(__mtr_flags)
  BIT __MTR_FLAGS_IS_PREEMPTIVE_BIT,A
  RET NZ
  EX (SP),HL
  POP HL
  POP AF
  RET

; aux: loads current task's eidi counter into DE,
; leaving HL with address of the last (high) counter byte
__mtr_load_task_eidi_ctr:
  LD HL,(__mtr_current_task_ctx)
  LD DE,__MTR_TASK_CTX_EIDI_CTR
  ADD HL,DE
  LD E,(HL)
  INC HL
  LD D,(HL)
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_di_guard:
  PUSH AF
  CALL __mtr_exit_if_cooperative
  CALL __mtr_di
  POP AF
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_di:
  DI
  PUSH HL
  PUSH DE
  CALL __mtr_load_task_eidi_ctr
  INC DE
; TODO: overflow assert
  LD (HL),D
  DEC HL
  LD (HL),E
  POP DE
  POP HL
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_ei_guard:
  PUSH AF
  CALL __mtr_exit_if_cooperative
  CALL __mtr_ei
  POP AF
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_ei:
  DI
  PUSH HL
  PUSH DE
  CALL __mtr_load_task_eidi_ctr
  DEC DE
; TODO: overflow assert
  LD (HL),D
  DEC HL
  LD (HL),E
  ORR D,E
  JR NZ, __mtr_ei_done
  EI
__mtr_ei_done:
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [out] DE : current task __mtr_ei/__mtr_di counter value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_get_eidi:
  DI
  PUSH HL
  CALL __mtr_load_task_eidi_ctr
  POP HL
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] DE : __mtr_ei/__mtr_di counter value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_set_eidi:
  DI
  PUSH HL
  PUSH BC
  LD HL,(__mtr_current_task_ctx)
  LD BC,__MTR_TASK_CTX_EIDI_CTR
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
  ORR D,E
  JR NZ,__mtr_set_eidi_done
  EI
__mtr_set_eidi_done:
  POP BC
  POP HL
  XOR A
  RET

__mtr_restore_eidi:
  DI
  PUSH AF
  PUSH HL
  PUSH DE
  CALL __mtr_load_task_eidi_ctr
  ORR D,E
  JR NZ,__mtr_restore_eidi_done
  EI
__mtr_restore_eidi_done:
  POP DE
  POP HL
  POP AF
  RET
