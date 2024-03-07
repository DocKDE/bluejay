#!/usr/bin/env bash

set -oue pipefail

rm -f /etc/yum.repos.d/tailscale.repo
rm -f /etc/yum.repos.d/ublue-os-staging-fedora-39.repo

