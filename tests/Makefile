TESTS+=		test_scholar.py
TESTS+=		test_providers.py
TESTS+=		test_cache.py
TESTS+=		test_enrich.py
TESTS+=		test_cli.py
TESTS+=		test_tui.py
TESTS+=		test_review.py
TESTS+=		test_notes.py
TESTS+=		test_llm_review.py
TESTS+=		test_pdf.py

CONFIG+=	conftest.py

.PHONY: all clean distclean test

all: ${TESTS} ${CONFIG}

test_scholar.py: ../src/scholar/scholar.nw
	notangle -R"test [[scholar.py]]" $< | cpif $@

test_providers.py: ../src/scholar/providers.nw
	notangle -R"test [[providers.py]]" $< | cpif $@

test_cache.py: ../src/scholar/cache.nw
	notangle -R"test [[cache.py]]" $< | cpif $@

test_enrich.py: ../src/scholar/enrich.nw
	notangle -R"test [[enrich.py]]" $< | cpif $@

test_cli.py: ../src/scholar/cli.nw
	notangle -R"test [[cli.py]]" $< | cpif $@

test_tui.py: ../src/scholar/tui.nw
	notangle -R"test [[tui.py]]" $< | cpif $@

test_review.py: ../src/scholar/review.nw
	notangle -R"test [[review.py]]" $< | cpif $@

test_notes.py: ../src/scholar/notes.nw
	notangle -R"test [[notes.py]]" $< | cpif $@

test_llm_review.py: ../src/scholar/llm_review.nw
	notangle -R"test [[llm_review.py]]" $< | cpif $@

test_pdf.py: ../src/scholar/pdf.nw
	notangle -R"test [[pdf.py]]" $< | cpif $@

conftest.py: ../src/scholar/cache.nw
	notangle -R"[[conftest.py]]" $< | cpif $@

test: all
	uv run pytest -v

INCLUDE_MAKEFILES=../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk

clean:
	${RM} ${TESTS} ${CONFIG}

distclean:
