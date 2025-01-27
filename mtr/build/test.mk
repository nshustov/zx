names := a b c

install: do-it

define assign
$(shell echo aaa-$($(1)))
#$($(1)):=$(2)
endef

$(call assign,a.bar,a-bar))

do-it:
	$(foreach name,$(names), echo $(name).bar=$($(name).bar);)
