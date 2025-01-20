#include "mtr-task-ctx.inc"
#include "mtr-control.inc"

SECTION data

; 0: 1 for preemptive, 0 for cooperative
__mtr_flags:
  defb 0

__mtr_shutdown:
  defw __mtr_shutdown_mtr

SECTION code

__mtr_shutdown_mtr:
;  RST 0x00 ?
  HALT
  JR __mtr_shutdown_mtr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Makes the caller the first and the only task of MTR.
; Must not be invoked while MTR scheduler is active.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_init:
  PUSH HL
  PUSH DE
; caller is the very first task
  LD HL,(__mtr_task_ctx_start)
  LD (__mtr_current_task_ctx),HL
; fill task context sp to mark it as reserved
  LD DE,__MTR_TASK_CTX_SP
  ADD HL,DE
  EX DE,HL
  LD HL,SP
  EX DE,HL
  LD (HL),E
  INC HL
  LD (HL),D
; initialize task context slots
  LD DE,(__mtr_task_ctx_end)
__mtr_init_clear_ctx_byte:
  XOR A
  LD (HL),A
  INC HL
  PUSH HL
  SBC HL,DE
  POP HL
  JR NZ,__mtr_init_clear_ctx_byte
; initialize tasks counter
  LD HL,1
  LD (__mtr_tasks_ctr),HL
; done
  POP DE
  POP HL
  XOR A
  RET
