#!/usr/bin/env bash
#
# update images from the source repo
#

set -o errexit
set -o pipefail
set -o nounset


echo "INFO: Starting refresh process at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DESIGN=${1:-BAD}
if [ "$DESIGN" == "BAD" ]; then
	echo "ERROR: No design specified"
	echo "INFO: Usage: $0 <design>"
	echo "design = [ apple | google | microsoft | twemoji ]"
	exit 1
fi

BRANCH=master
SRC_REPO="https://github.com/iamcal/emoji-data"
SRC_DIR="img-${DESIGN}-64"
DST_DIR="${REPO_DIR}/docs/${DESIGN}"

if [ "$DESIGN" == "apple" ]; then
	# all defaults
	pass
elif [ "$DESIGN" == "google" ]; then
	# all defaults
	pass
elif [ "$DESIGN" == "microsoft" ]; then
	SRC_REPO="Nerixyz/emoji-data"
	BRANCH="feat/fluent-emoji"
	echo "ERROR: microsoftdesigns not merged into main repo (and not being updated)"
	exit 1
elif [ "$DESIGN" == "twemoji" ]; then
	SRC_DIR="img-twitter-64"
else
	echo "ERROR: Unknown design specified"
	exit 1
fi

TMP_DIR="${REPO_DIR}/tmp"
if [ ! -d "${TMP_DIR}" ]; then
	echo "INFO: Creating temporary directory at ${TMP_DIR}"
	mkdir -p "${TMP_DIR}"
else
	echo "INFO: Using existing temporary directory at ${TMP_DIR}"
fi

echo "INFO: Using source repository ${SRC_REPO} and source directory ${SRC_DIR} on branch ${BRANCH}"

cd "${TMP_DIR}"
if [ ! -d "${SRC_REPO##*/}" ]; then
	echo "INFO: Cloning source repository ${SRC_REPO} into ${TMP_DIR}"
	git clone --branch "${BRANCH}" "${SRC_REPO}"
else
	echo "INFO: Using existing source repository at ${TMP_DIR}/${SRC_REPO##*/}"
	cd "${SRC_REPO##*/}"
	git fetch origin "${BRANCH}"
	git checkout "${BRANCH}"
	cd "${TMP_DIR}"
fi

cd "${SRC_REPO##*/}"

if [ ! -d "${SRC_DIR}" ]; then
	echo "ERROR: Source directory ${SRC_DIR} does not exist in repository ${SRC_REPO##*/}"
	exit 1
fi

echo "INFO: Copying files from ${SRC_DIR} to ${DST_DIR}"
mkdir -p "${DST_DIR}"
cp -r "${SRC_DIR}/." "${DST_DIR}/"


echo "INFO: Completed refresh process at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
