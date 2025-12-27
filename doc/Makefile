DOC+=		scholar.pdf

.PHONY: all clean distclean

all: ${DOC}

scholar.pdf: scholar.tex
scholar.pdf: preamble.tex

scholar.tex: ../src/scholar/scholar.nw
	noweave ${NOWEAVEFLAGS.tex} $< > $@

NOWEAVEFLAGS.tex?= -x -n -delay -t2

INCLUDE_MAKEFILES=../makefiles
include ${INCLUDE_MAKEFILES}/tex.mk

clean:
	latexmk -C ${DOC}
	${RM} scholar.tex

distclean:
