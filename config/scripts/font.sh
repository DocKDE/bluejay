#!/usr/bin/env bash
set -oue pipefail

RELEASE=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r .tag_name)
cd /tmp
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/"$RELEASE"/FiraCode.zip
mkdir -p /usr/share/fonts/fira-code-nerd && unzip FiraCode.zip -d /usr/share/fonts/fira-code-nerd
fc-cache -f /usr/share/fonts/fira-code-nerd
