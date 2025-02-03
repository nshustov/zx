root := ../../../..
include $(root)/build/common.include

asm-bins := print-char
asm-taps := print-char

print-char.tap.org := 36864
print-char.tap.cleanaddr := 36863
print-char.tap.usraddr := 36864
print-char.tap.blockname := print-char
print-char.tap.opts := --fast

asm-bin-libs := \
  mtr-util
#  mtr \

debug:=true
debug.tape=$(OUTPUT-DIR)/print-char.tap
debug.break=$(print-char.tap.usraddr)

# run-fuse := -t $(OUTPUT-DIR)/print-char.tap --debugger-command "br $(print-char.tap.usraddr)"

include $(root)/build/asm-bin.include
include $(root)/build/asm-tap.include

include $(root)/build/debug.include

