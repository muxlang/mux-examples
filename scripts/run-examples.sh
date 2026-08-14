#!/usr/bin/env bash
#
# Compile and run every example, and compare its output to the recorded
# expected_output.txt.
#
# This script is the contract shared by every caller: mux-examples' own CI
# against mux-compiler `main`, mux-compiler's release workflow against the
# artifact it is about to publish, and mux-runtime's CI against the runtime
# under review.
#
# Keep it dependent on nothing but a `mux` binary, so every one of those callers
# can use it without installing anything else.
#
# Usage:
#   MUX_BIN=/path/to/mux ./scripts/run-examples.sh            # check
#   MUX_BIN=/path/to/mux ./scripts/run-examples.sh --update   # rewrite expected
#   MUX_BIN=/path/to/mux ./scripts/run-examples.sh hello       # one example
#
# Environment:
#   MUX_BIN           the compiler to use (default: mux from PATH)
#   MUX_RUNTIME_LIB   optional, forwarded to the compiler untouched
#   TIMEOUT_SECS      per-example wall clock limit (default: 120)

set -uo pipefail

MUX_BIN="${MUX_BIN:-mux}"
TIMEOUT_SECS="${TIMEOUT_SECS:-120}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
examples_dir="$repo_root/examples"

update=0
selected=()

for arg in "$@"; do
    case "$arg" in
        --update) update=1 ;;
        -h|--help)
            sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        -*)
            echo "unknown option: $arg" >&2
            exit 2
            ;;
        *) selected+=("$arg") ;;
    esac
done

if ! command -v "$MUX_BIN" >/dev/null 2>&1 && [ ! -x "$MUX_BIN" ]; then
    echo "error: mux binary not found: $MUX_BIN" >&2
    echo "set MUX_BIN to a compiler binary" >&2
    exit 2
fi

# A per-example time limit, when the platform offers one. `timeout` is GNU
# coreutils and is absent from a default macOS install, where requiring it would
# turn every example into a command-not-found failure. The limit only guards
# against an example that hangs, so running without it loses a safety net rather
# than the check itself. `gtimeout` is what Homebrew's coreutils installs.
timeout_cmd=()
if command -v timeout >/dev/null 2>&1; then
    timeout_cmd=(timeout "$TIMEOUT_SECS")
elif command -v gtimeout >/dev/null 2>&1; then
    timeout_cmd=(gtimeout "$TIMEOUT_SECS")
else
    echo "note: no 'timeout' available, running without a per-example time limit" >&2
fi

if [ ${#selected[@]} -eq 0 ]; then
    while IFS= read -r dir; do
        selected+=("$(basename "$dir")")
    done < <(find "$examples_dir" -mindepth 1 -maxdepth 1 -type d | sort)
fi

passed=0
failed=0
updated=0
failures=()

for name in "${selected[@]}"; do
    dir="$examples_dir/$name"
    source_file="$dir/main.mux"
    expected_file="$dir/expected_output.txt"

    if [ ! -f "$source_file" ]; then
        echo "FAIL $name (no main.mux)"
        failed=$((failed + 1))
        failures+=("$name")
        continue
    fi

    actual="$(cd "$dir" && "${timeout_cmd[@]}" "$MUX_BIN" run main.mux 2>&1)"
    status=$?

    # Compiling leaves an executable beside the source; it is not output.
    rm -f "$dir/main"

    if [ $status -ne 0 ]; then
        echo "FAIL $name (exit $status)"
        echo "--- output ---"
        echo "$actual"
        echo "--------------"
        failed=$((failed + 1))
        failures+=("$name")
        continue
    fi

    if [ $update -eq 1 ]; then
        # Check the write. An unwritable baseline - a read-only checkout, a
        # permissions problem - would otherwise be counted as updated and the
        # run would exit 0, which is the same way an unrunnable example used to
        # pass silently.
        if ! printf '%s\n' "$actual" > "$expected_file"; then
            echo "FAIL $name (could not write $expected_file)"
            failed=$((failed + 1))
            failures+=("$name")
            continue
        fi
        echo "UPDATED $name"
        updated=$((updated + 1))
        continue
    fi

    if [ ! -f "$expected_file" ]; then
        echo "FAIL $name (no expected_output.txt; run with --update)"
        failed=$((failed + 1))
        failures+=("$name")
        continue
    fi

    if diff -u "$expected_file" <(printf '%s\n' "$actual") > /tmp/mux-example-diff.$$ 2>&1; then
        echo "ok   $name"
        passed=$((passed + 1))
    else
        echo "FAIL $name (output differs)"
        echo "--- diff (expected vs actual) ---"
        cat /tmp/mux-example-diff.$$
        echo "---------------------------------"
        failed=$((failed + 1))
        failures+=("$name")
    fi
    rm -f /tmp/mux-example-diff.$$
done

echo ""
if [ $update -eq 1 ]; then
    echo "updated $updated example(s)"
    # An example that failed to run got no baseline, so exiting 0 here would
    # report a partial re-record as a complete one - and the missing file only
    # surfaces later as a check failure, far from the run that caused it.
    if [ $failed -gt 0 ]; then
        echo "NOT updated: ${failures[*]}"
        echo "those examples failed to run, so their expected output is unchanged"
        exit 1
    fi
    exit 0
fi

echo "passed: $passed  failed: $failed"
if [ $failed -gt 0 ]; then
    echo "failing: ${failures[*]}"
    exit 1
fi
