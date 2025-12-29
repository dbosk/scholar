DOC+=		scholar.pdf

SRC_TEX+=	../src/scholar/scholar.tex
SRC_TEX+=	../src/scholar/cache.tex
SRC_TEX+=	../src/scholar/providers.tex
SRC_TEX+=	../src/scholar/cli.tex
SRC_TEX+=	../src/scholar/tui.tex

.PHONY: all clean distclean

all: ${DOC}

scholar.pdf: scholar.tex preamble.tex
scholar.pdf: ${SRC_TEX}

# Build .tex files in src/scholar if they don't exist or are outdated
../src/scholar/%.tex::
	${MAKE} -C ../src/scholar $(notdir $@)

INCLUDE_MAKEFILES=../makefiles
include ${INCLUDE_MAKEFILES}/tex.mk

clean:
	${RM} ${DOC}
	${MAKE} -C ../src/scholar clean

distclean:
