#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# Get repo to override from.
get_yaml_array REPO '.repo[]' "$1"
# Replace '%OS_VERSION%' with the current Fedora version if it's there,
# replace fedora-'xx' version with the current one,
# remove 'fedora-xx' from the .repo filename if it's there.
REPO=$(sed "s/%OS_VERSION%/${OS_VERSION}/; \
            s/fedora-[^/]\+/fedora-${OS_VERSION}/; \
            s/-fedora-[^/]\+.repo/.repo/" \
            <<< "${REPO}")

# Get packages to override replace.
get_yaml_array PACKAGES '.replace[]' "$1"
PACKAGES=$(echo "${PACKAGES[*]}" | tr -d '\n')

# Ensure there's only one repo and more than
# one package provided.
if [[ ${#REPO[@]} -gt 1 ]]; then
    echo "Error: More than one repo provided."
    exit 1
elif [ -z "${PACKAGES}" ]; then
    echo "Error: No packages were provided."
    exit 1
fi

MAINTAINER=$(awk -F'/' '{print $5}' <<< "${REPO}")
REPO_NAME=$(awk -F'/' '{print $6}' <<< "${REPO}")
FILE_NAME=$(awk -F'/' '{print $9}' <<< "${REPO}")

wget -P /etc/yum.repos.d/ ${REPO}
rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:${MAINTAINER}:${REPO_NAME} ${PACKAGES}
rm /etc/yum.repos.d/${FILE_NAME}