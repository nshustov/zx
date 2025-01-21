#include "mtr-control.inc"
#include "mtr-task.inc"
#include "mtr-util-print.inc"

SECTION code

ORG 0x8000

CALL mtr_init
PUSH AF
PUSH HL
CALL  mtr_print_str
defb "my string",13,0
POP HL
POP AF
RET

