#ifndef _MTR_CONTROL_INC_
#define _MTR_CONTROL_INC_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If MTR is in cooperative mode, executes RET with
; address on stack preceeding return address of
; caller
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_exit_if_cooperative

#endif