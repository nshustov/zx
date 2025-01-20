#ifndef _MTR_IM2_INC_
#define _MTR_IM2_INC_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Counted interrutps API: Disables interrupts.
; This routine is re-enterable;
; every invocaion of must be paired with __mtr_ei to have
; interrupts re-enabled.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUBLIC __mtr_di
#define mtr_di __mtr_di

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Counted interrutps API: Enables interrupts; see __mtr_di.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUBLIC __mtr_ei
#define mtr_ei __mtr_ei

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Yields execution to the next task,
; if available.
; Inerrupts are enabled upon return.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUBLIC __mtr_yield
#define mtr_yield __mtr_yield

#endif
