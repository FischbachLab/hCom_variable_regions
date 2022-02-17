#!/usr/bin/bash -x

# run_barrnap.sh INPUT_FASTA PREFIX_OUTPUT BARRNAP_OUTPUT_DIR

set -euo pipefail

INPUT_FASTA="${1}"
PREFIX="${2}"
BARRNAP_OUTPUT_DIR="${3}"
BIN_FASTA_EXT="fna"

BARRNAP_DOCKER_IMAGE="quay.io/biocontainers/barrnap"
BARRNAP_DOCKER_VERSION="0.9--hdfd78af_4"

mkdir -p ${BARRNAP_OUTPUT_DIR}

docker container run --rm \
        --workdir "$(pwd)" \
        --volume "$(pwd)":"$(pwd)" \
        ${BARRNAP_DOCKER_IMAGE}:${BARRNAP_DOCKER_VERSION} \
        barrnap --threads 1 \
            --quiet \
            --outseq ${BARRNAP_OUTPUT_DIR}/${PREFIX}.rrna.${BIN_FASTA_EXT} ${INPUT_FASTA} > ${BARRNAP_OUTPUT_DIR}/${PREFIX}.rrna.gff
