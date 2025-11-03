#!/bin/sh

set -xe

conjuge=$(find . -type f -name "conjuge" -exec realpath {} \;)
[ -x "$conjuge" ] || { printf '[ERROR] CMD not executable: %s\n' "$conjuge" >&2 ; exit 1 ; }
verbes=$(find . -type f -name "verbes" -exec realpath {} \;)
[ -f "$verbes" ] || { printf '[ERROR] CMD no such file: %s\n' "$verbes" >&2 ; exit 1 ; }
BESCHERELLE_DIR=${BESCHERELLE_DIR:-"$HOME/Documents/Bescherelle"}
( [ ! -d "$BESCHERELLE_DIR" ] && mkdir -p "$BESCHERELLE_DIR") || { printf '[ERROR] CMD could not create directory: %s\n' "$BESCHERELLE_DIR" >&2 ; exit 1 ; }

if [ -x "$(command -v parallel)" ]; then
    # async
    parallel=$(which parallel) || { printf '[ERROR] CMD: could not find parallel executable on PATH\n' >&2 ; }
    hul=$(ulimit -Hn) ul=$((hul/2))
    ulimit -n ${ul}
    $parallel --progress --verbose -j0 --joblog "$BESCHERELLE_DIR/bescherelle-bootstrap.log" $conjuge -vI {} :::: "$verbes"
else
    # sync
    while IFS= read -r verbe; do
        $conjuge -vI "$verbe" || continue
    done < "$verbes"
fi

exit 0
