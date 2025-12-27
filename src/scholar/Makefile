MODULES+=	__init__.py
MODULES+=	scholar.py

.PHONY: all clean distclean

all: ${MODULES}

__init__.py: scholar.nw
	${NOTANGLE.py}

scholar.py: scholar.nw
	${NOTANGLE.py}

INCLUDE_MAKEFILES=../../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk

clean:
	${RM} ${MODULES}

distclean:
