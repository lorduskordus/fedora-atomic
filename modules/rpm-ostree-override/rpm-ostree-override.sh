#!/usr/bin/env bash

set -euo pipefail

# Get repository to override from
REPO=$(echo "$1" | yq -I=0 ".repo")
# 1. Replace '%OS_VERSION%' with the current Fedora version if it's there
# 2. Replace fedora-'xx' version with the current one
# 3. Remove 'fedora-xx' from the .repo filename if it's there
REPO=$(sed "s/%OS_VERSION%/${OS_VERSION}/; \
            s/fedora-[^/]\+/fedora-${OS_VERSION}/; \
            s/-fedora-[^/]\+.repo/.repo/" \
            <<< "${REPO}")

# Get packages to replace
get_yaml_array PACKAGES '.replace[]' "$1"
PACKAGES=$(echo "${PACKAGES[*]}" | tr -d '\n')

# Ensure repository and packages are provided
if [ -z "${REPO}" ]; then
    echo "Error: No repository was provided."
    exit 1
elif [ -z "${PACKAGES}" ]; then
    echo "Error: No packages were provided."
    exit 1
fi

MAINTAINER=$(awk -F'/' '{print $5}' <<< "${REPO}")
REPO_NAME=$(awk -F'/' '{print $6}' <<< "${REPO}")
FILE_NAME=$(awk -F'/' '{print $9}' <<< "${REPO}")

wget -P "/etc/yum.repos.d/" ${REPO}
rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:${MAINTAINER}:${REPO_NAME} ${PACKAGES}
rm "/etc/yum.repos.d/${FILE_NAME}"