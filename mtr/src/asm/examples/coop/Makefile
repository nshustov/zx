root := ../../../..
include $(root)/build/common.include

asm-bins := print-char
asm-taps := print-char-t
print-char-t.tap.bins := print-char
print-char-t.tap.org := 32768
print-char-t.tap.cleanaddr := 32768
print-char-t.tap.usraddr := 32768
print-char-t.tap.blockname := dumbo
print-char-t.tap.opts := --fast

# print-char.appopts := -b "build.tmp/print-char_code.bin" -b "build.tmp/print-char_data.bin" --org 32768 --cleanaddr 32768 -usraddr 32768 --blockname dumbo --fast


asm-bin-libs := \
  mtr-util
#  mtr \

include $(root)/build/asm-bin.include
include $(root)/build/asm-tap.include

