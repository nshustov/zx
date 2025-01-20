#include "mtr-utils.inc"

SECTION data

LOCAL ix_reg_str, iy_reg_str, hl_reg_str, de_reg_str, bc_reg_str, a_reg_str, f_reg_str
ix_reg_str: defb "IX",0
iy_reg_str: defb "   IY",0
hl_reg_str: defb "\n\nHL",0
de_reg_str: defb "   DE",0
bc_reg_str: defb "\nBC",0
a_reg_str:  defb "    A",0
f_reg_str:  defb "\n F",0
ip_reg_str: defb "\n IP",0
sp_reg_str: defb "\n IP",0

SECTION code

; aux: prints named 1-byte data as hex
; [in] HL value address
; [out] E contains value
; [out] HL value address incremented
__mtr_dbg_print_hl_hex:
  LD A,(HL)
  LD E,A
  CALL __mtr_print_hex
  INC HL
  RET

; aux: prints named register data
; Output format:
;
; <name>[']= XX
;
; [in] HL address of register value
; [in] BC name string
; [in] A ==0 - regular registers;
;      A !=0 - alternative registers
; [out] E pair value
; [out] incremented HL
__mtr_dbg_print_named_reg:
  PUSH HL ; save HL
  PUSH AF ; save AF
  PUSH BC ;
  POP HL  ; HL <->BC
; print name
  CALL __mtr_print_string
; print space or ' suffix
  POP AF
  OR A
  LD A,'\''
  JR Z,__mtr_dbg_print_named_reg_suffix
  LD A,' '
__mtr_dbg_print_named_reg_suffix:
  CALL __mtr_print_chr
; print "= "
  CALL __mtr_print_str
  defb "= ",0
; print value
  POP HL
  JR __mtr_dbg_print_hl_hex; value in E

; aux: prints named registers pair data
; Output format:
;
; <pair name>[']= XXXX
;
; [in] HL address of 2-byte pair value
; [in] BC pair name string
; [in] A ==0 - regular registers;
;      A !=0 - alternative registers
; [out] DE pair value
; [out] HL = [in] HL + 2
__mtr_dbg_print_named_reg_pair:
  CALL __mtr_dbg_print_named_reg
  LD D,E ; high register in D
; print first pair low register and return
  JR __mtr_dbg_print_hl_hex ; low register in E

; aux: prints spaces counted by value in A.
; Does not preserve E.
__mtr_dbg_dump_mem_print_spaces:
  DEC A
  RET Z
  LD E,A
  LD A,' '
  CALL __mtr_print_chr
  LD A,E
  JR __mtr_dbg_dump_mem_print_spaces

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [in] HL memory address
; [in] BC number of bytes
; [in] A bytes per line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__mtr_dbg_dump_mem:
  PUSH DE
  LD D,A ; save initial bytes in row counter
; print bytes
; new row
__mtr_dbg_dump_mem_print_new_row:
  PUSH HL ; save memory pointer
  PUSH BC ; save bytes counter
__mtr_dbg_dump_mem_print_byte:
  LD E,A ; save bytes in row counter
; print byte
  LD A,(HL)
  CALL __mtr_print_hex
; print space
  LD A,' '
  CALL __mtr_print_chr
; decrement bytes counter
  DEC BC
  LD A,B
  OR C
  LD A,E ; restore bytes in row counter
  JR NZ,__mtr_dbg_dump_mem_next_byte ; have more bytes to print
; pad what is left with spaces
  CALL __mtr_dbg_dump_mem_print_spaces
????????
__mtr_dbg_dump_mem_next_byte:
; decrement bytes in row counter
  DEC A
  JR NZ,__mtr_dbg_dump_mem_print_byte ; more bytes in the row
; print delimiter
  CALL __mtr_print_str
  defb " | ",0
; print chars
  LD A,D ; initial bytes in row counter
  POP BC ; bytes counter before row
  POP HL ; memory pointer before row
__mtr_dbg_dump_mem_print_code_char:
  LD E,A  ; save bytes in row counter
; display non-printable chars as '.'
  LD A,(HL)
  INC HL
  CP 0x21
  JR C,__mtr_dbg_dump_mem_non_printable_char
  CP 0xA5
  JR C,__mtr_dbg_dump_mem_print_char
__mtr_dbg_dump_mem_non_printable_char:
  LD A,'.'
__mtr_dbg_dump_mem_print_char:
  CALL __mtr_print_chr
; decrement bytes counter
  DEC BC
  LD A,B
  OR C
  JR Z,__mtr_dbg_dump_mem_done ; no more bytes to process

; decrement bytes in row counter
  LD A,E  ; restore bytes in row counter
  DEC A
  JR NZ,__mtr_dbg_dump_mem_print_code_char ; another character

; newline
  LD A,'\n'
  CALL __mtr_print_chr

; rinse and repeat
  LD A,D  ; set bytes in row counter
  JR __mtr_dbg_dump_mem_print_new_row ; new row

; done with bytes
__mtr_dbg_dump_mem_done:
; newline
  LD A,'\n'
  CALL __mtr_print_chr
; exit
  POP DE
  RET

__mtr_dbg_print_flags3:
  RET

__mtr_dbg_print_flags:
  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; dumps registers info on screen
; [in] HL points to registers area of:
;
; IX
; IY
; AF'
; BC'
; DE'
; HL'
; AF
; BC
; DE
; HL
; IP
; SP
;
; Output example:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IX = 0123   IY = 4567
;
; HL'= 0123   DE'= 4567
; BC'= 89AB    A'= CD
;  F'= 8C (P,NZ,NC)
;
; HL = 0123   DE = 4567
; BC = 89AB    A = CD
;  F = 8C (P,NZ,NC)
; 
; IP = 2345
; 01 24 45 67 89 AB CD EF | ..eFt.!=
; 01 24 45 67 89 AB CD EF | ..eFt.!=
; 
; SP = 4567
; 01 24 45 67 89 AB CD EF | ..eFt.!=
; 01 24 45 67 89 AB CD EF | ..eFt.!=
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUBLIC __mtr_dbg_dump
__mtr_dbg_dump:

; print IX,IY registers
  XOR A
  LD BC,ix_reg_str
  CALL __mtr_dbg_print_named_reg_pair
  XOR A
  LD BC,iy_reg_str
  CALL __mtr_dbg_print_named_reg_pair

  XOR A ; print alt registers
  INC A
  CALL __mtr_dbg_print_register_pairs

  XOR A ; print registers
  CALL __mtr_dbg_print_register_pairs

__mtr_dbg_print_register_pairs:
; print HL,DE,BC,A registers
  LD BC,hl_reg_str
  PUSH AF
  CALL __mtr_dbg_print_named_reg_pair
  POP AF
  LD BC,de_reg_str
  PUSH AF
  CALL __mtr_dbg_print_named_reg_pair
  POP AF
  LD BC,bc_reg_str
  PUSH AF
  CALL __mtr_dbg_print_named_reg_pair
  POP AF
  LD BC,a_reg_str
  PUSH AF
  CALL __mtr_dbg_print_named_reg

; print F
  POP AF
  LD BC,f_reg_str
  CALL __mtr_dbg_print_named_reg

; print flags
  CALL __mtr_print_str
  defb " (",0
  LD A,E
  CALL __mtr_dbg_print_flags
  CALL __mtr_print_str
  defb ')',13,13,0

; print IP
  XOR A
  LD BC,ip_reg_str
  CALL __mtr_dbg_print_named_reg_pair
  LD A,13
  CALL __mtr_print_chr


;print IP dump
  EX DE,HL
  LD BC,16 ; total bytes per dump line
  LD A,8   ; bytes per line
  CALL __mtr_dbg_dump_mem
  LD A,13
  CALL __mtr_print_chr
  EX DE,HL

; print SP
  XOR A
  LD BC,sp_reg_str
  CALL __mtr_dbg_print_named_reg_pair
  LD A,13
  CALL __mtr_print_chr

;print SP dump
  EX DE,HL
  LD BC,16 ; total bytes per dump line
  LD A,8   ; bytes per line
  CALL __mtr_dbg_dump_mem
  LD A,13
  CALL __mtr_print_chr
  EX DE,HL
  RET
