#!/bin/bash -x

set -euo pipefail

PREFIX="${1}"
RRNA_FILE="${2}"
OUTPUT_DIR="${3}"

MINLEN=1000

grep  "16S_rRNA::" -A 1 "${RRNA_FILE}" |\
        awk '$0 ~ ">" {print c; c=0;printf substr($0,2,100) "\t"; } $0 !~ ">" {c+=length($0);} END { print c; }' |\
        awk -v minLen=${MINLEN} '$2 >= minLen {print $1}' \
        > "${PREFIX}.16S_atleast_${MINLEN}_nucl.list"

grep -A 1 -f "${PREFIX}.16S_atleast_${MINLEN}_nucl.list" "${RRNA_FILE}" |\
        grep -ve '--' > "${OUTPUT_DIR}/${PREFIX}.16S_rrna.fna"

rm -rf "${PREFIX}.16S_atleast_${MINLEN}_nucl.list"