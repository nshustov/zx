#ifndef _MTR_TASK_MACRO_
#define _MTR_TASK_MACRO_

MACRO ORR r1,r2
  LD A,r1
  OR r2
ENDM

MACRO ARR r1,r2
  LD A,r1
  AND r2
ENDM

#endif
