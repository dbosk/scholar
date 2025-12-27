MODULES+=	__init__.py
MODULES+=	scholar.py
MODULES+=	providers.py
MODULES+=	cli.py
MODULES+=	__main__.py

.PHONY: all clean distclean

all: ${MODULES}

__init__.py: scholar.nw
	${NOTANGLE.py}

scholar.py: scholar.nw
	${NOTANGLE.py}

providers.py: providers.nw
	${NOTANGLE.py}

cli.py: cli.nw
	${NOTANGLE.py}

__main__.py: cli.nw
	${NOTANGLE.py}

INCLUDE_MAKEFILES=../../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk

clean:
	${RM} ${MODULES}

distclean:
