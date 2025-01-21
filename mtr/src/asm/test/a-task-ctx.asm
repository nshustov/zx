#include "mtr-task-ctx.inc"

SECTION data
ORG 0x9000

__mtr_tasks_ctr:
  defw 0

__mtr_active_tasks_ctr:
  defw 0

__mtr_current_task_ctx:
  defw 0

__mtr_task_ctx_start:
  defw 0x9000

__mtr_task_ctx_end:
  defw 0xFFFF
