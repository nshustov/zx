#include "mtr-task-ctx.inc"
#include "mtr-eidi.inc"
#include "mtr-syscall.inc"

SECTION mtr_data
; syscall counter
__mtr_syscall_counter:
defw 0

SECTION mtr_code

; aux: invokes the function which address on the stack preceeding
; the return address of the caller.
__mtr_make_syscall:
; EX w(SP), w(SP+2) :
  PUSH AF ; SP+4
  PUSH HL ; SP+2
  PUSH IX ; SP+0
  LD IX,6
  ADD IX,SP
  LD A,(IX+0)
  LD L,(IX+2)
  LD (IX+0),L
  LD (IX+2),A
  LD A,(IX+1)
  LD L,(IX+3)
  LD (IX+1),L
  LD (IX+3),A
  POP IX
  POP HL
  POP AF
  RET ; will jump to the address of function that was on stack before the return address
; then the RET instruction of the called function will return execution to the caller

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_syscall:
  CALL __mtr_di_guard
; prepare to call address stored in location next to CALL __mtr_syscall instruction
; save registers
  EX (SP),HL ; HL saved, ret address is in HL : SP+8
  PUSH DE ; DE saved : SP+6
  PUSH AF ; AF saved : SP+4
  PUSH BC ; BC saved : SP+2
  EX DE,HL
; check if the current task owns a syscall already
  LD HL,(__mtr_current_task_ctx)
  LD BC,__MTR_TASK_CTX_FLAGS
  ADD HL,BC
  LD A,(HL)
  BIT __MTR_TASK_CTX_FLAGS_OWNS_SYSCALL_BIT,A
  JR NZ, __mtr_syscall_increment_counter; task already owns syscall
__mtr_syscall_check_counter:
; check if there is a syscall by another task
  LD BC,(__mtr_syscall_counter)
  LD A,C
  OR B
  JR Z, __mtr_syscall_mark_task_as_owner; no other task in syscall
; there is another task in syscall
; wait for things to change:
; let MTR to execute other tasks and when we are resumed,
; we will see again if we can make a syscall
  CALL __mtr_yield
  JR __mtr_syscall_check_counter ; see if counter dropped to zero
__mtr_syscall_mark_task_as_owner:
; set task syscall flag
  SET 0,A
  LD (HL),A
__mtr_syscall_increment_counter:
; increase syscall counter
  INC BC
  LD (__mtr_syscall_counter),BC
; do syscall
; load call address to DE
  EX DE,HL ; HL has address after CALL __mtr_syscall, which points to 2-byte call address
  LD E,(HL)
  INC HL
  LD D,(HL) ; call address is in DE
  INC HL ; HL has address next to the call address location, we will return to there
; place corrected return address to stack, while restoring HL
; EX (SP+8),HL :
  PUSH IX ; IX saved: SP+0
  LD IX,8
  ADD IX,SP ; IX == SP+8, pointing to HL saved on stack
  LD A,(IX+0)
  LD (IX+0),L
  LD L,A
  LD A,(IX+1)
  LD (IX+1),H
  LD H,A
; HL is restored, ret address+2 is the return address
; restore other registers
  POP IX ; IX restored
  POP BC ; BC restored
  POP AF ; AF restored
  EX DE,HL ; call address in HL, HL in DE
  EX (SP),HL ; call address on stack, DE in HL
  EX DE,HL ; DE restored, HL restored
  CALL __mtr_make_syscall ; invoke helper to jump to the address on stack and return here
; save registers
  PUSH AF
  PUSH BC
  PUSH HL
; decrement the syscall counter
  LD BC, (__mtr_syscall_counter)
  DEC BC
  LD (__mtr_syscall_counter),BC
  JR NZ,__mtr_syscall_done ; we are still in syscall
; reset current task syscall flag
  LD HL,(__mtr_current_task_ctx)
  INC HL
  INC HL
  INC HL
  LD A,(HL)
  RES __MTR_TASK_CTX_FLAGS_OWNS_SYSCALL_BIT,A
  LD (HL),A
__mtr_syscall_done:
; restore registers and return to the corrected address
  POP HL
  POP BC
  POP AF
  CALL __mtr_ei_guard
  RET
