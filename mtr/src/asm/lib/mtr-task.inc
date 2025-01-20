#ifndef _MTR_TASK_
#define _MTR_TASK_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gets current task's context.
; [out] HL current task's context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_get_current_task_ctx
#define mtr_get_current_task_ctx __mtr_get_current_task_ctx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Activates task.
; [in] HL task context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_activate
#define mtr_task_activate __mtr_task_activate

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Deactivates task.
; [in] HL task context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_deactivate
#define mtr_task_deactivate __mtr_task_deactivate

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Creates a new task context.
; [out] HL address of new initialized task context
; Errors: if no free slot found.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_new_ctx
#define mtr_task_new_ctx __mtr_task_new_ctx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initializes task context.
; [in] HL task context
; [in] DE task SP
; [in] BC task ei/di counter
; [in] A task flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_init_ctx
#define mtr_task_init_ctx __mtr_task_init_ctx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Creates a new task and starts it.
; New task will have the register values of the caller.
; [in] The task data must be placed on stack before the call:
; SP+0: task entry point
; SP+2: task SP
; SP+4: task ei/di counter
; SP+6: task flags (AF, flags in A)
; [out] HL task context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_start
#define mtr_task_start __mtr_task_start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Creates new task.
; Task stack must be initialized before the invocation.
; [in] HL task entry point
; [in] DE task SP
; [in] BC task ei/di counter
; [in] A task flags
; [out] HL task context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_create
#define mtr_task_create __mtr_task_create

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ends execution of the current task.
; If it was the last task, shutdowns MTR.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_end
#define mtr_task_end __mtr_task_end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aborts task execution.
; [in] HL task context address.
; If it is the current task, equivalent to mtr_task_end.
; If it was the last task, shutdowns MTR.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_task_abort
#define mtr_task_abort __mtr_task_abort

#endif
