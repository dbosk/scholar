DOC+=		scholar.pdf

SRC_TEX+=	../src/scholar/scholar.tex
SRC_TEX+=	../src/scholar/utils.tex
SRC_TEX+=	../src/scholar/cache.tex
SRC_TEX+=	../src/scholar/ratelimit.tex
SRC_TEX+=	../src/scholar/providers.tex
SRC_TEX+=	../src/scholar/enrich.tex
SRC_TEX+=	../src/scholar/crossref.tex
SRC_TEX+=	../src/scholar/unpaywall.tex
SRC_TEX+=	../src/scholar/preprint.tex
SRC_TEX+=	../src/scholar/pdf.tex
SRC_TEX+=	../src/scholar/notes.tex
SRC_TEX+=	../src/scholar/review.tex
SRC_TEX+=	../src/scholar/llm_review.tex
SRC_TEX+=	../src/scholar/cli.tex
SRC_TEX+=	../src/scholar/tui.tex

.PHONY: all clean distclean

all: ${DOC}

scholar.pdf: scholar.tex preamble.tex
scholar.pdf: ${SRC_TEX}
# The woven .tex ask minted to load noweb's custom lexer; noweb.mk provides the
# rule that copies it here from noweb's library directory.
scholar.pdf: noweb_lexer.py

# Build .tex files in src/scholar if they don't exist or are outdated
../src/scholar/%.tex::
	${MAKE} -C ../src/scholar $(notdir $@)

INCLUDE_MAKEFILES=../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk

clean:
	${RM} ${DOC}
	${RM} noweb_lexer.py
	${MAKE} -C ../src/scholar clean

distclean:
