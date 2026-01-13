# Scholar

A command-line tool for conducting structured literature searches across multiple academic databases, with built-in support for systematic literature reviews.

## Features

### Multi-Database Search

Search across six academic databases with a single query:

- **Semantic Scholar** - AI-powered research database with 200M+ papers
- **OpenAlex** - Open catalog of 250M+ scholarly works
- **DBLP** - Computer science bibliography
- **Web of Science** - Comprehensive citation index (requires API key)
- **IEEE Xplore** - IEEE technical literature (requires API key)
- **arXiv** - Preprints (no API key)

```bash
# Search specific providers
scholar search "federated learning" -p semantic_scholar -p openalex

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

Some providers require API keys set as environment variables:

| Provider | Environment Variable | Required | How to Get |
|----------|---------------------|----------|------------|
| Semantic Scholar | `S2_API_KEY` | No | [api.semanticscholar.org](https://api.semanticscholar.org) |
| OpenAlex | `OPENALEX_EMAIL` | No | Any email (for polite pool) |
| DBLP | - | No | No key needed |
| Web of Science | `WOS_API_KEY` | Yes | [developer.clarivate.com](https://developer.clarivate.com) |
| IEEE Xplore | `IEEE_API_KEY` | Yes | [developer.ieee.org](https://developer.ieee.org) |

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
scholar llm-review "session-name" --count 10
```

### How It Works

1. **Tag some papers manually** - The LLM needs examples to learn from. Review at least 5 papers with tags (themes for kept, motivations for discarded).

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

# Pick a default model (used by `scholar rq` and `scholar llm-review`)
llm models
llm models default gpt-4o-mini
```

If you installed Scholar with `pipx install scholarcli` and want the `llm` CLI
available from that same environment, you can alternatively install Scholar
with `pipx install --include-deps scholarcli`.

The LLM integration supports models available through Simon Willison's `llm`
package (OpenAI, Anthropic, local models, etc.).

Note: `scholar llm-review` learns from your existing labeled examples (typically
~5 tagged papers). `scholar rq` can start without examples by using the research
question as context.

## Documentation

Full documentation is available in the `doc/` directory as a literate program combining documentation and implementation.

## License

MIT License - see [LICENSE](LICENSE) for details.
