SOURCES:=laoshi.pld

SRC := $(SOURCES:%.pld=%.pld)
JED := $(SOURCES:%.pld=%.jed)
CUPL = LIBCUPL=C:\\Wincupl\\Shared\\cupl.dl WINEDEBUG=-all wine c:Wincupl/Shared/cupl.exe
OPT  = 3

all: $(JED)

%.jed: %.pld Makefile util/jedcrc
	$(CUPL) -jm$(OPT) $(LIBCUPL) $<
	util/fixup_jed.sh $< $(<:%.pld=%.jed)

util/jedcrc : util/jedcrc.c

test:
	./laoshi-test.tcl

clean:
	rm -f util/jedcrc
distclean: clean
	rm -f $(JED)
