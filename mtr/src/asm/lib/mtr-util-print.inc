#ifndef _MTR_UTILS_PRINT_INC_
#define _MTR_UTILS_PRINT_INC_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prints two-digit hex number
; [in] A : number to print
; All registers but AF are preserved.
; Returns no errors or checks.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_print_hex
#define mtr_print_hex __mtr_print_hex

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prints zero terminated string
; [in] HL string start
; [out] HL points to the next byte after string zero byte
; All other registers are preserved.
; Returns no errors or checks.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_print_string
#define mtr_print_string __mtr_print_string

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prints zero terminated string from location immediately
; following CALL instruction that invoked this function.
; The execution continues from the  address following the
; zero byte of the string.
; All registers but HL are preserved.
; Returns no errors or checks.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_print_str
#define mtr_print_str __mtr_print_str

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prints character.
; [in] A : character to print
; All registers are preserved.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_print_chr
#define mtr_print_chr __mtr_print_chr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Skips zero terminated string
; [in] HL string start
; [out] HL points to the next byte after string zero byte
; All other registers are preserved.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_skip_string
#define mtr_skip_string __mtr_skip_string

#endif