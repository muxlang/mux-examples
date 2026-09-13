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

diff_file=''
cleanup() {
    if [ -n "$diff_file" ]; then
        rm -f -- "$diff_file"
    fi
}
trap cleanup EXIT INT TERM

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

# A per-example time limit is required on every host. `timeout` is GNU
# coreutils and is absent from a default macOS install; `gtimeout` is what
# Homebrew's coreutils installs. When neither exists, use a Bash process-group
# fallback so a hung compiler or compiled program cannot outlive the check.
run_bounded() {
    local secs="$1"
    shift

    # Job control gives the background command its own process group. Killing
    # the group matters because `mux run` starts a compiled child whose stdout
    # may otherwise keep the command-substitution pipe open after its parent
    # exits.
    set -m
    "$@" &
    local pid=$!

    (
        sleep "$secs"
        if kill -0 "$pid" 2>/dev/null; then
            kill -TERM -"$pid" 2>/dev/null || true
            sleep 1
            kill -KILL -"$pid" 2>/dev/null || true
        fi
    ) &
    local watcher=$!
    set +m
    local status=0
    wait "$pid" || status=$?
    # The watcher owns a child `sleep`; signal its process group so a normal
    # (non-timeout) example does not leave that sleep behind or wait for the
    # full deadline before returning.
    kill -KILL -"$watcher" 2>/dev/null || true
    wait "$watcher" 2>/dev/null || true
    # Sweep anything that outlived the direct child. The process group contains
    # only this example invocation.
    kill -KILL -"$pid" 2>/dev/null || true
    return "$status"
}

run_example() {
    if command -v timeout >/dev/null 2>&1; then
        timeout "$TIMEOUT_SECS" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$TIMEOUT_SECS" "$@"
    else
        run_bounded "$TIMEOUT_SECS" "$@"
    fi
}

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
    case "$name" in
        ""|.|..|*/*)
            echo "FAIL $name (example name must be a direct directory under examples/)"
            failed=$((failed + 1))
            failures+=("$name")
            continue
            ;;
    esac
    dir="$examples_dir/$name"
    source_file="$dir/main.mux"
    expected_file="$dir/expected_output.txt"

    if [ ! -f "$source_file" ]; then
        echo "FAIL $name (no main.mux)"
        failed=$((failed + 1))
        failures+=("$name")
        continue
    fi

    actual="$(cd "$dir" && run_example "$MUX_BIN" run main.mux 2>&1)"
    status=$?

    # Compiling leaves an executable beside the source; it is not output. The
    # compiler uses the native `.exe` spelling for its default output on
    # Windows, so remove both spellings. The compiler and some examples create
    # local outputs beside the source. Remove them even when execution times
    # out or fails, so a killed run cannot leave generated input/output in the
    # teaching tree.
    rm -f -- "$dir/main" "$dir/main.exe" "$dir/employees.csv"

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

    diff_file=$(mktemp "${TMPDIR:-/tmp}/mux-example-diff.XXXXXX") || {
        echo "FAIL $name (could not allocate a temporary diff file)"
        failed=$((failed + 1))
        failures+=("$name")
        continue
    }
    if diff -u "$expected_file" <(printf '%s\n' "$actual") > "$diff_file" 2>&1; then
        echo "ok   $name"
        passed=$((passed + 1))
    else
        echo "FAIL $name (output differs)"
        echo "--- diff (expected vs actual) ---"
        cat "$diff_file"
        echo "---------------------------------"
        failed=$((failed + 1))
        failures+=("$name")
    fi
    rm -f -- "$diff_file"
    diff_file=''
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
