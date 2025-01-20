#ifndef _MTR_EIDI_INC_
#define _MTR_EIDI_INC_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Disables interrupts.
; This function is re-enterable;
; every invocaion of must be paired with __mtr_ei to have
; interrupts re-enabled.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_di
#define mtr_di __mtr_di

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Enables interrupts; see __mtr_di
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_ei
#define mtr_ei __mtr_ei

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Like mtr_di but is noop if MTR is in cooperative mode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_di_guard
#define mtr_di_guard __mtr_di_guard

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Like mtr_ei but is noop if MTR is in cooperative mode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_ei_guard
#define mtr_ei_guard __mtr_ei_guard

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Resets current task __mtr_ei/__mtr_di counter and returns
; its value. Disables interrupts.
; [out] DE : current task __mtr_ei/__mtr_di counter value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_reset_eidi
#define mtr_reset_eidi __mtr_reset_eidi

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets current task __mtr_ei/__mtr_di counter and sets up
; interrupts according to its value.
; [in] DE : __mtr_ei/__mtr_di counter value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_set_eidi
#define mtr_set_eidi __mtr_set_eidi

#endif
