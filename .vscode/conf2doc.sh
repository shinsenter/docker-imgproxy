#!/bin/bash

BASE=$(dirname $0)
README=$BASE/../README.md
PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

USAGE="$(
    grep -aPzo --color=never \
        '\n\n## (.|\n)*?\nmap (.|\n)*?\n}' \
        $BASE/../imgproxy.conf |
        tr -d '\0' |
        perl -pe 's/^\s*$//g' |
        perl -pe 's/^map/```nginx\nmap/g' |
        perl -pe 's/^}\s*/}\n```\n/g' |
        perl -pe 's/^#+ *(\*.*)$/\1<br\/>/g' |
        perl -pe 's/^#+ *(.*)$/\1/g' |
        perl -pe 's/^(\s+# +.*[^;\s])$/\n\1/g' |
        perl -pe 's/^/> /g' |
        perl -pe 's/^> +$/>/g' |
        perl -pe 's/```\s+/```\n\n\n/g'
)"

perl -i -p0e 's#> \*\*(.|\n)*```#@@@@@@#' $README

CONTENT="$(cat $README)"
echo "${CONTENT/@@@@@@/$USAGE}" >$README
