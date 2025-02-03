#include "mtr-util-print.inc"

ORG 0x9000

SECTION code

PUSH HL
PUSH AF
CALL __mtr_print_str
defb "my string", 13, 0
POP AF
POP HL
RET

SECTION data
__mtr_tasks_ctr:
  defw 0

__mtr_active_tasks_ctr:
  defw 0

__mtr_current_task_ctx:
  defw 0

__mtr_task_ctx_start:
  defw 0

__mtr_task_ctx_end:
  defw 0
