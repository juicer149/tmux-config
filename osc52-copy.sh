#!/usr/bin/env bash
# Read stdin, base64-encode, send OSC 52

payload=$(base64 | tr -d '\n')
printf '\033]52;c;%s\a' "$payload"
