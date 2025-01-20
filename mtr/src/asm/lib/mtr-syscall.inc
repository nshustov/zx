#ifndef _MTR_SYSCALL_INC_
#define _MTR_SYSCALL_INC_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Invokes the function which address is expected to be after
; the CALL __mtr_syscall instruction.
; While this function is running, the tasks switching is
; suspended while MTR will still does the time counting.
; This function is re-enterable within the current task.
; When a task is in syscall, another task invoking the syscall
; is blocked until the task performing syscall will complete
; the syscall.
;
; Usage:
;
; CALL __mtr_syscall
; defw <function address>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_syscall
#define mtr_syscall __mtr_syscall

#endif
