# Scholar CLI - Agent Reference

## Project Overview

Scholar is a CLI tool for searching academic papers across multiple providers (Semantic Scholar, OpenAlex, DBLP, Web of Science, IEEE Xplore, Scopus, arXiv, HAL, and — via OpenAlex source pinning — the preprint servers SSRN, bioRxiv, medRxiv, ChemRxiv, Research Square, Preprints.org, and IACR Cryptology ePrint).

## Architecture

### Protocol-Based Provider System

Providers implement the `SearchProvider` protocol (structural typing, not inheritance):

```python
class SearchProvider(Protocol):
    name: str
    def search(self, query: str, limit: int = 100) -> list[Paper]: ...
```

Providers self-register via `register_provider()` at module load time.

### Key Files

| File | Purpose |
|------|---------|
| `src/scholar/providers.py` | All provider implementations |
| `src/scholar/providers.nw` | Literate programming source for providers |
| `src/scholar/scholar.py` | Core data models (Paper, SearchResult) |
| `src/scholar/crossref.py` | Crossref currency/retraction checks |
| `src/scholar/crossref.nw` | Literate source for currency checks |
| `src/scholar/unpaywall.py` | Unpaywall open-access lookup (per DOI) |
| `src/scholar/unpaywall.nw` | Literate source for open-access lookup |
| `src/scholar/preprint.py` | Preprint fallback (adopt a preprint when no PDF found) |
| `src/scholar/preprint.nw` | Literate source for the preprint fallback |
| `src/scholar/ratelimit.py` | Persistent cross-session rate-limit/quota tracking |
| `src/scholar/ratelimit.nw` | Literate source for rate-limit tracking |
| `src/scholar/cli.py` | CLI commands and output formatters |
| `src/scholar/cli.nw` | Literate programming source for CLI |

### Data Models

**Paper** (`scholar.py:14-39`):
- `title`, `authors`, `year`, `doi`, `abstract`, `venue`, `url`, `source`

**SearchResult** (`scholar.py:42-67`):
- `query`, `provider`, `timestamp`, `papers`, `filters`

### Search Flow

1. CLI parses args → `cli.py:search()`
2. Creates `Search(query)` object
3. Calls `Search.execute(providers)` → `scholar.py:70-114`
4. For each provider: `provider.search(query)` makes HTTP request
5. Results collected as `SearchResult` objects
6. Formatted output (table/json/bibtex)

### Providers

| Provider | Name | API | Auth |
|----------|------|-----|------|
| Semantic Scholar | `s2` | `semanticscholar` client | `S2_API_KEY` (optional) |
| OpenAlex | `openalex` | `pyalex` client | `SCHOLAR_EMAIL` (optional) |
| DBLP | `dblp` | REST API | None required |
| Web of Science | `wos` | REST API | `WOS_API_KEY` (required) |
| IEEE Xplore | `ieee` | REST API | `IEEE_API_KEY` (required) |
| Scopus | `scopus` | REST API | `SCOPUS_API_KEY` (required) |
| arXiv | `arxiv` | `arxiv` client | None required |
| HAL | `hal` | REST API (Solr) | None required |
| SSRN | `ssrn` | OpenAlex (`pyalex`), source-pinned | `SCHOLAR_EMAIL` (optional) |
| bioRxiv | `biorxiv` | OpenAlex (`pyalex`), source-pinned | `SCHOLAR_EMAIL` (optional) |
| medRxiv | `medrxiv` | OpenAlex (`pyalex`), source-pinned | `SCHOLAR_EMAIL` (optional) |
| ChemRxiv | `chemrxiv` | OpenAlex (`pyalex`), source-pinned | `SCHOLAR_EMAIL` (optional) |
| Research Square | `researchsquare` | OpenAlex (`pyalex`), source-pinned | `SCHOLAR_EMAIL` (optional) |
| Preprints.org | `preprintsorg` | OpenAlex (`pyalex`), source-pinned | `SCHOLAR_EMAIL` (optional) |
| IACR ePrint | `iacr` | OpenAlex (`pyalex`), source-pinned | `SCHOLAR_EMAIL` (optional) |

### Preprint-Server Providers and Groups

