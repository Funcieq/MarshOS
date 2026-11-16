#!/bin/sh
set -eu
version=$1
archive_sha=$2
protocol_commit=$3
header_sha=$4
destination=$5
for tool in curl tar sha256sum mktemp; do
    command -v "$tool" >/dev/null 2>&1 || {
        echo "Missing dependency: $tool (see README.md)" >&2
        exit 1
    }
done
mkdir -p "$(dirname "$destination")"
temporary=$(mktemp -d "${destination}.tmp.XXXXXX")
trap 'rm -rf "$temporary"' EXIT HUP INT TERM
curl -fL --retry 3 "https://github.com/Limine-Bootloader/Limine/releases/download/v${version}/limine-binary.tar.gz" -o "$temporary/limine.tar.gz"
printf '%s  %s\n' "$archive_sha" "$temporary/limine.tar.gz" | sha256sum -c -
tar -xzf "$temporary/limine.tar.gz" -C "$temporary"
curl -fL --retry 3 "https://raw.githubusercontent.com/limine-bootloader/limine-protocol/${protocol_commit}/include/limine.h" -o "$temporary/limine-binary/limine.h"
printf '%s  %s\n' "$header_sha" "$temporary/limine-binary/limine.h" | sha256sum -c -
mkdir -p "$destination"
cp -R "$temporary/limine-binary/." "$destination/"
touch "$destination/.ready"
