#!/usr/bin/env bash
# Helper script for the hello-world skill.
#
# Prints the current OS username (whoami output, trimmed) to stdout.
# The agent invokes this when the hello-world skill is activated, NOT
# at install time.

set -euo pipefail

name="$(whoami | tr -d '[:space:]')"

if [[ -z "${name}" ]]; then
  echo "friend"
  exit 0
fi

echo "${name}"
