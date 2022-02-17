#!/bin/bash -x

set -euo pipefail

PROJECT_NAME="${1}"
S3_GENOMES_PATH="${2}"
S3_V_XTRACTOR_PATH="s3://maf-users/Sunit_Jain/scratch/v_xtractor/V-Xtractor-master"
S3_HMMR3_PATH="s3://maf-users/Sunit_Jain/scratch/v_xtractor/hmmer-3.0"

mkdir -p "${PROJECT_NAME}"/{barrnap,rrna,input,output}

aws s3 sync "${S3_GENOMES_PATH}" "${PROJECT_NAME}"/fasta --quiet
aws s3 sync ${S3_V_XTRACTOR_PATH} "${PROJECT_NAME}"/V-Xtractor-master --quiet
aws s3 sync ${S3_HMMR3_PATH} "${PROJECT_NAME}"/hmmer-3.0 --quiet