
include $(EMDIR)/etc/make/Makefile.mk
EM_CPPFLAGS = '-I$(EMDIR)/head' -D_forcePrototypes
EM_LDFLAGS = '-L$(EMDIR)/lib' $(LIBEMBRK) $(LIBEMDRI) $(LIBEMPBUF) $(LIBEMPTABLE) $(LIBEMLOG) $(LIBEMMEM) $(LIBEMVARG) $(LIBEMICON)

CC = xlc
LD = $(CC)
CXX = xlC
M4 = m4
MAKEDEPEND = /usr/bin/X11/makedepend
CTAGS = ctags

CPPFLAGS += $(EM_CPPFLAGS)
# Voir les CFLAGS d'OpenSSL: SSLeay_version(SSLEAY_CFLAGS)
CFLAGS += $(CPPFLAGS) -qextchk -g -qstrict -qro -qroconst
LDFLAGS += $(EM_LDFLAGS)
#LDFLAGS += -bdynamic
LDFLAGS += -lc -bstatic

EXE = varg
HEADER =
SRC = varg.c
OBJ = $(SRC:.c=.o)
GENERATED_HEADER =
GENERATED_SRC =

TARGETS = $(EXE)

all: tags $(TARGETS) varg.txt

varg.txt: varg
	@#./varg > varg.txt
	./varg | tee varg.txt

.PHONY: debug insure lint clean stop depend deps install dist

debug:
	@# Check LIBPATH
	$(MAKE) "CFLAGS=-g $(CFLAGS)" "TARGETS=$(TARGETS)" clean all

insure:
	@# Check LIBPATH
	@echo "LIBPATH=$$LIBPATH"
	$(MAKE) "CC=insure $(CC)" "LD=insure $(LD)" "CXX=insure $(CXX)" debug

lint:
	lint -DLINT $(CPPFLAGS) $(SRC)

deps: depend
depend: $(GENERATED_SRC) $(GENERATED_HEADER)
	$(MAKEDEPEND) -DMAKEDEPEND -- $(CPPFLAGS) $(DEPFLAGS) -- $(SRC) $(GENERATED_SRC)

tags: $(SRC) $(HEADER) $(GENERATED_SRC) $(GENERATED_HEADER)
	$(CTAGS) -- $(SRC) $(HEADER) $(GENERATED_SRC) $(GENERATED_HEADER)

clean:
	@rm -f $(TARGETS) *.o $(GENERATED_SRC) $(GENERATED_HEADER) tags


.SUFFIXES: .c .h


# DO NOT DELETE THIS LINE -- make depend depends on it.

varg.o: /usr/include/stdio.h /usr/include/standards.h /usr/include/va_list.h
varg.o: /usr/include/sys/types.h /usr/include/strict_stdtypes.h
varg.o: /usr/include/sys/inttypes.h /usr/include/stdint.h
varg.o: /usr/include/end_strict_stdtypes.h /usr/include/sys/m_types.h
varg.o: /usr/include/sys/vm_types.h /usr/include/sys/limits.h
varg.o: /usr/include/float.h /usr/include/math.h /usr/include/stdlib.h
varg.o: /usr/include/sys/wait.h /usr/include/sys/resource.h
varg.o: /usr/include/sys/time.h /usr/include/sys/signal.h
varg.o: /usr/include/sys/context.h /usr/include/sys/m_param.h
varg.o: /usr/include/sys/mstsave.h /usr/include/sys/m_signal.h
varg.o: /usr/include/sys/localedef.h /usr/include/sys/lc_core.h
varg.o: /usr/include/locale.h /usr/include/sys/localedef31.h
varg.o: /usr/em/head/varg.h /usr/include/stdarg.h /usr/em/head/log.h
varg.o: /usr/em/head/spec.h /usr/em/head/kvs.h /usr/em/head/mem.h
varg.o: /usr/em/head/pbuf.h /usr/em/head/ptable.h
