#ifndef _MTR_SEM_INC_
#define _MTR_SEM_INC_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Acquires semaphore.
; While semaphore counter is zero, yields to other tasks.
; When semaphore is acquired, semaphore counter is decremented.
; [in] HL : semaphore address
; [out] BC : updated semaphore counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_sem_acquire
#define mtr_sem_acquire __mtr_sem_acquire

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Attempts to acquire semaphore.
; If semaphore counter is not zero, acquires it; otherwise
; returns.
; When semaphore is acquired, semaphore counter is decremented.
; Interrupts are enabled upon return.
; [in] HL : semaphore address
; [out] F: Z:0 semaphore acquired, Z:1 semaphore not acquired
; [out] BC : semaphore counter (updated if sempahore was acquired)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_sem_try_acquire
#define mtr_sem_try_acquire __mtr_sem_try_acquire

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Releases semaphore.
; Semaphore counter is incremented.
; During execution suspends interrupts using counted interrupts API.
; [in] HL : semaphore address
; [out] BC : updated semaphore counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GLOBAL __mtr_sem_release
#define mtr_sem_release __mtr_sem_release

#endif