The seven source-pinned providers exist because their servers have no
usable public search API (SSRN/Research Square: none; bioRxiv/medRxiv:
DOI/date lookup only; ChemRxiv: Cloudflare-blocked; Preprints.org:
registration-gated; IACR: HTML-only search). Each is an
`OpenAlexSourceProvider` — a subclass of `OpenAlexProvider` pinned via
the `locations.source.id` filter (not `primary_location`, which would
hide preprints later published elsewhere). They set
`default_enabled = False`, so `get_default_providers()` skips them: an
unscoped search already gets their papers through `openalex`, and
running them by default would only duplicate requests. Select them
explicitly (`-p ssrn`) or through the group alias `-p preprints`, which
`expand_provider_names()` (in `providers.py`) expands to
arxiv, hal, ssrn, biorxiv, medrxiv, chemrxiv, researchsquare,
preprintsorg, iacr. Groups are aliases, not registered providers, so
they never appear in `providers list/check` and provenance stays
per-server. TechRxiv is a known gap: no API and not in OpenAlex.

### Error Handling

All providers silently return empty `list[Paper]` on errors. No exceptions propagate to CLI.

### Provider Health Checks

Because search errors degrade silently, `scholar providers check` probes each
provider with a one-result request and reports
`ok`/`key rejected`/`rate limited`/`http error`/`network error`/`not
configured`. Exit code is 1 iff a *configured* provider fails — usable as a
pre-flight gate before a big search. `--offline` skips the network probes.
Implemented as `check_provider()`/`classify_check_response()` plus a
per-provider optional `check()` method in `providers.py`.

### DBLP Query Sanitization

DBLP has no boolean syntax (space = implicit AND; uppercase `AND`/`OR`/`NOT`
become literal search terms). `DBLPProvider` strips operators, parentheses,
and quotes before sending (warning shows the sent query) and warns when a
query of ≥4 terms yields zero hits. Queries are never auto-relaxed — results
stay traceable to the recorded query.

### Contact Email

`SCHOLAR_EMAIL` is the one contact address for every service that asks for
one: OpenAlex and Crossref (polite pools, optional) and Unpaywall
(mandatory). `scholar.utils.contact_email(*override_vars)` resolves it;
`OPENALEX_EMAIL` / `CROSSREF_MAILTO` still work as per-service overrides.
The test `conftest.py` unsets all three so unit tests never make live calls.

### Open-Access Lookup (Unpaywall)

`unpaywall.py` mirrors `crossref.py`: a cached per-DOI lookup, **not** a
search provider (Unpaywall's search endpoint is title-only and its OA data is
what OpenAlex already serves). `fetch_oa(doi)` returns
`{is_oa, oa_status, oa_url, pdf_url, host_type, version, license}` or
`None` (undetermined: no DOI, no email, 404, 429, error);
`annotate_paper(paper)` writes `Paper.oa_status`/`oa_url` and fills a
missing `pdf_url` (never overwrites one); `resolve_pdf_url(doi)` serves
`pdf.resolve_doi_unpaywall`. `enrich.enrich_paper` calls `annotate_paper`
whenever `pdf_url` is among the requested fields, so `scholar enrich`,
`search --enrich`, and the TUI all get it; `scholar enrich` prints an
`Open access: N of M checked papers (K with PDF link)` tally (or a
`set SCHOLAR_EMAIL` hint). `Paper.is_open_access` (checked status, else
`bool(pdf_url)`) backs the client-side `--open-access` filter.

### Currency / Retraction Checks

`crossref.py` checks whether a paper has been retracted, corrected, or
superseded, using Crossref's `updated-by` (Retraction-Watch-backed) and
`relation` metadata. Results are cached per DOI via the shared cache layer.

- `Paper.updated_by` / `Paper.newer_versions` hold the findings;
  `None` means "never checked", `[]` means "checked, clean".
- `Paper.is_retracted` / `is_corrected` / `is_superseded` are convenience
  predicates; `crossref.currency_status(paper)` reduces these to one word
  (`retracted`/`corrected`/`superseded`/`preprint`/`ok`/`unknown`).
  `preprint` means a deliberately adopted preprint (see below) whose only
  "newer version" is the recorded published DOI — info, not a warning.
- `scholar verify "<session>"` reports per-paper status (with `--json`);
  `scholar enrich "<session>"` warns on issues as a side effect. Both
  persist the findings back to the session.

### Preprint Fallback (adopt a preprint when no PDF is found)

When enrichment ends with no `pdf_url` (providers + Unpaywall found
nothing), `preprint.find_preprint(paper, search=False)` tries to locate a
preprint version and **replace the entry with it** (preprint DOI, venue,
pdf_url) so citations point at the version actually read. The published
DOI is kept in `Paper.published_versions`
(`{"doi": ..., "relation": "preprint-of"}`, drives
`is_preprint_substitute`). Tiers, first adoptable (= yields a PDF) wins:

