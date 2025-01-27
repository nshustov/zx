#include "mtr-macro.inc"
#include "mtr-eidi.inc"
#include "mtr-util-regs.inc"
#include "mtr-task.inc"
#include "mtr-task-ctx.inc"
#include "mtr-task-yield.inc"

SECTION mtr_data
__mtr_task_switching:
  defw __mtr_task_switching_mtr

__mtr_task_switched:
  defw __mtr_task_switched_mtr


SECTION mtr_code

PUBLIC __mtr_next_task

; MTR task switched function
; NOOP for now
__mtr_task_switching_mtr:
  RET

; MTR task switched function
; Restores the tasks registers from stack and turns execution to the stack
; RET from this function will invoke the task
__mtr_task_switched_mtr:
  CALL __mtr_restore_all_regs
  CALL __mtr_ei_guard
  RET

__call__mtr_task_switching:
  PUSH HL
  LD HL,(__mtr_task_switching)
  EX (SP),HL
  RET ; will jump to task switching rountine
; RET from task switching rountine will return to the caller of __call__mtr_task_switching

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_task_yield:
  CALL __mtr_di_guard
; check if it is a last active task
  PUSH HL
  PUSH AF
  LD HL,(__mtr_active_tasks_ctr)
  DEC HL
  ORR H,L
  JR NZ, __mtr_task_yield_has_more_tasks
  POP AF
  POP HL
  CALL __mtr_ei_guard
  RET ; no more tasks, current task's execution continues
; there are more tasks
__mtr_task_yield_has_more_tasks:
; correct current active tasks count
  LD (__mtr_active_tasks_ctr),HL
; save current task registers on task's stack
  CALL __mtr_save_all_regs
; call pre-switching function
  CALL __call__mtr_task_switching
  CALL __mtr_save_all_regs
; save current task SP
  LD HL,(__mtr_current_task_ctx)
  PUSH HL
  LD BC,__MTR_TASK_CTX_SP
  ADD HL,BC
  EX DE,HL
  LD HL,0
  ADD HL,SP
  EX DE,HL
  LD (HL),E
  INC HL
  LD (HL),D
  POP HL
__mtr_next_task: ; this is an entry point invoked from __mtr_task_end
; HL has address of the context of the current task
; find next task
  LD BC,(__mtr_task_ctx_end) ; prep for checking if we reached the end of slots
; next task context
__mtr_task_yield_next_task_ctx:
  LD DE,__MTR_TASK_CTX_LEN
  ADD HL,DE
  PUSH HL
  OR A
  SBC HL,BC ; BC has the address after the end of slots
  POP HL
  JR NZ, __mtr_task_yield_check_sp ; not at the end of slots
; at the end of slots, continue from the first slot
  LD HL,(__mtr_task_ctx_start)
__mtr_task_yield_check_sp:
; check if slot's SP is set
  PUSH HL
  LD DE,__MTR_TASK_CTX_SP
  ADD HL,DE
  LD E,(HL)
  INC HL
  LD D,(HL) ; DE has SP from slot
  POP HL
  ORR D,E
  JR Z,__mtr_task_yield_next_task_ctx ; slot's SP is not set
; slot's SP is set, check if task active
  PUSH HL
  LD BC,__MTR_TASK_CTX_FLAGS
  ADD HL,BC
  LD A,__MTR_TASK_CTX_FLAGS_ACTIVE
  AND (HL)
  POP HL
  JR Z,__mtr_task_yield_next_task_ctx ; task is not active
; task is active
; DE has SP from slot
; save new current task slot address
  LD (__mtr_current_task_ctx),HL
; switch to new task's SP
  EX DE,HL
  LD SP,HL
; restore task's registers from its stack
  CALL __mtr_restore_all_regs
; call task switched function
  PUSH HL
  LD HL,(__mtr_task_switched)
  EX (SP),HL
; invoke task switch
  RET ; will jump to task switched function
