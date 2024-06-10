#!/usr/bin/env bash
set -oue pipefail

RELEASE=$(curl -s https://api.github.com/repos/ProtonMail/inbox-desktop/releases/latest | jq -r .tag_name)
cd /tmp
curl -LO https://github.com/ProtonMail/inbox-desktop/releases/download/"${RELEASE}"/proton-mail-"${RELEASE:1}"-1.x86_64.rpm
rpm-ostree install ./proton-mail-"${RELEASE:1}"-1.x86_64.rpm