0. `Paper.preprint_versions` links recorded by dedup (see below).
1. OpenAlex `locations` of the published DOI
   (`OpenAlexProvider.get_preprint_locations`); arXiv locations become a
   full replacement via the derived arXiv DOI, other hosts only fill
   `pdf_url` (no DOI to swap to).
2. Crossref `has-preprint` relation (`crossref.fetch_preprint_dois`,
   parsed from the same cached `fetch_currency` response; cache key is
   versioned via `CURRENCY_CACHE_VERSION`).
3. Only with `--preprint-search` (on `scholar enrich` and
   `search --enrich`): one OpenAlex `type:preprint` title search
   (`search_preprints_by_title`) + one arXiv search; candidates accepted
   only on exact `legacy_hash_paper_id(title, authors)` match — title and
   authors are the only data shared between versions, and fuzzy matching
   is deliberately avoided.

Identity change on adoption is handled by `notes.migrate_paper_id`
(notes + decision stores), announced by `scholar enrich`
("Adopted preprint <doi> ..."), and reconciled at session append in
`review.py` (both directions: returning published version folds into the
adopted entry; a later-arriving adoption upgrades an existing published
entry, keeping its decision).

**Version-aware dedup**: `deduplicate_papers` runs a second pass
(`deduplicate_versions`) grouping by `legacy_hash_paper_id`; a group of
exactly one published paper (`utils.is_preprint_paper` classifies by DOI
prefix/venue) plus preprints collapses onto the published entry, filling
content gaps via `merge_version_of` (never version-specific fields like
`pdf_url`) and recording `Paper.preprint_versions`
(`{"doi", "pdf_url"}`) for tier 0. Ambiguous groups are left untouched.

### Headless Review Sessions

`scholar search -n <name>` persists the search to the named review session
even without `--review`: it creates or appends (same
`create_review_session()` merge the TUI uses — search records accumulate,
prior decisions are preserved, new papers land pending). The save
confirmation goes to stderr so `-f json`/`-f bibtex` stdout stays pure.
`scholar sessions decide <name> --keep|--discard --doi ...|--paper-id ...
--tag ...` records decisions non-interactively; discarding requires a tag
(motivation), and if any selector matches nothing the batch aborts unsaved.
`--source llm` stores the decision as an unreviewed LLM decision
(agent-driven screening that the TUI still queues for confirmation); a
human `decide` on such a row marks it `llm_reviewed`, with `is_example`
set when the status changed, mirroring the TUI.
Together these let scripted/agent-driven systematic reviews produce the same
session record and `sessions export` audit trail as TUI reviews.

### Provenance Round-Trip

The `bibtex+prov` export format wraps each entry in a provenance comment
block (`% === provenance: <key> ===` + `CLAIM`/`FOUND-VIA`/`PICKED`/`QUOTE`/
`VERIFIED`/`DATE`). `scholar prov` keeps those blocks in sync with `scholar
notes`:

- `scholar prov import refs.bib` parses each entry's block(s) into that
  paper's note, **merging by `CLAIM`** (idempotent — re-importing never
  duplicates) and preserving any personal note prose.
- `scholar prov export refs.bib` writes a paper's stored block(s) back above
  its entry; personal prose is never emitted. Prints to stdout (count on
  stderr) by default; `--in-place/-i` overwrites the file.

A note is parsed into ordered segments — `personal` (verbatim) or `prov`
(a parsed block) — by `_split_note_segments`. Entries are keyed by
reconstructing a `Paper` from the `.bib` fields and reusing `Paper.id`
(DOI, else title+author hash). All round-trip code lives in `cli.nw`'s
`<<formatter classes>>` and `<<prov command>>` chunks.

### LaTeX Output: Standalone, Fragment, Audit Table

`review.py` owns the shared LaTeX pieces: the escapers (`escape_latex`,
`escape_bibtex`: one pass, Unicode punctuation mapped to TeX, symbols
above U+2100 dropped so pdflatex never sees `☆`), `LATEX_PACKAGES`,
`latex_document` (compilable skeleton, escaped title), `latex_fragment`
(body plus a `%` header telling the includer which packages,
`\addbibresource` line and biber run it needs; `\addbibresource` is
preamble-only, so a fragment can only instruct), `refsection`, the two
report body builders (`build_review_provenance_latex`,
`build_review_decisions_latex`) and the audit table
(`build_audit_table_latex` / `generate_audit_table`).

