# Scholar CLI - Agent Reference

## Project Overview

Scholar is a CLI tool for searching academic papers across multiple providers (Semantic Scholar, OpenAlex, DBLP, Web of Science, IEEE Xplore).

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
| Semantic Scholar | `semantic_scholar` | `semanticscholar` client | `S2_API_KEY` (optional) |
| OpenAlex | `openalex` | `pyalex` client | `OPENALEX_EMAIL` (optional) |
| DBLP | `dblp` | REST API | None required |
| Web of Science | `wos` | REST API | `WOS_API_KEY` (required) |
| IEEE Xplore | `ieee` | REST API | `IEEE_API_KEY` (required) |

### Error Handling

All providers silently return empty `list[Paper]` on errors. No exceptions propagate to CLI.

## Testing

```bash
poetry run pytest tests/
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

## Dependencies

- `requests` - HTTP client
- `typer` - CLI framework
- `rich` - Terminal formatting
- `semanticscholar`, `pyalex` - Provider-specific clients
- `cachetools` - Caching with decorators
- `platformdirs` - Platform-appropriate cache directory
