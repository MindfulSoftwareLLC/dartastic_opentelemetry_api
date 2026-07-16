#!/usr/bin/env bash
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0
#
# Generates the semantic-convention Dart enums (lib/src/api/semantics/semconv/)
# and their audit-test fixtures (test/unit/api/semantics/semconv/) from the
# OpenTelemetry semantic-conventions registry using OTel Weaver.
#
# Usage:
#   tool/semconv/generate.sh            # regenerate in place
#   tool/semconv/generate.sh --check    # verify checked-in output is fresh
#
# The registry location defaults to the opentelemetry.io website checkout's
# semantic-conventions submodule; override with SEMCONV_REPO=/path/to/repo.
set -euo pipefail

# Pinned to the same image digest the semantic-conventions repo pins
# (see its dependencies.Dockerfile).
WEAVER_IMAGE="docker.io/otel/weaver:v0.24.2@sha256:d1fb16d279f39810c340fbbf1cf9e5e995a3a9cefa531938e9012437e3bc00c1"

SEMCONV_REPO="${SEMCONV_REPO:-/Users/mbushe/dev/mf/otel/opentelemetry.io/content-modules/semantic-conventions}"
PKG_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEMPLATES_DIR="$PKG_ROOT/tool/semconv/templates"
LIB_OUT="$PKG_ROOT/lib/src/api/semantics/semconv"
TEST_OUT="$PKG_ROOT/test/unit/api/semantics/semconv"
MODE="${1:-generate}" # generate | --check

if [ ! -f "$SEMCONV_REPO/model/manifest.yaml" ]; then
  echo "SEMCONV_REPO does not look like a semantic-conventions checkout: $SEMCONV_REPO" >&2
  exit 2
fi

# e.g. "1.44.0-unreleased" from the schema_url in model/manifest.yaml
SEMCONV_VERSION="$(sed -n 's|^schema_url:.*/||p' "$SEMCONV_REPO/model/manifest.yaml" | tr -d '[:space:]')"
REGISTRY_COMMIT="$(git -C "$SEMCONV_REPO" rev-parse --short HEAD 2>/dev/null || echo unknown)"
REGISTRY_DESCRIBE="$(git -C "$SEMCONV_REPO" describe --tags 2>/dev/null || echo unknown)"

# Match host uid/gid inside the container on Linux so generated files aren't
# root-owned. (Unnecessary on macOS Docker Desktop, which maps ownership.)
DOCKER_USER_ARG=()
[ "$(uname)" = "Linux" ] && DOCKER_USER_ARG=(-u "$(id -u):$(id -g)")

run_weaver() { # $1 = target name (templates/registry/<target>), $2 = output dir
  local target="$1" out="$2"
  mkdir -p "$out"
  docker run --rm "${DOCKER_USER_ARG[@]}" --network=none \
    --mount "type=bind,source=$TEMPLATES_DIR,target=/home/weaver/templates,readonly" \
    --mount "type=bind,source=$SEMCONV_REPO/model,target=/home/weaver/source,readonly" \
    --mount "type=bind,source=$out,target=/home/weaver/target" \
    "$WEAVER_IMAGE" registry generate \
    --registry=/home/weaver/source \
    --templates=/home/weaver/templates \
    --param "semconv_version=$SEMCONV_VERSION" \
    --param "registry_commit=$REGISTRY_COMMIT" \
    --param "registry_describe=$REGISTRY_DESCRIBE" \
    "$target" \
    /home/weaver/target
}

generate_into() { # $1 = lib out, $2 = test out
  local lib_out="$1" test_out="$2"
  rm -rf "$lib_out" "$test_out"
  run_weaver dart "$lib_out"
  run_weaver dart_test "$test_out"
  (cd "$PKG_ROOT" && dart format "$lib_out" "$test_out" >/dev/null)
}

if [ "$MODE" = "--check" ]; then
  # Check dirs must live inside the repo: paths outside Docker Desktop's
  # shared file systems cannot be bind-mounted.
  CHECK_ROOT="$PKG_ROOT/tool/semconv/.check-out"
  rm -rf "$CHECK_ROOT"
  mkdir -p "$CHECK_ROOT/lib" "$CHECK_ROOT/test"
  generate_into "$CHECK_ROOT/lib" "$CHECK_ROOT/test"
  status=0
  diff -ru "$LIB_OUT" "$CHECK_ROOT/lib" || status=1
  diff -ru "$TEST_OUT" "$CHECK_ROOT/test" || status=1
  rm -rf "$CHECK_ROOT"
  if [ "$status" -ne 0 ]; then
    echo "ERROR: generated semconv code is stale; run tool/semconv/generate.sh" >&2
    exit 1
  fi
  echo "semconv generated code is up to date (registry $REGISTRY_DESCRIBE @ $REGISTRY_COMMIT)"
else
  generate_into "$LIB_OUT" "$TEST_OUT"
  echo "generated semconv code from registry $REGISTRY_DESCRIBE @ $REGISTRY_COMMIT (schema $SEMCONV_VERSION)"
fi