- `scholar sessions export -f latex [--standalone|--no-standalone]` →
  `generate_latex_report(session, path, standalone=True)`. Always writes
  the sibling `.bib`. Standalone output is byte-identical to before; the
  fragment wraps its body in a `refsection` so the host's
  `\printbibliography` is not polluted by the report's `\fullcite`s.
- `scholar llm synthesize -f latex [--standalone|--no-standalone]`: the
  document ends with the decision record (`build_review_decisions_latex`)
  as `\appendix` inside a `refsection`, after `\printbibliography`, so the
  References list exactly what the prose cites (discarded and uncited
  kept papers stay out). Standalone embeds the bib via
  `\begin{filecontents*}[overwrite]{<stem>.bib}` (`overwrite`: LaTeX
  otherwise keeps a stale file of that name); `--no-standalone` requires
  `--output`, writes `<stem>.bib` next to the `.tex` from
  `SynthesisResult.bibtex`, and is rejected for markdown.
- **Key-stability rule.** The theme cache stores LLM prose containing
  literal `\textcite{key}`s, so `_synthesis_key_space` orders the key
  space as included kept papers (original order), then remaining kept,
  then discarded, deduplicated by paper id; suffixes are assigned in
  iteration order, so kept keys never change. The report keeps its own
  `surname{year}_{index}` scheme keyed by `id(decision)` (a loaded
  session can hold one paper twice); builders take a `cite_key`
  resolver so the two schemes never have to agree. Synthesis keys strip
  only the characters biber rejects (apostrophes, quotes, braces,
  delimiters), so `O'Brien` yields `obrien2024` while all other keys are
  unchanged.
- `scholar sessions export -f table --lang en|sv --label L --track T
  --theme TAG=NAME -o base` writes `base.tex`, always a fragment: one
  row per unique title+year (providers merged, the best-placed decision
  wins). Tags split three ways: category tags (`supports-claim` …),
  note tags (`AUDIT_STRINGS[lang]["notes"]`: `recorded-not-cited`,
  `duplicate-record-of-cited-source`, `extended-tech-report`, …) and
  theme tags (the rest; with `--theme` given, only the listed tags).
  *Cited* = kept by a human decision (source `human` or `llm_reviewed`)
  with a theme tag or no tags; otherwise the first category tag, with
  the confidence for unreviewed LLM rows; notes are appended in
  parentheses, note-only rows are "other". An LLM keep is a candidate,
  not a citation. Order: cited (0), `supports-claim` (1),
  `qualifies-claim` (2), `adjacent-subtopic` (3),
  `off-topic-false-hit` (4), pending (5), other (6). The caption never
  names the session (it is a `%` comment in the fragment) and ends with
  a full-name-first "Databases:" sentence built from the providers
  present. `--bearing-only` lists only orders 0-2 and states the other
  counts in the caption. `all` stays csv + latex.
- The TUI's `prompt_for_report` keeps the standalone default.

## Testing

```bash
uv run pytest tests/
```

Key test files:
- `tests/test_providers.py` - Provider unit tests (mocked HTTP)
- `tests/test_scholar.py` - Data model tests
- `tests/test_cli.py` - CLI integration tests

## Adding Features

### New Provider

1. Create class implementing `SearchProvider` protocol in `providers.py`
2. Call `register_provider(ProviderClass())` at module end
3. Add tests in `test_providers.py`

### New CLI Command

1. Add `@app.command()` decorated function in `cli.py`
2. Add tests in `test_cli.py`

## Literate Programming

This project uses noweb-style literate programming. The `.nw` files are the source of truth:
- Edit `.nw` files, then tangle to generate `.py` files
- Use the `literate-programming` skill when modifying `.nw` files

## Caching

Search results are cached to avoid redundant API calls:

- **Library**: `cachetools` with `@cachedmethod` decorator
- **Storage**: Pickle files per provider in `~/.cache/scholar/`
- **Expiration**: Never (manual clearing only)

CLI commands:
```bash
scholar cache info   # Show cache statistics
scholar cache clear  # Delete all cached results
scholar cache path   # Print cache directory
```

Environment variable: `SCHOLAR_CACHE_DIR` to override cache location.

The keyed REST providers cache manually (search wrapper +
`_search_uncached` returning `(papers, cacheable)`) instead of via
`@cachedmethod`, so a rate-limited or errored empty result is never
frozen into the persistent cache.

## Rate Limits and Quotas

