#include "mtr-macro.inc"
#include "mtr-eidi.inc"
#include "mtr-control.inc"
#include "mtr-task-ctx.inc"
#include "mtr-util-regs.inc"
#include "mtr-task.inc"

SECTION code

EXTERN __mtr_next_task

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__mtr_get_current_task_ctx:
  CALL __mtr_di_guard
  LD HL,(__mtr_current_task_ctx)
  CALL __mtr_ei_guard
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] HL task context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_task_activate:
  CALL __mtr_di_guard
  PUSH HL
  PUSH BC
  LD BC,__MTR_TASK_CTX_FLAGS
  ADD HL,BC
  LD A,__MTR_TASK_CTX_FLAGS_ACTIVE
  OR (HL)
  LD (HL),A
  LD HL,(__mtr_active_tasks_ctr)
  INC HL
; TODO overflow assert
  LD (__mtr_active_tasks_ctr),HL
  POP BC
  POP HL
  CALL __mtr_ei_guard
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] HL task context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_task_deactivate:
  CALL __mtr_di_guard
  PUSH HL
  PUSH BC
  LD BC,__MTR_TASK_CTX_FLAGS
  ADD HL,BC
  LD A,~__MTR_TASK_CTX_FLAGS_ACTIVE
  AND (HL)
  LD (HL),A
  LD HL,(__mtr_active_tasks_ctr)
  DEC HL
; TODO overflow assert
  LD (__mtr_active_tasks_ctr),HL
  POP BC
  POP HL
  CALL __mtr_ei_guard
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [out] HL address of new initialized task context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_task_new_ctx:
  CALL __mtr_di_guard
  PUSH BC
  PUSH DE
  PUSH HL
  LD HL,(__mtr_task_ctx_start)
  LD DE,(__mtr_task_ctx_end)
__mtr_task_new_ctx_check_sp:
  PUSH HL
  LD BC,__MTR_TASK_CTX_SP
  ADD HL,BC
  LD A,(HL)
  INC HL
  OR (HL)
  POP HL
  JR Z,__mtr_task_new_ctx_found
; next slot
  LD BC,__MTR_TASK_CTX_LEN
  ADD HL,BC
  PUSH HL
  OR A
  SBC HL,DE
  POP HL
  JR NZ,__mtr_task_new_ctx_check_sp
; no free slots
  LD A,1
  SCF
  JR __mtr_task_new_ctx_done
__mtr_task_new_ctx_found:
; clear task slot
  LD E,L
  LD D,H
  XOR A
__mtr_task_new_ctx_clear_byte:
  LD (HL),A
  DEC BC
  ORR B,C
  JR NZ,__mtr_task_new_ctx_clear_byte
  LD L,E
  LD H,D
  EX (SP),HL
__mtr_task_new_ctx_done:
  POP HL
  POP DE
  POP BC
  CALL __mtr_ei_guard
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] HL task context
; [in] DE task SP
; [in] BC task ei/di counter
; [in] A task flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_task_init_ctx:
  CALL __mtr_di_guard
  PUSH BC
; set SP
  PUSH HL
  LD BC,__MTR_TASK_CTX_SP
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
  POP HL
; set ei/di counter
  POP BC
  PUSH DE
  PUSH HL
  LD DE,__MTR_TASK_CTX_EIDI_CTR
  ADD HL,DE
  LD (HL),C
  INC HL
  LD (HL),B
  POP HL
; set flags
  PUSH HL
  LD DE,__MTR_TASK_CTX_FLAGS
  ADD HL,DE
  LD (HL),A
; increment task counter
  LD HL,(__mtr_tasks_ctr)
  INC HL
; TODO overflow assert
  LD (__mtr_tasks_ctr),HL
  POP HL
  CALL __mtr_ei_guard
  XOR A
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] The task data must be placed on stack before the call:
; SP+0: task entry point
; SP+2: task SP
; SP+4: task ei/di counter
; SP+6: task flags (AF, flags in A)
; [out] HL task context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_task_start:
  DI
  CALL __mtr_save_all_regs
  LD IX, __MTR_SAVE_ALL_REGS_SIZE ; offset to the stack pointer in the beginning
  ADD IX,SP
  LD L,(IX+0)
  LD H,(IX+1) ; task SP in HL
  LD E,(IX+2)
  LD D,(IX+3) ; task entry point is in DE
  RST 0 ; TODO: incomplete


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] HL task entry point
; [in] DE task SP
; [in] BC task ei/di counter
; [in] A task flags
; [out] HL task context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_task_create:
  CALL __mtr_di_guard
  PUSH DE
  PUSH AF
; put entry point on task's stack
  EX DE,HL
  DEC HL
  LD (HL),D
  DEC HL
  LD (HL),E
; new task context
  CALL __mtr_task_new_ctx
; initialize task context
  POP DE
  POP AF
  CALL __mtr_task_init_ctx
; done
  XOR A
  CALL __mtr_ei_guard
  RET


; aux: Deletes task which context address is in HL.
; If it was the last task, shutdowns MTR.
; Does not preserve HL,BC,AF.
__mtr_task_delete:
; wipe out SP in the current task slot
  LD BC,__MTR_TASK_CTX_SP
  ADD HL,BC
  XOR A
  LD (HL),A
  INC HL
  LD (HL),A
; decrement task counter
  LD HL,(__mtr_tasks_ctr)
  DEC HL
; TODO overflow assert
  LD (__mtr_tasks_ctr),HL
  JR Z,__mtr_task_deleted_last_task
  LD HL,(__mtr_active_tasks_ctr)
  DEC HL
; TODO overflow assert
  LD (__mtr_active_tasks_ctr),HL
  RET
__mtr_task_deleted_last_task:
; no more active tasks, shutdown MTR
  LD HL,(__mtr_shutdown)
  JP (HL)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_task_end:
  DI
__mtr_task_end_delete_current_task:
  LD HL,(__mtr_current_task_ctx)
  CALL __mtr_task_delete
  JP __mtr_next_task

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] HL task context address.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_task_abort:
  CALL __mtr_di_guard
  PUSH HL
  PUSH BC
  LD BC,(__mtr_current_task_ctx)
  OR A
  SBC HL,BC
  JR Z, __mtr_task_end_delete_current_task
  CALL __mtr_task_delete
  POP BC
  POP HL
  CALL __mtr_ei_guard
  XOR A
  RET
