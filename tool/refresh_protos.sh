#!/usr/bin/env bash
# Refresh the vendored Sui protos from sui-apis, then regenerate the Dart bindings.
set -euo pipefail

PLUGIN_VERSION=25.0.0
UPSTREAM=https://github.com/MystenLabs/sui-apis.git

# A forward sync adds; it does not gut the bindings. Anything past this means the
# generated code was ahead of the protos it came from.
MAX_DELETIONS=200

cd "$(dirname "$0")/.."

# `dart pub global activate` installs here, and it is not on PATH by default.
export PATH="$HOME/.pub-cache/bin:$PATH"

command -v protoc >/dev/null || {
  echo "protoc is missing. Install it with: brew install protobuf" >&2
  exit 1
}

# A different plugin version reflows all 41 files instead of the few that changed.
# Also rebuilds it after a Dart upgrade (stale builds break protoc).
dart pub global activate protoc_plugin "$PLUGIN_VERSION" >/dev/null

# porcelain, not `git diff`: staged changes are invisible to a working-tree diff,
# and they would also skew the deletion count below.
if [ -n "$(git status --porcelain -- lib/grpc/proto lib/grpc/generated)" ]; then
  echo "lib/grpc/proto or lib/grpc/generated has uncommitted changes." >&2
  echo "Commit or stash them first, so the regen diff is readable." >&2
  exit 1
fi

checkout=$(mktemp -d)
trap 'rm -rf "$checkout"' EXIT

git clone --quiet --depth 1 "$UPSTREAM" "$checkout/sui-apis"
rev=$(git -C "$checkout/sui-apis" rev-parse --short HEAD)

# Protos first. Generating from stale protos silently reverts the bindings.
rsync -a --delete "$checkout/sui-apis/proto/" lib/grpc/proto/

protoc --dart_out=grpc:lib/grpc/generated -Ilib/grpc/proto \
  lib/grpc/proto/sui/rpc/v2/*.proto \
  lib/grpc/proto/google/protobuf/*.proto \
  lib/grpc/proto/google/rpc/*.proto

read -r insertions deletions <<<"$(
  git diff --numstat -- lib/grpc/generated |
    awk '{ add += $1; del += $2 } END { print add + 0, del + 0 }'
)"

echo
echo "sui-apis $rev  ->  generated +$insertions -$deletions"

if [ "$deletions" -gt "$MAX_DELETIONS" ]; then
  cat >&2 <<EOF

Stopped: $deletions deletions exceeds the $MAX_DELETIONS line guard.

Check what upstream dropped before keeping this. To undo:
  git checkout -- lib/grpc/proto lib/grpc/generated
EOF
  exit 1
fi

dart analyze
dart test
