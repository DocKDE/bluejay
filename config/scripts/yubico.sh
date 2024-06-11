#!/usr/bin/env bash
set -oue pipefail

DESKTOP_FILENAME="com.yubico.authenticator.desktop"
DESKTOP_FILE="/usr/share/applications/${DESKTOP_FILENAME}"
EXEC_PATH="/opt/yubico-authenticator"

cd /tmp
curl -L https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz --output yubico.tar.gz
mkdir yubico-authenticator
tar xf yubico.tar.gz -C yubico-authenticator --strip-components=1
mv yubico-authenticator /opt/
sed -e "s|@EXEC_PATH|${EXEC_PATH}|g" <"${EXEC_PATH}/linux_support/${DESKTOP_FILENAME}" >"${DESKTOP_FILE}"
