#!/usr/bin/env bash

set -oue pipefail

cd /tmp
git clone https://github.com/kazysmaster/gnome-shell-extension-disable-unredirect.git
cp -r gnome-shell-extension-disable-unredirect/unredirect@vaina.lt /usr/share/gnome-shell/extensions

