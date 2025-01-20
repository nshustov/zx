#ifndef _MTR_TASK_YIELD_
#define _MTR_TASK_YIELD_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function to be executed before switching from the current task
; the replacement for that function must invoke the previous 
; __mtr_task_switching function before returning
; the registers will be setup as they were in the current task 
; at the moment switch is happening.
; stack has these registers saved with __mtr_save_all_regs, 
; with task's CP preceeding it
; modification of the common registers is allowed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_switching
#define mtr_task_switching __mtr_task_switching

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function to be executed after switching to a new task
; the replacement for that function must invoke the previous 
; __mtr_task_switching function before returning
; the registers of the new task will be on the stack as they were
; saved with __mtr_save_all_regs, with task's CP preceeding it
; modification of the common registers is allowed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_switched
#define mtr_task_switched __mtr_task_switched

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Switches to execution between current task and the next active
; task, if available. If there is the next active task, invokes
; (mtr_task_switching) before switching and (mtr_task_switched)
; after switching.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_yield
#define mtr_task_yield __mtr_task_yield

#endif
