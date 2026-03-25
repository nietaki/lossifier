# AGENTS.md - Coding Agent Instructions

Project: Lossifier - FLAC to Opus/mp3 converter for music collections

## Project Overview

This is a Bash-based audio conversion tool that converts lossless FLAC music files to lossy formats (Opus/mp3). It uses Docker for deployment and includes comprehensive test coverage with bashunit framework.

## Build/Lint/Test Commands

### Running Tests

```bash
make test
```

#### Running Single Test File

```bash
./lib/bashunit test tests/docker_test.sh
```

#### Running Specific Test Function

```bash
./lib/bashunit test tests/bashunit_test.sh --filter="test_example"
```

### Linting

```bash
make check
```

Shellcheck is configured to ignore the `lib/` directory (third-party bashunit).

### Build Commands

```bash
make build_tmp
```

### Local Smoke Test

```bash
make smoke-test-local
```

This performs lossification on the dev machine for manual review

### Docker Smoke Test

```bash
make smoke-test-docker
```

This performs lossification on docker for manual review

### Clean Test Output

```bash
make clean
```

## Code Style Guidelines

### Bash Script Structure

- **Shebang**: Always use `#!/usr/bin/env bash` (not `#!/bin/bash`)
- **Error handling**: Start scripts with `set -e` to fail on errors
- **Progress output**: Print environment variables at startup for debugging

### Imports and Dependencies

- External dependencies are defined in Dockerfile: `opus-tools`, `lame`, `flac`, `shellcheck`, `coreutils`
- For local development, install via:
  - **macOS**: `make mac-install` (uses Homebrew)
  - **Debian/Ubuntu**: `make debian-install`
- bashunit is downloaded to `lib/` directory (gitignored)

### Formatting

- **Indentation**: 2 spaces per indent level
- **Line length**: Keep under 100 characters where practical
- **Whitespace**:
  - No trailing whitespace
  - Single blank line between logical sections
  - Blank line before function definitions

### Variable Naming Conventions

- **Environment variables**: SCREAMING_SNAKE_CASE (e.g., `TARGET_FORMAT`, `INPUT_DIR`)
- **Global variables**: SCREAMING_SNAKE_CASE (e.g., `FILE_COUNT`, `FILE_NO`)
- **Local variables**: lowercase_snake_case in functions, prefixed with `local`
- **Function names**: lowercase_snake_case (e.g., `get_opus_tag`, `set_up`)

### Function Definitions

```bash
function function_name() {
  local variable="value"
  # function body
}
```

### Variable Quoting

- Always quote variables to prevent word splitting: `"$VARIABLE"`
- Exception: When deliberately splitting is needed, add `# shellcheck disable=2086` comment
- Use braces for clarity: `"${VARIABLE}"` vs `"$VARIABLE"`

### Paths and File Handling

- Use `find` with `-not -path '*/[@.]*'` to ignore hidden files
- Use `read -r` to prevent backslash interpretation
- Use `$(...)` for command substitution (not backticks)
- Quote all file paths to handle spaces: `"$FILE_PATH"`

### Error Handling

- Use `set -e` at script start
- Use `|| true` for commands that might fail but should continue
- Validate inputs early and fail fast
- Provide clear error messages with context

```bash
if [ "$TARGET_FORMAT" != "opus" ]; then
    echo "Invalid TARGET_FORMAT: $TARGET_FORMAT. Currently supported: 'opus'."
    exit 1
fi
```

### Testing Conventions

#### Bashunit Test Structure

- Test files go in `tests/` directory
- File naming: `*_test.sh`
- Test function names must start with `test_`: `function test_example()`
- Use `set_up()` for per-test setup
- Use `set_up_before_script()` for script-level setup

#### Test Assertions

Available bashunit assertions (from tests/docker_test.sh:16:):
- `assert_same "expected" "$actual"`
- `assert_file_exists "$path"`
- `assert_file_not_exists "$path"`
- `assert_files_equals "$file1" "$file2"`

#### Testing lossify.sh

Only the docker tests (`tests/docker_test.sh`) execute the main `lossify.sh` script. When modifying `lossify.sh`, always run `make test` to ensure docker tests pass, not just `./lib/bashunit test tests/functions_test.sh`.

### Comments

- Use comments sparingly - code should be self-documenting
- Comment any non-obvious logic or business rules
- Reference external resources: `# https://stackoverflow.com/questions/14802807/...`
- Use comments to explain shellcheck disables: `# deliberately not quoted to allow splitting`

### Shellcheck Compliance

All code must pass shellcheck. Common patterns:

```bash
# Allow splitting of flags into multiple arguments
# shellcheck disable=2086
opusenc $EXTRA_OPUS_FLAGS --bitrate "$TARGET_BITRATE" "$1" "$2"
```

### Process Substitution and Pipes

- Use `shopt -s lastpipe` when using pipes with variable assignment in while loops
- Prefer `while read -r VAR` over `for VAR in $(...)` for file processing

### Cross-Platform Compatibility

- Check for macOS vs Linux utilities:
  ```bash
  if command -v grealpath > /dev/null 2>&1; then
      grealpath "$@"
  else
      realpath "$@"
  fi
  ```

### Exit Codes

- `0` = success
- `1` = general error
- Exit immediately on invalid input: `exit 1`

### Output Formatting

- Use `printf` over `echo` for formatted output: `printf "Converting %s\n" "$FILE"`
- Use `echo` for simple messages
- Provide progress indicators for long-running operations (every 100 files)

## Project Structure

```
lossifier/
├── lossify.sh           # Main conversion script
├── convert_to_opus.sh   # Opus conversion helper
├── Dockerfile           # Docker build configuration
├── Makefile            # Build and test commands
├── test/               # Test data directory
│   ├── input/          # Sample FLAC files
│   └── output/         # Test output (gitignored)
├── tests/              # Test scripts
│   ├── bashunit_test.sh
│   └── docker_test.sh
└── lib/                # Third-party tools (bashunit)
```

## CI/CD Pipeline

GitHub Actions workflow (.github/workflows/main.yml:1:) runs on every push:
1. Shellcheck linting
2. Bashunit tests
3. Multi-platform Docker build (amd64, arm64)
4. Docker Hub deployment (on master branch)

When modifying test dependencies or workflows in the Makefile, always update the corresponding GitHub Actions CI workflow (.github/workflows/main.yml) to ensure consistency.

## Git Commits

Don't commit unless explicitly asked to.

When creating a commit, use single-line commit messages (max 83 characters) that summarize changes concisely.

## Common Tasks

### Adding New Test

1. Create test file in `tests/` ending with `_test.sh`
2. Define test functions starting with `test_`
3. Run `make local-test` to verify
4. If end-to-end tests are required, run `make test`, which takes a longer time and runs in-docker operations

### Adding New Environment Variable

1. Define default in Dockerfile ENV
2. Document in README.md table
3. Use in relevant scripts with proper quoting
