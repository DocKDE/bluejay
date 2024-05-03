#!/usr/bin/env bash

set -oue pipefail

rm -f /etc/yum.repos.d/tailscale.repo
rm -f /etc/yum.repos.d/kylegospo-webapp-manager-fedora-39.repo
rm -f /etc/yum.repos.d/ublue-os-staging-fedora-39.repo
rm -f /etc/yum.repos.d/1password.repo
rm -f /etc/yum.repos.d/docker-ce.repo
rm -f /etc/yum.repos.d/protonvpn-stable.repo
