SUBDIR+=		src/scholar
SUBDIR+=		doc
SUBDIR+=		tests

SUBDIR_GOALS+=	all clean distclean test

INCLUDE_MAKEFILES=makefiles
include ${INCLUDE_MAKEFILES}/subdir.mk
