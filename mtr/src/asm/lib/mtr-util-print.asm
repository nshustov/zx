#include "mtr-util-regs.inc"
#include "mtr-util-print.inc"

; aux: prints low 4 bits of A as hex digit
__mtr_print_hex_low:
  PUSH HL
  CALL __mtr_save_regs
  ADD A,'0'
  CP '9'
  JR NC,__mtr_print_hex_low_char
  ADD A,7
__mtr_print_hex_low_char:
  RST 0x10
  CALL __mtr_restore_regs
  POP HL
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] A : number to print
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_print_hex:
  PUSH AF
  AND 0xF0
  RRA
  RRA
  RRA
  RRA
  CALL __mtr_print_hex_low
  POP AF
  AND 0x0F
  CALL __mtr_print_hex_low
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] HL string start
; [out] HL points to the next byte after string zero byte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_print_string:
  CALL __mtr_save_regs
__mtr_print_string_next_char:
  LD A,(HL)
  OR A
  JR Z,__mtr_print_string_done
  PUSH HL
  RST 0x10
  POP HL
  INC HL
  JR __mtr_print_string_next_char
__mtr_print_string_done:
  INC HL
  CALL __mtr_restore_regs
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_print_str:
  EX (SP),HL
  CALL __mtr_print_string
  EX (SP),HL
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] A : character to print
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_print_chr:
  CALL __mtr_save_all_regs
;  CALL __mtr_syscall
;  defw 0x10 ; RST 0x10
  RST 0x10
  CALL __mtr_restore_all_regs
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] HL string start
; [out] HL points to the next byte after string zero byte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUBLIC __mtr_skip_string
__mtr_skip_string:
  LD A,(HL)
  OR A
  JR Z,__mtr_skip_string_done
  INC HL
  JR __mtr_skip_string
__mtr_skip_string_done:
  INC HL
  RET
