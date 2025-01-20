#include "mtr-im2.inc"

SECTION data
__mtr_flags:
; bit 0: 1 if we are in IM2 handler
  defb 0

SECTION data

__mtr_im2_switch:
  defw __mtr_default_im2_switch

SECTION code
__mtr_default_im2_switch:
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets address of function that will be called when IM2 interrupt occured.
; The function is called before task switch happens.
; [in] HL : function address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUBLIC __mtr_set_im2_switch
__mtr_set_im2_switch:
  CALL __mtr_di
  LD (__mtr_im2_switch),HL
  CALL __mtr_ei
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gets address of function that is called when IM2 interrupt occured.
; [out] HL : function address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUBLIC __mtr_get_im2_switch
__mtr_get_im2_switch:
  CALL __mtr_di
  LD HL,(__mtr_im2_switch)
  CALL __mtr_ei
  XOR A
  RET

SECTION data
__mtr_task_switch:
  defw __mtr_im2_task_switch

SECTION code
__mtr_im2_task_switch:
  PUSH AF
; reset im2 handler flag
  LD A,(__mtr_flags)
  RES 0,A
  LD (__mtr_flags),A
  POP AF
  EI
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets address of function that will be called after task is switched.
; The function are executed on the task stack and within its context.
; It must preserve all registers for the task to continue and call
; (or jump to) the previously set task switch routine in the end.
; [in] HL : routine address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUBLIC __mtr_set_task_switch
__mtr_set_task_switch:
  CALL __mtr_di
  LD (__mtr_task_switch),HL
  CALL __mtr_ei
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gets address of routine that is called after task was switched.
; [in] HL : routine address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUBLIC __mtr_get_task_switch
__mtr_get_task_switch:
  CALL __mtr_di
  LD HL,(__mtr_task_switch)
  CALL __mtr_ei
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks if there are more than 1 tasks are running
; [out] F: Z - no more tasks
; [out] F: NZ - there are more tasks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_has_multiple_tasks:
  PUSH HL
  LD HL,(__mtr_tasks_ctr)
  LD A,L
  DEC L
  OR H
  POP HL
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convenience routine to jump to the address in HL
; Is used to emulate CALL (HL)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_call_hl:
  JP (HL)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Switches execution to the next task, if available.
; Interrupts are enabled upon return.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_switch_task:
  DI
  PUSH AF
; if we are in im2 handler, call im2 switch
  LD A,(__mtr_flags)
  BIT 0,A
  JZ,__mtr_switch_task_not_im2
  PUSH HL
  LD HL,(__mtr_im2_switch)
  CALL __mtr_call_hl
  POP HL
__mtr_switch_task_not_im2:
; check if it is a last task
  CALL __mtr_has_more_tasks
  JR NZ, __mtr_switch_task_has_more_tasks
  POP AF
  EI
  RET ; no more tasks, current task's execution continues
; there are more tasks
__mtr_switch_task_has_more_tasks:
; save current task registers on task's stack
  CALL __mtr_save_all_regs
; save current task SP
  LD DE,(__mtr_current_task)
  LD HL,0
  ADD HL,SP
  EX DE,HL
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL
  INC HL ; account for the task flags entry in slot
; find next task
  LD BC,(__mtr_tasks_data_end) ; prep for checking if we reached the end of slots
; check current address against end of slots
__mtr_switch_task_check_end_of_slots:
  PUSH HL
  OR A
  SBC HL,BC ; BC has the address after the end of slots
  POP HL
  JR NZ, __mtr_switch_task_check_slot ; not at the end of slots
; at the end of slots, continue from the first slot
  LD HL,(__mtr_tasks_data_start)
__mtr_switch_task_check_slot:
; check if slot's SP is set
  LD E,(HL)
  INC HL
  LD D,(HL) ; DE has SP from slot
  INC HL
  INC HL ; account for the task flags entry in slot
  LD A,E
  OR D
  JR Z,__mtr_switch_task_check_end_of_slots ; slot's SP is not set, continue
; slot's SP is set, we found task
; DE has SP from slot, but HL is on the next task slot address
; save new current task slot address
  DEC HL
  DEC HL
  DEC HL
  LD (__mtr_current_task),HL
; switch to task's SP
  EX DE,HL
  LD SP,HL
; restore task's registers
  CALL __mtr_restore_all_regs
; put task switch routine address on stack
  PUSH HL
  LD HL,(__mtr_task_switch)
  EX (SP),HL
; invoke task switch
  RET

