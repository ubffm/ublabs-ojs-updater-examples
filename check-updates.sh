#!/usr/bin/env bash
# Copyright 2019-2022, UB JCS, Goethe University Frankfurt am Main
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -e
command -v "mailx" >/dev/null 2>&1 || { echo "mailx needed."; exit 1; }
command -v "xmlstarlet" >/dev/null 2>&1 || { echo "xmlstarlet needed."; exit 1; }
command -v "curl" >/dev/null 2>&1 || { echo "curl needed."; exit 1; }

OJS_VERSIONS='/usr/local/ojs/versions'
URL='http://pkp.sfu.ca/ojs/xml/ojs-version.xml'
QUERY='/version/package'
SENDER='sender@example.com'
RECIPIENT='recipient@example.com'
OWNER='www-data'
GROUP='www-data'

package="$(curl -Lsf "$URL" | xmlstarlet sel -t -v "$QUERY" 2>/dev/null)"

[[ -z "$package" ]] && { echo 'No package url.'; exit 1; }
file="$(basename "$package")"
target="${OJS_VERSIONS}/${file}"
[[ -e "$target" ]] && { echo "No need to update"; exit 1; } 
temp_file="$(mktemp tmp.XXXXXX.ojs-download)"
curl -Ls "$package" -o "$temp_file" \
     && install -m 0644 \
                -o "$OWNER" \
                -g "$GROUP" \
                "$temp_file" "$target"
rm -f "$temp_file"
folder_name="$(basename "$target" ".tar.gz")"
[[ -d "$folder_name" ]] && { echo "Directory already exists."; exit 1; }
pushd "$OJS_VERSIONS" > /dev/null || exit
tar -C "$OJS_VERSIONS" -xf "$target" \
    && chown -R "$OWNER":"$GROUP" "$folder_name" \
    && echo "Downloaded: $package" \
    | mailx -s "New OJS Version: $target" -r "$SENDER" "$RECIPIENT" 
popd > /dev/null || exit

