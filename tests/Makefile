TESTS+=		test_scholar.py

.PHONY: all clean distclean test

all: ${TESTS}

test_scholar.py: ../src/scholar/scholar.nw
	notangle -R"test [[scholar.py]]" $< | cpif $@

test: all
	poetry run pytest -v

INCLUDE_MAKEFILES=../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk

clean:
	${RM} ${TESTS}

distclean:
