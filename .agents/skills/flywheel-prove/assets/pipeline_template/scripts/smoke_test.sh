#!/usr/bin/env sh
set -eu
uv run -m tproof.cli smoke-test "$@"
