root := ../../..

asm-libs := \
  mtr \
  mtr-util

mtr.lib.opts := --split-bin

shared-asm-libs := $(asm-libs)

shared-asm-includes := \
  mtr-control.inc \
  mtr-eidi.inc \
  mtr.inc \
  mtr-macro.inc \
  mtr-task-ctx.inc \
  mtr-task.inc \
  mtr-task-yield.inc \
  mtr-util-print.inc \
  mtr-util-regs.inc

include $(root)/build/asm-lib.include
	
