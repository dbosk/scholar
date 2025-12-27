DOC+=		scholar.pdf
DOC+=		cli.pdf

.PHONY: all clean distclean

all: ${DOC}

scholar.pdf: scholar.tex
scholar.pdf: preamble.tex

scholar.tex: ../src/scholar/scholar.nw
	noweave ${NOWEAVEFLAGS.tex} $< > $@

cli.pdf: cli.tex
cli.pdf: preamble.tex

cli.tex: ../src/scholar/cli.nw
	noweave ${NOWEAVEFLAGS.tex} $< > $@

NOWEAVEFLAGS.tex?= -x -n -delay -t2

INCLUDE_MAKEFILES=../makefiles
include ${INCLUDE_MAKEFILES}/tex.mk

clean:
	latexmk -C ${DOC}
	${RM} scholar.tex cli.tex

distclean:
