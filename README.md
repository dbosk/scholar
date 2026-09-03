# Scholar

A command-line tool for conducting structured literature searches across multiple academic databases, with built-in support for systematic literature reviews.

## Features

### Multi-Database Search

Search across fifteen academic databases with a single query:

- **Semantic Scholar** - AI-powered research database with 200M+ papers
- **OpenAlex** - Open catalog of 250M+ scholarly works
- **DBLP** - Computer science bibliography
- **Web of Science** - Comprehensive citation index (requires API key)
- **IEEE Xplore** - IEEE technical literature (requires API key)
- **Scopus** - Elsevier's abstract and citation database (requires API key)
- **arXiv** - Preprints in physics, math, CS (no API key)
- **HAL** - The French national open archive (no API key)
- **Preprint servers** - SSRN, bioRxiv, medRxiv, ChemRxiv, Research
  Square, Preprints.org, and the IACR Cryptology ePrint Archive, each
  searched through OpenAlex pinned to that server (none of them offers
  a usable search API of its own)

The preprint-server providers are opt-in: a default search already finds
their papers through OpenAlex, so they run only when you name them —
either individually (`-p ssrn` scopes a search to SSRN) or all at once
with the `preprints` group.

```bash
# Search specific providers
scholar search "federated learning" -p s2 -p openalex

# Scope a search to one preprint server
scholar search "corporate governance" -p ssrn

# All preprint servers at once (arXiv, HAL, SSRN, bioRxiv, medRxiv, ...)
scholar search "diffusion models" -p preprints

# Start from a research question (LLM generates provider-specific queries)
scholar rq "How can privacy-preserving ML be evaluated?" \
  --provider openalex --provider dblp \
  --count 20
```

### Interactive Review Interface

Review search results in a terminal-based interface with vim-style navigation:

```bash
scholar search "neural networks" --review
```

The TUI supports:
- **Keep/Discard decisions** with mandatory motivations for discards
- **Theme tagging** for organizing kept papers
- **Note-taking** with your preferred editor
- **PDF viewing** with automatic download and caching
- **Abstract enrichment** for papers missing abstracts
- **LLM-assisted classification** to help review large result sets
- **Sorting and filtering** by various criteria

### Output Formats

Export results in multiple formats:

```bash
# Pretty table (default for terminal)
scholar search "query"

# Machine-readable formats
scholar search "query" -f json
scholar search "query" -f csv
scholar search "query" -f bibtex
```

### Session Management

Save and resume review sessions:

```bash
# List saved sessions
scholar sessions list

# Resume a session
scholar sessions resume "machine learning"

# Export session to reports
scholar sessions export "machine learning" -f all
```

### Paper Notes

Manage notes across all reviewed papers:

```bash
# Browse papers with notes
scholar notes

# List papers with notes
scholar notes list

# Export/import notes
scholar notes export notes.json
scholar notes import notes.json
```

### Caching

Search results are cached to avoid redundant API calls:

```bash
scholar cache info    # Show cache statistics
scholar cache clear   # Delete cached results
scholar cache path    # Print cache directory
```

PDF downloads are also cached for offline viewing.

### Rate-Limit and Quota Tracking

Provider rate limits and daily quotas (e.g. IEEE's 200 requests/day) are
tracked persistently across invocations: a provider whose budget is spent
is skipped with a warning naming the reset time instead of firing doomed
requests.

```bash
scholar providers limits              # Show usage, remaining budget, reset times
scholar providers limits --reset ieee # Clear tracked state for one provider
```

## Quickstart

### Install

```bash
pipx install scholarcli
```

### Configure LLM access (optional, for `scholar rq` and LLM-assisted review)

Scholar uses the [`llm`](https://llm.datasette.io/) package for model selection
and API key configuration.

If you want to configure it via the `llm` CLI, install it as well (or install
`scholarcli` with `pipx --include-deps` so the dependency CLIs are exposed):

```bash
pipx install llm
# Or: pipx install --include-deps scholarcli
```

Then configure at least one provider (examples):

```bash
llm install llm-openai-plugin
llm keys set openai

# Or:
llm install llm-anthropic
llm keys set anthropic
```

Set a default model for Scholar to use:

```bash
llm models
llm models default gpt-4o-mini
```

### First run

```bash
# Search directly
scholar search "machine learning privacy"

# Start from a research question (LLM generates provider-specific queries)
scholar rq "How do LLMs support novice programming?" --count 20
```

## Installation

If you don't use `pipx`, you can install with `pip`:

```bash
pip install scholarcli
```

Or with [uv](https://github.com/astral-sh/uv):

```bash
uv pip install scholarcli
```

## Configuration

Set `SCHOLAR_EMAIL` to a contact address: OpenAlex (and thus every
preprint-server provider), Crossref, and the polite pools use it for
faster responses, and Unpaywall (open-access lookup during
`scholar enrich` and `scholar pdf open <doi>`) requires it. `OPENALEX_EMAIL`
and `CROSSREF_MAILTO` are still honoured as per-service overrides.

Some providers require API keys set as environment variables:

| Provider | Environment Variable | Required | How to Get |
|----------|---------------------|----------|------------|
| Semantic Scholar | `S2_API_KEY` | No | [api.semanticscholar.org](https://api.semanticscholar.org) |
| OpenAlex | `SCHOLAR_EMAIL` | No | Any email (for polite pool) |
| DBLP | - | No | No key needed |
| arXiv | - | No | No key needed |
| HAL | - | No | No key needed |
| SSRN, bioRxiv, medRxiv, ChemRxiv, Research Square, Preprints.org, IACR | `SCHOLAR_EMAIL` | No | Any email (they search via OpenAlex) |
| Web of Science | `WOS_EXPANDED_API_KEY` or `WOS_STARTER_API_KEY` | Yes | [developer.clarivate.com](https://developer.clarivate.com) |
| IEEE Xplore | `IEEE_API_KEY` | Yes | [developer.ieee.org](https://developer.ieee.org) |
| Scopus | `SCOPUS_API_KEY` | Yes | [dev.elsevier.com](https://dev.elsevier.com); the key is bound to the institution's IP range, so run from that network (or VPN) or set `SCOPUS_INST_TOKEN` |

View provider status:

```bash
scholar providers
```

## Usage Examples

### Basic Search

```bash
# Search with default providers (Semantic Scholar, OpenAlex, DBLP)
scholar search "differential privacy"

# Limit results per provider (default: 1000)
scholar search "blockchain" -l 50

# Unlimited results per provider
scholar search "blockchain" -l 0
```

### Systematic Review Workflow

```bash
# 1. Search and review interactively
scholar search "privacy-preserving machine learning" --review --name "privacy-ml-review"

# 2. Add more searches to the same session
scholar search "federated learning privacy" --review --name "privacy-ml-review"

# 3. Resume reviewing later
scholar sessions resume "privacy-ml-review"

# 4. Generate reports
scholar sessions export "privacy-ml-review" -f all
```

### Enriching Results

Some providers (like DBLP) don't include abstracts. Fetch them from other sources:

```bash
# Enrich during search
scholar search "query" --enrich

# Enrich an existing session
scholar enrich "session-name"
```

When no PDF can be found for a paper, enrichment falls back to preprint
versions: authoritative links (OpenAlex's alternate locations and
Crossref's `has-preprint` relation) are always followed, and with
`--preprint-search` the preprint servers are additionally searched by
title and authors (exact match only). An adopted preprint *replaces*
the entry — its DOI, venue, and PDF — so exported citations point at
the version you actually read; the published DOI is kept on the entry
for provenance, and `scholar verify` reports such entries as
`preprint of <doi>` rather than superseded.

```bash
# Also search preprint servers for papers without a PDF
scholar enrich "session-name" --preprint-search
scholar search "query" --enrich --preprint-search
```

### PDF Management

```bash
# Download and open a PDF
scholar pdf open "https://arxiv.org/pdf/2301.00001.pdf"

# View PDF cache
scholar pdf info
scholar pdf clear
```

## Keybindings (Review TUI)

| Key | Action |
|-----|--------|
| `j`/`k` | Navigate up/down |
| `Enter` | View paper details |
| `K` | Keep paper (quick) |
| `T` | Keep with themes |
| `d` | Discard (requires motivation) |
| `n` | Edit notes |
| `p` | Open PDF |
| `e` | Enrich (fetch abstract) |
| `L` | LLM-assisted classification |
| `s` | Sort papers |
| `f` | Filter by status |
| `q` | Quit |

## LLM-Assisted Review

For large result sets, Scholar can use LLMs to assist with paper classification:

```bash
# In the TUI, press 'L' to invoke LLM classification
# Or use the CLI command directly
scholar llm classify "session-name" --count 10
```

### How It Works

1. **Tag some papers manually** (recommended) - Examples help the LLM learn your criteria. Tagging ~5 papers (themes for kept, motivations for discarded) improves quality, but classification will still run — with a warning — if you have fewer or none.

2. **Set research context** (optional) - Describe your review's focus to help the LLM understand relevance criteria.

3. **Invoke LLM classification** - The LLM classifies pending papers based on your examples, returning confidence scores.

4. **Review LLM decisions** - Prioritize low-confidence classifications. Accept correct ones, correct wrong ones.

5. **Iterate** - Corrections become training examples for the next round.

### Requirements

Install and configure the `llm` command (Scholar uses `llm`'s configuration and
default model):

```bash
pipx install llm

llm install llm-openai-plugin
llm keys set openai

# Pick a default model (used by `scholar rq` and `scholar llm classify`)
llm models
llm models default gpt-4o-mini
```

If you installed Scholar with `pipx install scholarcli` and want the `llm` CLI
available from that same environment, you can alternatively install Scholar
with `pipx install --include-deps scholarcli`.

The LLM integration supports models available through Simon Willison's `llm`
package (OpenAI, Anthropic, local models, etc.).

Note: `scholar llm classify` learns from your existing labeled examples (typically
~5 tagged papers). `scholar rq` can start without examples by using the research
question as context.

## Documentation

Full documentation is available in the `doc/` directory as a literate program combining documentation and implementation.

## License

MIT License - see [LICENSE](LICENSE) for details.
