MODULES+=	__init__.py
MODULES+=	scholar.py
MODULES+=	providers.py
MODULES+=	cache.py
MODULES+=	enrich.py
MODULES+=	cli.py
MODULES+=	tui.py
MODULES+=	notes.py
MODULES+=	pdf.py
MODULES+=	review.py
MODULES+=	llm_review.py
MODULES+=	__main__.py

DOC+=		scholar.tex
DOC+=		providers.tex
DOC+=		cache.tex
DOC+=		enrich.tex
DOC+=		cli.tex
DOC+=		tui.tex
DOC+=		notes.tex
DOC+=		pdf.tex
DOC+=		review.tex
DOC+=		llm_review.tex

.PHONY: all clean distclean

all: ${MODULES} ${DOC}

__init__.py: scholar.nw
	${NOTANGLE.py}

__main__.py: cli.nw
	${NOTANGLE.py}

INCLUDE_MAKEFILES=../../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk

clean:
	${RM} ${MODULES} ${DOC}

distclean:
