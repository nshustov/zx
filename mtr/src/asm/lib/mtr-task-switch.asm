#include "mtr-task.inc"
#include "mtr-task-switch.inc"

SECTION data
__mtr_task_switched:
  defw 0 

SECTION code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets address of routine that will be called after task is switched.
; The function are executed on the task stack and within its context.
; It must preserve all registers for the task to continue and call
; (or jump to) the previously set task switch function in the end.
; [in] HL : function address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_set_task_switched:
  CALL __mtr_di_guard
  LD (__mtr_task_switch),HL
  CALL __mtr_ei_guard
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gets address of function that is called after task was switched.
; [in] HL : function address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_get_task_switched:
  CALL __mtr_di_guard
  LD HL,(__mtr_task_switch)
  CALL __mtr_ei_guard
  XOR A
  RET

; aux: checks if there are more than 1 tasks are running
; [out] F: Z - no more tasks
; [out] F: NZ - there are more tasks
__mtr_has_multiple_tasks:
  PUSH HL
  LD HL,(__mtr_tasks_ctr)
  LD A,L
  DEC L
  OR H
  POP HL
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] HL current task slot address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
??????????
__mtr_task_jump:
  DI
  EX DE,HL
  LD HL,(__mtr_tasks_ctr)
  LD A,L
  OR H
  EX DE,HL
  JR NZ,

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Switches execution to the next task, if available.
; Interrupts are enabled upon return.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_switch_task:
  DI
  PUSH AF
; check if it is a last task
  CALL __mtr_has_multiple_tasks
  JR NZ, __mtr_switch_task_has_more_tasks
  POP AF
  EI
  RET ; no more tasks, current task's execution continues
; there are more tasks
__mtr_switch_task_has_more_tasks:
; save current task registers on task's stack
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
; find next task
__mtr_switch_task_next_task: ; this is also an entry point when task ends, HL should point on the context of the current task
  LD BC,(__mtr_tasks_data_end) ; prep for checking if we reached the end of slots
; next task context
__mtr_switch_task_next_task_ctx:
  LD DE,__MTR_TASK_CTX_LEN
  ADD HL,DE
  PUSH HL
  OR A
  SBC HL,BC ; BC has the address after the end of slots
  POP HL
  JR NZ, __mtr_switch_task_check_sp ; not at the end of slots
; at the end of slots, continue from the first slot
  LD HL,(__mtr_tasks_data_start)
__mtr_switch_task_check_sp:
; check if slot's SP is set
  PUSH HL
  LD DE,__MTR_TASK_CTX_SP
  ADD HL,DE
  LD E,(HL)
  INC HL
  LD D,(HL) ; DE has SP from slot
  POP HL
  LD A,E
  OR D
  JR Z,__mtr_switch_task_next_task_ctx ; slot's SP is not set, continue
; slot's SP is set, we found task
; DE has SP from slot
; save new current task slot address
  LD (__mtr_current_task_ctx),HL
; switch to task's SP
  EX DE,HL
  LD SP,HL
; restore task's registers from its stack
  CALL __mtr_restore_all_regs
; put task switch function address on stack
  PUSH HL
  LD HL,(__mtr_task_switched)
  EX (SP),HL
; invoke task switch
  RET
