MODULES+=	__init__.py
MODULES+=	scholar.py
MODULES+=	providers.py
MODULES+=	cache.py
MODULES+=	cli.py
MODULES+=	tui.py
MODULES+=	notes.py
MODULES+=	pdf.py
MODULES+=	__main__.py

TEX+=		scholar.tex
TEX+=		providers.tex
TEX+=		cache.tex
TEX+=		cli.tex
TEX+=		tui.tex
TEX+=		notes.tex
TEX+=		pdf.tex

.PHONY: all clean distclean

all: ${MODULES} ${TEX}

__init__.py: scholar.nw
	${NOTANGLE.py}

scholar.py: scholar.nw
	${NOTANGLE.py}

providers.py: providers.nw
	${NOTANGLE.py}

cache.py: cache.nw
	${NOTANGLE.py}

cli.py: cli.nw
	${NOTANGLE.py}

tui.py: tui.nw
	${NOTANGLE.py}

__main__.py: cli.nw
	${NOTANGLE.py}

scholar.tex: scholar.nw
	${NOWEAVE.tex}

providers.tex: providers.nw
	${NOWEAVE.tex}

cache.tex: cache.nw
	${NOWEAVE.tex}

cli.tex: cli.nw
	${NOWEAVE.tex}

tui.tex: tui.nw
	${NOWEAVE.tex}

notes.py: notes.nw
	${NOTANGLE.py}

notes.tex: notes.nw
	${NOWEAVE.tex}

pdf.py: pdf.nw
	${NOTANGLE.py}

pdf.tex: pdf.nw
	${NOWEAVE.tex}

INCLUDE_MAKEFILES=../../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk

clean:
	${RM} ${MODULES} ${TEX}

distclean:
