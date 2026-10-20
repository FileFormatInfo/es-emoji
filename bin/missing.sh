#!/usr/bin/env bash
#
# report of which emoji images are missing for the specified design
#

set -o errexit
set -o pipefail
set -o nounset


echo "INFO: Starting missing report at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DESIGN=${1:-BAD}
if [ "$DESIGN" == "BAD" ]; then
	echo "ERROR: No design specified"
	echo "INFO: Usage: $0 <design>"
	echo "design = [ apple | google | microsoft | twemoji ]"
	exit 1
fi

IMG_DIR="${REPO_DIR}/docs/${DESIGN}"

if [ ! -d "${IMG_DIR}" ]; then
	echo "ERROR: Image directory ${IMG_DIR} does not exist for design ${DESIGN}"
	exit 1
fi

TMP_DIR="${REPO_DIR}/tmp"
if [ ! -d "${TMP_DIR}" ]; then
	echo "INFO: Creating temporary directory at ${TMP_DIR}"
	mkdir -p "${TMP_DIR}"
else
	echo "INFO: Using existing temporary directory at ${TMP_DIR}"
fi

DATA_FILE="${TMP_DIR}/emoji.json"

if [ -f "${DATA_FILE}" ]; then
	echo "INFO: Using existing emoji data file at ${DATA_FILE}"
else
	echo "INFO: Downloading emoji data file to ${DATA_FILE}"

	curl \
		--compressed \
		--header 'User-Agent: es-emoji missing report' \
		--output "${DATA_FILE}" \
		'https://www.emojisearch.org/emoji.json'
fi

FOUND=0
MISSING=0

CODEPOINTS=$(jq --raw-output '.data[].codepoints' "${DATA_FILE}")
while IFS= read -r CODEPOINT; do
	# convert to lowercase and replace space with dash
	IMG_CODEPOINT=$(echo "$CODEPOINT" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
	if [ ! -f "${IMG_DIR}/${IMG_CODEPOINT}.png" ]; then
		echo "MISSING: ${IMG_CODEPOINT}.png"
		MISSING=$((MISSING+1))
	else
		FOUND=$((FOUND+1))
	fi
done <<< "$CODEPOINTS"

echo "INFO: Found ${FOUND} emoji images"
echo "INFO: Missing ${MISSING} emoji images"

echo "INFO: Completed missing report at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