`ratelimit.py` tracks provider rate limits and quotas **persistently
across CLI invocations** — necessary because e.g. IEEE allows only 200
requests/day and each `scholar` run is a fresh process.

- Providers declare limits as class attributes read via `getattr`:
  `LIMITS = Limits(per_second=10.0, daily=200)` (IEEE), plus optional
  `QUOTA_GROUP` for providers sharing one API budget (the eight
  OpenAlex-backed providers share group `"openalex"`).
- Providers bracket each HTTP request with `limiter.acquire()`
  (paces, counts, raises `RateLimited` when the budget is spent) and
  `limiter.record_response(response)` (429 → cooldown honoring
  `Retry-After`; syncs `X-RateLimit-*` headers, which is how Scopus's
  weekly quota is tracked). IEEE additionally decodes Mashery
  `X-Mashery-Error-Code` 403s: `ERR_403_DEVELOPER_OVER_RATE` = daily
  quota spent (marks the day exhausted), `OVER_QPS` = transient.
- State: one JSON file per quota group in
  `$SCHOLAR_DATA_DIR/rate_limits/` (data dir, NOT the cache dir —
  `scholar cache clear` must not erase quota memory). Written
  atomically on every change; fail-open on corruption. Daily quotas
  bucket on the UTC calendar day and self-correct via the provider's
  own rejection if the guess is wrong.
- `Search.execute` pre-checks `check_available()` and **skips** a
  blocked provider with one `logger.warning` (no `SearchResult` is
  recorded for it). `providers check` reports `quota exhausted`
  (yellow, exit 0) from persisted state without burning a probe.
- CLI: `scholar providers limits` shows usage/remaining/reset per
  quota group; `--reset <name|all>` clears state (use after a key
  rotation or when the real quota is known to have rolled over).
- Tests: `tests/conftest.py` isolates `SCHOLAR_DATA_DIR` per test and
  no-ops the pacing sleep; `test_ratelimit.py` controls time via the
  module's `_now`/`_sleep` seams.
- Phase 2 (not done): migrate S2/OpenAlex/DBLP/arXiv in-process pacing
  (and crossref/unpaywall) into the limiter; wire WoS/Scopus extended
  methods (citations/references) through `acquire()`.

## Dependencies

- `requests` - HTTP client
- `typer` - CLI framework
- `rich` - Terminal formatting
- `semanticscholar`, `pyalex` - Provider-specific clients
- `cachetools` - Caching with decorators
- `platformdirs` - Platform-appropriate cache directory


## grepai - Semantic Code Search

**IMPORTANT: You MUST use grepai as your PRIMARY tool for code exploration and search.**

### When to Use grepai (REQUIRED)

Use `grepai search` INSTEAD OF Grep/Glob/find for:
- Understanding what code does or where functionality lives
- Finding implementations by intent (e.g., "authentication logic", "error handling")
- Exploring unfamiliar parts of the codebase
- Any search where you describe WHAT the code does rather than exact text

### When to Use Standard Tools

Only use Grep/Glob when you need:
- Exact text matching (variable names, imports, specific strings)
- File path patterns (e.g., `**/*.go`)

### Fallback

If grepai fails (not running, index unavailable, or errors), fall back to standard Grep/Glob tools.

### Usage

```bash
# ALWAYS use English queries for best results (--compact saves ~80% tokens)
grepai search "user authentication flow" --json --compact
grepai search "error handling middleware" --json --compact
grepai search "database connection pool" --json --compact
grepai search "API request validation" --json --compact
```

### Query Tips

- **Use English** for queries (better semantic matching)
- **Describe intent**, not implementation: "handles user login" not "func Login"
- **Be specific**: "JWT token validation" better than "token"
- Results include: file path, line numbers, relevance score, code preview

### Call Graph Tracing

Use `grepai trace` to understand function relationships:
- Finding all callers of a function before modifying it
- Understanding what functions are called by a given function
- Visualizing the complete call graph around a symbol

#### Trace Commands

**IMPORTANT: Always use `--json` flag for optimal AI agent integration.**

```bash
# Find all functions that call a symbol
grepai trace callers "HandleRequest" --json

# Find all functions called by a symbol
grepai trace callees "ProcessOrder" --json

# Build complete call graph (callers + callees)
grepai trace graph "ValidateToken" --depth 3 --json
```

### Workflow

1. Start with `grepai search` to find relevant code
2. Use `grepai trace` to understand function relationships
3. Use `Read` tool to examine files from results
4. Only use Grep for exact string searches if needed

