# Scholar

A command-line tool for conducting structured literature searches across multiple academic databases, with built-in support for systematic literature reviews.

## Features

### Multi-Database Search

Search across five academic databases with a single query:

- **Semantic Scholar** - AI-powered research database with 200M+ papers
- **OpenAlex** - Open catalog of 250M+ scholarly works
- **DBLP** - Computer science bibliography
- **Web of Science** - Comprehensive citation index (requires API key)
- **IEEE Xplore** - IEEE technical literature (requires API key)

```bash
# Search all available providers
scholar search "machine learning privacy"

# Search specific providers
scholar search "federated learning" -p semantic_scholar -p openalex
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

## Installation

```bash
pip install scholar-cli
```

Or with [uv](https://github.com/astral-sh/uv):

```bash
uv pip install scholar-cli
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

# Limit results per provider
scholar search "blockchain" -l 50
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
| `s` | Sort papers |
| `f` | Filter by status |
| `q` | Quit |

## Documentation

Full documentation is available in the `doc/` directory as a literate program combining documentation and implementation.

## License

MIT License - see [LICENSE](LICENSE) for details.
