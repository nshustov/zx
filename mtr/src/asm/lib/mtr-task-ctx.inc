#ifndef _MTR_TASK_CTX_
#define _MTR_TASK_CTX_

GLOBAL __mtr_tasks_ctr
#define mtr_task_ctr __mtr_tasks_ctr

GLOBAL __mtr_active_tasks_ctr
#define mtr_active_tasks_ctr __mtr_active_tasks_ctr

GLOBAL __mtr_current_task_ctx
#define mtr_current_task_ctx __mtr_current_task_ctx

GLOBAL __mtr_task_ctx_start
#define mtr_task_ctx_start __mtr_task_ctx_start

GLOBAL __mtr_task_ctx_end
#define mtr_task_ctx_end __mtr_task_ctx_end


#define __MTR_TASK_CTX_SP 0
#define __MTR_TASK_CTX_FLAGS 2
#define __MTR_TASK_CTX_EIDI_CTR 3
#define __MTR_TASK_CTX_LEN 5

#define __MTR_TASK_CTX_FLAGS_ACTIVE 1
#define __MTR_TASK_CTX_FLAGS_ACTIVE_BIT 0

#define __MTR_TASK_CTX_FLAGS_OWNS_SYSCALL 2
#define __MTR_TASK_CTX_FLAGS_OWNS_SYSCALL_BIT 1

#endif
