#ifndef _MTR_UTILS_REGS_INC_
#define _MTR_UTILS_REGS_INC_

; __mtr_save_regs memory block size for registers
#define __MTR_SAVE_REGS_SIZE 18
; __mtr_save_all_regs memory block size for registers
#define __MTR_SAVE_ALL_REGS_SIZE 20

; Offsets to the saved registers for __mtr_save_* functions
#define __MTR_SAVE_REGS_OFFSET_IX 0
#define __MTR_SAVE_REGS_OFFSET_IY 2
#define __MTR_SAVE_REGS_OFFSET_AF_ALT 4
#define __MTR_SAVE_REGS_OFFSET_BC_ALT 6
#define __MTR_SAVE_REGS_OFFSET_DE_ALT 8
#define __MTR_SAVE_REGS_OFFSET_HL_ALT 10
#define __MTR_SAVE_REGS_OFFSET_AF 12
#define __MTR_SAVE_REGS_OFFSET_BC 14
#define __MTR_SAVE_REGS_OFFSET_DE 16
#define __MTR_SAVE_REGS_OFFSET_HL 18

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Saves all registers on the stack
;
; Order of registers stored on stack:
; IX  ; SP+0
; IY  ; SP+2
; AF' ; SP+4
; BC' ; SP+6
; DE' ; SP+8
; HL' ; SP+10
; AF  ; SP+12
; BC  ; SP+14
; DE  ; SP+16
; HL  ; SP+18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_save_all_regs
#define mtr_save_all_regs __mtr_save_all_regs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Saves registers on the stack, all but HL
; HL value is not preserved
;
; Order of registers stored on stack:
; AF' ; SP+0
; BC' ; SP+2
; DE' ; SP+4
; HL' ; SP+6
; IX  ; SP+8
; IY  ; SP+10
; AF  ; SP+12
; BC  ; SP+14
; DE  ; SP+16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GLOBAL __mtr_save_regs
#define mtr_save_regs __mtr_save_regs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restores all registers from the stack, as saved by
; __mtr_save_all_regs.
;
; Order of registers stored on stack (below PC return address):
; IX  ; SP+0
; IY  ; SP+2
; AF' ; SP+4
; BC' ; SP+6
; DE' ; SP+8
; HL' ; SP+10
; AF  ; SP+12
; BC  ; SP+14
; DE  ; SP+16
; HL  ; SP+18
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_restore_all_regs
#define mtr_restore_all_regs __mtr_restore_all_regs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restores all registers from the stack, as saved by
; __mtr_save_regs
;
; Order of registers stored on stack:
; AF' ; SP+0
; BC' ; SP+2
; DE' ; SP+4
; HL' ; SP+6
; IX  ; SP+8
; IY  ; SP+10
; AF  ; SP+12
; BC  ; SP+14
; DE  ; SP+16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_restore_regs
#define mtr_restore_regs __mtr_restore_regs

#endif
