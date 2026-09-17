# The tutorials are literate sources: each <id>.nw tangles to the Markdown
# that pytorial runs (<id>.md, shipped as package data) and weaves to a
# chapter of doc/scholar.pdf (<id>.tex).  noweb.mk only knows how to tangle
# the suffixes in NOWEB_SUFFIXES, and it defines the rules at include time,
# so .md must be added *before* the include.
NOWEB_SUFFIXES+=	.md

MODULES+=	first-search.md
MODULES+=	reviewing-in-the-tui.md
MODULES+=	enrich-verify-export.md
MODULES+=	llm-synthesis.md
MODULES+=	scholar-with-an-agent.md

DOC+=		first-search.tex
DOC+=		reviewing-in-the-tui.tex
DOC+=		enrich-verify-export.tex
DOC+=		llm-synthesis.tex
DOC+=		scholar-with-an-agent.tex

.PHONY: all clean distclean

all: ${MODULES} ${DOC}

first-search.md: first-search.nw
reviewing-in-the-tui.md: reviewing-in-the-tui.nw
enrich-verify-export.md: enrich-verify-export.nw
llm-synthesis.md: llm-synthesis.nw
scholar-with-an-agent.md: scholar-with-an-agent.nw

first-search.tex: first-search.nw
reviewing-in-the-tui.tex: reviewing-in-the-tui.nw
enrich-verify-export.tex: enrich-verify-export.nw
llm-synthesis.tex: llm-synthesis.nw
scholar-with-an-agent.tex: scholar-with-an-agent.nw

INCLUDE_MAKEFILES=../../../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk

clean:
	${RM} ${MODULES} ${DOC}

distclean:
	${RM} -Rf ltxobj
