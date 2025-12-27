TESTS+=		test_scholar.py
TESTS+=		test_providers.py
TESTS+=		test_cli.py

.PHONY: all clean distclean test

all: ${TESTS}

test_scholar.py: ../src/scholar/scholar.nw
	notangle -R"test [[scholar.py]]" $< | cpif $@

test_providers.py: ../src/scholar/providers.nw
	notangle -R"test [[providers.py]]" $< | cpif $@

test_cli.py: ../src/scholar/cli.nw
	notangle -R"test [[cli.py]]" $< | cpif $@

test: all
	poetry run pytest -v

INCLUDE_MAKEFILES=../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk

clean:
	${RM} ${TESTS}

distclean:
